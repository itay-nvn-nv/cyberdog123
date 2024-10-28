FROM pytorch/pytorch:2.5.0-cuda12.1-cudnn9-runtime
RUN curl https://raw.githubusercontent.com/itaynvn-runai/scripts/refs/heads/main/gpu_utilizer_pytorch.py > run.py
RUN pip install wandb torch
RUN python version
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["python run.py"]
