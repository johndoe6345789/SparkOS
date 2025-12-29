#!/bin/bash
# Download a minimal Linux kernel for UEFI image

set -e

echo "=== Downloading Linux kernel from Ubuntu repositories ==="

mkdir -p /kernel
apt-get update

# Get the actual kernel package name (not the metapackage)
echo "Finding latest kernel package..."
KERNEL_PKG=$(apt-cache depends linux-image-generic | grep -E 'Depends.*linux-image-[0-9]' | head -1 | awk '{print $2}')

if [ -z "$KERNEL_PKG" ]; then
    echo "ERROR: Could not determine kernel package name"
    exit 1
fi

echo "Downloading kernel package: $KERNEL_PKG"
apt-get download "$KERNEL_PKG"

# Extract the kernel package
echo "Extracting kernel..."
dpkg -x ${KERNEL_PKG}*.deb /kernel

# Verify kernel was extracted
if [ ! -d /kernel/boot ]; then
    echo "ERROR: Kernel boot directory not found after extraction"
    exit 1
fi

KERNEL_FILE=$(find /kernel/boot -name "vmlinuz-*" | head -1)
if [ -z "$KERNEL_FILE" ]; then
    echo "ERROR: No kernel image found"
    exit 1
fi

echo "Kernel extracted successfully: $KERNEL_FILE"
ls -lh /kernel/boot/

# Clean up
rm -rf /var/lib/apt/lists/* ${KERNEL_PKG}*.deb
