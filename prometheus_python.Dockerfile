FROM python:3.11

RUN apt update && apt install -y vim jq

RUN python --version
RUN pip install -U pip prometheus-client prometheus-api-client
RUN pip list | grep prometheus

RUN echo "import prometheus_api_client\n\
client = prometheus_api_client.prometheus_connect.PrometheusConnect(url = 'http://localhost:9090')\n\
query_result = client.custom_query(query='up')\n\
print(query_result)" > /tmp/prometheus.py

RUN cat /tmp/prometheus.py

CMD ["/bin/bash"]
