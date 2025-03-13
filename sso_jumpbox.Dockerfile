FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends adduser sudo chpasswd

# Create the users and set passwords
RUN useradd -m -u 301 -g 601 john && echo "john:123456" | chpasswd
RUN useradd -m -u 302 -g 602 jane && echo "jane:123456" | chpasswd
RUN useradd -m -u 303 -g 603 steve && echo "steve:123456" | chpasswd
RUN useradd -m -u 304 -g 604 jacky && echo "jacky:123456" | chpasswd
RUN useradd -m -u 305 -g 605 blip && echo "blip:123456" | chpasswd

# Set permissions for the home directories
RUN chown john:601 /home/john
RUN chown jane:602 /home/jane
RUN chown steve:603 /home/steve
RUN chown jacky:604 /home/jacky
RUN chown blip:605 /home/blip

# Create admin user and grant sudo privileges
RUN useradd -m -G sudo admin && echo "admin:123456" | chpasswd

# Set working directory (optional)
WORKDIR /home/john

# Expose any necessary ports
# EXPOSE 8080

# Command to run when the container starts (replace with your application)
CMD ["/bin/bash"]
