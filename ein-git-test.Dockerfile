FROM python:3.13-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive
# Define environment variables, CHANGE UID TO YOUR OWN UID
ENV USERNAME=developer
ENV PASSWORD=developer
ENV SSH_PORT=2222
ENV USER_UID=7777
ENV USER_GID=$USER_UID

########################### SSH Installation ##################################

RUN apt update && apt install -y openssh-server

# Create group and user with specific UID/GID
RUN groupadd -g $USER_GID $USERNAME && \
    useradd -m -u $USER_UID -g $USER_GID -s /bin/bash "$USERNAME" && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo "$USERNAME"

# Configure SSH
RUN mkdir -p /home/"$USERNAME"/.ssh && \
    chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh && \
    chmod 700 /home/"$USERNAME"/.ssh

# Allow password authentication and configure for non-root operation
RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config

# Create the /run/sshd directory and ensure it has the correct permissions
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd

# Create SSH directory in user's home and copy sshd_config
RUN mkdir -p /home/"$USERNAME"/.ssh/etc && \
    cp /etc/ssh/sshd_config /home/"$USERNAME"/.ssh/etc/sshd_config && \
    chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Modify sshd_config to use user-writable paths and non-privileged port
RUN sed -i "s|#HostKey /etc/ssh/ssh_host_rsa_key|HostKey /home/$USERNAME/.ssh/ssh_host_rsa_key|g" /home/"$USERNAME"/.ssh/etc/sshd_config && \
    sed -i "s|#HostKey /etc/ssh/ssh_host_ecdsa_key|HostKey /home/$USERNAME/.ssh/ssh_host_ecdsa_key|g" /home/"$USERNAME"/.ssh/etc/sshd_config && \
    sed -i "s|#HostKey /etc/ssh/ssh_host_ed25519_key|HostKey /home/$USERNAME/.ssh/ssh_host_ed25519_key|g" /home/"$USERNAME"/.ssh/etc/sshd_config && \
    sed -i "s|#PidFile /var/run/sshd.pid|PidFile /home/$USERNAME/.ssh/sshd.pid|g" /home/"$USERNAME"/.ssh/etc/sshd_config && \
    sed -i "s|#Port 22|Port $SSH_PORT|g" /home/"$USERNAME"/.ssh/etc/sshd_config && \
    chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Create a startup script that generates host keys in user directory. Remove the -e flag if you are using mac/unix
RUN echo -e '#!/bin/bash\n\
SSH_DIR="/home/'$USERNAME'/.ssh"\n\
\n\
# Generate host keys if they don'\''t exist\n\
if [ ! -f "$SSH_DIR/ssh_host_rsa_key" ]; then\n\
    echo "Generating RSA host key..."\n\
    ssh-keygen -t rsa -f "$SSH_DIR/ssh_host_rsa_key" -N "" -q\n\
fi\n\
if [ ! -f "$SSH_DIR/ssh_host_ecdsa_key" ]; then\n\
    echo "Generating ECDSA host key..."\n\
    ssh-keygen -t ecdsa -f "$SSH_DIR/ssh_host_ecdsa_key" -N "" -q\n\
fi\n\
if [ ! -f "$SSH_DIR/ssh_host_ed25519_key" ]; then\n\
    echo "Generating ED25519 host key..."\n\
    ssh-keygen -t ed25519 -f "$SSH_DIR/ssh_host_ed25519_key" -N "" -q\n\
fi\n\
\n\
# Start sshd with custom config\n\
echo "Starting SSH daemon..."\n\
exec /usr/sbin/sshd -D -e \\\n\
     -f "$SSH_DIR/etc/sshd_config" \\\n\
     -o PidFile="$SSH_DIR/sshd.pid" \\\n\
     -o UsePAM=no\n' > /start-sshd.sh && \
    chmod +x /start-sshd.sh

################################## End of SSH installation ##################################

############################################## Switch to user and start the server ##############################################

# Switch to non-root user
USER $USER_UID:$USER_GID

# Expose SSH port
EXPOSE $SSH_PORT

# Use the startup script
CMD ["/start-sshd.sh"]
