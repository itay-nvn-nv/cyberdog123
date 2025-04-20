FROM python:3.11

RUN python --version
RUN pip install -U pip
RUN pip install requests pygments

RUN wget https://raw.githubusercontent.com/itay-nvn-nv/scripts/refs/heads/main/prometheus_query.py -O /prometheus_query.py

CMD ["sleep", "infinity"]
