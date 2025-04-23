Enhanced IPFIX Data Simulator
Generates realistic network flow data with extended fields and sends directly to Kafka
"""

import ipaddress
import json
import random
import time
import threading
import logging
import argparse
import yaml
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import numpy as np
from scipy import stats
from faker import Faker
from kafka import KafkaProducer

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('enhanced-ipfix-simulator')

# Initialize Faker for generating realistic data
fake = Faker()
(.venv) [root@cheux37oracleos7 ipfixgen]#
def random_mac():
    """Generate a random MAC address"""
    return ':'.join([f'{random.randint(0, 255):02x}' for _ in range(6)])

class TrafficProfile:
    """Defines a network traffic pattern with extended fields"""
    def __init__(self, config: Dict[str, Any]):
        self.name = config['name']
        self.source_networks = config['source_networks']
        self.destination_networks = config['destination_networks']
        self.protocols = config['protocols']
        self.port_ranges = config['port_ranges']
        self.vlans = config.get('vlans', {})
        self.applications = config.get('applications', ['http', 'https', 'smtp', 'dns'])
        self.urls = config.get('urls', [
            'example.com', 'api.example.com', 'media.example.com',
            'download.example.com', 'static.example.com'
        ])

        # Configure distributions
        self.flow_size_distribution = config.get('flow_size_distribution', {
            'type': 'lognormal',
            'mean': 7.5,
            'sigma': 1.5
        })
        self.packet_size_distribution = config.get('packet_size_distribution', {
            'type': 'normal',
            'mean': 800,
            'sigma': 400,
            'min': 64,
            'max': 1500
        })
        self.flow_duration_distribution = config.get('flow_duration_distribution', {
            'type': 'lognormal',
            'mean': 8.0,
            'sigma': 1.2
        })
        self.time_pattern = config.get('time_pattern', {
            'type': 'constant',
            'flows_per_minute': 100
        })

        # TCP error rates
        self.retransmit_probability = config.get('retransmit_probability', 0.05)
        self.rst_probability = config.get('rst_probability', 0.02)
        self.fin_probability = config.get('fin_probability', 0.8)

    def generate_ip(self, network: str) -> str:
        """Generate a random IP within the specified network"""
        net = ipaddress.IPv4Network(network)
        random_int = random.randint(int(net.network_address), int(net.broadcast_address))
        return str(ipaddress.IPv4Address(random_int))

    def generate_flow(self, timestamp: int) -> Dict[str, Any]:
        """Generate a random flow with extended fields based on this profile"""
        # Select random source and destination networks
        source_network = random.choice(self.source_networks)
        destination_network = random.choice(self.destination_networks)
        subnet = source_network.split('/')[0].rsplit('.', 1)[0] + '.0'

        # Generate random IPs
        source_ip = self.generate_ip(source_network)
        destination_ip = self.generate_ip(destination_network)

        # Generate MAC addresses
        source_mac = random_mac()
        destination_mac = random_mac()

        # Generate VLAN
        vlan = random.choice(self.vlans.get(subnet, [1]))

        # Select protocol
        protocol = random.choice(self.protocols)
        protocol_name = {6: 'TCP', 17: 'UDP', 1: 'ICMP', 132: 'sctp'}.get(protocol, str(protocol))

        # Generate ports based on protocol
        if protocol == 6 or protocol == 17 or protocol == 132:  # TCP or UDP
            source_port_range = self.port_ranges['source']
            dest_port_range = self.port_ranges['destination']
            source_port = random.randint(source_port_range[0], source_port_range[1])
            destination_port = random.choice(dest_port_range)
        else:
            source_port = 0
            destination_port = 0

        # Determine application based on destination port
        application_name = "unknown"
        if destination_port == 80:
            application_name = "http"
        elif destination_port == 443:
            application_name = "https"
        elif destination_port == 25 or destination_port == 587:
            application_name = "smtp"
        elif destination_port == 53:
            application_name = "dns"
        elif destination_port == 22:
            application_name = "ssh"
        elif destination_port == 8080:
            application_name = "quic"
        elif destination_port == 8443:
            application_name = "http2"
        elif destination_port == 8000:
            application_name = "graphql"
        elif destination_port == 3000:
            application_name = "rest"
        elif destination_port == 3306:
            application_name = "mysql"
        elif destination_port == 5432:
            application_name = "postgres"
        elif destination_port == 1521:
            application_name = "oracle"
        elif destination_port == 1433:
            application_name = "mssql"
        elif destination_port == 27017:
            application_name = "mongodb"
        elif destination_port == 6379:
            application_name = "redis"
        elif destination_port == 143:
            application_name = "imap"
        elif destination_port == 110:
            application_name = "pop3"
        elif destination_port == 636:
            application_name = "ldaps"
        elif destination_port == 587:
            application_name = "submission"
        elif destination_port == 465:
            application_name = "smtps"
        elif destination_port == 873:
            application_name = "rsync"
        elif destination_port == 445:
            application_name = "smb"
        elif destination_port == 2049:
            application_name = "nfs"
        elif 5000 <= destination_port <= 5100:
            application_name = "custom-app"

        # Generate URL if it's HTTP/HTTPS
        url = None
        if application_name in ["http", "https"]:
            protocol_prefix = "https://" if application_name == "https" else "http://"
            base_url = random.choice(self.urls)
            path_components = [fake.word() for _ in range(random.randint(0, 3))]
            path = '/'.join(path_components)
            url = f"{protocol_prefix}{base_url}/{path}"

            # Add query parameters occasionally
            if random.random() < 0.3:
                num_params = random.randint(1, 3)
                params = '&'.join([f"{fake.word()}={fake.word()}" for _ in range(num_params)])
                url += f"?{params}"

        # Generate certificate hash for HTTPS
        https_cert = fake.sha256() if application_name == "https" else None

        # Generate flow size (bytes)
        if self.flow_size_distribution['type'] == 'lognormal':
            flow_size = int(np.random.lognormal(
                self.flow_size_distribution['mean'],
                self.flow_size_distribution['sigma']
            ))
        else:
            flow_size = random.randint(1000, 100000)

        # Generate packet count
        avg_packet_size = min(
            max(
                int(np.random.normal(
                    self.packet_size_distribution['mean'],
                    self.packet_size_distribution['sigma']
                )),
                self.packet_size_distribution['min']
            ),
            self.packet_size_distribution['max']
        )
        packet_count = max(1, int(flow_size / avg_packet_size))

        # Generate flow duration
        if self.flow_duration_distribution['type'] == 'lognormal':
            duration_ms = int(np.random.lognormal(
                self.flow_duration_distribution['mean'],
                self.flow_duration_distribution['sigma']
            ))
        else:
            duration_ms = random.randint(1, 60000)

        # Calculate flow start and end times
        start_time = datetime.fromtimestamp(timestamp)
        end_time = start_time + timedelta(milliseconds=duration_ms)

        # Generate TCP flags if applicable
        tcp_retransmits = 0
        tcp_rst = 0
        tcp_fin = 0

        if protocol == 6:  # TCP
            # Generate retransmits
            if random.random() < self.retransmit_probability:
                tcp_retransmits = random.randint(1, 5)

            # RST flag
            if random.random() < self.rst_probability:
                tcp_rst = 1

            # FIN flag (if not RST)
            if tcp_rst == 0 and random.random() < self.fin_probability:
                tcp_fin = 1

        # Create enhanced flow record
        flow = {
            # Standard IPFIX fields
            'sourceIPv4Address': source_ip,
            'destinationIPv4Address': destination_ip,
            'protocolIdentifier': protocol,
            'protocolName': protocol_name,
            'sourceTransportPort': source_port,
            'destinationTransportPort': destination_port,
            'octetDeltaCount': flow_size,
            'packetDeltaCount': packet_count,
            'flowStartMilliseconds': int(start_time.timestamp() * 1000),
            'flowEndMilliseconds': int(end_time.timestamp() * 1000),

            # Extended fields
            'mac_source': source_mac,
            'mac_destination': destination_mac,
            'transport_source_port': source_port,
            'transport_destination_port': destination_port,
            'application_name': application_name,
            'http_url': url,
            'https_url_certificate': https_cert,
            'datalink_vlan': vlan,
            'flow_start_time': start_time.isoformat(timespec='microseconds'),
            'flow_end_time': end_time.isoformat(timespec='microseconds'),
            'bytes_accumulated': flow_size,
            'tcp_retransmits': tcp_retransmits,
            'tcp_rst': tcp_rst,
            'tcp_fin': tcp_fin,

            # Additional fields for analysis
            'bytes_per_packet': flow_size / packet_count if packet_count > 0 else 0,
            'flow_duration_ms': duration_ms,
            'flow_direction': 'outbound' if source_network in self.source_networks else 'inbound',
            'profile_name': self.name
        }

        return flow

    def get_flow_rate(self, current_time: datetime) -> int:
        """Calculate flow rate based on time pattern"""
        base_rate = self.time_pattern.get('flows_per_minute', 100)

        # Apply pattern modifiers
        if self.time_pattern['type'] == 'constant':
            return base_rate

        elif self.time_pattern['type'] == 'diurnal':
            # Daily pattern with peak during working hours
            hour = current_time.hour
            # Simple bell curve centered at noon
            hour_factor = 0.5 + 0.5 * np.exp(-0.5 * ((hour - 12) / 4) ** 2)
            return int(base_rate * hour_factor)

        elif self.time_pattern['type'] == 'weekly':
            # Weekly pattern with weekdays having more traffic
            day_of_week = current_time.weekday()  # 0=Monday, 6=Sunday
            # Weekend factor
            if day_of_week >= 5:  # Weekend
                day_factor = 0.5
            else:  # Weekday
                day_factor = 1.0

            # Apply hourly pattern on top
            hour = current_time.hour
            hour_factor = 0.5 + 0.5 * np.exp(-0.5 * ((hour - 12) / 4) ** 2)

            return int(base_rate * day_factor * hour_factor)

        else:
            return base_rate


class AnomalyGenerator:
    """Generates network traffic anomalies with extended fields"""
    def __init__(self, config: Dict[str, Any]):
        self.anomalies = config.get('anomalies', [])

    def get_active_anomalies(self, current_time: datetime) -> List[Dict[str, Any]]:
        """Return list of anomalies that should be active at the current time"""
        active = []

        for anomaly in self.anomalies:
            # Check if anomaly should be triggered
            start_time = datetime.fromisoformat(anomaly['start_time'])
            end_time = datetime.fromisoformat(anomaly['end_time'])

            if start_time <= current_time <= end_time:
                active.append(anomaly)

        return active

    def apply_anomalies(self, flows: List[Dict[str, Any]],
                         active_anomalies: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Apply active anomalies to a batch of flows"""
        if not active_anomalies:
            return flows

        modified_flows = flows.copy()

        for anomaly in active_anomalies:
            anomaly_type = anomaly['type']

            if anomaly_type == 'volumetric_ddos':
                # Volumetric DDoS attack - add many flows to a single destination
                target_ip = anomaly['target_ip']
                attack_flow_count = anomaly['flow_count']

                for _ in range(attack_flow_count):
                    # Create attack flow
                    current_time = datetime.now()
                    start_time = current_time
                    end_time = start_time + timedelta(milliseconds=random.randint(1, 100))

                    attack_flow = {
                        'sourceIPv4Address': f"10.{random.randint(1, 254)}.{random.randint(1, 254)}.{random.randint(1, 254)}",
                        'destinationIPv4Address': target_ip,
                        'protocolIdentifier': random.choice([6, 17]),  # TCP or UDP
                        'protocolName': 'TCP' if random.choice([6, 17]) == 6 else 'UDP',
                        'sourceTransportPort': random.randint(1024, 65535),
                        'destinationTransportPort': anomaly.get('target_port', 80),
                        'octetDeltaCount': random.randint(60, 1500),
                        'packetDeltaCount': 1,
                        'flowStartMilliseconds': int(start_time.timestamp() * 1000),
                        'flowEndMilliseconds': int(end_time.timestamp() * 1000),

                        # Extended fields
                        'mac_source': random_mac(),
                        'mac_destination': random_mac(),
                        'transport_source_port': random.randint(1024, 65535),
                        'transport_destination_port': anomaly.get('target_port', 80),
                        'application_name': 'http' if anomaly.get('target_port', 80) == 80 else 'unknown',
                        'http_url': 'http://example.com/' if anomaly.get('target_port', 80) == 80 else None,
                        'https_url_certificate': None,
                        'datalink_vlan': random.randint(1, 10),
                        'flow_start_time': start_time.isoformat(),
                        'flow_end_time': end_time.isoformat(),
                        'bytes_accumulated': random.randint(60, 1500),
                        'tcp_retransmits': 0,
                        'tcp_rst': 0,
                        'tcp_fin': 0,

                        'anomaly': True,
                        'anomaly_type': 'volumetric_ddos'
                    }
                    modified_flows.append(attack_flow)

            elif anomaly_type == 'port_scan':
                # Port scan - single source scanning multiple ports on target
                source_ip = anomaly['source_ip']
                target_ip = anomaly['target_ip']
                port_count = anomaly['port_count']

                # Generate port scan flows
                current_time = datetime.now()

                for i in range(port_count):
                    start_time = current_time + timedelta(milliseconds=i*10)
                    end_time = start_time + timedelta(milliseconds=random.randint(1, 10))

                    scan_flow = {
                        'sourceIPv4Address': source_ip,
                        'destinationIPv4Address': target_ip,
                        'protocolIdentifier': 6,  # TCP
                        'protocolName': 'TCP',
                        'sourceTransportPort': random.randint(1024, 65535),
                        'destinationTransportPort': i + 1,  # Sequential ports
                        'octetDeltaCount': random.randint(40, 100),
                        'packetDeltaCount': 1,
                        'flowStartMilliseconds': int(start_time.timestamp() * 1000),
                        'flowEndMilliseconds': int(end_time.timestamp() * 1000),

                        # Extended fields
                        'mac_source': random_mac(),
                        'mac_destination': random_mac(),
                        'transport_source_port': random.randint(1024, 65535),
                        'transport_destination_port': i + 1,
                        'application_name': 'unknown',
                        'http_url': None,
                        'https_url_certificate': None,
                        'datalink_vlan': random.randint(1, 10),
                        'flow_start_time': start_time.isoformat(),
                        'flow_end_time': end_time.isoformat(),
                        'bytes_accumulated': random.randint(40, 100),
                        'tcp_retransmits': 0,
                        'tcp_rst': random.choice([0, 1]),  # Sometimes RST
                        'tcp_fin': 0,

                        'anomaly': True,
                        'anomaly_type': 'port_scan'
                    }
                    modified_flows.append(scan_flow)

            elif anomaly_type == 'data_exfiltration':
                # Data exfiltration - large outbound flows to unusual destination
                source_ip = anomaly['source_ip']
                destination_ip = anomaly['destination_ip']

                # Create large outbound flow
                current_time = datetime.now()
                start_time = current_time
                duration_ms = random.randint(10000, 300000)
                end_time = start_time + timedelta(milliseconds=duration_ms)

                exfil_bytes = random.randint(10000000, 100000000)  # 10MB-100MB

                exfil_flow = {
                    'sourceIPv4Address': source_ip,
                    'destinationIPv4Address': destination_ip,
                    'protocolIdentifier': 6,  # TCP
                    'protocolName': 'TCP',
                    'sourceTransportPort': random.randint(1024, 65535),
                    'destinationTransportPort': random.choice([22, 443, 8080]),
                    'octetDeltaCount': exfil_bytes,
                    'packetDeltaCount': int(exfil_bytes / 1400),  # Approx MTU size
                    'flowStartMilliseconds': int(start_time.timestamp() * 1000),
                    'flowEndMilliseconds': int(end_time.timestamp() * 1000),

                    # Extended fields
                    'mac_source': random_mac(),
                    'mac_destination': random_mac(),
                    'transport_source_port': random.randint(1024, 65535),
                    'transport_destination_port': random.choice([22, 443, 8080]),
                    'application_name': 'https' if random.choice([22, 443, 8080]) == 443 else 'ssh' if random.choice([22, 443, 8080]) == 22 else 'http-alt',
                    'http_url': None,
                    'https_url_certificate': fake.sha256() if random.choice([22, 443, 8080]) == 443 else None,
                    'datalink_vlan': random.randint(1, 10),
                    'flow_start_time': start_time.isoformat(),
                    'flow_end_time': end_time.isoformat(),
                    'bytes_accumulated': exfil_bytes,
                    'tcp_retransmits': random.randint(0, 3),
                    'tcp_rst': 0,
                    'tcp_fin': 1,

                    'anomaly': True,
                    'anomaly_type': 'data_exfiltration'
                }
                modified_flows.append(exfil_flow)

            elif anomaly_type == 'unusual_protocol':
                # Unusual protocol usage
                source_ip = anomaly['source_ip']
                destination_ip = anomaly['destination_ip']
                protocol = anomaly['protocol']

                current_time = datetime.now()
                start_time = current_time
                duration_ms = random.randint(100, 10000)
                end_time = start_time + timedelta(milliseconds=duration_ms)

                # Create unusual protocol flow
                unusual_flow = {
                    'sourceIPv4Address': source_ip,
                    'destinationIPv4Address': destination_ip,
                    'protocolIdentifier': protocol,
                    'protocolName': str(protocol),
                    'sourceTransportPort': random.randint(1024, 65535),
                    'destinationTransportPort': random.randint(1, 1024),
                    'octetDeltaCount': random.randint(100, 10000),
                    'packetDeltaCount': random.randint(1, 100),
                    'flowStartMilliseconds': int(start_time.timestamp() * 1000),
                    'flowEndMilliseconds': int(end_time.timestamp() * 1000),

                    # Extended fields
                    'mac_source': random_mac(),
                    'mac_destination': random_mac(),
                    'transport_source_port': random.randint(1024, 65535),
                    'transport_destination_port': random.randint(1, 1024),
                    'application_name': 'unknown',
                    'http_url': None,
                    'https_url_certificate': None,
                    'datalink_vlan': random.randint(1, 10),
                    'flow_start_time': start_time.isoformat(),
                    'flow_end_time': end_time.isoformat(),
                    'bytes_accumulated': random.randint(100, 10000),
                    'tcp_retransmits': 0,
                    'tcp_rst': 0,
                    'tcp_fin': 0,

                    'anomaly': True,
                    'anomaly_type': 'unusual_protocol'
                }
                modified_flows.append(unusual_flow)

            elif anomaly_type == 'connection_failure':
                # Connection failures with retransmits and RST flags
                source_network = anomaly.get('source_network', '192.168.0.0/16')
                destination_ip = anomaly['destination_ip']
                port = anomaly.get('port', 443)
                flow_count = anomaly.get('flow_count', 50)

                for _ in range(flow_count):
                    # Generate source IP from the specified network
                    net = ipaddress.IPv4Network(source_network)
                    random_int = random.randint(int(net.network_address), int(net.broadcast_address))
                    source_ip = str(ipaddress.IPv4Address(random_int))

                    current_time = datetime.now()
                    start_time = current_time
                    duration_ms = random.randint(500, 5000)  # Longer due to retransmits
                    end_time = start_time + timedelta(milliseconds=duration_ms)

                    # Connection failure flow - high retransmits, eventual RST
                    failure_flow = {
                        'sourceIPv4Address': source_ip,
                        'destinationIPv4Address': destination_ip,
                        'protocolIdentifier': 6,  # TCP
                        'protocolName': 'TCP',
                        'sourceTransportPort': random.randint(1024, 65535),
                        'destinationTransportPort': port,
                        'octetDeltaCount': random.randint(200, 2000),
                        'packetDeltaCount': random.randint(5, 20),
                        'flowStartMilliseconds': int(start_time.timestamp() * 1000),
                        'flowEndMilliseconds': int(end_time.timestamp() * 1000),

                        # Extended fields
                        'mac_source': random_mac(),
                        'mac_destination': random_mac(),
                        'transport_source_port': random.randint(1024, 65535),
                        'transport_destination_port': port,
                        'application_name': 'https' if port == 443 else 'http' if port == 80 else 'unknown',
                        'http_url': None,
                        'https_url_certificate': None,
                        'datalink_vlan': random.randint(1, 10),
                        'flow_start_time': start_time.isoformat(),
                        'flow_end_time': end_time.isoformat(),
                        'bytes_accumulated': random.randint(200, 2000),
                        'tcp_retransmits': random.randint(3, 10),  # High retransmit count
                        'tcp_rst': 1,  # Connection reset
                        'tcp_fin': 0,  # No normal termination

                        'anomaly': True,
                        'anomaly_type': 'connection_failure'
                    }
                    modified_flows.append(failure_flow)

            elif anomaly_type == 'slow_response':
                # Slow application response times
                source_ip = anomaly.get('source_ip', '192.168.1.100')
                destination_ip = anomaly['destination_ip']
                port = anomaly.get('port', 80)
                flow_count = anomaly.get('flow_count', 30)

                for _ in range(flow_count):
                    current_time = datetime.now()
                    start_time = current_time

                    # Unusually long duration for the flow type
                    if port == 80 or port == 443:
                        duration_ms = random.randint(5000, 30000)  # Very slow web response
                    else:
                        duration_ms = random.randint(2000, 10000)

                    end_time = start_time + timedelta(milliseconds=duration_ms)

                    # Generate relatively normal-sized flow but with long duration
                    slow_flow = {
                        'sourceIPv4Address': source_ip,
                        'destinationIPv4Address': destination_ip,
                        'protocolIdentifier': 6,  # TCP
                        'protocolName': 'TCP',
                        'sourceTransportPort': random.randint(1024, 65535),
                        'destinationTransportPort': port,
                        'octetDeltaCount': random.randint(1000, 50000),  # Normal size
                        'packetDeltaCount': random.randint(10, 100),
                        'flowStartMilliseconds': int(start_time.timestamp() * 1000),
                        'flowEndMilliseconds': int(end_time.timestamp() * 1000),

                        # Extended fields
                        'mac_source': random_mac(),
                        'mac_destination': random_mac(),
                        'transport_source_port': random.randint(1024, 65535),
                        'transport_destination_port': port,
                        'application_name': 'https' if port == 443 else 'http' if port == 80 else 'unknown',
                        'http_url': f"http://{destination_ip}/resource" if port == 80 else None,
                        'https_url_certificate': fake.sha256() if port == 443 else None,
                        'datalink_vlan': random.randint(1, 10),
                        'flow_start_time': start_time.isoformat(),
                        'flow_end_time': end_time.isoformat(),
                        'bytes_accumulated': random.randint(1000, 50000),
                        'tcp_retransmits': random.randint(0, 2),
                        'tcp_rst': 0,
                        'tcp_fin': 1,

                        'anomaly': True,
                        'anomaly_type': 'slow_response',
                        'response_time_ms': duration_ms
                    }
                    modified_flows.append(slow_flow)

        return modified_flows


