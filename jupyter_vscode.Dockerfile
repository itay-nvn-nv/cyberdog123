FROM jupyter/datascience-notebook:latest

USER root

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install additional tools
RUN apt-get update && apt-get install -y \
  git \
  curl \
  wget \
  vim \
  tmux \
  && rm -rf /var/lib/apt/lists/*

# Create test script for build-time verification
RUN mkdir -p /usr/local/bin && \
  echo '#!/bin/bash' > /usr/local/bin/test-services.sh && \
  echo 'set -e' >> /usr/local/bin/test-services.sh && \
  echo 'echo "Testing services during build..."' >> /usr/local/bin/test-services.sh && \
  echo '' >> /usr/local/bin/test-services.sh && \
  echo '# Start JupyterLab in background' >> /usr/local/bin/test-services.sh && \
  echo 'echo "Starting JupyterLab for testing..."' >> /usr/local/bin/test-services.sh && \
  echo 'jupyter lab --allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password="" &' >> /usr/local/bin/test-services.sh && \
  echo 'JUPYTER_PID=$!' >> /usr/local/bin/test-services.sh && \
  echo '' >> /usr/local/bin/test-services.sh && \
  echo '# Start code-server in background' >> /usr/local/bin/test-services.sh && \
  echo 'echo "Starting code-server for testing..."' >> /usr/local/bin/test-services.sh && \
  echo 'code-server --bind-addr 0.0.0.0:8080 --auth none / &' >> /usr/local/bin/test-services.sh && \
  echo 'CODESERVER_PID=$!' >> /usr/local/bin/test-services.sh && \
  echo '' >> /usr/local/bin/test-services.sh && \
  echo '# Wait for services to start' >> /usr/local/bin/test-services.sh && \
  echo 'echo "Waiting for services to start..."' >> /usr/local/bin/test-services.sh && \
  echo 'sleep 15' >> /usr/local/bin/test-services.sh && \
  echo '' >> /usr/local/bin/test-services.sh && \
  echo '# Test JupyterLab' >> /usr/local/bin/test-services.sh && \
  echo 'echo "Testing JupyterLab connection..."' >> /usr/local/bin/test-services.sh && \
  echo 'if curl -f http://localhost:8888/ > /dev/null 2>&1; then' >> /usr/local/bin/test-services.sh && \
  echo '  echo "✓ JupyterLab is responding"' >> /usr/local/bin/test-services.sh && \
  echo 'else' >> /usr/local/bin/test-services.sh && \
  echo '  echo "✗ JupyterLab failed to start"' >> /usr/local/bin/test-services.sh && \
  echo '  kill $JUPYTER_PID $CODESERVER_PID 2>/dev/null || true' >> /usr/local/bin/test-services.sh && \
  echo '  exit 1' >> /usr/local/bin/test-services.sh && \
  echo 'fi' >> /usr/local/bin/test-services.sh && \
  echo '' >> /usr/local/bin/test-services.sh && \
  echo '# Test code-server' >> /usr/local/bin/test-services.sh && \
  echo 'echo "Testing code-server connection..."' >> /usr/local/bin/test-services.sh && \
  echo 'if curl -f http://localhost:8080/ > /dev/null 2>&1; then' >> /usr/local/bin/test-services.sh && \
  echo '  echo "✓ Code-server is responding"' >> /usr/local/bin/test-services.sh && \
  echo 'else' >> /usr/local/bin/test-services.sh && \
  echo '  echo "✗ Code-server failed to start"' >> /usr/local/bin/test-services.sh && \
  echo '  kill $JUPYTER_PID $CODESERVER_PID 2>/dev/null || true' >> /usr/local/bin/test-services.sh && \
  echo '  exit 1' >> /usr/local/bin/test-services.sh && \
  echo 'fi' >> /usr/local/bin/test-services.sh && \
  echo '' >> /usr/local/bin/test-services.sh && \
  echo '# Stop services after successful test' >> /usr/local/bin/test-services.sh && \
  echo 'echo "✓ Both services are working! Stopping test processes..."' >> /usr/local/bin/test-services.sh && \
  echo 'kill $JUPYTER_PID $CODESERVER_PID 2>/dev/null || true' >> /usr/local/bin/test-services.sh && \
  echo 'sleep 2' >> /usr/local/bin/test-services.sh && \
  echo 'echo "✓ Services test completed successfully!"' >> /usr/local/bin/test-services.sh && \
  chmod +x /usr/local/bin/test-services.sh

# Create startup script for runtime
RUN echo '#!/bin/bash' > /usr/local/bin/start-services.sh && \
  echo 'set -e' >> /usr/local/bin/start-services.sh && \
  echo '# Start JupyterLab in background' >> /usr/local/bin/start-services.sh && \
  echo 'echo "Starting JupyterLab..."' >> /usr/local/bin/start-services.sh && \
  echo 'jupyter lab --allow-root --no-browser --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password="" &' >> /usr/local/bin/start-services.sh && \
  echo '' >> /usr/local/bin/start-services.sh && \
  echo '# Start code-server in background' >> /usr/local/bin/start-services.sh && \
  echo 'echo "Starting code-server..."' >> /usr/local/bin/start-services.sh && \
  echo 'code-server --bind-addr 0.0.0.0:8080 --auth none / &' >> /usr/local/bin/start-services.sh && \
  echo '' >> /usr/local/bin/start-services.sh && \
  echo '# Wait for both services to be ready' >> /usr/local/bin/start-services.sh && \
  echo 'echo "Waiting for services to start..."' >> /usr/local/bin/start-services.sh && \
  echo 'sleep 10' >> /usr/local/bin/start-services.sh && \
  echo '' >> /usr/local/bin/start-services.sh && \
  echo '# Keep container running' >> /usr/local/bin/start-services.sh && \
  echo 'echo "Services started! JupyterLab: :8888, VS Code: :8080"' >> /usr/local/bin/start-services.sh && \
  echo 'wait' >> /usr/local/bin/start-services.sh && \
  chmod +x /usr/local/bin/start-services.sh

# Switch to notebook user for testing
USER $NB_UID

# Run the service test during build
RUN /usr/local/bin/test-services.sh

EXPOSE 8888 8080

CMD ["/usr/local/bin/start-services.sh"]