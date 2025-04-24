CREATE MATERIALIZED VIEW IF NOT EXISTS mv_date_agg
ENGINE = SummingMergeTree()
ORDER BY date
AS
SELECT
    date,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY date;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_time_inserted_ns_agg
ENGINE = SummingMergeTree()
ORDER BY time_inserted_ns
AS
SELECT
    time_inserted_ns,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY time_inserted_ns;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_time_received_ns_agg
ENGINE = SummingMergeTree()
ORDER BY time_received_ns
AS
SELECT
    time_received_ns,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY time_received_ns;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_start_time_agg
ENGINE = SummingMergeTree()
ORDER BY flow_start_time
AS
SELECT
    flow_start_time,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY flow_start_time;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_end_time_agg
ENGINE = SummingMergeTree()
ORDER BY flow_end_time
AS
SELECT
    flow_end_time,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY flow_end_time;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_protocolIdentifier_agg
ENGINE = SummingMergeTree()
ORDER BY protocolIdentifier
AS
SELECT
    protocolIdentifier,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY protocolIdentifier;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_protocolName_agg
ENGINE = SummingMergeTree()
ORDER BY protocolName
AS
SELECT
    protocolName,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY protocolName;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceIPv4Address_agg
ENGINE = SummingMergeTree()
ORDER BY sourceIPv4Address
AS
SELECT
    sourceIPv4Address,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY sourceIPv4Address;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_destinationIPv4Address_agg
ENGINE = SummingMergeTree()
ORDER BY destinationIPv4Address
AS
SELECT
    destinationIPv4Address,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY destinationIPv4Address;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceTransportPort_agg
ENGINE = SummingMergeTree()
ORDER BY sourceTransportPort
AS
SELECT
    sourceTransportPort,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY sourceTransportPort;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_destinationTransportPort_agg
ENGINE = SummingMergeTree()
ORDER BY destinationTransportPort
AS
SELECT
    destinationTransportPort,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY destinationTransportPort;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_octetDeltaCount_agg
ENGINE = SummingMergeTree()
ORDER BY octetDeltaCount
AS
SELECT
    octetDeltaCount,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY octetDeltaCount;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_packetDeltaCount_agg
ENGINE = SummingMergeTree()
ORDER BY packetDeltaCount
AS
SELECT
    packetDeltaCount,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY packetDeltaCount;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flowStartMilliseconds_agg
ENGINE = SummingMergeTree()
ORDER BY flowStartMilliseconds
AS
SELECT
    flowStartMilliseconds,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY flowStartMilliseconds;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flowEndMilliseconds_agg
ENGINE = SummingMergeTree()
ORDER BY flowEndMilliseconds
AS
SELECT
    flowEndMilliseconds,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY flowEndMilliseconds;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_mac_source_agg
ENGINE = SummingMergeTree()
ORDER BY mac_source
AS
SELECT
    mac_source,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY mac_source;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_mac_destination_agg
ENGINE = SummingMergeTree()
ORDER BY mac_destination
AS
SELECT
    mac_destination,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY mac_destination;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_application_name_agg
ENGINE = SummingMergeTree()
ORDER BY application_name
AS
SELECT
    application_name,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY application_name;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_http_url_agg
ENGINE = SummingMergeTree()
ORDER BY http_url
AS
SELECT
    http_url,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY http_url;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_https_url_certificate_agg
ENGINE = SummingMergeTree()
ORDER BY https_url_certificate
AS
SELECT
    https_url_certificate,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY https_url_certificate;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_datalink_vlan_agg
ENGINE = SummingMergeTree()
ORDER BY datalink_vlan
AS
SELECT
    datalink_vlan,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY datalink_vlan;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_bytes_accumulated_agg
ENGINE = SummingMergeTree()
ORDER BY bytes_accumulated
AS
SELECT
    bytes_accumulated,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY bytes_accumulated;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_retransmits_agg
ENGINE = SummingMergeTree()
ORDER BY tcp_retransmits
AS
SELECT
    tcp_retransmits,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY tcp_retransmits;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_rst_agg
ENGINE = SummingMergeTree()
ORDER BY tcp_rst
AS
SELECT
    tcp_rst,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY tcp_rst;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_fin_agg
ENGINE = SummingMergeTree()
ORDER BY tcp_fin
AS
SELECT
    tcp_fin,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY tcp_fin;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_bytes_per_packet_agg
ENGINE = SummingMergeTree()
ORDER BY bytes_per_packet
AS
SELECT
    bytes_per_packet,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY bytes_per_packet;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_duration_ms_agg
ENGINE = SummingMergeTree()
ORDER BY flow_duration_ms
AS
SELECT
    flow_duration_ms,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY flow_duration_ms;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_direction_agg
ENGINE = SummingMergeTree()
ORDER BY flow_direction
AS
SELECT
    flow_direction,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY flow_direction;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_profile_name_agg
ENGINE = SummingMergeTree()
ORDER BY profile_name
AS
SELECT
    profile_name,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY profile_name;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_asn_number_agg
ENGINE = SummingMergeTree()
ORDER BY asn_number
AS
SELECT
    asn_number,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY asn_number;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_asn_organization_agg
ENGINE = SummingMergeTree()
ORDER BY asn_organization
AS
SELECT
    asn_organization,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY asn_organization;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_city_name_agg
ENGINE = SummingMergeTree()
ORDER BY city_name
AS
SELECT
    city_name,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY city_name;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_country_name_agg
ENGINE = SummingMergeTree()
ORDER BY country_name
AS
SELECT
    country_name,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY country_name;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_latitude_agg
ENGINE = SummingMergeTree()
ORDER BY latitude
AS
SELECT
    latitude,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY latitude;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_longitude_agg
ENGINE = SummingMergeTree()
ORDER BY longitude
AS
SELECT
    longitude,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY longitude;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_iso_code_agg
ENGINE = SummingMergeTree()
ORDER BY iso_code
AS
SELECT
    iso_code,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY iso_code;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_application_name_flow_start_time_agg
ENGINE = SummingMergeTree()
ORDER BY (application_name, flow_start_time)
AS
SELECT
    application_name,
    flow_start_time,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY application_name, flow_start_time;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceIPv4Address_destinationIPv4Address_flow_start_time_agg
ENGINE = SummingMergeTree()
ORDER BY (sourceIPv4Address, destinationIPv4Address, flow_start_time)
AS
SELECT
    sourceIPv4Address,
    destinationIPv4Address,
    flow_start_time,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY sourceIPv4Address, destinationIPv4Address, flow_start_time;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sourceTransportPort_destinationTransportPort_flow_start_time_agg
ENGINE = SummingMergeTree()
ORDER BY (sourceTransportPort, destinationTransportPort, flow_start_time)
AS
SELECT
    sourceTransportPort,
    destinationTransportPort,
    flow_start_time,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY sourceTransportPort, destinationTransportPort, flow_start_time;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_tcp_rst_flow_start_time_agg
ENGINE = SummingMergeTree()
ORDER BY (tcp_rst, flow_start_time)
AS
SELECT
    tcp_rst,
    flow_start_time,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY tcp_rst, flow_start_time;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_protocolIdentifier_bytes_accumulated_agg
ENGINE = SummingMergeTree()
ORDER BY (protocolIdentifier, bytes_accumulated)
AS
SELECT
    protocolIdentifier,
    bytes_accumulated,
    sum(octetDeltaCount) AS total_bytes,
    sum(packetDeltaCount) AS total_packets,
    count() AS flow_count
FROM flows_raw
GROUP BY protocolIdentifier, bytes_accumulated;