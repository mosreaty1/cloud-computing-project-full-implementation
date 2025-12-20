#!/bin/bash
# setup-kafka-topics.sh
# Run this script on the Kafka broker via SSM Session Manager

echo "==================================================="
echo "Kafka Topics Setup for Learning Platform"
echo "==================================================="
echo ""

# Kafka broker address
KAFKA_BROKER="localhost:9092"

# Note: Using replication-factor 1 because we only have 1 broker (Free Tier)
# For production with 3 brokers, use replication-factor 2 or 3

echo "Creating Kafka topics..."
echo ""

# Document processing topics
echo "→ Creating document.uploaded topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic document.uploaded \
  --if-not-exists

echo "→ Creating document.processed topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic document.processed \
  --if-not-exists

# Notes generation topic
echo "→ Creating notes.generated topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic notes.generated \
  --if-not-exists

# Quiz topics
echo "→ Creating quiz.requested topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic quiz.requested \
  --if-not-exists

echo "→ Creating quiz.generated topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic quiz.generated \
  --if-not-exists

# Audio transcription topics (STT)
echo "→ Creating audio.transcription.requested topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.transcription.requested \
  --if-not-exists

echo "→ Creating audio.transcription.completed topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.transcription.completed \
  --if-not-exists

# Audio generation topics (TTS)
echo "→ Creating audio.generation.requested topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.generation.requested \
  --if-not-exists

echo "→ Creating audio.generation.completed topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic audio.generation.completed \
  --if-not-exists

# Chat topic
echo "→ Creating chat.message topic..."
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server $KAFKA_BROKER \
  --replication-factor 1 \
  --partitions 3 \
  --topic chat.message \
  --if-not-exists

echo ""
echo "==================================================="
echo "✓ Kafka topics created successfully!"
echo "==================================================="
echo ""

# List all topics
echo "Current Kafka topics:"
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server $KAFKA_BROKER

echo ""
echo "==================================================="
echo "Topic Details"
echo "==================================================="

# Describe each topic
for topic in document.uploaded document.processed notes.generated quiz.requested quiz.generated \
             audio.transcription.requested audio.transcription.completed \
             audio.generation.requested audio.generation.completed chat.message; do
  echo ""
  echo "--- Topic: $topic ---"
  /opt/kafka/bin/kafka-topics.sh --describe --topic $topic --bootstrap-server $KAFKA_BROKER
done

echo ""
echo "==================================================="
echo "Setup Complete!"
echo "==================================================="
