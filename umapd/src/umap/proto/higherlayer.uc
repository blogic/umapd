/*
 * Copyright (c) 2025 John Crispin <john@phrozen.org>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

import model from 'umap.model';
import cmdu from 'umap.cmdu';
import defs from 'umap.defs';
import ubus from 'umap.ubus';

const REPLY_HANDLER_TIMEOUT = 1000;

const IProtoHigherLayer = {
	init: function () {
		ubus.register('send_higher_layer_data',
			{
				al_mac: "00:00:00:00:00:00",
				protocol: 0,
				data: "base64",
			},
			this.emit_higher_layer_data);
	},

	emit_higher_layer_data: function(req) {
		if (!req.args.data || !req.args.protocol)
			return req.reply(null, defs.UBUS_STATUS_INVALID_ARGUMENT);

		const i1905dev = model.lookupDevice(req.args.al_mac);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_HIGHER_LAYER_DATA);
		// TODO: data is base64
		query.add_tlv(defs.TLV_HIGHER_LAYER_DATA, {
			protocol: req.args.protocol,
			data: req.args.data,
		});

		query.on_reply(response => {
			if (!response)
				return req.reply(null, defs.UBUS_STATUS_TIMEOUT);
			return req.reply(null, defs.UBUS_STATUS_OK);
		}, REPLY_HANDLER_TIMEOUT, defs.MSG_IEEE1905_ACK);

		for (let i1905lif in model.getLocalInterfaces())
			query.send(i1905lif.i1905sock, model.address, i1905dev.al_address);

		return req.defer();

	},

	handle_cmdu: function (i1905lif, dstmac, srcmac, msg) {
		// disregard CMDUs not directed to our AL
		if (dstmac != model.address)
			return true;

		if (msg.type === defs.MSG_HIGHER_LAYER_DATA) {
			const data = msg.get_tlv(defs.TLV_HIGHER_LAYER_DATA);
			if (!data)
				return false;

			const ack = cmdu.create(defs.MSG_IEEE1905_ACK, msg.mid);
			ack.send(i1905lif.i1905sock, model.address, srcmac);

			ubus.notify('higher-level', data);

			return true;

		} 
		return false;
	}
};

export default proto({}, IProtoHigherLayer);
