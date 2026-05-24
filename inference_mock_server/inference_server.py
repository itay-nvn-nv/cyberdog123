# Unified inference mock server - Compatible with both Knative and NIM
# Supports both legacy (Knative) and NIM endpoints
#
# Knative mode (backward compatible):
#   - GET  /          -> health check (plain text)
#   - POST /          -> inference (plain text response)
#
# NIM mode:
#   - GET  /v1/health/ready        -> readiness probe (JSON)
#   - GET  /v1/health/live         -> liveness probe (JSON)
#   - GET  /v1/models              -> list available models (JSON)
#   - GET  /v1/metadata            -> service metadata (JSON)
#   - POST /v1/infer               -> inference (JSON response)
#   - POST /v1/chat/completions    -> inference (JSON response)

from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse as urlparse
import json
import time
import os

# Configuration via environment variables
PORT = int(os.getenv('PORT', '8000'))  # Default to 8000 (NIM), can override to 8080 (Knative)
WARMUP_SECONDS = int(os.getenv('WARMUP_SECONDS', '5'))
INIT_DELAY_SECONDS = int(os.getenv('INIT_DELAY_SECONDS', '0'))
SERVER_START_TIME = None  # Set after init delay completes

def hello(word1, word2):
    chars1 = len(str(word1))
    chars2 = len(str(word2))
    return f"1st word '{word1}' has {chars1} characters, 2nd word '{word2}' has {chars2} characters."

class UnifiedHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # NIM health check endpoints
        if self.path == '/v1/health/ready':
            self._handle_ready()
        elif self.path == '/v1/health/live':
            self._handle_live()
        elif self.path in ['/', '/v1/health', '/health']:
            self._handle_status()
        elif self.path == '/v1/models':
            self._handle_models()
        elif self.path == '/v1/metadata':
            self._handle_metadata()
        else:
            self.send_error(404, "Not Found")

    def _handle_ready(self):
        """Readiness probe - NIM standard"""
        elapsed = time.time() - SERVER_START_TIME
        if elapsed >= WARMUP_SECONDS:
            response = json.dumps({
                "ready": True,
                "message": "Server is ready to serve requests"
            })
            self.send_response(200)
        else:
            response = json.dumps({
                "ready": False,
                "message": f"Server warming up, {WARMUP_SECONDS - elapsed:.1f}s remaining"
            })
            self.send_response(503)
        
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))

    def _handle_live(self):
        """Liveness probe - NIM standard"""
        response = json.dumps({
            "live": True,
            "uptime_seconds": time.time() - SERVER_START_TIME
        })
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))

    def _handle_status(self):
        """General status endpoint - works for both Knative and NIM"""
        # Return plain text for backward compatibility with Knative
        response = "Server is running, ready to predict..."
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))
        self.log_message("GET request: %s", response)

    def _handle_models(self):
        """NIM models endpoint - lists available models"""
        response = json.dumps({
            "object": "list",
            "data": [
                {
                    "id": "mock-inference-v1",
                    "object": "model",
                    "created": int(SERVER_START_TIME),
                    "owned_by": "mock-server"
                }
            ]
        })
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))
        self.log_message("Models list requested")

    def _handle_metadata(self):
        """NIM metadata endpoint - provides service metadata"""
        response = json.dumps({
            "name": "mock-inference-server",
            "version": "1.0.0",
            "model": "mock-inference-v1",
            "description": "Mock inference server for testing NIM compatibility",
            "uptime_seconds": time.time() - SERVER_START_TIME
        })
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))
        self.log_message("Metadata requested")

    def do_POST(self):
        if self.path == '/':
            # Legacy Knative endpoint - plain text response
            self._handle_inference_legacy()
        elif self.path in ['/v1/infer', '/v1/chat/completions']:
            # NIM endpoints - JSON response
            self._handle_inference_nim()
        else:
            self.send_error(404, "Not Found")

    def _handle_inference_legacy(self):
        """Legacy Knative-compatible endpoint with plain text response"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        query_params = urlparse.parse_qs(post_data)

        word1 = query_params.get('word1', [''])[0]
        word2 = query_params.get('word2', [''])[0]

        response = hello(word1, word2)

        # Plain text response for backward compatibility
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))
        self.log_message(f"POST request: {response}")

    def _handle_inference_nim(self):
        """NIM-style inference endpoint with JSON response"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        
        # Try to parse as JSON first (NIM standard), fall back to form data
        try:
            data = json.loads(post_data)
            word1 = data.get('word1', '')
            word2 = data.get('word2', '')
        except json.JSONDecodeError:
            query_params = urlparse.parse_qs(post_data)
            word1 = query_params.get('word1', [''])[0]
            word2 = query_params.get('word2', [''])[0]

        result = hello(word1, word2)

        # NIM-style JSON response
        response = json.dumps({
            "id": f"inference-{int(time.time() * 1000)}",
            "object": "inference.result",
            "created": int(time.time()),
            "model": "mock-inference-v1",
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": result
                }
            }]
        })

        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))
        self.log_message(f"Inference request: {result}")

def run(server_class=HTTPServer, handler_class=UnifiedHandler, port=PORT):
    global SERVER_START_TIME

    if INIT_DELAY_SECONDS > 0:
        print(f'Simulating model loading for {INIT_DELAY_SECONDS}s (set INIT_DELAY_SECONDS=0 to skip)...')
        time.sleep(INIT_DELAY_SECONDS)
        print(f'Model loading complete.')

    SERVER_START_TIME = time.time()

    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    
    print(f'Starting unified inference server on port {port}...')
    print(f'Mode: NIM-compatible with Knative backward compatibility')
    print(f'Init delay: {INIT_DELAY_SECONDS}s, Warmup: {WARMUP_SECONDS}s')
    print(f'')
    print(f'Knative endpoints (backward compatible):')
    print(f'  - GET  /          -> health check (plain text)')
    print(f'  - POST /          -> inference (plain text)')
    print(f'')
    print(f'NIM endpoints:')
    print(f'  - GET  /v1/health/ready        -> readiness probe')
    print(f'  - GET  /v1/health/live         -> liveness probe')
    print(f'  - GET  /v1/models              -> list available models')
    print(f'  - GET  /v1/metadata            -> service metadata')
    print(f'  - POST /v1/infer               -> inference (JSON)')
    print(f'  - POST /v1/chat/completions    -> inference (JSON)')
    print(f'')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
