#!/bin/bash
set -e

# Update system
yum update -y

# Install Java
yum install -y java-11-amazon-corretto

# Format and mount EBS volume for Zookeeper data
mkfs -t ext4 /dev/sdf
mkdir -p /var/lib/zookeeper
mount /dev/sdf /var/lib/zookeeper
echo '/dev/sdf /var/lib/zookeeper ext4 defaults,nofail 0 2' >> /etc/fstab

# Download and install Kafka (includes Zookeeper)
KAFKA_VERSION="3.6.0"
SCALA_VERSION="2.13"
cd /opt
wget https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz
tar -xzf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz
ln -s kafka_$SCALA_VERSION-$KAFKA_VERSION kafka
rm kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

# Create Zookeeper user
useradd zookeeper -m
chown -R zookeeper:zookeeper /opt/kafka*
chown -R zookeeper:zookeeper /var/lib/zookeeper

# Set Zookeeper myid
mkdir -p /var/lib/zookeeper/data
echo "${node_id}" > /var/lib/zookeeper/data/myid

# Configure Zookeeper
cat > /opt/kafka/config/zookeeper.properties <<EOF
dataDir=/var/lib/zookeeper/data
clientPort=2181
maxClientCnxns=0
admin.enableServer=false
tickTime=2000
initLimit=10
syncLimit=5
server.1=ZOOKEEPER_HOST_1:2888:3888
server.2=ZOOKEEPER_HOST_2:2888:3888
server.3=ZOOKEEPER_HOST_3:2888:3888
EOF

# Create systemd service
cat > /etc/systemd/system/zookeeper.service <<EOF
[Unit]
Description=Apache Zookeeper
After=network.target

[Service]
Type=simple
User=zookeeper
ExecStart=/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/opt/kafka/bin/zookeeper-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start Zookeeper
systemctl daemon-reload
systemctl enable zookeeper
systemctl start zookeeper

echo "Zookeeper node ${node_id} initialization complete"
