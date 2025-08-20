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

# Create startup script inline
RUN mkdir -p /usr/local/bin && \
  echo '#!/bin/bash' > /usr/local/bin/start-services.sh && \
  echo 'set -e' >> /usr/local/bin/start-services.sh && \
  echo '# Start JupyterLab in background' >> /usr/local/bin/start-services.sh && \
  echo 'echo "Starting JupyterLab..."' >> /usr/local/bin/start-services.sh && \
  echo 'jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root \' >> /usr/local/bin/start-services.sh && \
  echo ' --NotebookApp.token="" --NotebookApp.password="" \' >> /usr/local/bin/start-services.sh && \
  echo ' --notebook-dir=/ &' >> /usr/local/bin/start-services.sh && \
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

USER $NB_UID

EXPOSE 8888 8080

CMD ["/usr/local/bin/start-services.sh"]