class KafkaFlowProducer:
    """Sends IPFIX flow data to Kafka"""
    def __init__(self, bootstrap_servers: str, topic: str):
        self.bootstrap_servers = bootstrap_servers
        self.topic = topic
        self.producer = None
        self.connect()

    def connect(self):
        """Establish connection to Kafka"""
        try:
            self.producer = KafkaProducer(
                bootstrap_servers=self.bootstrap_servers,
                value_serializer=lambda x: json.dumps(x).encode('utf-8')
            )
            logger.info(f"Connected to Kafka at {self.bootstrap_servers}")
        except Exception as e:
            logger.error(f"Failed to connect to Kafka: {e}")
            self.producer = None

    def send_flow(self, flow: Dict[str, Any]):
        """Send a single flow to Kafka"""
        if not self.producer:
            logger.warning("Kafka producer not available, skipping message")
            return

        try:
            # Send flow data to Kafka
            self.producer.send(self.topic, flow)
        except Exception as e:
            logger.error(f"Error sending to Kafka: {e}")
            # Try to reconnect
            self.connect()

    def send_flows(self, flows: List[Dict[str, Any]]):
        """Send multiple flows to Kafka"""
        for flow in flows:
            self.send_flow(flow)

    def close(self):
        """Close the Kafka producer"""
        if self.producer:
            self.producer.flush()
            self.producer.close()
            logger.info("Kafka producer closed")


