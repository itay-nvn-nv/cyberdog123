# Unified Inference Mock Server

A single Docker image that works with both **Knative** and **NVIDIA NIM** deployments.

## 🚀 Quick Start

### Build
```bash
docker build -f inference_mock_server.Dockerfile -t inference-mock-server:latest .
```

### Run - Knative Mode (Port 8080)
```bash
docker run -d -p 8080:8080 -e PORT=8080 inference-mock-server:latest

# Test
curl http://localhost:8080/
curl -X POST http://localhost:8080/ --data "word1=hello" --data "word2=knative"
```

### Run - NIM Mode (Port 8000)
```bash
docker run -d -p 8000:8000 inference-mock-server:latest

# Test
curl http://localhost:8000/v1/health/ready
curl -X POST http://localhost:8000/v1/infer \
  -H "Content-Type: application/json" \
  -d '{"word1": "hello", "word2": "nim"}'
```

---

## 📋 API Reference

### Knative Endpoints (Port 8080)
| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| GET | `/` | - | Plain text health check |
| POST | `/` | Form: `word1=X&word2=Y` | Plain text result |

### NIM Endpoints (Port 8000)
| Method | Endpoint | Request | Response |
|--------|----------|---------|----------|
| GET | `/v1/health/ready` | - | JSON readiness probe |
| GET | `/v1/health/live` | - | JSON liveness probe |
| POST | `/v1/infer` | JSON: `{"word1":"X","word2":"Y"}` | JSON result |
| POST | `/v1/chat/completions` | JSON: `{"word1":"X","word2":"Y"}` | JSON result |

---

## ⚙️ Configuration

Set via environment variables:
- `PORT`: Server port (default: `8000`, set to `8080` for Knative)
- `WARMUP_SECONDS`: Seconds before readiness (default: `5`)

---

## 🎯 How It Works

The unified image supports **all endpoints** in both modes:
- **Knative mode** (`PORT=8080`): Primarily uses `/` endpoints, but NIM endpoints also work
- **NIM mode** (`PORT=8000`): Primarily uses `/v1/*` endpoints, but Knative endpoints also work

This allows the same image to be deployed to both platforms without modification.

---

## 🔧 Kubernetes Deployment Examples

### Knative Service
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: inference-mock-server
spec:
  template:
    spec:
      containers:
      - image: your-registry.com/inference-mock-server:latest
        env:
        - name: PORT
          value: "8080"
        ports:
        - containerPort: 8080
```

### NIM Service
```yaml
apiVersion: apps.nvidia.com/v1alpha1
kind: NIMService
metadata:
  name: inference-mock-server
spec:
  image: your-registry.com/inference-mock-server:latest
  replicas: 1
  resources:
    limits:
      nvidia.com/gpu: "0"  # Mock server doesn't need GPU
  expose:
    enabled: true
    service:
      port: 8000
  livenessProbe:
    httpGet:
      path: /v1/health/live
      port: 8000
  readinessProbe:
    httpGet:
      path: /v1/health/ready
      port: 8000
```

---

## ✨ Key Features

- ✅ Single codebase for both Knative and NIM
- ✅ Backward compatible with existing Knative deployments
- ✅ NIM-compliant health endpoints
- ✅ Lightweight image (~150MB) - uses `python:3.10-slim`
- ✅ Configurable via environment variables

---

## 💡 Note on Base Image

This mock server uses **`python:3.10-slim`** (~150MB) instead of a CUDA base image since it doesn't perform actual GPU inference.

**If you need real GPU inference:**
```dockerfile
# Change line 13 in inference_mock_server.Dockerfile from:
FROM python:3.10-slim

# To:
FROM nvidia/cuda:12.2.0-base-ubuntu22.04
# Then add: RUN apt-get update && apt-get install -y python3.10 python3-pip && ...
```

For a mock server, the lightweight image provides the same NIM-compatible API without the extra ~1.3GB overhead.

---

## 📁 Files

- `inference_server.py` - Unified Python server script
- `../inference_mock_server.Dockerfile` - Dockerfile that uses this script
