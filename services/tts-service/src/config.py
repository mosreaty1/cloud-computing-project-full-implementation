from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # Service configuration
    SERVICE_NAME: str = "tts-service"
    LOG_LEVEL: str = "INFO"

    # AWS Configuration
    AWS_REGION: str = "us-east-1"
    S3_BUCKET_NAME: str = "tts-service-storage-dev"

    # Kafka Configuration
    KAFKA_BOOTSTRAP_SERVERS: str = "localhost:9092"
    KAFKA_TOPIC_AUDIO_GENERATED: str = "audio.generation.completed"
    KAFKA_TOPIC_AUDIO_REQUESTED: str = "audio.generation.requested"

    # TTS Configuration
    DEFAULT_LANGUAGE: str = "en"
    DEFAULT_FORMAT: str = "mp3"
    SUPPORTED_FORMATS: list = ["mp3", "wav", "ogg"]
    SUPPORTED_LANGUAGES: list = ["en", "es", "fr", "de", "it", "pt", "ja", "ko", "zh"]

    # Storage Configuration
    PRESIGNED_URL_EXPIRY: int = 3600  # 1 hour

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
