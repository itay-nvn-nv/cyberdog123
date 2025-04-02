FROM python:3.10
RUN curl -o inference_server.py https://raw.githubusercontent.com/itay-nvn-nv/scripts/refs/heads/main/inference_server.py
EXPOSE 8080
ENTRYPOINT ["python", "inference_server.py"]
