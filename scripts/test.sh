#!/bin/sh
echo "SparkOS Docker Test Environment"
echo "================================"
echo ""

# Verify BusyBox is present and working
echo "Verifying BusyBox..."
echo "-------------------"
if command -v busybox >/dev/null 2>&1; then
    echo "✓ BusyBox is installed"
    echo ""
    echo "BusyBox version:"
    busybox | head -n 1
    echo ""
    echo "BusyBox location:"
    which busybox
    ls -lh "$(which busybox)"
    echo ""
    echo "Shell (/bin/sh) is BusyBox:"
    ls -lh /bin/sh
    if [ -L /bin/sh ]; then
        echo "  → /bin/sh is a symlink to: \"$(readlink /bin/sh)\""
    fi
    echo ""
    echo "Available BusyBox applets (sample):"
    # Store applet list once to avoid redundant executions
    APPLET_LIST=$(busybox --list)
    echo "$APPLET_LIST" | head -n 20
    echo "  ... and $(echo "$APPLET_LIST" | wc -l) total applets"
    echo ""
    echo "Networking applets (required for SparkOS):"
    for cmd in udhcpc ip ifconfig ping wget; do
        if echo "$APPLET_LIST" | grep -q "^${cmd}$"; then
            echo "  ✓ $cmd"
        else
            echo "  ✗ $cmd (NOT FOUND)"
        fi
    done
else
    echo "✗ BusyBox not found!"
    echo "  SparkOS requires BusyBox for shell and utilities"
    exit 1
fi

echo ""
echo "Verifying SparkOS init binary..."
echo "--------------------------------"
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
echo "--------------------------"
ls -la /sparkos/rootfs/
echo ""
echo "================================"
echo "✓ SparkOS is ready for testing!"
echo "================================"
echo ""
echo "Summary:"
echo "  - BusyBox: $(busybox | head -n 1)"
echo "  - Init: Custom SparkOS init system"
echo "  - Shell: BusyBox sh (/bin/sh)"
echo "  - Networking: BusyBox udhcpc, ip, ping, wget"
echo ""
echo "To test the init system:"
echo "  docker run --rm <image> /sparkos/rootfs/sbin/init --help"