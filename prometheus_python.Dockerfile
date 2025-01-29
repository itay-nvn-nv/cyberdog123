FROM nginx

# Update package lists
RUN apt update

# Install python3 and pip
RUN apt install -y python3 python3-pip

RUN pip install -U pip
RUN pip install promcli prometheus-api-client
RUN promcli --version

# Command to run by default
CMD ["/bin/bash"]
