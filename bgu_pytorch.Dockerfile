FROM pytorch/pytorch:2.7.1-cuda12.6-cudnn9-devel

# Install InfiniBand Tools
RUN apt-get update && apt-get install -y \
    infiniband-diags \
    && rm -rf /var/lib/apt/lists/*

# Install CuPy
RUN pip install cupy-cuda12x

# Copy the code
WORKDIR /workspace
COPY bgu_pytorch/wang_landau_walkers.py bgu_pytorch/utils.py bgu_pytorch/config.py /workspace
CMD ["python", "wang_landau_walkers.py", "-u"]