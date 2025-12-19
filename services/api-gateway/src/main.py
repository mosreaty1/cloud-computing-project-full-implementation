from fastapi import FastAPI, Request, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import httpx
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Rate limiter
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title="Learning Platform API Gateway",
    description="Central API Gateway for all microservices",
    version="1.0.0"
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Service URLs from environment
SERVICES = {
    "tts": os.getenv("TTS_SERVICE_URL", "http://tts-service:8001"),
    "stt": os.getenv("STT_SERVICE_URL", "http://stt-service:8002"),
    "chat": os.getenv("CHAT_SERVICE_URL", "http://chat-service:8003"),
    "document": os.getenv("DOCUMENT_SERVICE_URL", "http://document-reader:8004"),
    "quiz": os.getenv("QUIZ_SERVICE_URL", "http://quiz-service:8005"),
}

@app.get("/health")
async def health_check():
    """API Gateway health check"""
    return {
        "status": "healthy",
        "service": "api-gateway",
        "version": "1.0.0"
    }

@app.get("/services/health")
async def check_all_services():
    """Check health of all microservices"""
    health_status = {}

    async with httpx.AsyncClient(timeout=5.0) as client:
        for service_name, service_url in SERVICES.items():
            try:
                response = await client.get(f"{service_url}/health")
                health_status[service_name] = {
                    "status": "healthy" if response.status_code == 200 else "unhealthy",
                    "status_code": response.status_code
                }
            except Exception as e:
                health_status[service_name] = {
                    "status": "unreachable",
                    "error": str(e)
                }

    return health_status

# Proxy routes to microservices
@app.api_route("/api/tts/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
@limiter.limit("60/minute")
async def proxy_tts(path: str, request: Request):
    """Proxy requests to TTS service"""
    return await proxy_request("tts", path, request)

@app.api_route("/api/stt/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
@limiter.limit("60/minute")
async def proxy_stt(path: str, request: Request):
    """Proxy requests to STT service"""
    return await proxy_request("stt", path, request)

@app.api_route("/api/chat/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
@limiter.limit("60/minute")
async def proxy_chat(path: str, request: Request):
    """Proxy requests to Chat service"""
    return await proxy_request("chat", path, request)

@app.api_route("/api/documents/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
@limiter.limit("60/minute")
async def proxy_documents(path: str, request: Request):
    """Proxy requests to Document Reader service"""
    return await proxy_request("document", path, request)

@app.api_route("/api/quiz/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
@limiter.limit("60/minute")
async def proxy_quiz(path: str, request: Request):
    """Proxy requests to Quiz service"""
    return await proxy_request("quiz", path, request)

async def proxy_request(service: str, path: str, request: Request):
    """Generic proxy function"""
    service_url = SERVICES.get(service)
    if not service_url:
        raise HTTPException(status_code=404, detail=f"Service {service} not found")

    # Construct target URL
    target_url = f"{service_url}/api/{service}/{path}"

    # Get request body
    body = await request.body()

    # Forward headers
    headers = dict(request.headers)
    headers.pop('host', None)  # Remove host header

    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            response = await client.request(
                method=request.method,
                url=target_url,
                content=body,
                headers=headers,
                params=request.query_params
            )

            return response.json() if response.headers.get('content-type') == 'application/json' else response.text

        except httpx.TimeoutException:
            raise HTTPException(status_code=504, detail="Service timeout")
        except Exception as e:
            logger.error(f"Error proxying to {service}: {str(e)}")
            raise HTTPException(status_code=502, detail=f"Service unavailable: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
