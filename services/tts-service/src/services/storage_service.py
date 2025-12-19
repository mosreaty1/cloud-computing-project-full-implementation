import boto3
from botocore.exceptions import ClientError
import logging
from src.config import settings

logger = logging.getLogger(__name__)

class StorageService:
    def __init__(self):
        self.s3_client = boto3.client('s3', region_name=settings.AWS_REGION)
        self.bucket_name = settings.S3_BUCKET_NAME

    async def upload_file(self, file_path: str, s3_key: str):
        """Upload file to S3"""
        try:
            self.s3_client.upload_file(file_path, self.bucket_name, s3_key)
            logger.info(f"Uploaded file to s3://{self.bucket_name}/{s3_key}")
        except ClientError as e:
            logger.error(f"Error uploading file to S3: {str(e)}")
            raise

    async def generate_presigned_url(self, s3_key: str, expiry: int = None):
        """Generate presigned URL for S3 object"""
        if expiry is None:
            expiry = settings.PRESIGNED_URL_EXPIRY

        try:
            url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': self.bucket_name, 'Key': s3_key},
                ExpiresIn=expiry
            )
            return url
        except ClientError as e:
            logger.error(f"Error generating presigned URL: {str(e)}")
            raise

    async def delete_file(self, s3_key: str):
        """Delete file from S3"""
        try:
            self.s3_client.delete_object(Bucket=self.bucket_name, Key=s3_key)
            logger.info(f"Deleted file from s3://{self.bucket_name}/{s3_key}")
        except ClientError as e:
            logger.error(f"Error deleting file from S3: {str(e)}")
            raise

    async def list_objects(self, prefix: str = "", max_keys: int = 100):
        """List objects in S3 bucket"""
        try:
            response = self.s3_client.list_objects_v2(
                Bucket=self.bucket_name,
                Prefix=prefix,
                MaxKeys=max_keys
            )
            return response.get('Contents', [])
        except ClientError as e:
            logger.error(f"Error listing objects from S3: {str(e)}")
            raise
