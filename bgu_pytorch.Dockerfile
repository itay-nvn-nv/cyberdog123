FROM pytorch/pytorch:2.7.1-cuda11.8-cudnn9-runtime

WORKDIR /workspace
COPY bgu_pytorch/wang_landau_walkers.py bgu_pytorch/utils.py bgu_pytorch/config.py /workspace
CMD ["python", "wang_landau_walkers.py", "-u"]