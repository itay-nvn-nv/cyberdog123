FROM python:3.10
RUN curl -o endpoint_server.py https://raw.githubusercontent.com/itay-nvn-nv/scripts/refs/heads/main/endpoint_server.py
EXPOSE 8080
ENTRYPOINT ["python", "endpoint_server.py"]
