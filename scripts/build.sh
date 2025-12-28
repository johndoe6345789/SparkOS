#!/bin/bash
# Quick build script for SparkOS development

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "SparkOS Quick Build"
echo "==================="
echo ""

# Build init
echo "Building init system..."
make init

# Setup rootfs structure
echo ""
echo "Setting up root filesystem..."
./scripts/setup_rootfs.sh

# Install init
echo ""
echo "Installing init to rootfs..."
make install

echo ""
echo "Build complete!"
echo ""
echo "Next steps to create a full bootable system:"
echo "  1. Copy busybox to rootfs/bin/"
echo "     (cp /bin/busybox rootfs/bin/)"
echo "  2. Create symlinks in rootfs/bin for common utilities"
echo "     (cd rootfs/bin && for cmd in sh ls cat mkdir rm cp mount; do ln -sf busybox \$cmd; done)"
echo "  3. Add a Linux kernel to rootfs/boot/vmlinuz"
echo "  4. Run: sudo make image"
echo ""
