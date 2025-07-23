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
import utils from 'umap.utils';
import wireless from 'umap.wireless';
import events from 'umap.events';


function emit_association_status_notification(event) {
	if (event.associated)
		return;

	const i1905dev = model.lookupDevice(event.ap_address);
	if (!i1905dev)
		return;

	const msg = cmdu.create(defs.MSG_CLIENT_DISASSOCIATION_STATS);

	msg.add_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE, event.sta_address);
	/* TODO: 8.4.1.7 - Reason code */
	msg.add_tlv(defs.TLV_REASON_CODE, 8);
	msg.add_tlv(defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS, { mac_address: event.sta_address, ...event.stats});

	for (let i1905lif in model.getLocalInterfaces())
		msg.send(i1905lif.i1905sock, model.address, i1905dev.al_address);
}

const IProtoSteering = {
	init: function () {
		events.register('wireless.association', emit_association_status_notification);
	},

	handle_cmdu: function (i1905lif, dstmac, srcmac, msg) {
		// disregard CMDUs not directed to our AL
		if (dstmac != model.address)
			return true;

		return false;
	}
};

export default proto({}, IProtoSteering);
