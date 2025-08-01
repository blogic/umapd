import * as ubus from 'ubus';

export default {
	IEEE1905_MULTICAST_MAC: '01:80:c2:00:00:13',
	LLDP_NEAREST_BRIDGE_MAC: '01:80:c2:00:00:0e',

	CMDU_F_LASTFRAG: 0b10000000,
	CMDU_F_ISRELAY: 0b01000000,

	MSG_TOPOLOGY_DISCOVERY: 0x0000,
	MSG_TOPOLOGY_NOTIFICATION: 0x0001,
	MSG_TOPOLOGY_QUERY: 0x0002,
	MSG_TOPOLOGY_RESPONSE: 0x0003,
	MSG_VENDOR_SPECIFIC: 0x0004,
	MSG_LINK_METRIC_QUERY: 0x0005,
	MSG_LINK_METRIC_RESPONSE: 0x0006,
	MSG_AP_AUTOCONFIGURATION_SEARCH: 0x0007,
	MSG_AP_AUTOCONFIGURATION_RESPONSE: 0x0008,
	MSG_AP_AUTOCONFIGURATION_WSC: 0x0009,
	MSG_AP_AUTOCONFIGURATION_RENEW: 0x000a,
	MSG_IEEE1905_PUSH_BUTTON_EVENT_NOTIFICATION: 0x000b,
	MSG_IEEE1905_PUSH_BUTTON_JOIN_NOTIFICATION: 0x000c,
	MSG_HIGHER_LAYER_QUERY: 0x000d,
	MSG_HIGHER_LAYER_RESPONSE: 0x000e,
	MSG_INTERFACE_POWER_CHANGE_REQUEST: 0x000f,
	MSG_INTERFACE_POWER_CHANGE_RESPONSE: 0x0010,
	MSG_GENERIC_PHY_QUERY: 0x0011,
	MSG_GENERIC_PHY_RESPONSE: 0x0012,
	MSG_IEEE1905_ACK: 0x8000,
	MSG_AP_CAPABILITY_QUERY: 0x8001,
	MSG_AP_CAPABILITY_REPORT: 0x8002,
	MSG_MULTI_AP_POLICY_CONFIG_REQUEST: 0x8003,
	MSG_CHANNEL_PREFERENCE_QUERY: 0x8004,
	MSG_CHANNEL_PREFERENCE_REPORT: 0x8005,
	MSG_CHANNEL_SELECTION_REQUEST: 0x8006,
	MSG_CHANNEL_SELECTION_RESPONSE: 0x8007,
	MSG_OPERATING_CHANNEL_REPORT: 0x8008,
	MSG_CLIENT_CAPABILITY_QUERY: 0x8009,
	MSG_CLIENT_CAPABILITY_REPORT: 0x800a,
	MSG_AP_METRICS_QUERY: 0x800b,
	MSG_AP_METRICS_RESPONSE: 0x800c,
	MSG_ASSOCIATED_STA_LINK_METRICS_QUERY: 0x800d,
	MSG_ASSOCIATED_STA_LINK_METRICS_RESPONSE: 0x800e,
	MSG_UNASSOCIATED_STA_LINK_METRICS_QUERY: 0x800f,
	MSG_UNASSOCIATED_STA_LINK_METRICS_RESPONSE: 0x8010,
	MSG_BEACON_METRICS_QUERY: 0x8011,
	MSG_BEACON_METRICS_RESPONSE: 0x8012,
	MSG_COMBINED_INFRASTRUCTURE_METRICS: 0x8013,
	MSG_CLIENT_STEERING_REQUEST: 0x8014,
	MSG_CLIENT_STEERING_BTM_REPORT: 0x8015,
	MSG_CLIENT_ASSOCIATION_CONTROL_REQUEST: 0x8016,
	MSG_STEERING_COMPLETED: 0x8017,
	MSG_HIGHER_LAYER_DATA: 0x8018,
	MSG_BACKHAUL_STEERING_REQUEST: 0x8019,
	MSG_BACKHAUL_STEERING_RESPONSE: 0x801a,
	MSG_CHANNEL_SCAN_REQUEST: 0x801b,
	MSG_CHANNEL_SCAN_REPORT: 0x801c,
	MSG_DPP_CCE_INDICATION: 0x801d,
	MSG_IEEE1905_REKEY_REQUEST: 0x801e,
	MSG_IEEE1905_DECRYPTION_FAILURE: 0x801f,
	MSG_CAC_REQUEST: 0x8020,
	MSG_CAC_TERMINATION: 0x8021,
	MSG_CLIENT_DISASSOCIATION_STATS: 0x8022,
	MSG_SERVICE_PRIORITIZATION_REQUEST: 0x8023,
	MSG_ERROR_RESPONSE: 0x8024,
	MSG_ASSOCIATION_STATUS_NOTIFICATION: 0x8025,
	MSG_TUNNELED: 0x8026,
	MSG_BACKHAUL_STA_CAPABILITY_QUERY: 0x8027,
	MSG_BACKHAUL_STA_CAPABILITY_REPORT: 0x8028,
	MSG_PROXIED_ENCAP_DPP: 0x8029,
	MSG_DIRECT_ENCAP_DPP: 0x802a,
	MSG_RECONFIGURATION_TRIGGER: 0x802b,
	MSG_BSS_CONFIGURATION_REQUEST: 0x802c,
	MSG_BSS_CONFIGURATION_RESPONSE: 0x802d,
	MSG_BSS_CONFIGURATION_RESULT: 0x802e,
	MSG_CHIRP_NOTIFICATION: 0x802f,
	MSG_IEEE1905_ENCAP_EAPOL: 0x8030,
	MSG_DPP_BOOTSTRAPPING_URI_NOTIFICATION: 0x8031,
	MSG_ANTICIPATED_CHANNEL_PREFERENCE: 0x8032,
	MSG_FAILED_CONNECTION: 0x8033,
	MSG_AGENT_LIST: 0x8035,
	MSG_ANTICIPATED_CHANNEL_USAGE_REPORT: 0x8036,
	MSG_QOS_MANAGEMENT_NOTIFICATION: 0x8037,
	MSG_VIRTUAL_BSS_CAPABILITIES_REQUEST: 0x8038,
	MSG_VIRTUAL_BSS_CAPABILITIES_RESPONSE: 0x8039,
	MSG_VIRTUAL_BSS_REQUEST: 0x803a,
	MSG_VIRTUAL_BSS_RESPONSE: 0x803b,
	MSG_CLIENT_SECURITY_CONTEXT_REQUEST: 0x803c,
	MSG_CLIENT_SECURITY_CONTEXT_RESPONSE: 0x803d,
	MSG_TRIGGER_CHANNEL_SWITCH_ANNOUNCEMENT_REQUEST: 0x803e,
	MSG_TRIGGER_CHANNEL_SWITCH_ANNOUNCEMENT_RESPONSE: 0x803f,
	MSG_VIRTUAL_BSS_MOVE_PREPARATION_REQUEST: 0x8040,
	MSG_VIRTUAL_BSS_MOVE_PREPARATION_RESPONSE: 0x8041,
	MSG_VIRTUAL_BSS_MOVE_CANCEL_REQUEST: 0x8042,

	TLV_END_OF_MESSAGE: 0x0000,
	TLV_IEEE1905_AL_MAC_ADDRESS: 0x0001,
	TLV_MAC_ADDRESS: 0x0002,
	TLV_IEEE1905_DEVICE_INFORMATION: 0x0003,
	TLV_DEVICE_BRIDGING_CAPABILITY: 0x0004,
	TLV_NON_IEEE1905_NEIGHBOR_DEVICES: 0x0006,
	TLV_IEEE1905_NEIGHBOR_DEVICES: 0x0007,
	TLV_LINK_METRIC_QUERY: 0x0008,
	TLV_IEEE1905_TRANSMITTER_LINK_METRIC: 0x0009,
	TLV_IEEE1905_RECEIVER_LINK_METRIC: 0x000a,
	TLV_VENDOR_SPECIFIC: 0x000b,
	TLV_IEEE1905_LINK_METRIC_RESULT_CODE: 0x000c,
	TLV_SEARCHED_ROLE: 0x000d,
	TLV_AUTOCONFIG_FREQUENCY_BAND: 0x000e,
	TLV_SUPPORTED_ROLE: 0x000f,
	TLV_SUPPORTED_FREQUENCY_BAND: 0x0010,
	TLV_WSC: 0x0011,
	TLV_PUSH_BUTTON_EVENT_NOTIFICATION: 0x0012,
	TLV_PUSH_BUTTON_JOIN_NOTIFICATION: 0x0013,
	TLV_GENERIC_PHY_DEVICE_INFORMATION: 0x0014,
	TLV_DEVICE_IDENTIFICATION: 0x0015,
	TLV_CONTROL_URL: 0x0016,
	TLV_IPV4: 0x0017,
	TLV_IPV6: 0x0018,
	TLV_PUSH_BUTTON_GENERIC_PHY_EVENT: 0x0019,
	TLV_IEEE1905_PROFILE_VERSION: 0x001a,
	TLV_POWER_OFF_INTERFACE: 0x001b,
	TLV_INTERFACE_POWER_CHANGE_INFORMATION: 0x001c,
	TLV_INTERFACE_POWER_CHANGE_STATUS: 0x001d,
	TLV_L2_NEIGHBOR_DEVICE: 0x001e,
	TLV_SUPPORTED_SERVICE: 0x0080,
	TLV_SEARCHED_SERVICE: 0x0081,
	TLV_AP_RADIO_IDENTIFIER: 0x0082,
	TLV_AP_OPERATIONAL_BSS: 0x0083,
	TLV_ASSOCIATED_CLIENTS: 0x0084,
	TLV_AP_RADIO_BASIC_CAPABILITIES: 0x0085,
	TLV_AP_HT_CAPABILITIES: 0x0086,
	TLV_AP_VHT_CAPABILITIES: 0x0087,
	TLV_AP_HE_CAPABILITIES: 0x0088,
	TLV_STEERING_POLICY: 0x0089,
	TLV_METRIC_REPORTING_POLICY: 0x008a,
	TLV_CHANNEL_PREFERENCE: 0x008b,
	TLV_RADIO_OPERATION_RESTRICTION: 0x008c,
	TLV_TRANSMIT_POWER_LIMIT: 0x008d,
	TLV_CHANNEL_SELECTION_RESPONSE: 0x008e,
	TLV_OPERATING_CHANNEL_REPORT: 0x008f,
	TLV_CLIENT_INFO: 0x0090,
	TLV_CLIENT_CAPABILITY_REPORT: 0x0091,
	TLV_CLIENT_ASSOCIATION_EVENT: 0x0092,
	TLV_AP_METRIC_QUERY: 0x0093,
	TLV_AP_METRICS: 0x0094,
	TLV_STA_MAC_ADDRESS_TYPE: 0x0095,
	TLV_ASSOCIATED_STA_LINK_METRICS: 0x0096,
	TLV_UNASSOCIATED_STA_LINK_METRICS_QUERY: 0x0097,
	TLV_UNASSOCIATED_STA_LINK_METRICS_RESPONSE: 0x0098,
	TLV_BEACON_METRICS_QUERY: 0x0099,
	TLV_BEACON_METRICS_RESPONSE: 0x009a,
	TLV_STEERING_REQUEST: 0x009b,
	TLV_STEERING_BTM_REPORT: 0x009c,
	TLV_CLIENT_ASSOCIATION_CONTROL_REQUEST: 0x009d,
	TLV_BACKHAUL_STEERING_REQUEST: 0x009e,
	TLV_BACKHAUL_STEERING_RESPONSE: 0x009f,
	TLV_HIGHER_LAYER_DATA: 0x00a0,
	TLV_AP_CAPABILITY: 0x00a1,
	TLV_ASSOCIATED_STA_TRAFFIC_STATS: 0x00a2,
	TLV_ERROR_CODE: 0x00a3,
	TLV_CHANNEL_SCAN_REPORTING_POLICY: 0x00a4,
	TLV_CHANNEL_SCAN_CAPABILITIES: 0x00a5,
	TLV_CHANNEL_SCAN_REQUEST: 0x00a6,
	TLV_CHANNEL_SCAN_RESULT: 0x00a7,
	TLV_TIMESTAMP: 0x00a8,
	TLV_IEEE1905_LAYER_SECURITY_CAPABILITY: 0x00a9,
	TLV_AP_WIFI6_CAPABILITIES: 0x00aa,
	TLV_MIC: 0x00ab,
	TLV_ENCRYPTED: 0x00ac,
	TLV_CAC_REQUEST: 0x00ad,
	TLV_CAC_TERMINATION: 0x00ae,
	TLV_CAC_COMPLETION_REPORT: 0x00af,
	TLV_ASSOCIATED_WIFI6_STA_STATUS_REPORT: 0x00b0,
	TLV_CAC_STATUS_REPORT: 0x00b1,
	TLV_CAC_CAPABILITIES: 0x00b2,
	TLV_MULTI_AP_PROFILE: 0x00b3,
	TLV_PROFILE_2_AP_CAPABILITY: 0x00b4,
	TLV_DEFAULT_802_1Q_SETTINGS: 0x00b5,
	TLV_TRAFFIC_SEPARATION_POLICY: 0x00b6,
	TLV_BSS_CONFIGURATION_REPORT_TLV_FORMAT_BSSID: 0x00b7,
	TLV_BSSID: 0x00b8,
	TLV_SERVICE_PRIORITIZATION_RULE: 0x00b9,
	TLV_DSCP_MAPPING_TABLE: 0x00ba,
	TLV_BSS_CONFIGURATION_REQUEST: 0x00bb,
	TLV_PROFILE_2_ERROR_CODE: 0x00bc,
	TLV_BSS_CONFIGURATION_RESPONSE: 0x00bd,
	TLV_AP_RADIO_ADVANCED_CAPABILITIES: 0x00be,
	TLV_ASSOCIATION_STATUS_NOTIFICATION: 0x00bf,
	TLV_SOURCE_INFO: 0x00c0,
	TLV_TUNNELED_MESSAGE_TYPE: 0x00c1,
	TLV_TUNNELED: 0x00c2,
	TLV_PROFILE_2_STEERING_REQUEST: 0x00c3,
	TLV_UNSUCCESSFUL_ASSOCIATION_POLICY: 0x00c4,
	TLV_METRIC_COLLECTION_INTERVAL: 0x00c5,
	TLV_RADIO_METRICS: 0x00c6,
	TLV_AP_EXTENDED_METRICS: 0x00c7,
	TLV_ASSOCIATED_STA_EXTENDED_LINK_METRICS: 0x00c8,
	TLV_STATUS_CODE: 0x00c9,
	TLV_REASON_CODE: 0x00ca,
	TLV_BACKHAUL_STA_RADIO_CAPABILITIES: 0x00cb,
	TLV_AKM_SUITE_CAPABILITIES: 0x00cc,
	TLV_IEEE1905_ENCAP_DPP: 0x00cd,
	TLV_IEEE1905_ENCAP_EAPOL: 0x00ce,
	TLV_DPP_BOOTSTRAPPING_URI_NOTIFICATION: 0x00cf,
	TLV_BACKHAUL_BSS_CONFIGURATION: 0x00d0,
	TLV_DPP_MESSAGE: 0x00d1,
	TLV_DPP_CCE_INDICATION: 0x00d2,
	TLV_DPP_CHIRP_VALUE: 0x00d3,
	TLV_DEVICE_INVENTORY: 0x00d4,
	TLV_AGENT_LIST: 0x00d5,
	TLV_ANTICIPATED_CHANNEL_PREFERENCE: 0x00d6,
	TLV_ANTICIPATED_CHANNEL_USAGE: 0x00d7,
	TLV_SPATIAL_REUSE_REQUEST: 0x00d8,
	TLV_SPATIAL_REUSE_REPORT: 0x00d9,
	TLV_SPATIAL_REUSE_CONFIG_RESPONSE: 0x00da,
	TLV_QOS_MANAGEMENT_POLICY: 0x00db,
	TLV_QOS_MANAGEMENT_DESCRIPTOR: 0x00dc,
	TLV_CONTROLLER_CAPABILITY: 0x00dd,

	TLV_EXTENDED: 0xde,
	TLV_EXTENDED_AP_RADIO_VBSS_CAPABILITIES: 0x0001,
	TLV_EXTENDED_VIRTUAL_BSS_CREATION: 0x0002,
	TLV_EXTENDED_VIRTUAL_BSS_DESTRUCTION: 0x0003,
	TLV_EXTENDED_VIRTUAL_BSS_EVENT: 0x0004,
	TLV_EXTENDED_CLIENT_SECURITY_CONTEXT: 0x0005,
	TLV_EXTENDED_TRIGGER_CHANNEL_SWITCH_ANNOUNCEMENT: 0x0006,
	TLV_EXTENDED_VBSS_CONFIGURATION_REPORT: 0x0007,

	ADVERTISE_CCE: {
		[0]: 'Disable',
		[1]: 'Enable',
	},

	ASSOCIATION_ALLOWANCE_STATUS: {
		[0x00]: 'No more associations allowed',
		[0x01]: 'Associations allowed',
	},

	ASSOCIATION_CONTROL: {
		[0x00]: 'Block',
		[0x01]: 'Unblock',
		[0x02]: 'Timed block',
		[0x03]: 'Indefinite block',
	},

	BYTE_COUNTER_UNIT: {
		[0x0]: 'bytes',
		[0x1]: 'kibibytes (KiB)',
		[0x2]: 'mebibytes (MiB)',
	},

	CAC_COMPLETION_STATUS: {
		[0x00]: 'Successful',
		[0x01]: 'Radar detected',
		[0x02]: 'CAC not supported as requested (capability mismatch)',
		[0x03]: 'Radio too busy to perform CAC',
		[0x04]: 'Request was considered to be non-conformant to regulations in the country in which the Multi-AP Agent is operating',
		[0x05]: 'Other error',
	},

	CAC_METHOD_SUPPORTED: {
		[0x00]: 'Continuous CAC',
		[0x01]: 'Continuous with dedicated radio',
		[0x02]: 'MIMO dimension reduced',
		[0x03]: 'Time sliced CAC',
	},

	CHANGE_STATE: {
		[0x00]: 'Request completed',
		[0x01]: 'No change made',
		[0x02]: 'Alternative change made',
	},

	CHANNEL_PREFERENCE_REASON_CODE: {
		[0b0000]: 'Unspecified',
		[0b0001]: 'Proximate non-802.11 interferer in local environment',
		[0b0010]: 'Intra-network 802.11 OBSS interference management',
		[0b0011]: 'External network 802.11 OBSS interference management',
		[0b0100]: 'Reduced coverage',
		[0b0101]: 'Reduced throughput',
		[0b0110]: 'In-device Interferer within AP',
		[0b0111]: 'Operation disallowed due to radar detection on a DFS channel',
		[0b1000]: 'Operation would prevent backhaul operation using shared radio',
		[0b1001]: 'Immediate operation possible on a DFS channel',
		[0b1010]: 'DFS channel state unknown',
		[0b1011]: 'Controller DFS Channel Clear Indication',
		[0b1100]: 'Operation disallowed by regulatory restriction',
	},

	CHANNEL_SELECTION_RESPONSE_CODE: {
		[0x00]: 'Accept',
		[0x01]: 'Decline because request violates current preferences which have changed since last reported',
		[0x02]: 'Decline because request violates most recently reported preferences',
		[0x03]: 'Decline because request would prevent operation of a currently operating backhaul link (where backhaul STA and BSS share a radio)',
	},

	IEEE1905_FREQUENCY_BAND: {
		[0x00]: '802.11 2.4 GHz',
		[0x01]: '802.11 5 GHz',
		[0x02]: '802.11 60 GHz',
	},

	IEEE1905_PROFILE: {
		[0x00]: '1905.1',
		[0x01]: '1905.1a',
	},

	IEEE1905_ROLE: {
		[0x00]: 'Registrar',
	},

	IPV4ADDR_TYPE: {
		[0]: 'Unknown',
		[1]: 'DHCP',
		[2]: 'Static',
		[3]: 'Auto-IP',
	},

	IPV6ADDR_TYPE: {
		[0]: 'Unknown',
		[1]: 'DHCP',
		[2]: 'Static',
		[3]: 'SLAAC',
	},

	LINK_METRICS_REQUESTED: {
		[0x00]: 'Tx link metrics only',
		[0x01]: 'Rx link metrics only',
		[0x02]: 'Both Tx and Rx link metrics',
	},

	LINK_METRIC_RESULT_CODE: {
		[0x00]: 'Invalid neighbor',
	},

	MAX_SUPPORTED_RX_SPATIAL_STREAMS: {
		[0b000]: '1 Rx spatial stream',
		[0b001]: '2 Rx spatial stream',
		[0b010]: '3 Rx spatial stream',
		[0b011]: '4 Rx spatial stream',
		[0b100]: '5 Rx spatial stream',
		[0b101]: '6 Rx spatial stream',
		[0b110]: '7 Rx spatial stream',
		[0b111]: '8 Rx spatial stream',
	},

	MAX_SUPPORTED_TX_SPATIAL_STREAMS: {
		[0b000]: '1 Tx spatial stream',
		[0b001]: '2 Tx spatial stream',
		[0b010]: '3 Tx spatial stream',
		[0b011]: '4 Tx spatial stream',
		[0b100]: '5 Tx spatial stream',
		[0b101]: '6 Tx spatial stream',
		[0b110]: '7 Tx spatial stream',
		[0b111]: '8 Tx spatial stream',
	},

	MEDIA_TYPE: {
		[0x0000]: 'IEEE 802.3u fast Ethernet',
		[0x0001]: 'IEEE 802.3ab gigabit Ethernet',
		[0x0100]: 'IEEE 802.11b (2.4 GHz)',
		[0x0101]: 'IEEE 802.11g (2.4 GHz)',
		[0x0102]: 'IEEE 802.11a (5 GHz)',
		[0x0103]: 'IEEE 802.11n (2.4 GHz)',
		[0x0104]: 'IEEE 802.11n (5 GHz)',
		[0x0105]: 'IEEE 802.11ac (5 GHz)',
		[0x0106]: 'IEEE 802.11ad (60 GHz)',
		[0x0107]: 'IEEE 802.11ax (2.4 GHz)',
		[0x0108]: 'IEEE 802.11ax (5 GHz)',
		[0x0200]: 'IEEE 1901 wavelet',
		[0x0201]: 'IEEE 1901 FFT',
		[0x0300]: 'MoCA v1.1',
		[0xffff]: 'Unknown Media',
	},

	MULTI_AP_PROFILE: {
		[0x01]: 'Multi-AP Profile-1',
		[0x02]: 'Multi-AP Profile-2',
		[0x03]: 'Multi-AP Profile-3',
	},

	MULTI_AP_SERVICE: {
		[0x00]: 'Multi-AP Controller',
		[0x01]: 'Multi-AP Agent',
	},

	POWER_STATE: {
		[0x00]: 'PWR_OFF',
		[0x01]: 'PWR_ON',
		[0x02]: 'PWR_SAVE',
	},

	PROFILE_2_REASON_CODE: {
		[0x01]: 'Service Prioritization Rule not found',
		[0x02]: 'Number of Service Prioritization Rules exceeded the maximum supported',
		[0x03]: 'Default PCP or Primary VLAN ID not provided',
		[0x05]: 'Number of unique VLAN ID exceeds maximum supported',
		[0x07]: 'Traffic Separation on combined BSS for fronthaul and a backhaul that does support Traffic Separation unsupported',
		[0x08]: 'Cannot support mixture of backhauls that do and do not support Traffic Separation',
		[0x0A]: 'Traffic Separation not supported',
		[0x0B]: 'Unable to configure requested QoS Management Policy',
		[0x0C]: 'QoS Management DSCP Policy Request rejected',
		[0x0D]: 'Agent can not onboard other Agents via DPP over Wi-Fi',
	},

	QUERY_TYPE: {
		[0x00]: 'All neighbors',
		[0x01]: 'Specific neighbor',
	},

	REASON_CODE: {
		[0x01]: 'STA associated with a BSS operated by the Multi-AP Agent.',
		[0x02]: 'STA not associated with any BSS operated by the Multi-AP Agent.',
		[0x03]: 'Client capability report unspecified failure',
		[0x04]: 'Backhaul steering request rejected because the backhaul STA cannot operate on the channel specified.',
		[0x05]: 'Backhaul steering request rejected because the target BSS signal is too weak or not found.',
		[0x06]: 'Backhaul steering request authentication or association Rejected by the target BSS.',
	},

	RESPONSE_CODE: {
		[0x00]: 'Accept',
		[0x01]: 'Decline because radio does not support requested configuration.',
	},

	RESULT_CODE: {
		[0x00]: 'Success',
		[0x01]: 'Failure',
	},

	SCAN_IMPACT: {
		[0x00]: 'No impact (independent radio is available for scanning that is not used for Fronthaul or backhaul)',
		[0x01]: 'Reduced number of spatial streams',
		[0x02]: 'Time slicing impairment (Radio may go off channel for a series of short intervals)',
		[0x03]: 'Radio unavailable for >= 2 seconds)',
	},

	SCAN_STATUS: {
		[0x00]: 'Success',
		[0x01]: 'Scan not supported on this operating class and channel on this radio',
		[0x02]: 'Request too soon after last scan',
		[0x03]: 'Radio too busy to perform scan',
		[0x04]: 'Scan not completed',
		[0x05]: 'Scan aborted',
		[0x06]: 'Fresh scan not supported. Radio only supports on boot scans.',
	},

	STEERING_POLICY: {
		[0x00]: 'Agent Initiated Steering Disallowed',
		[0x01]: 'Agent Initiated RCPI-based Steering Mandated',
		[0x02]: 'Agent Initiated RCPI-based Steering Allowed',
	},

	TUNNELED_PROTOCOL_TYPE: {
		[0x00]: 'Association Request',
		[0x01]: 'Re-Association Request',
		[0x02]: 'BTM Query',
		[0x03]: 'WNM Request',
		[0x04]: 'ANQP request for Neighbor Report',
		[0x05]: 'DSCP Policy Query',
		[0x06]: 'DSCP Policy Response',
	},

	UBUS: {
		STATUS_OK: ubus.STATUS_OK,
		STATUS_INVALID_COMMAND: ubus.STATUS_INVALID_COMMAND,
		STATUS_INVALID_ARGUMENT: ubus.STATUS_INVALID_ARGUMENT,
		STATUS_METHOD_NOT_FOUND: ubus.STATUS_METHOD_NOT_FOUND,
		STATUS_NOT_FOUND: ubus.STATUS_NOT_FOUND,
		STATUS_NO_DATA: ubus.STATUS_NO_DATA,
		STATUS_PERMISSION_DENIED: ubus.STATUS_PERMISSION_DENIED,
		STATUS_TIMEOUT: ubus.STATUS_TIMEOUT,
		STATUS_NOT_SUPPORTED: ubus.STATUS_NOT_SUPPORTED,
		STATUS_UNKNOWN_ERROR: ubus.STATUS_UNKNOWN_ERROR,
		STATUS_CONNECTION_FAILED: ubus.STATUS_CONNECTION_FAILED
	},
};
