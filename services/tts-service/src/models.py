from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class TTSRequest(BaseModel):
    text: str = Field(..., description="Text to convert to speech", min_length=1, max_length=5000)
    language: str = Field(default="en", description="Language code (e.g., en, es, fr)")
    voice: Optional[str] = Field(default=None, description="Voice identifier")
    format: str = Field(default="mp3", description="Audio format (mp3, wav, ogg)")
    user_id: str = Field(..., description="User identifier")

    class Config:
        json_schema_extra = {
            "example": {
                "text": "Hello, this is a text to speech demo.",
                "language": "en",
                "voice": "default",
                "format": "mp3",
                "user_id": "user123"
            }
        }

class TTSResponse(BaseModel):
    audio_id: str = Field(..., description="Unique identifier for the generated audio")
    download_url: str = Field(..., description="Presigned URL to download the audio")
    format: str = Field(..., description="Audio format")
    size_bytes: int = Field(..., description="File size in bytes")
    duration_seconds: Optional[float] = Field(None, description="Audio duration in seconds")
    created_at: datetime = Field(..., description="Creation timestamp")

class AudioRetrievalResponse(BaseModel):
    audio_id: str
    download_url: str
    format: str
    size_bytes: int
    created_at: datetime
    expires_at: datetime
