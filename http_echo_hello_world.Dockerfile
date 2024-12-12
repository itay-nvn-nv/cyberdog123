FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Create a single Python script that serves hostname and IP
RUN echo "from flask import Flask\nimport socket\n\napp = Flask(__name__)\n\n@app.route('/')\ndef hello():\n    hostname = socket.gethostname()\n    hostname_ip = socket.gethostbyname(hostname)\n    return f'Hello from {hostname} ({hostname_ip})'\n\nif __name__ == '__main__':\n    app.run(host='0.0.0.0', port=80)" > /app/server.py

# Install necessary packages
RUN pip install flask
RUN apt update && apt install -y curl

# Expose the port the app runs on
EXPOSE 80

# Command to run the application
CMD ["python", "/app/server.py"]
