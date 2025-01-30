FROM python:3.10

RUN python --version
RUN pip install -U pip
RUN pip install prometheus-client prometheus-api-client
RUN pip list | grep prometheus

# Command to run by default
CMD ["/bin/bash"]
