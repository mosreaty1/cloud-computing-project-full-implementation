# Kafka Topics Setup Guide

This guide shows you how to configure Kafka topics for the Learning Platform microservices.

## Prerequisites

- ✅ Infrastructure deployed (Kafka broker running)
- ✅ AWS CLI configured
- ✅ Access to AWS Console or Session Manager plugin installed

---

## Option 1: Automated Setup (Recommended)

### Using PowerShell Script

```powershell
cd scripts
.\setup-kafka-topics.ps1
```

This script will:
1. Upload the setup script to the Kafka broker
2. Execute it via SSM
3. Display the results

---

## Option 2: Manual Setup via AWS Console

### Step 1: Connect to Kafka Broker

1. Go to: https://us-east-1.console.aws.amazon.com/systems-manager/session-manager/
2. Click "Start session"
3. Select instance: **learning-platform-kafka-broker-1** (i-0a834978ec5715681)
4. Click "Start session"

### Step 2: Download and Run Setup Script

In the SSM terminal:

```bash
# Download the script
curl -o /tmp/setup-kafka-topics.sh https://raw.githubusercontent.com/YOUR-REPO/scripts/setup-kafka-topics.sh

# Or create it manually
cat > /tmp/setup-kafka-topics.sh << 'EOF'
# ... paste script content ...
EOF

# Make executable
chmod +x /tmp/setup-kafka-topics.sh

# Run it
bash /tmp/setup-kafka-topics.sh
```

### Step 3: Verify Topics

```bash
# List all topics
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Describe a specific topic
/opt/kafka/bin/kafka-topics.sh --describe --topic document.uploaded --bootstrap-server localhost:9092
```

---

## Option 3: Manual Topic Creation

If you prefer to create topics one by one:

### Connect via SSM Session Manager

```bash
# Switch to root
sudo -s

# Create document topics
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic document.uploaded

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic document.processed

# Create notes topic
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic notes.generated

# Create quiz topics
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic quiz.requested

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic quiz.generated

# Create audio transcription topics (STT)
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.transcription.requested

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.transcription.completed

# Create audio generation topics (TTS)
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.generation.requested

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.generation.completed

# Create chat topic
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic chat.message
```

---

## Verify Kafka Setup

### Check Cluster Status

```bash
# Check broker API versions
/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# List all topics
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Describe all topics
/opt/kafka/bin/kafka-topics.sh --describe --bootstrap-server localhost:9092
```

### Test Producing and Consuming Messages

```bash
# Terminal 1: Start a consumer
/opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic test.topic \
  --from-beginning

# Terminal 2: Produce some messages
/opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic test.topic

# Type messages and press Enter. They should appear in Terminal 1.
```

---

## Important Notes

### Replication Factor

**Current Setup (Free Tier):**
- Replication factor: **1** (only 1 Kafka broker)
- Partitions: **3** per topic

**Production Setup (with 3 brokers):**
- Replication factor: **2 or 3** (for high availability)
- Partitions: **3+ per topic**

To increase replication when you scale to 3 brokers:

```bash
/opt/kafka/bin/kafka-topics.sh --alter \
  --bootstrap-server localhost:9092 \
  --topic document.uploaded \
  --partitions 6  # Can only increase partitions, not decrease
```

### Topic Naming Convention

```
<service>.<action>.<status>

Examples:
- document.uploaded
- audio.transcription.requested
- audio.generation.completed
```

---

## Troubleshooting

### Kafka Not Responding

```bash
# Check if Kafka is running
systemctl status kafka

# Check Kafka logs
journalctl -u kafka -n 100 --no-pager

# Restart Kafka
systemctl restart kafka
```

### Topic Already Exists Error

Topics with `--if-not-exists` flag won't throw errors. Without it, you'll get:

```
ERROR org.apache.kafka.common.errors.TopicExistsException: Topic 'xxx' already exists.
```

Solution: Ignore or use `--if-not-exists` flag.

### Connection Refused

If you get "Connection refused to localhost:9092":

```bash
# Check if Kafka is listening
netstat -tulpn | grep 9092

# Check Zookeeper is running (Kafka depends on it)
systemctl status zookeeper
```

---

## Next Steps

After setting up topics:

1. **Deploy microservices** to EC2 container hosts
2. **Configure service connections** to Kafka (use internal IP: 10.0.30.81:9092)
3. **Monitor topics** using Kafka tools or third-party monitoring
4. **Set up consumer groups** for each microservice
5. **Implement dead-letter queues** for error handling

---

## Useful Kafka Commands

```bash
# Delete a topic (if needed)
/opt/kafka/bin/kafka-topics.sh --delete --topic test.topic --bootstrap-server localhost:9092

# Change topic configuration
/opt/kafka/bin/kafka-configs.sh --alter \
  --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name document.uploaded \
  --add-config retention.ms=86400000  # 1 day retention

# View topic configuration
/opt/kafka/bin/kafka-configs.sh --describe \
  --bootstrap-server localhost:9092 \
  --entity-type topics \
  --entity-name document.uploaded

# Check consumer groups
/opt/kafka/bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092

# View consumer group details
/opt/kafka/bin/kafka-consumer-groups.sh --describe \
  --group my-consumer-group \
  --bootstrap-server localhost:9092
```
