import uuid
import logging
from datetime import datetime
from gtts import gTTS
import tempfile
import os

logger = logging.getLogger(__name__)

class TTSService:
    def __init__(self, storage_service, kafka_service):
        self.storage = storage_service
        self.kafka = kafka_service

    async def synthesize(self, text: str, language: str, voice: str, format: str, user_id: str):
        """Generate speech from text"""
        audio_id = str(uuid.uuid4())
        logger.info(f"Synthesizing audio {audio_id} for user {user_id}")

        try:
            # Generate speech using gTTS
            tts = gTTS(text=text, lang=language, slow=False)

            # Save to temporary file
            with tempfile.NamedTemporaryFile(delete=False, suffix=f'.{format}') as temp_file:
                temp_path = temp_file.name
                tts.save(temp_path)

            # Get file size
            file_size = os.path.getsize(temp_path)

            # Upload to S3
            s3_key = f"{user_id}/{audio_id}.{format}"
            await self.storage.upload_file(temp_path, s3_key)

            # Clean up temp file
            os.unlink(temp_path)

            # Generate presigned URL
            download_url = await self.storage.generate_presigned_url(s3_key)

            # Publish Kafka event
            await self.kafka.publish_event('audio.generation.completed', {
                'audio_id': audio_id,
                'user_id': user_id,
                'format': format,
                'size_bytes': file_size,
                'timestamp': datetime.utcnow().isoformat()
            })

            return {
                'audio_id': audio_id,
                'download_url': download_url,
                'format': format,
                'size_bytes': file_size,
                'duration_seconds': None,  # gTTS doesn't provide duration
                'created_at': datetime.utcnow()
            }

        except Exception as e:
            logger.error(f"Error synthesizing audio: {str(e)}")
            raise

    async def get_audio(self, audio_id: str):
        """Retrieve audio file metadata"""
        # In production, query metadata from a database
        # For now, we'll try to get it from S3
        objects = await self.storage.list_objects(prefix=audio_id)
        if not objects:
            return None

        s3_key = objects[0]['Key']
        download_url = await self.storage.generate_presigned_url(s3_key)

        return {
            'audio_id': audio_id,
            'download_url': download_url,
            'format': s3_key.split('.')[-1],
            'size_bytes': objects[0]['Size'],
            'created_at': objects[0]['LastModified'],
            'expires_at': datetime.utcnow()
        }

    async def delete_audio(self, audio_id: str):
        """Delete audio file"""
        objects = await self.storage.list_objects(prefix=audio_id)
        for obj in objects:
            await self.storage.delete_file(obj['Key'])

    async def list_audio_files(self, user_id: str, limit: int = 10):
        """List audio files for a user"""
        objects = await self.storage.list_objects(prefix=f"{user_id}/", max_keys=limit)
        return [
            {
                'audio_id': obj['Key'].split('/')[-1].split('.')[0],
                'size_bytes': obj['Size'],
                'created_at': obj['LastModified'].isoformat()
            }
            for obj in objects
        ]
