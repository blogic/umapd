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
import { interval, timer } from 'uloop';
import events from 'umap.events';

const REPLY_HANDLER_TIMEOUT = 1000;
const BEACON_REPORT_TIMEOUT = 1000;

let IBeaconReport = {
	reports: {},

	init: function() {
		if (!model.isController) {
			const self = this;
			events.register('wireless.beacon-report', (data) => { self.queue_beacon_report(data); });
			this.timer = timer(1, () => { self.emit_beacon_report_notification(); });
		}
	},

	emit_beacon_report_notification: function() {
		if (!length(this.reports))
			return;
		for (let mac, reports in this.reports) {
			const msg = cmdu.create(defs.MSG_BEACON_METRICS_RESPONSE);
			msg.add_tlv(defs.TLV_BEACON_METRICS_RESPONSE, reports);

			for (let i1905lif in model.getLocalInterfaces())
				msg.send(i1905lif.i1905sock, model.address, reports.srcmac);
		}
		this.reports = {};
	},

	queue_beacon_report: function(data) {
		push(this.reports[data.address].measurement_report_elements, {
			id: 39, // 9-92—Element IDs, Measurement Report (see 9.4.2.21)
			token: data.token,
			type: 5, // 9-125 Measurement Type, Beacon
			report_mode: data['rep-mode'],
			//TODO add base64 struct
			report_data: b64dec(data.report),
		});
		this.timer.set(BEACON_REPORT_TIMEOUT);
	},

	create_beacon_report: function(srcmac, mac_address) {
		this.reports[mac_address] = {
			srcmac,
			mac_address,
			measurement_report_elements: [],
		};
		this.timer.set(BEACON_REPORT_TIMEOUT);
	},
};

const ILinkMetricReporting = {
	policy: {},

	init: function() {
		const self = this;
		events.register('policy.metric-reporting', (data) => { self.update_policy(data, self); });
	},

	emit_ap_metric: function(i1905lif, target, bssids, mid, self) {
		self ??= this;
		if (!length(bssids))
			return false;

		const metrics = ubus.call('umap-rrmd', 'ap_metric', { bssids });
		if (!length(metrics))
			return false;

		const reply = cmdu.create(defs.MSG_AP_METRICS_RESPONSE, mid);
	
		for (let bssid, metric in metrics) {
			reply.add_tlv(defs.TLV_AP_METRICS, {
				bssid,
				channel_utilization: metric.survey.utilization,
				sta_count: length(metric.stations),
				esp_be: '\x00\x00\x00',
				// TODO include_esp_be / ESP
			});

			let extended = model.getLocalStats(bssid);
			if (extended)
				reply.add_tlv(defs.TLV_AP_EXTENDED_METRICS, { bssid, ...extended });

			reply.add_tlv(defs.TLV_RADIO_METRICS, {
				radio_unique_identifier: bssid,
				noise: metric.survey.noise,
				transmit: metric.survey.transmit,
				receive_self: metric.survey.receive_self,
				receive_other: metric.survey.receive_other,
			});

			for (let mac, sta in metric.stations) {
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS, sta.traffic);
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_LINK_METRICS, sta.link);
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_EXTENDED_LINK_METRICS, sta.link_ext);
				/* TODO
				reply.add_tlv(defs.TLV_ASSOCIATED_WIFI6_STA_STATUS_REPORT, ...);
				Zero or more Affiliated AP Metrics TLV (see section 17.2.101)
				Zero or more Affiliated STA Metrics TLV (see section 17.2.100)
				*/
			}
		}

		reply.send(i1905lif.i1905sock, model.address, target);

		return true;
	},

	emit_periodic_link_metric: function(self) {
		log.debug('send periodic linkmetric ');
		//TODO: controller AL
	},

	update_policy: function(data, self) {
		log.debug('received a link metric policy update');
		self.policy = data;

		if (self.policy.ap_metrics_reporting_interval) {
			self.interval ??= interval(self.policy.ap_metrics_reporting_interval * 1000, (self) => { self.emit_periodic_link_metric(self); });
		} else if (self.interval) {
			self.interval.cancel();
			self.interval = null;
	        }
	}
};

