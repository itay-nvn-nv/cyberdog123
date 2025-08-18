import os
import time
from datetime import timedelta
import subprocess

import torch
import torch.distributed as dist
import torch.nn.parallel

from utils import Walker, exchange
from config import eq_limits, params
from config import paired_ranks_for_exchange

def main():
    # Run Infiniband debug commands early
    try:
        print("Running ibstat:")
        subprocess.run(["ibstat"], check=True)
    except Exception as e:
        print("Failed to run ibstat:", e)

    try:
        print("Running ibv_devinfo:")
        subprocess.run(["ibv_devinfo"], check=True)
    except Exception as e:
        print("Failed to run ibv_devinfo:", e)

    # Environment variables for threading
    os.environ["OMP_NUM_THREADS"] = '8'
    os.environ["MKL_NUM_THREADS"] = "8"

    rank = int(os.environ["RANK"])
    world_size = int(os.environ["WORLD_SIZE"])
    master_addr = os.environ["MASTER_ADDR"]
    master_port = os.environ.get("MASTER_PORT", "29500")

    # Set CUDA device based on what's available
    device = torch.device(f"cuda:{torch.cuda.current_device()}")
    torch.cuda.set_device(device)

    # Print selected environment variables for debugging
    print("Rank:", rank)
    for var in [
        "NCCL_SOCKET_IFNAME", "NCCL_IB_HCA", "NCCL_IB_DISABLE",
        "UCX_NET_DEVICES", "UCX_TLS"
    ]:
        if var in os.environ:
            print(f"[ENV] {var}={os.environ[var]}")

    dist.init_process_group(
        backend="nccl",
        init_method=f"tcp://{master_addr}:{master_port}",
        rank=rank,
        world_size=world_size,
        timeout=timedelta(minutes=600)
    )

    import cupy as cp
    cp.random.seed(rank)
    torch.manual_seed(rank)

    limits = eq_limits[rank]
    walker = Walker(limits, params, device, rank)

    t0 = time.time()
    print_every = 5000
    exchange_every = 50000
    save_every = 40000

    exchange_count = 0
    it = 0

    print(f'Starting one walker per container in rank {rank}')
    while True:
        walker.step()
        it += 1

        if it % exchange_every == 0:
            exchange_direction = exchange_count % 2
            exchange_count += 1
            pair = paired_ranks_for_exchange[exchange_direction]
            paired_rank = pair[rank]
            print(f'\nit: {it}. I will try to exchange with rank {paired_rank}')
            exchange(walker, paired_rank)

        if it % print_every == 0:
            print('\nTime:', f'{time.time() - t0:.2f}', 'rank', f'{rank}', 'it:', f'{it}')
            if walker.need_initialization:
                print('Not yet initialized.')
            else:
                h = walker.h.size - (walker.h > 0.9 * walker.h.mean()).sum()
                print('h_zeros:', (walker.h == 0).sum(), '  cond_h:', f'{h}')
                print(f'reject_out rate: {walker.reject_out / print_every}  accept rate: {walker.random_accept / print_every}')
                walker.reject_out = 0
                walker.random_accept = 0
            t0 = time.time()

        if it % save_every == 0:
            walker.save()

    dist.barrier()
    print(f'{rank} finished!')
    dist.destroy_process_group()

if __name__ == "__main__":
    main()
