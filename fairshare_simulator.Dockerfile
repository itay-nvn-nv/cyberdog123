# Dockerfile for NVIDIA KAI-Scheduler Fairshare Simulator
# This builds and runs the fairshare-simulator from the latest source

FROM golang:1.24-alpine AS builder

# Install git for cloning
RUN apk add --no-cache git

WORKDIR /build

# Cache bust: This ARG changes with each build when using --build-arg CACHEBUST=$(date +%s)
# Even without the arg, using --no-cache or --pull will force fresh clone
ARG CACHEBUST=1

# Always clone the latest version of the repository
RUN echo "Cache bust: ${CACHEBUST}" && \
    git clone --depth 1 https://github.com/NVIDIA/KAI-Scheduler.git

WORKDIR /build/KAI-Scheduler/cmd/fairshare-simulator

# Download dependencies and build
RUN go mod download || true
RUN CGO_ENABLED=0 GOOS=linux go build -o /fairshare-simulator .

# --- Runtime stage ---
FROM alpine:3.19

# Add ca-certificates, curl and vim for debugging/testing
RUN apk add --no-cache ca-certificates curl vim

WORKDIR /app

# Copy the built binary from builder
COPY --from=builder /fairshare-simulator /app/fairshare-simulator

# Copy documentation and example files for reference
COPY --from=builder /build/KAI-Scheduler/cmd/fairshare-simulator/README.md /app/README.md
COPY --from=builder /build/KAI-Scheduler/cmd/fairshare-simulator/example.http /app/example.http

# Expose the default port
EXPOSE 8080

# Run the simulator
ENTRYPOINT ["/app/fairshare-simulator"]
CMD ["-port=8080"]

