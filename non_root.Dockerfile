FROM nginx

# Create the non-root user
RUN addgroup -g 1001 thedude && \
    adduser -D -u 1001 -G thedude thedude

# Switch to non-root user
USER thedude

# Keep container running
CMD ["sleep", "infinity"]