const IProtoLinkMetric = {
	init: function() {
		ubus.register('query_ap_metrics',
			{ ap_macs: [ "00:00:00:00:00:00" ] },
			this.emit_query_ap_metrics);

		ubus.register('query_assoc_sta_metrics',
			{ ap_mac: "00:00:00:00:00:00", sta_mac: "00:00:00:00:00:00" },
			this.emit_query_assoc_sta_metrics);

		ubus.register('query_beacon_metrics',
			{
				ap_mac: "00:00:00:00:00:00",
				sta_mac: "00:00:00:00:00:00",
				opclass: 1,
				channel: 1,
				bssid: "00:00:00:00:00:00",
				reporting_detail_value: 1,
				ssid: "ssid",
				/* TODO
				ap_channel_reports: [],
				element_list: [],
				*/
			},
			this.query_beacon_metrics);

		if (!model.isController) {
			IBeaconReport.init();
			ILinkMetricReporting.init();
		}
	},

	emit_query_ap_metrics: function (req) {
		if (!length(req.args.ap_macs))
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const i1905dev = model.lookupDevice(req.args.ap_macs[0]);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_AP_METRICS_QUERY);
		query.add_tlv(defs.TLV_AP_METRIC_QUERY, req.args.ap_macs);

		query.on_reply(response => {
			if (!response)
				return req.reply(null, defs.UBUS_STATUS_TIMEOUT);

			const ret = { tlvs: []};

			for (let tt in [
				defs.TLV_AP_METRICS,
				defs.TLV_AP_EXTENDED_METRICS,
				defs.TLV_RADIO_METRICS,
				defs.TLV_ASSOCIATED_STA_TRAFFIC_STATS,
				defs.TLV_ASSOCIATED_STA_LINK_METRICS,
				defs.TLV_ASSOCIATED_STA_EXTENDED_LINK_METRICS,
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

	emit_query_assoc_sta_metrics: function (req) {
		if (!req.args.ap_mac || !req.args.sta_mac)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const i1905dev = model.lookupDevice(req.args.ap_mac);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_ASSOCIATED_STA_LINK_METRICS_QUERY);
		query.add_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE, req.args.sta_mac);
		query.on_reply(response => {
			if (!response)
				return req.reply(null, defs.UBUS_STATUS_TIMEOUT);

			const ret = { tlvs: [] };

			for (let tt in [
				defs.TLV_ASSOCIATED_STA_LINK_METRICS,
				defs.TLV_ASSOCIATED_STA_EXTENDED_LINK_METRICS,
				defs.TLV_REASON_CODE,
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

	query_beacon_metrics: function (req) {
		if (!req.args.ap_mac || !req.args.sta_mac)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);
		
		const i1905dev = model.lookupDevice(req.args.ap_mac);
		if (!i1905dev)
			return req.reply(null, defs.UBUS_STATUS_NOT_FOUND);

		const query = cmdu.create(defs.MSG_BEACON_METRICS_QUERY);
		query.add_tlv(defs.TLV_BEACON_METRICS_QUERY, {
			bssid: req.args.ap_mac,
			mac_address: req.args.sta_mac,
			ssid: "",
			ap_channel_reports: [],
			element_list: [],
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

		if (msg.type === defs.MSG_AP_METRICS_QUERY) {
			const bssids = msg.get_tlv(defs.TLV_AP_METRIC_QUERY);

			return ILinkMetricReporting.emit_ap_metric(i1905lif, srcmac, bssids, msg.mid);

		} else if (msg.type === defs.MSG_ASSOCIATED_STA_LINK_METRICS_QUERY) {
			const mac_address = msg.get_tlv(defs.TLV_STA_MAC_ADDRESS_TYPE);
			if (!mac_address)
				return false;

			const reply = cmdu.create(defs.MSG_ASSOCIATED_STA_LINK_METRICS_RESPONSE, msg.mid);

			const metrics = ubus.call('umap-rrmd', 'sta_metric', { mac_address });
			if (length(metrics)) {	
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_LINK_METRICS, metrics.link);
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_EXTENDED_LINK_METRICS, metrics.link_ext);
			} else {
				let empty = {
					mac_address,
			                bssids: [],
				};
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_LINK_METRICS, empty);
				reply.add_tlv(defs.TLV_ASSOCIATED_STA_EXTENDED_LINK_METRICS, empty);
				reply.add_tlv(defs.TLV_REASON_CODE, 2);
			}

			// TODO Zero or more Associated STA MLD Configuration Report TLV (see section 17.2.98)
			reply.send(i1905lif.i1905sock, model.address, srcmac);

			return true;

		} else if (msg.type === defs.MSG_BEACON_METRICS_QUERY) {
			const beacon_metrics = msg.get_tlv(defs.TLV_BEACON_METRICS_QUERY);
			if (!beacon_metrics)
				return false;
			ubus.call('umap-rrmd', 'beacon_req', beacon_metrics);
			let error = ubus.error();
			const ack = cmdu.create(defs.MSG_IEEE1905_ACK, msg.mid);
			if (error)
				ack.add_tlv(defs.TLV_REASON_CODE, 2);
			ack.send(i1905lif.i1905sock, model.address, srcmac);

			IBeaconReport.create_beacon_report(srcmac, beacon_metrics.mac_address);

			return true;
		}

		return false;
	}
};

export default proto({}, IProtoLinkMetric);
