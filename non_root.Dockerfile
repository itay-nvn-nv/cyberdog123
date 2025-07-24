FROM nginx

# Create the non-root user
RUN addgroup --gid 7777 thedude && \
    adduser --disabled-password --uid 5555 --ingroup thedude thedude

# Switch to non-root user
USER thedude

# Keep container running
CMD ["sleep", "infinity"]
