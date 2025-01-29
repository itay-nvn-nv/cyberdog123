FROM python:3.10

RUN python --version
RUN pip install -U pip
RUN pip install promcli prometheus-api-client
RUN promcli --version
RUN pip list

# Command to run by default
CMD ["/bin/bash"]
