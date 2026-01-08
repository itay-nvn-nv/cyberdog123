FROM nvidia/cuda:12.0.1-runtime-ubuntu22.04

RUN apt update && apt install -y git make build-essential nvidia-cuda-dev cuda-nvcc-12-0

RUN git clone https://github.com/wilicc/gpu-burn

WORKDIR /gpu-burn

RUN make

RUN ./gpu_burn --help

ENTRYPOINT ["./gpu_burn"]
