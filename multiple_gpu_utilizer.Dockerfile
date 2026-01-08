FROM nvidia/cuda:12.0.1-runtime-ubuntu22.04

RUN apt update && apt install -y git make build-essential nvidia-cuda-dev cuda-nvcc-12-0

RUN git clone https://github.com/wilicc/gpu-burn

RUN cd gpu-burn && make

RUN ./gpu-burn/gpu-burn --help

ENTRYPOINT ["./gpu-burn/gpu-burn"]