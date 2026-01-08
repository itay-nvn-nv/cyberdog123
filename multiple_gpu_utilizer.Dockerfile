FROM nvcr.io/nvidia/cuda:12.6.1-base-ubuntu24.04

RUN apt update && apt install -y git make build-essential nvidia-cuda-dev cuda-nvcc-12-0

RUN git clone https://github.com/wilicc/gpu-burn

RUN cd gpu-burn && make

ENTRYPOINT ["./gpu-burn"]