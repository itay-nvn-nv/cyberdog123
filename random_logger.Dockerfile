FROM python:3.10.15-slim
RUN curl https://raw.githubusercontent.com/itaynvn-runai/scripts/refs/heads/main/random_logger.py > run.py
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["python run.py"]
