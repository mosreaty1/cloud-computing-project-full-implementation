from kafka import KafkaProducer
import json
import logging
from src.config import settings

logger = logging.getLogger(__name__)

class KafkaProducerService:
    def __init__(self):
        self.producer = None
        self.bootstrap_servers = settings.KAFKA_BOOTSTRAP_SERVERS.split(',')

    async def start(self):
        """Initialize Kafka producer"""
        try:
            self.producer = KafkaProducer(
                bootstrap_servers=self.bootstrap_servers,
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                acks='all',
                retries=3
            )
            logger.info("Kafka producer initialized")
        except Exception as e:
            logger.error(f"Error initializing Kafka producer: {str(e)}")
            # Don't fail if Kafka is unavailable (for local development)

    async def stop(self):
        """Close Kafka producer"""
        if self.producer:
            self.producer.close()
            logger.info("Kafka producer closed")

    async def publish_event(self, topic: str, event: dict):
        """Publish event to Kafka topic"""
        if not self.producer:
            logger.warning("Kafka producer not initialized, skipping event publication")
            return

        try:
            future = self.producer.send(topic, value=event)
            future.get(timeout=10)  # Wait for acknowledgment
            logger.info(f"Published event to topic {topic}: {event}")
        except Exception as e:
            logger.error(f"Error publishing event to Kafka: {str(e)}")
            # Don't fail the request if Kafka is unavailable
