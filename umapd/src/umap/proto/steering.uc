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

import { timer, interval } from 'uloop';
import wireless from 'umap.wireless';
import events from 'umap.events';
import model from 'umap.model';
import utils from 'umap.utils';
import cmdu from 'umap.cmdu';
import defs from 'umap.defs';
import ubus from 'umap.ubus';
import log from 'umap.log';

const FAILED_CONNECTION_INTERVAL = 60 * 1000;
const REPLY_HANDLER_TIMEOUT = 1000;

let IFailedConnections = {
	policy: {},
	failed_interval: null,
	failed_connections: 0,

	init: function () {
		if (!model.isController) {
			const self = this;
			events.register('wireless.association-error', (data) => { self.emit_failed_connection_message(data, self); });
			events.register('policy.unsuccessful-association', (data) => { self.update_policy(data, self); });
		}
	},

	update_policy: function(data, self) {
		log.debug('received a failed connection policy update');
		self.policy = data;

		if (self.policy.report_unsuccessful_assocs && self.policy.max_reporting_rate) {
			self.ailed_interval ??= interval(FAILED_CONNECTION_INTERVAL, () => { self.failed_connections = 0; }); 
		} else if (self.failed_interval) {
			self.failed_interval.cancel();
			self.failed_interval = null;
		}
	},

	emit_failed_connection_message: function(event, self) {
		if (!self.policy.report_unsuccessful_assocs)
			return;

		self.failed_connections++;
		if (self.policy.max_reporting_rate && self.failed_connections > self.policy.max_reporting_rate)
			return;

		// TODO controller AL
		const i1905dev = model.lookupDevice(event.ap_address);
		if (!i1905dev)
			return;

		const msg = cmdu.create(defs.MSG_FAILED_CONNECTION);

		msg.add_tlv(defs.TLV_BSSID, event.ap_address);
		msg.add_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE, event.sta_address);

		let reason_code = 1;
		switch(event.reason) {
		case 'key-mismatch':
			/* TODO:  9-49 802_1_X_AUTH_FAILED */
			reason_code = 23;
			break;
		}
		msg.add_tlv(defs.TLV_REASON_CODE, reason_code);
		msg.add_tlv(defs.TLV_STATUS_CODE, 1);

		for (let i1905lif in model.getLocalInterfaces())
			msg.send(i1905lif.i1905sock, model.address, i1905dev.al_address);
	},
};

const IProtoSteering = {
	init: function () {
		ubus.register('request_client_steering',
			{
				bssid: "00:00:00:00:00:00"
			},
			this.emit_client_steering_request);

		if (!model.isController) {
			events.register('wireless.association', this.emit_disassociation_status_notification);
			IFailedConnections.init();
		}
	},

	emit_client_steering_request: function (req) {
		let args = {
			bssid: '20:05:b6:ff:86:1b',
			request_mode: true, 
			btm_disassociation_imminent_bit: true,
			btm_abridged_bit: true,
			steering_opportunity_window: 10,
			btm_disassociation_timer: 10,
			sta_list: [ 'a2:82:84:3c:31:84' ],
			target_bssids: [
				{
					target_bssid: '20:05:b6:ff:86:1a',
					target_bss_opclass: 82,
					target_bss_channel: 10,
					reason_code: 5,
				},
			],
		};

		if (!req.args.bssid)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const i1905dev = model.lookupDevice(req.args.bssid);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_CLIENT_STEERING_REQUEST);
		//query.add_tlv(TLV_PROFILE_2_STEERING_REQUEST, req.args);
		query.add_tlv(defs.TLV_PROFILE_2_STEERING_REQUEST, args);

		query.on_reply(response => {
			if (!response)
				return req.reply(null, defs.UBUS_STATUS_TIMEOUT);

			return req.reply(null, defs.UBUS_STATUS_OK);
		}, REPLY_HANDLER_TIMEOUT, defs.MSG_IEEE1905_ACK);

		for (let i1905lif in model.getLocalInterfaces())
			query.send(i1905lif.i1905sock, model.address, i1905dev.al_address);

		return req.defer();
	},


	emit_disassociation_status_notification: function(event) {
		if (event.associated)
			return;

		// TODO controller AL
		const i1905dev = model.lookupDevice(event.ap_address);
		if (!i1905dev)
			return;

		const msg = cmdu.create(defs.MSG_CLIENT_DISASSOCIATION_STATS);

		msg.add_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE, event.sta_address);
		msg.add_tlv(defs.TLV_REASON_CODE, 8); // 9-49—Reason codes: LEAVING_NETWORK_DISASSOC
		msg.add_tlv(defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS, { mac_address: event.sta_address, ...event.stats});

		for (let i1905lif in model.getLocalInterfaces())
			msg.send(i1905lif.i1905sock, model.address, i1905dev.al_address);
	},

	handle_cmdu: function (i1905lif, dstmac, srcmac, msg) {
		// disregard CMDUs not directed to our AL
		if (dstmac != model.address)
			return true;

		if (msg.type === defs.MSG_CLIENT_STEERING_REQUEST) {
			const profile_2_steering_request = msg.get_tlv(defs.TLV_PROFILE_2_STEERING_REQUEST);
			if (!profile_2_steering_request)
				return false;
//			ubus.call('umap-rrmd', 'beacon_req', beacon_metrics);
//			let error = ubus.error();
			const ack = cmdu.create(defs.MSG_IEEE1905_ACK, msg.mid);
//			if (error)
//				ack.add_tlv(defs.TLV_REASON_CODE, 2);
			ack.send(i1905lif.i1905sock, model.address, srcmac);

			return true;
		}

		return false;
	}
};

export default proto({}, IProtoSteering);
