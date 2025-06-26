FROM python:3.11-slim

# Define environment variables (optional, but good practice)
ENV USERNAME=developer
ENV PASSWORD=123456
ENV SSH_PORT=22
ENV USER_UID=5000
ENV USER_GID=5000

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends vim curl jq openssh-server sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create group and user with specific UID/GID
RUN groupadd -g $USER_GID $USERNAME && \
    useradd -m -u $USER_UID -g $USER_GID -s /bin/bash "$USERNAME" && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo "$USERNAME"

# Configure SSH
RUN mkdir -p /home/"$USERNAME"/.ssh && \
    chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh && \
    chmod 700 /home/"$USERNAME"/.ssh

#  Uncomment to generate new ssh keys.  ***HIGHLY INSECURE FOR PRODUCTION***
#  RUN ssh-keygen -t rsa -b 4096 -N "" -f /home/"$USERNAME"/.ssh/id_rsa && \
#      chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh/id_rsa*

# Allow password authentication (ONLY FOR DEV - REMOVE FOR PRODUCTION!)
RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config

# Create the /run/sshd directory and ensure it has the correct permissions
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd

# Create a startup script that can run sshd as non-root
RUN echo '#!/bin/bash\n\
# Generate host keys if they don'\''t exist\n\
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then\n\
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""\n\
fi\n\
if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then\n\
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""\n\
fi\n\
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then\n\
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""\n\
fi\n\
\n\
# Start sshd in foreground\n\
exec /usr/sbin/sshd -D -e\n' > /start-sshd.sh && \
    chmod +x /start-sshd.sh

# Switch to non-root user
USER $USER_UID:$USER_GID

# Expose SSH port
EXPOSE $SSH_PORT

# Use the startup script
CMD ["/start-sshd.sh"]
