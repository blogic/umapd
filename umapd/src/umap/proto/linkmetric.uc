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
import ubusclient from 'umap.ubusclient';


const REPLY_HANDLER_TIMEOUT = 1000;

const IProtoLinkMetric = {
	init: function () {
		ubus.register('query_ap_metrics',
			{ bssids: [ "00:00:00:00:00:00" ] },
			this.query_ap_metrics);

		ubus.register('query_assoc_sta_metrics',
			{ bssid: "00:00:00:00:00:00", mac_address: "00:00:00:00:00:00" },
			this.query_assoc_sta_metrics);
	},

	query_ap_metrics: function (req) {
		if (!length(req.args.bssids))
			return req.reply(null, ubus.const.STATUS_NOT_FOUND);
		
		const i1905dev = model.lookupDevice(req.args.bssids[0]);
		if (!i1905dev)
			return req.reply(null, ubus.const.STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_AP_METRICS_QUERY);
		// TODO: report error if TLV is not generated
		query.add_tlv(defs.TLV_AP_METRIC_QUERY, req.args.bssids);

		query.on_reply(response => {
			if (!response)
				return req.reply(null, ubus.const.STATUS_TIMEOUT);

			const ret = { tlvs: []};

			for (let tt in [
				defs.TLV_AP_METRICS,
				defs.TLV_AP_EXTENDED_METRICS,
				defs.TLV_RADIO_METRICS,
				defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS,
				defs.TLV_AP_METRICS,
				defs.TLV_AP_EXTENDED_METRICS,
                        ]) {
                                for (let data in response.get_tlvs(tt)) {
					push(ret.tlvs, data);
				}
			}
			return req.reply(ret);
		}, REPLY_HANDLER_TIMEOUT);

		for (let i1905lif in model.getLocalInterfaces())
			query.send(i1905lif.i1905sock, model.address, i1905dev.al_address);

		return req.defer();
	},

	query_assoc_sta_metrics: function (req) {
		if (!req.args.bssid || !req.args.mac_address)
			return req.reply(null, ubus.const.STATUS_NOT_FOUND);
		
		const i1905dev = model.lookupDevice(req.args.bssid);
		if (!i1905dev)
			return req.reply(null, ubus.const.STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_ASSOCIATED_STA_LINK_METRICS_QUERY);
		query.add_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE, req.args.mac_address);
		query.on_reply(response => {
			if (!response)
				return req.reply(null, ubus.const.STATUS_TIMEOUT);

			const ret = { tlvs: []};

			for (let tt in [
				defs.TLV_AP_METRICS,
				defs.TLV_AP_EXTENDED_METRICS,
				defs.TLV_RADIO_METRICS,
				defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS,
				defs.TLV_AP_METRICS,
				defs.TLV_AP_EXTENDED_METRICS,
                        ]) {
                                for (let data in response.get_tlvs(tt)) {
					push(ret.tlvs, data);
				}
			}
			return req.reply(ret);
		}, REPLY_HANDLER_TIMEOUT);

		for (let i1905lif in model.getLocalInterfaces())
			query.send(i1905lif.i1905sock, model.address, i1905dev.al_address);

		return req.defer();
	},
			
	handle_cmdu: function (i1905lif, dstmac, srcmac, msg) {
		// disregard CMDUs not directed to our AL
		if (dstmac != model.address)
			return true;

		if (msg.type === defs.MSG_AP_METRICS_QUERY) {
			const bssids = msg.get_tlv(defs.TLV_AP_METRIC_QUERY);
			if (!length(bssids))
				return false;

			const metrics = ubus.call('umap-rrmd', 'ap_metric', { bssids });
			if (!length(metrics))
				return false;

			const reply = cmdu.create(defs.MSG_AP_METRICS_RESPONSE, msg.mid);
			
			for (let bssid, metric in metrics) {
				reply.add_tlv(defs.TLV_AP_METRICS, {
					bssid,
					channel_utilization: metric.survey.utilization,
					sta_count: length(metric.stations),
					// TODO include_esp_be / ESP
				});
				reply.add_tlv(defs.TLV_AP_EXTENDED_METRICS, metric.extended);
				reply.add_tlv(defs.TLV_RADIO_METRICS, {
					radio_unique_identifier: bssid,
					noise: metric.survey.noise,
					transmit: metric.survey.transmit,
					receive_self: metric.survey.receive_self,
					receive_other: metric.survey.receive_other,
				});
				for (let mac, sta in metric.stations) {
					reply.add_tlv(defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS, sta.traffic);
					reply.add_tlv(defs.TLV_AP_METRICS, sta.link);
					reply.add_tlv(defs.TLV_AP_EXTENDED_METRICS, sta.link_ext);
					/* TODO
					reply.add_tlv(defs.TLV_ASSOCIATED_WIFI6_STA_STATUS_REPORT, ...);
					Zero or more Affiliated AP Metrics TLV (see section 17.2.101)
					Zero or more Affiliated STA Metrics TLV (see section 17.2.100)
					*/
				}
			}

			reply.send(i1905lif.i1905sock, model.address, srcmac);
			return true;
		} else if (msg.type === defs.MSG_ASSOCIATED_STA_LINK_METRICS_QUERY) {
			const mac_address = msg.get_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE);
			if (!mac_address)
				return false;

			const metrics = ubus.call('umap-rrmd', 'ap_metric', { bssids });
			if (!length(metrics))
				return false;

			const reply = cmdu.create(defs.MSG_AP_METRICS_RESPONSE, msg.mid);
			
			for (let bssid, metric in metrics) {
				reply.add_tlv(defs.TLV_AP_METRICS, {
					bssid,
					channel_utilization: metric.survey.utilization,
					sta_count: length(metric.stations),
					// TODO include_esp_be / ESP
				});
				reply.add_tlv(defs.TLV_AP_EXTENDED_METRICS, metric.extended);
				reply.add_tlv(defs.TLV_RADIO_METRICS, {
					radio_unique_identifier: bssid,
					noise: metric.survey.noise,
					transmit: metric.survey.transmit,
					receive_self: metric.survey.receive_self,
					receive_other: metric.survey.receive_other,
				});
				for (let mac, sta in metric.stations) {
					reply.add_tlv(defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS, sta.traffic);
					reply.add_tlv(defs.TLV_AP_METRICS, sta.link);
					reply.add_tlv(defs.TLV_AP_EXTENDED_METRICS, sta.link_ext);
					/* TODO
					reply.add_tlv(defs.TLV_ASSOCIATED_WIFI6_STA_STATUS_REPORT, ...);
					Zero or more Affiliated AP Metrics TLV (see section 17.2.101)
					Zero or more Affiliated STA Metrics TLV (see section 17.2.100)
					*/
				}
			}

			reply.send(i1905lif.i1905sock, model.address, srcmac);
			return true;
		}


defs.MSG_ASSOCIATED_STA_LINK_METRICS_QUERY
		return false;
	}
};

export default proto({}, IProtoLinkMetric);
