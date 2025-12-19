from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
from prometheus_client import Counter, Histogram, generate_latest
from fastapi.responses import Response

from src.config import settings
from src.models import TTSRequest, TTSResponse, AudioRetrievalResponse
from src.services.tts_service import TTSService
from src.services.storage_service import StorageService
from src.services.kafka_service import KafkaProducerService

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Prometheus metrics
tts_requests_total = Counter('tts_requests_total', 'Total TTS requests')
tts_request_duration = Histogram('tts_request_duration_seconds', 'TTS request duration')
tts_errors_total = Counter('tts_errors_total', 'Total TTS errors')

# Initialize services
storage_service = StorageService()
kafka_service = KafkaProducerService()
tts_service = TTSService(storage_service, kafka_service)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting TTS Service...")
    await kafka_service.start()
    logger.info("TTS Service started successfully")
    yield
    # Shutdown
    logger.info("Shutting down TTS Service...")
    await kafka_service.stop()
    logger.info("TTS Service stopped")

app = FastAPI(
    title="Text-to-Speech Service",
    description="Convert text to natural-sounding speech",
    version="1.0.0",
    lifespan=lifespan
)

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "tts-service",
        "version": "1.0.0"
    }

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(), media_type="text/plain")

@app.post("/api/tts/synthesize", response_model=TTSResponse)
async def synthesize_speech(
    request: TTSRequest,
    background_tasks: BackgroundTasks
):
    """
    Generate speech from text

    Args:
        request: TTSRequest containing text, language, and voice options
        background_tasks: FastAPI background tasks

    Returns:
        TTSResponse with audio_id and download URL
    """
    tts_requests_total.inc()

    try:
        with tts_request_duration.time():
            result = await tts_service.synthesize(
                text=request.text,
                language=request.language,
                voice=request.voice,
                format=request.format,
                user_id=request.user_id
            )

        return TTSResponse(**result)

    except Exception as e:
        tts_errors_total.inc()
        logger.error(f"Error synthesizing speech: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to synthesize speech: {str(e)}")

@app.get("/api/tts/audio/{audio_id}", response_model=AudioRetrievalResponse)
async def get_audio(audio_id: str):
    """
    Retrieve generated audio file information

    Args:
        audio_id: Unique identifier for the audio file

    Returns:
        AudioRetrievalResponse with presigned URL for download
    """
    try:
        result = await tts_service.get_audio(audio_id)
        if not result:
            raise HTTPException(status_code=404, detail="Audio file not found")

        return AudioRetrievalResponse(**result)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving audio: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve audio: {str(e)}")

@app.delete("/api/tts/audio/{audio_id}")
async def delete_audio(audio_id: str):
    """
    Delete audio file

    Args:
        audio_id: Unique identifier for the audio file

    Returns:
        Success message
    """
    try:
        await tts_service.delete_audio(audio_id)
        return {"message": "Audio file deleted successfully", "audio_id": audio_id}

    except Exception as e:
        logger.error(f"Error deleting audio: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to delete audio: {str(e)}")

@app.get("/api/tts/list")
async def list_audio_files(user_id: str, limit: int = 10):
    """
    List audio files for a user

    Args:
        user_id: User identifier
        limit: Maximum number of files to return

    Returns:
        List of audio files
    """
    try:
        files = await tts_service.list_audio_files(user_id, limit)
        return {"audio_files": files, "count": len(files)}

    except Exception as e:
        logger.error(f"Error listing audio files: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to list audio files: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
