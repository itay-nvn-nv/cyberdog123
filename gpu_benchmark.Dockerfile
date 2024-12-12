# https://medium.com/@gauravvij/want-to-benchmark-your-gpus-for-deep-learning-3266d7703f7f
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags

# Criteria for Evaluation:
# - GPU Utilization: High utilization indicates efficient use of the GPU.
# - Memory Usage: Keep an eye on both GPU memory usage and overall allocation.
# - Temperature and Power Consumption: Track these to ensure your GPU is not overheating or drawing excessive power.
# - I/O and Throughput: Measure bandwidth (for both PCIe and InfiniBand if available), which will help determine data transfer efficiency between components.

# Additional Metrics:
# - Latency: If your benchmark tools support it, latency measurements can provide insight into how quickly the GPU responds to tasks.
# - Error Rates: Especially in cases where workloads are very intensive, error rates or retries in the I/O system can indicate performance degradation.

FROM nvcr.io/nvidia/cuda:12.6.1-base-ubuntu24.04
# RUN git clone https://github.com/linux-rdma/perftest && \
#     cd perftest/ && \
#     ./autogen.sh && \
#     ./configure && \
#     make && \
#     make install

# Create the script directly within the Dockerfile using a heredoc
ENV SCRIPT_FILE /usr/local/bin/gpu-monitor.sh

RUN echo "#!/bin/bash" >> $SCRIPT_FILE
RUN echo "nvidia-smi cuda-benchmarks # Benchmarking" >> $SCRIPT_FILE
RUN echo "nvidia-smi --query-gpu=utilization.gpu --format=csv # GPU utilization" >> $SCRIPT_FILE
RUN echo "nvidia-smi --query-gpu=memory.total,memory.used --format=csv # GPU memory allocation" >> $SCRIPT_FILE
RUN echo "nvidia-smi --query-gpu=temperature.gpu --format=csv # Temperature monitoring" >> $SCRIPT_FILE
RUN echo "nvidia-smi --query-gpu=power.draw --format=csv # Power usage" >> $SCRIPT_FILE
RUN echo "ib_write_bw -d mlx5_0 -a # I/O and Throughput for InfiniBand" >> $SCRIPT_FILE
RUN echo "bandwidthTest # CUDA BandwidthTest" >> $SCRIPT_FILE

# Make the script executable
RUN chmod +x $SCRIPT_FILE

# Set the script as the default command
CMD ["sh", "-c", "$SCRIPT_FILE"]
