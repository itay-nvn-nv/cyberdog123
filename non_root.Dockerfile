FROM ubuntu:22.04

# Create the non-root user
RUN addgroup --gid 7777 thedude && \
    adduser --disabled-password --uid 5555 --ingroup thedude --home /home/thedude thedude

# Switch to non-root user
USER thedude

# Simple command that tries to write to home directory, keeps running if successful
CMD ["sh", "-c", "mkdir -p ~/.local/share && echo 'success' && sleep infinity || (echo 'failed: permission denied' && exit 1)"]