class IPFIXSimulator:
    """Main simulator class that generates and sends flow data"""
    def __init__(self, config_file: str):
        # Load configuration
        with open(config_file, 'r') as f:
            self.config = yaml.safe_load(f)

        # Set up Kafka producer
        kafka_config = self.config.get('kafka', {})
        bootstrap_servers = kafka_config.get('bootstrap_servers', '127.0.0.1:9093')
        print(f"Using Kafka bootstrap servers: {bootstrap_servers}")
        topic = kafka_config.get('topic', 'flow-data')
        self.kafka_producer = KafkaFlowProducer(bootstrap_servers, topic)

        # Set up traffic profiles
        self.profiles = []
        for profile_config in self.config['traffic_profiles']:
            self.profiles.append(TrafficProfile(profile_config))

        # Set up anomaly generator
        self.anomaly_generator = AnomalyGenerator(self.config.get('anomalies', {}))

# Simulation parameters
        self.simulation_speed = self.config.get('simulation_speed', 1.0)
        self.start_time = datetime.fromisoformat(
            self.config.get('start_time', datetime.now().isoformat())
        )
        self.end_time = datetime.fromisoformat(
            self.config.get('end_time', (datetime.now() + timedelta(hours=1)).isoformat())
        )
        self.current_time = self.start_time
        self.running = False

    def start(self):
        """Start the simulation"""
        logger.info(f"Starting IPFIX simulation from {self.start_time} to {self.end_time}")
        logger.info(f"Exporting to Kafka: {self.kafka_producer.bootstrap_servers}, topic: {self.kafka_producer.topic}")

        self.running = True
        self.run_simulation()

    def stop(self):
        """Stop the simulation"""
        self.running = False
        self.kafka_producer.close()
        logger.info("Simulation stopped")

    def run_simulation(self):
        """Run the simulation loop"""
        # Main simulation loop
        while self.running and self.current_time <= self.end_time:
            # Get active anomalies for current time
            active_anomalies = self.anomaly_generator.get_active_anomalies(self.current_time)
            if active_anomalies:
                logger.info(f"Active anomalies at {self.current_time}: {len(active_anomalies)}")
                for anomaly in active_anomalies:
                    logger.info(f"  - {anomaly['type']}")

            # Generate flows for each profile
            all_flows = []
            for profile in self.profiles:
                # Calculate how many flows to generate
                flow_rate = profile.get_flow_rate(self.current_time)
                num_flows = max(1, int(flow_rate / 60))  # per second

                # Generate flows
                profile_flows = []
                for _ in range(num_flows):
                    flow = profile.generate_flow(int(self.current_time.timestamp()))
                    profile_flows.append(flow)

                logger.debug(f"Generated {len(profile_flows)} flows for profile {profile.name}")
                all_flows.extend(profile_flows)

            # Apply anomalies
            all_flows = self.anomaly_generator.apply_anomalies(all_flows, active_anomalies)

            # Send flows to Kafka
            self.kafka_producer.send_flows(all_flows)
            logger.debug(f"Sent {len(all_flows)} flows to Kafka")

            # Update simulation time
            time_step = timedelta(seconds=1 * self.simulation_speed)
            self.current_time += time_step

            # Progress update
            if self.current_time.second % 10 == 0:
                progress = (self.current_time - self.start_time) / (self.end_time - self.start_time) * 100
                logger.info(f"Simulation progress: {progress:.1f}% - Current time: {self.current_time}")
                logger.info(f"Generated {len(all_flows)} flows in this iteration")

            # Sleep to control simulation speed
            time.sleep(0.1 / self.simulation_speed)


def main():
    parser = argparse.ArgumentParser(description='Enhanced IPFIX Traffic Simulator')
    parser.add_argument('--config', '-c', required=True, help='Configuration file path')
    parser.add_argument('--log-level', '-l', default='INFO',
                      choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
                      help='Logging level')
    args = parser.parse_args()

    # Set log level
    logging.getLogger().setLevel(getattr(logging, args.log_level))

    simulator = IPFIXSimulator(args.config)

    try:
        simulator.start()
    except KeyboardInterrupt:
        logger.info("Simulation interrupted")
        simulator.stop()
    except Exception as e:
        logger.error(f"Simulation error: {e}", exc_info=True)
        simulator.stop()


if __name__ == "__main__":
    main()