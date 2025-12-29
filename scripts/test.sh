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