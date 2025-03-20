FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends adduser sudo

# Create the groups first!
RUN groupadd -g 6010 johnnies
RUN groupadd -g 6020 janies
RUN groupadd -g 6030 stevies
RUN groupadd -g 6040 jackies
RUN groupadd -g 6050 blipis


# Create the users and set passwords
RUN useradd -m -u 3010 -g 6010 john && echo "john:123456" | chpasswd
RUN useradd -m -u 3020 -g 6020 jane && echo "jane:123456" | chpasswd
RUN useradd -m -u 3030 -g 6030 steve && echo "steve:123456" | chpasswd
RUN useradd -m -u 3040 -g 6040 jacky && echo "jacky:123456" | chpasswd
RUN useradd -m -u 3050 -g 6050 blip && echo "blip:123456" | chpasswd

# Set permissions for the home directories
RUN chown john:johnnies /home/john
RUN chown jane:janies /home/jane
RUN chown steve:stevies /home/steve
RUN chown jacky:jackies /home/jacky
RUN chown blip:blipis /home/blip

# Secure home directories (restrict other users)
RUN chmod 700 /home/john /home/jane /home/steve /home/jacky /home/blip

# Create admin user and grant sudo privileges
RUN useradd -m -G sudo admin && echo "admin:123456" | chpasswd

RUN cat /etc/passwd
RUN cat /etc/group

# Set working directory (optional)
WORKDIR /home/john

# Command to run when the container starts (replace with your application)
CMD ["/bin/bash"]
