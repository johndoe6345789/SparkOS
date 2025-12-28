# SparkOS Docker Image
# Multi-stage build for minimal final image size

# Build stage - use gcc image which has all build tools pre-installed
FROM gcc:13-bookworm AS builder

# Set working directory
WORKDIR /build

# Copy source files
COPY src/ ./src/
COPY Makefile .
COPY scripts/ ./scripts/

# Build the init system
RUN make init

# Runtime stage - use Alpine for minimal size
FROM alpine:3.19

# Install file command for testing init binary
# file package provides the file(1) command to determine file type
RUN apk add --no-cache file

# Note: Alpine includes busybox by default

# Create minimal rootfs structure
RUN mkdir -p /sparkos/rootfs/bin \
    /sparkos/rootfs/sbin \
    /sparkos/rootfs/etc \
    /sparkos/rootfs/proc \
    /sparkos/rootfs/sys \
    /sparkos/rootfs/dev \
    /sparkos/rootfs/tmp \
    /sparkos/rootfs/usr/bin \
    /sparkos/rootfs/usr/sbin \
    /sparkos/rootfs/usr/lib \
    /sparkos/rootfs/var/log \
    /sparkos/rootfs/var/run \
    /sparkos/rootfs/root \
    /sparkos/rootfs/home/spark && \
    chmod 1777 /sparkos/rootfs/tmp && \
    chmod 700 /sparkos/rootfs/root && \
    chmod 755 /sparkos/rootfs/home/spark

# Copy built init binary from builder
COPY --from=builder /build/init /sparkos/rootfs/sbin/init

# Set up basic configuration files
RUN echo "sparkos" > /sparkos/rootfs/etc/hostname && \
    echo "127.0.0.1   localhost" > /sparkos/rootfs/etc/hosts && \
    echo "127.0.1.1   sparkos" >> /sparkos/rootfs/etc/hosts && \
    echo "root:x:0:0:root:/root:/bin/sh" > /sparkos/rootfs/etc/passwd && \
    echo "spark:x:1000:1000:SparkOS User:/home/spark:/bin/sh" >> /sparkos/rootfs/etc/passwd && \
    echo "root:x:0:" > /sparkos/rootfs/etc/group && \
    echo "spark:x:1000:" >> /sparkos/rootfs/etc/group

# Create a test entrypoint
COPY <<'EOF' /sparkos/test.sh
#!/bin/sh
echo "SparkOS Docker Test Environment"
echo "================================"
echo ""
echo "SparkOS init binary: /sparkos/rootfs/sbin/init"
echo ""
echo "Verifying init binary..."
if [ -f /sparkos/rootfs/sbin/init ]; then
    echo "✓ Init binary exists"
    ls -lh /sparkos/rootfs/sbin/init
    echo ""
    echo "File type:"
    if command -v file >/dev/null 2>&1; then
        file /sparkos/rootfs/sbin/init
    else
        echo "  (file command not available)"
    fi
    echo ""
    echo "Dependencies:"
    ldd /sparkos/rootfs/sbin/init 2>&1 || echo "  Static binary (no dependencies)"
else
    echo "✗ Init binary not found!"
    exit 1
fi
echo ""
echo "Root filesystem structure:"
ls -la /sparkos/rootfs/
echo ""
echo "SparkOS is ready for testing!"
echo ""
echo "To test the init system:"
echo "  docker run --rm <image> /sparkos/rootfs/sbin/init --help"
echo ""
exec /bin/sh
EOF

RUN chmod +x /sparkos/test.sh

WORKDIR /sparkos

# Set entrypoint
ENTRYPOINT ["/sparkos/test.sh"]
