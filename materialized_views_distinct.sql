CREATE MATERIALIZED VIEW IF NOT EXISTS mv_date_distinct
ENGINE = ReplacingMergeTree()
ORDER BY date
AS
SELECT DISTINCT date FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_time_inserted_ns_distinct
ENGINE = ReplacingMergeTree()
ORDER BY time_inserted_ns
AS
SELECT DISTINCT time_inserted_ns FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_time_received_ns_distinct
ENGINE = ReplacingMergeTree()
ORDER BY time_received_ns
AS
SELECT DISTINCT time_received_ns FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_start_time_distinct
ENGINE = ReplacingMergeTree()
ORDER BY flow_start_time
AS
SELECT DISTINCT flow_start_time FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_end_time_distinct
ENGINE = ReplacingMergeTree()
ORDER BY flow_end_time
AS
SELECT DISTINCT flow_end_time FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_protocolIdentifier_distinct
ENGINE = ReplacingMergeTree()
ORDER BY protocolIdentifier
AS
SELECT DISTINCT protocolIdentifier FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_protocolName_distinct
ENGINE = ReplacingMergeTree()
ORDER BY protocolName
AS
SELECT DISTINCT protocolName FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceIPv4Address_distinct
ENGINE = ReplacingMergeTree()
ORDER BY sourceIPv4Address
AS
SELECT DISTINCT sourceIPv4Address FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_destinationIPv4Address_distinct
ENGINE = ReplacingMergeTree()
ORDER BY destinationIPv4Address
AS
SELECT DISTINCT destinationIPv4Address FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceTransportPort_distinct
ENGINE = ReplacingMergeTree()
ORDER BY sourceTransportPort
AS
SELECT DISTINCT sourceTransportPort FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_destinationTransportPort_distinct
ENGINE = ReplacingMergeTree()
ORDER BY destinationTransportPort
AS
SELECT DISTINCT destinationTransportPort FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_octetDeltaCount_distinct
ENGINE = ReplacingMergeTree()
ORDER BY octetDeltaCount
AS
SELECT DISTINCT octetDeltaCount FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_packetDeltaCount_distinct
ENGINE = ReplacingMergeTree()
ORDER BY packetDeltaCount
AS
SELECT DISTINCT packetDeltaCount FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flowStartMilliseconds_distinct
ENGINE = ReplacingMergeTree()
ORDER BY flowStartMilliseconds
AS
SELECT DISTINCT flowStartMilliseconds FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flowEndMilliseconds_distinct
ENGINE = ReplacingMergeTree()
ORDER BY flowEndMilliseconds
AS
SELECT DISTINCT flowEndMilliseconds FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_mac_source_distinct
ENGINE = ReplacingMergeTree()
ORDER BY mac_source
AS
SELECT DISTINCT mac_source FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_mac_destination_distinct
ENGINE = ReplacingMergeTree()
ORDER BY mac_destination
AS
SELECT DISTINCT mac_destination FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_application_name_distinct
ENGINE = ReplacingMergeTree()
ORDER BY application_name
AS
SELECT DISTINCT application_name FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_http_url_distinct
ENGINE = ReplacingMergeTree()
ORDER BY http_url
AS
SELECT DISTINCT http_url FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_https_url_certificate_distinct
ENGINE = ReplacingMergeTree()
ORDER BY https_url_certificate
AS
SELECT DISTINCT https_url_certificate FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_datalink_vlan_distinct
ENGINE = ReplacingMergeTree()
ORDER BY datalink_vlan
AS
SELECT DISTINCT datalink_vlan FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_bytes_accumulated_distinct
ENGINE = ReplacingMergeTree()
ORDER BY bytes_accumulated
AS
SELECT DISTINCT bytes_accumulated FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_retransmits_distinct
ENGINE = ReplacingMergeTree()
ORDER BY tcp_retransmits
AS
SELECT DISTINCT tcp_retransmits FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_rst_distinct
ENGINE = ReplacingMergeTree()
ORDER BY tcp_rst
AS
SELECT DISTINCT tcp_rst FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_fin_distinct
ENGINE = ReplacingMergeTree()
ORDER BY tcp_fin
AS
SELECT DISTINCT tcp_fin FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_bytes_per_packet_distinct
ENGINE = ReplacingMergeTree()
ORDER BY bytes_per_packet
AS
SELECT DISTINCT bytes_per_packet FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_duration_ms_distinct
ENGINE = ReplacingMergeTree()
ORDER BY flow_duration_ms
AS
SELECT DISTINCT flow_duration_ms FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_direction_distinct
ENGINE = ReplacingMergeTree()
ORDER BY flow_direction
AS
SELECT DISTINCT flow_direction FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_profile_name_distinct
ENGINE = ReplacingMergeTree()
ORDER BY profile_name
AS
SELECT DISTINCT profile_name FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_asn_number_distinct
ENGINE = ReplacingMergeTree()
ORDER BY asn_number
AS
SELECT DISTINCT asn_number FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_asn_organization_distinct
ENGINE = ReplacingMergeTree()
ORDER BY asn_organization
AS
SELECT DISTINCT asn_organization FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_city_name_distinct
ENGINE = ReplacingMergeTree()
ORDER BY city_name
AS
SELECT DISTINCT city_name FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_country_name_distinct
ENGINE = ReplacingMergeTree()
ORDER BY country_name
AS
SELECT DISTINCT country_name FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_latitude_distinct
ENGINE = ReplacingMergeTree()
ORDER BY latitude
AS
SELECT DISTINCT latitude FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_longitude_distinct
ENGINE = ReplacingMergeTree()
ORDER BY longitude
AS
SELECT DISTINCT longitude FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_iso_code_distinct
ENGINE = ReplacingMergeTree()
ORDER BY iso_code
AS
SELECT DISTINCT iso_code FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_application_name_flow_start_time_distinct
ENGINE = ReplacingMergeTree()
ORDER BY (application_name, flow_start_time)
AS
SELECT DISTINCT application_name,
    flow_start_time FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceIPv4Address_destinationIPv4Address_flow_start_time_distinct
ENGINE = ReplacingMergeTree()
ORDER BY (sourceIPv4Address, destinationIPv4Address, flow_start_time)
AS
SELECT DISTINCT sourceIPv4Address,
    destinationIPv4Address,
    flow_start_time FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceTransportPort_destinationTransportPort_flow_start_time_distinct
ENGINE = ReplacingMergeTree()
ORDER BY (sourceTransportPort, destinationTransportPort, flow_start_time)
AS
SELECT DISTINCT sourceTransportPort,
    destinationTransportPort,
    flow_start_time FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_rst_flow_start_time_distinct
ENGINE = ReplacingMergeTree()
ORDER BY (tcp_rst, flow_start_time)
AS
SELECT DISTINCT tcp_rst,
    flow_start_time FROM flows_raw;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_protocolIdentifier_bytes_accumulated_distinct
ENGINE = ReplacingMergeTree()
ORDER BY (protocolIdentifier, bytes_accumulated)
AS
SELECT DISTINCT protocolIdentifier,
    bytes_accumulated FROM flows_raw;