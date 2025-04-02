FROM nvcr.io/nvidia/tritonserver:25.01-trtllm-python-py3

RUN python --version

RUN curl -o inference_server.py https://raw.githubusercontent.com/itay-nvn-nv/scripts/refs/heads/main/inference_server.py
EXPOSE 8080
ENTRYPOINT ["python", "inference_server.py"]
