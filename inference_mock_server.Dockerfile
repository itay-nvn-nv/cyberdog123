# Unified Inference Mock Server Dockerfile
# Compatible with both Knative and NVIDIA NIM deployments

FROM python:3.10-slim

# Copy the unified inference server
COPY inference_mock_server/inference_server.py /app/inference_server.py

WORKDIR /app

# Default to port 8000 (NIM standard)
# Override with -e PORT=8080 for Knative
ENV PORT=8000
ENV WARMUP_SECONDS=5

# Expose both ports (use PORT env to determine which one)
EXPOSE 8000
EXPOSE 8080

# Health check - tries NIM endpoint first, falls back to root
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:' + __import__('os').getenv('PORT', '8000') + '/v1/health/ready')" || \
        python -c "import urllib.request; urllib.request.urlopen('http://localhost:' + __import__('os').getenv('PORT', '8000') + '/')"

# Run the unified server
ENTRYPOINT ["python", "inference_server.py"]
