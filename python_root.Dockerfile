FROM ubuntu:24.04

# Update package lists
RUN apt-get update

# Install python3 and pip
RUN apt-get install -y python3 python3-pip

# keep root user as default
USER root

# set workdir to /app
WORKDIR /app

# Command to run by default
CMD ["/bin/bash"]
