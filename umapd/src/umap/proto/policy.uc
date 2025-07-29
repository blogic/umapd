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

import events from 'umap.events';
import model from 'umap.model';
import cmdu from 'umap.cmdu';
import defs from 'umap.defs';
import ubus from 'umap.ubus';
import { cursor } from 'uci';
import log from 'umap.log';
import { glob, readfile } from 'fs';

const policies = [ 'steering', 'metric_reporting', 'channel_scan_reporting', 'unsuccessful_association' ];
let policy = {};

const IProtoPolicy = {
	policy: {},

	load: function() {
		policy = {};
		let files = glob('/etc/umap-policy.d/*.json');
		for (let file in files) {
			let data = readfile(file);
			if (!data)
				continue;
			data = json(data);
			if (!data)
				continue;
			for (let k, v in data) {
				policy[k] ??= {};
				for (let key in policies) {
					if (!v[key])
						continue;
					if (policy[k][key]) {
						log.error('duplicate policy ${k}: ${key}');
						continue;
					}
					policy[k][key] = v[key];
				}
			}
		}

		return defs.UBUS_STATUS_OK;
	},

	init: function () {
		if (model.isController) {
			this.load(this);
			ubus.register('renew_policy_config', {
				al_mac: "00:00:00:00:00:00",
			}, this.emit_policy_config_message);
			let self = this;
			ubus.register('reload_policy', { }, () => { return self.load(); });
			ubus.register('dump_policy', { }, () => { return policy; });
		}
	},

	emit_policy_config_message: function (req) {
		if (!req.args.al_mac)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const i1905dev = model.lookupDevice(req.args.al_mac);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const msg = cmdu.create(defs.MSG_MULTI_AP_POLICY_CONFIG_REQUEST);

		let al_policy = {};
		for (let key in policies) {
			let data = policy[req.args.al_mac]?.[key] || policy['*']?.[key];
			if (data)
				al_policy[key] = data;
		}

		if (al_policy.steering)
			msg.add_tlv(defs.TLV_STEERING_POLICY, al_policy.steering);

		if (al_policy.metric_reporting)
			msg.add_tlv(defs.TLV_METRIC_REPORTING_POLICY, al_policy.metric_reporting);

		if (al_policy.channel_scan_reporting)
			msg.add_tlv(defs.TLV_CHANNEL_SCAN_REPORTING_POLICY, al_policy.channel_scan_reporting.report_independent_channel_scan);

		if (al_policy.unsuccessful_association)
			msg.add_tlv(defs.TLV_UNSUCCESSFUL_ASSOCIATION_POLICY, al_policy.unsuccessful_association);
	
		// TLV_DEFAULT_802_1Q_SETTINGS
		// TLV_TRAFFIC_SEPARATION_POLICY
		// TLV_BACKHAUL_BSS_CONFIGURATION
		// TLV_QOS_MANAGEMENT_POLICY

		for (let i1905lif in model.getLocalInterfaces())
			msg.send(i1905lif.i1905sock, model.address, i1905dev.al_address);
	},

	handle_cmdu: function (i1905lif, dstmac, srcmac, msg) {
		if (model.isController)
			return true;

		// disregard CMDUs not directed to our AL
		if (dstmac != model.address)
			return true;

		if (msg.type === defs.MSG_MULTI_AP_POLICY_CONFIG_REQUEST) {
			const steering = msg.get_tlv(defs.TLV_STEERING_POLICY);
			if (steering)
				events.dispatch('policy.steering', steering);

			const metric_reporting = msg.get_tlv(defs.TLV_METRIC_REPORTING_POLICY);
			if (metric_reporting)
				events.dispatch('policy.metric-reporting', metric_reporting);

			const channel_scan_reporting = msg.get_tlv(defs.TLV_CHANNEL_SCAN_REPORTING_POLICY);
			if (channel_scan_reporting)
				events.dispatch('policy.channel-scan-reporting', channel_scan_reporting);

			const unsuccessful_association  = msg.get_tlv(defs.TLV_UNSUCCESSFUL_ASSOCIATION_POLICY);
			if (unsuccessful_association)
				events.dispatch('policy.unsuccessful-association', unsuccessful_association);

			const ack = cmdu.create(defs.MSG_IEEE1905_ACK, msg.mid);
			ack.send(i1905lif.i1905sock, model.address, srcmac);

			return true;
		}

		return false;
	}
};

export default proto({}, IProtoPolicy);
