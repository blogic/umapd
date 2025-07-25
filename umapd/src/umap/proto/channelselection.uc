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

import log from 'umap.log';
import model from 'umap.model';
import cmdu from 'umap.cmdu';
import defs from 'umap.defs';
import ubus from 'umap.ubus';
import wireless from 'umap.wireless';

const IProtoChannelSelection = {
	init: function () {
		if (model.isController) {
			ubus.register('query_channel_preference', {
				al_mac: "00:00:00:00:00:00",
			}, this.emit_channel_preference_query);

			ubus.register('request_channel_selection', {
				al_mac: "00:00:00:00:00:00",
				ruid: "00:00:00:00:00:00",
			}, this.emit_channel_selection_request);
		} else {

		}
	},

	emit_channel_preference_query: function(req) {
		if (!req.args.al_mac || req.args.al_mac == model.address)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);
	
		const i1905dev = model.lookupDevice(req.args.al_mac);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_CHANNEL_PREFERENCE_QUERY);
		for (let i1905lif in model.getLocalInterfaces())
			query.send(i1905lif.i1905sock, model.address, i1905dev.al_address);
	},

	emit_channel_selection_request: function(req) {
		if (!req.args.al_mac || req.args.al_mac == model.address || !req.args.ruid)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const i1905dev = model.lookupDevice(req.args.al_mac);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_CHANNEL_SELECTION_REQUEST);
		query.add_tlv(defs.TLV_CHANNEL_PREFERENCE, report);
		for (let i1905lif in model.getLocalInterfaces())
			query.send(i1905lif.i1905sock, model.address, i1905dev.al_address);
	},

	handle_cmdu: function (i1905lif, dstmac, srcmac, msg) {
		if (model.isController)
			return true;

		// disregard CMDUs not directed to our AL
		if (dstmac != model.address)
			return true;

		if (msg.type === defs.MSG_CHANNEL_PREFERENCE_QUERY) {
			let report = {
				available_channels: [],
				radar_detected_channels: [],
				active_cac_channels: [],
			};
			for (let radio in wireless.radios) {
				let channels = radio.getChannels();
				for (let opclass in radio.getSupportedOperatingClasses()) {
					for (let channel in opclass.available_channels) {
						if (channels[channel].disabled)
							continue;

						if (channels[channel].dfs_state == 1) {
							push(report.radar_detected_channels, {
								opclass: opclass.opclass,
								duration: 60 * 60 - (channels[channel].dfs_time / 60000),
								channel,
							});
						} else {
							push(report.available_channels, {
								opclass: opclass.opclass,
								duration: channels[channel].dfs_state ? (channels[channel].dfs_time / 60000) : 0,
								channel,
							});
						}
					}
				}
			}

			const reply = cmdu.create(defs.MSG_CHANNEL_PREFERENCE_REPORT, msg.mid);
			reply.add_tlv(defs.TLV_CAC_STATUS_REPORT, report);
			//TODO add other TLVs
			reply.send(i1905lif.i1905sock, model.address, srcmac);

			return true;
		}

		return false;
	}
};

export default proto({}, IProtoChannelSelection);
