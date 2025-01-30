FROM python:3.10

RUN apt update && apt install -y vim jq

RUN python --version
RUN pip install -U pip prometheus-client prometheus-api-client
RUN pip list | grep prometheus

CMD ["/bin/bash"]
