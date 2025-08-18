runai training pytorch submit bgu-pytorch-v5 \
-p test -i cyberdog123/bgu_pytorch --large-shm \
-e NCCL_DEBUG=INFO  -e NCCL_P2P_DISABLE=0  \
-e NCCL_IB_DISABLE=0  -e NCCL_SOCKET_IFNAME=^lo,docker \
-e NCCL_IB_HCA=mlx5_0  -e UCX_NET_DEVICES=mlx5_0:1 \
-e UCX_TLS=rc,sm,cuda_copy  --clean-pod-policy All \
--gpu-portion-request 0.3 \
--cpu-core-request 1 --cpu-core-limit 8 \
--cpu-memory-request 1Gi --cpu-memory-limit 16Gi \
--workers 3 --allow-privilege-escalation