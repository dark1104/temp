#!/bin/bash
set -e

clickhouse client -n <<-EOSQL

    CREATE DATABASE IF NOT EXISTS dictionaries;

    CREATE DICTIONARY IF NOT EXISTS dictionaries.protocols (
        proto UInt8,
        name String,
        description String
    )
    PRIMARY KEY proto
    LAYOUT(FLAT())
    SOURCE (FILE(path '/var/lib/clickhouse/user_files/protocols.csv' format 'CSVWithNames'))
    LIFETIME(3600);

    CREATE TABLE IF NOT EXISTS flows_raw
    (
        date Date DEFAULT toDate(flow_start_time),
        time_inserted_ns DateTime,
        time_received_ns DateTime,
        flow_start_time DateTime64(9),
        flow_end_time DateTime64(9),
        protocolIdentifier UInt32,
        protocolName String,
        sourceIPv4Address String,
        destinationIPv4Address String,
        sourceTransportPort UInt16,
        destinationTransportPort UInt16,
        octetDeltaCount UInt64,
        packetDeltaCount UInt64,
        flowStartMilliseconds UInt64,
        flowEndMilliseconds UInt64,
        mac_source String,
        mac_destination String,
        application_name String,
        http_url String,
        https_url_certificate String,
        datalink_vlan UInt32,
        bytes_accumulated UInt64,
        tcp_retransmits UInt32,
        tcp_rst UInt32,
        tcp_fin UInt32,
        bytes_per_packet Float64,
        flow_duration_ms UInt64,
        flow_direction String,
        profile_name String,
	asn_number UInt64,
	asn_organization String,
	city_name String,
	country_name String,
	latitude Float64,
	longitude Float64,
	iso_code Uint64
    ) ENGINE = MergeTree()
    PARTITION BY toDate(flow_start_time)
    ORDER BY flow_start_time;

    CREATE MATERIALIZED VIEW IF NOT EXISTS mv_app_metrics
    ENGINE = AggregatingMergeTree()
    ORDER BY application_name
    AS
    SELECT
       application_name,
       sum(octetDeltaCount) AS total_bytes,
       sum(packetDeltaCount) AS total_packets,
       sum(tcp_retransmits) AS total_retransmits,
       sum(tcp_rst) AS total_rst,
       avg(bytes_per_packet) AS avg_bytes_per_packet
    FROM flows_raw
    GROUP BY application_name;

    CREATE MATERIALIZED VIEW IF NOT EXISTS mv_vlan_traffic
    ENGINE = SummingMergeTree()
    ORDER BY datalink_vlan
    AS
    SELECT
        datalink_vlan,
        sum(octetDeltaCount) AS total_bytes,
        sum(packetDeltaCount) AS total_packets
    FROM flows_raw
    GROUP BY datalink_vlan;

    CREATE MATERIALIZED VIEW IF NOT EXISTS mv_flow_direction
    ENGINE = SummingMergeTree()
    ORDER BY flow_direction
    AS
    SELECT
        flow_direction,
        sum(octetDeltaCount) AS total_bytes,
        count() AS total_flows
    FROM flows_raw
    GROUP BY flow_direction;

    CREATE MATERIALIZED VIEW IF NOT EXISTS mv_vlan_traffic
    ENGINE = SummingMergeTree()
    ORDER BY datalink_vlan
    AS
    SELECT
        datalink_vlan,
        sum(octetDeltaCount) AS total_bytes,
        sum(packetDeltaCount) AS total_packets
    FROM flows_raw
    GROUP BY datalink_vlan;

    CREATE TABLE IF NOT EXISTS flows_5m
    (
        date Date,
        timeslot DateTime,
        bytes UInt64,
        count UInt64,
        total_bytes UInt64,
        total_count UInt64
    ) ENGINE = SummingMergeTree()
    PARTITION BY date
    ORDER BY (date, timeslot);

    CREATE MATERIALIZED VIEW IF NOT EXISTS flows_5m_view TO flows_5m
    AS
    SELECT
        toDate(flow_start_time) AS date,
        toStartOfFiveMinute(flow_start_time) AS timeslot,
        sum(bytes_accumulated) AS bytes,
        count() AS count,
        sum(bytes_accumulated) AS total_bytes,
        count() AS total_count
    FROM flows_raw
    GROUP BY date, timeslot;

EOSQL