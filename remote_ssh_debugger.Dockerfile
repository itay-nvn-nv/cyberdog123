FROM python:3.11-slim

# Define environment variables (optional, but good practice)
ENV USERNAME=developer
ENV PASSWORD=123456
ENV SSH_PORT=22

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl jq openssh-server sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user and set password
RUN useradd -m -s /bin/bash "$USERNAME" && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo "$USERNAME"

# Configure SSH
RUN mkdir /home/"$USERNAME"/.ssh && \
    chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh && \
    chmod 700 /home/"$USERNAME"/.ssh

#  Uncomment to generate new ssh keys.  ***HIGHLY INSECURE FOR PRODUCTION***
#  RUN ssh-keygen -t rsa -b 4096 -N "" -f /home/"$USERNAME"/.ssh/id_rsa


# Allow password authentication (ONLY FOR DEV - REMOVE FOR PRODUCTION!)
RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config


# Expose SSH port
EXPOSE $SSH_PORT

# Startup script (required for running SSH in a container)
CMD ["/usr/sbin/sshd", "-D"]
