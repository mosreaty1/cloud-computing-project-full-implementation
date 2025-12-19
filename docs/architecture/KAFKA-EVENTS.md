# Kafka Event Architecture

## Overview

The Cloud-Based Learning Platform uses Apache Kafka for event-driven communication between microservices. This document describes all event topics, their schemas, and event flows.

## Event Topics

### 1. document.uploaded

**Purpose**: Notify when a user uploads a new document

**Producers**: Document Reader Service

**Consumers**: None (logged for audit)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "document.uploaded",
  "timestamp": "ISO8601",
  "user_id": "string",
  "document_id": "string",
  "document_name": "string",
  "document_size_bytes": number,
  "document_format": "pdf|docx|txt",
  "s3_key": "string"
}
```

### 2. document.processed

**Purpose**: Notify when document processing and note generation complete

**Producers**: Document Reader Service

**Consumers**: Quiz Service, Chat Service

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "document.processed",
  "timestamp": "ISO8601",
  "user_id": "string",
  "document_id": "string",
  "extracted_text": "string",
  "summary": "string",
  "key_points": ["string"],
  "notes_generated": boolean
}
```

### 3. notes.generated

**Purpose**: Notify when AI-generated notes are created from document

**Producers**: Document Reader Service

**Consumers**: Quiz Service

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "notes.generated",
  "timestamp": "ISO8601",
  "user_id": "string",
  "document_id": "string",
  "notes_id": "string",
  "notes_content": "string",
  "topics": ["string"]
}
```

### 4. quiz.requested

**Purpose**: User requests quiz generation from document

**Producers**: Quiz Service (from API request)

**Consumers**: Quiz Service (internal processing)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "quiz.requested",
  "timestamp": "ISO8601",
  "user_id": "string",
  "document_id": "string",
  "quiz_type": "multiple_choice|true_false|short_answer",
  "num_questions": number,
  "difficulty": "easy|medium|hard"
}
```

### 5. quiz.generated

**Purpose**: Quiz generation completed

**Producers**: Quiz Service

**Consumers**: None (logged)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "quiz.generated",
  "timestamp": "ISO8601",
  "user_id": "string",
  "quiz_id": "string",
  "document_id": "string",
  "num_questions": number,
  "quiz_url": "string"
}
```

### 6. audio.transcription.requested

**Purpose**: Request speech-to-text transcription

**Producers**: STT Service (from API)

**Consumers**: STT Service (internal worker)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "audio.transcription.requested",
  "timestamp": "ISO8601",
  "user_id": "string",
  "audio_id": "string",
  "audio_format": "mp3|wav|ogg",
  "language": "en|es|fr|...",
  "s3_key": "string"
}
```

### 7. audio.transcription.completed

**Purpose**: Transcription completed

**Producers**: STT Service

**Consumers**: Document Reader Service (if transcription used for notes)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "audio.transcription.completed",
  "timestamp": "ISO8601",
  "user_id": "string",
  "audio_id": "string",
  "transcription_id": "string",
  "transcription_text": "string",
  "confidence_score": number,
  "language_detected": "string"
}
```

### 8. audio.generation.requested

**Purpose**: Request text-to-speech audio generation

**Producers**: TTS Service (from API)

**Consumers**: TTS Service (internal worker)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "audio.generation.requested",
  "timestamp": "ISO8601",
  "user_id": "string",
  "text": "string",
  "language": "string",
  "voice": "string",
  "format": "mp3|wav|ogg"
}
```

### 9. audio.generation.completed

**Purpose**: Audio generation completed

**Producers**: TTS Service

**Consumers**: None (logged)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "audio.generation.completed",
  "timestamp": "ISO8601",
  "user_id": "string",
  "audio_id": "string",
  "format": "string",
  "size_bytes": number,
  "duration_seconds": number,
  "s3_key": "string"
}
```

### 10. chat.message

**Purpose**: Log chat interactions

**Producers**: Chat Service

**Consumers**: None (audit/analytics)

**Schema**:
```json
{
  "event_id": "uuid",
  "event_type": "chat.message",
  "timestamp": "ISO8601",
  "user_id": "string",
  "conversation_id": "string",
  "message_id": "string",
  "message_type": "user|assistant",
  "message_content": "string",
  "tokens_used": number
}
```

## Event Flow Diagrams

### Document Upload → Quiz Generation Flow

```
User uploads document
        ↓
Document Reader Service
        ↓
    [document.uploaded event]
        ↓
Document processing (extract text, generate notes)
        ↓
    [document.processed event]
        ↓
    [notes.generated event]
        ↓
Quiz Service (consumes events)
        ↓
User requests quiz
        ↓
    [quiz.requested event]
        ↓
Quiz generation using document content
        ↓
    [quiz.generated event]
        ↓
Quiz ready for user
```

### Audio Transcription Flow

```
User uploads audio
        ↓
STT Service
        ↓
    [audio.transcription.requested event]
        ↓
Transcription worker processes audio
        ↓
    [audio.transcription.completed event]
        ↓
Transcription stored and returned to user
```

## Kafka Configuration

### Broker Configuration
```properties
num.partitions=3
default.replication.factor=2
min.insync.replicas=2
log.retention.hours=168  # 7 days
log.segment.bytes=1073741824  # 1GB
compression.type=snappy
```

### Topic Configuration
```bash
# Create topic with specific configuration
kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic document.processed \
  --config retention.ms=604800000 \
  --config compression.type=snappy
```

## Consumer Groups

- `quiz-service-group` - Consumes document and notes events
- `chat-service-group` - Consumes document events for context
- `analytics-group` - Consumes all events for analytics

## Event Patterns

### Event Sourcing
All state changes are captured as events, providing:
- Complete audit trail
- Ability to replay events
- Time-travel debugging
- Analytics and reporting

### CQRS (Command Query Responsibility Segregation)
- Commands: API requests trigger events
- Queries: Read from optimized databases
- Events: Bridge between command and query sides

### Saga Pattern
For distributed transactions across services:
1. Service A publishes event
2. Service B consumes and processes
3. Service B publishes completion event
4. Service A updates state

## Monitoring

### Metrics to Monitor
- Event publishing rate
- Consumer lag
- Processing time
- Failed events
- Partition distribution

### Kafka Manager
Access Kafka Manager UI for monitoring:
```
http://kafka-manager:9000
```

## Best Practices

1. **Always include event_id** for idempotency
2. **Use ISO8601 timestamps** for consistency
3. **Version your schemas** for evolution
4. **Keep events immutable** once published
5. **Use appropriate partitioning** for scalability
6. **Monitor consumer lag** to detect issues
7. **Implement dead letter queues** for failed events
8. **Test event handling** thoroughly

## Troubleshooting

### Check Topic Lag
```bash
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group quiz-service-group
```

### View Messages in Topic
```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic document.processed \
  --from-beginning
```

### Publish Test Event
```bash
echo '{"event_id":"test-123","event_type":"document.uploaded"}' | \
  kafka-console-producer.sh --bootstrap-server localhost:9092 \
  --topic document.uploaded
```
