#!/bin/bash

# Wait for LocalStack to be ready
echo "Waiting for LocalStack..."
sleep 10

# Create S3 buckets for all services
echo "Creating S3 buckets..."
awslocal s3 mb s3://tts-service-storage-dev
awslocal s3 mb s3://stt-service-storage-dev
awslocal s3 mb s3://chat-service-storage-dev
awslocal s3 mb s3://document-reader-storage-dev
awslocal s3 mb s3://quiz-service-storage-dev
awslocal s3 mb s3://shared-assets-dev

echo "LocalStack initialization complete"
