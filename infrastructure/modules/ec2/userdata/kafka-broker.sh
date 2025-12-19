#!/bin/bash
set -e

# Update system
yum update -y

# Install Java
yum install -y java-11-amazon-corretto

# Format and mount EBS volume for Kafka data
mkfs -t ext4 /dev/sdf
mkdir -p /var/lib/kafka
mount /dev/sdf /var/lib/kafka
echo '/dev/sdf /var/lib/kafka ext4 defaults,nofail 0 2' >> /etc/fstab

# Download and install Kafka
KAFKA_VERSION="3.6.0"
SCALA_VERSION="2.13"
cd /opt
wget https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz
tar -xzf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz
ln -s kafka_$SCALA_VERSION-$KAFKA_VERSION kafka
rm kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

# Create Kafka user
useradd kafka -m
chown -R kafka:kafka /opt/kafka*
chown -R kafka:kafka /var/lib/kafka

# Configure Kafka
cat > /opt/kafka/config/server.properties <<EOF
broker.id=${broker_id}
listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://\$(ec2-metadata --local-ipv4 | cut -d ' ' -f 2):9092
log.dirs=/var/lib/kafka/logs
num.partitions=3
default.replication.factor=2
min.insync.replicas=2
log.retention.hours=168
log.segment.bytes=1073741824
zookeeper.connect=ZOOKEEPER_HOSTS:2181
zookeeper.connection.timeout.ms=18000
auto.create.topics.enable=false
delete.topic.enable=true
EOF

# Create systemd service
cat > /etc/systemd/system/kafka.service <<EOF
[Unit]
Description=Apache Kafka
After=network.target

[Service]
Type=simple
User=kafka
ExecStart=/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/opt/kafka/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable but don't start yet (need Zookeeper first)
systemctl daemon-reload
systemctl enable kafka

echo "Kafka broker ${broker_id} initialization complete"
