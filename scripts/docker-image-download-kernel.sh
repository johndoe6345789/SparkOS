#!/bin/bash
# Download and build a minimal Linux kernel from kernel.org

set -e

echo "=== Building minimal Linux kernel from kernel.org ==="

# Use a stable LTS kernel version
KERNEL_VERSION="6.6.68"
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)

mkdir -p /kernel/build
cd /kernel/build

# Download kernel source
echo "Downloading kernel ${KERNEL_VERSION}..."
wget -q --show-progress https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_MAJOR}.x/linux-${KERNEL_VERSION}.tar.xz

# Extract
echo "Extracting kernel source..."
tar -xf linux-${KERNEL_VERSION}.tar.xz
cd linux-${KERNEL_VERSION}

# Create minimal config for x86_64 UEFI boot
echo "Configuring kernel for minimal UEFI boot..."
make defconfig
make kvm_guest.config

# Enable essential features for SparkOS
scripts/config --enable CONFIG_EFI
scripts/config --enable CONFIG_EFI_STUB
scripts/config --enable CONFIG_DEVTMPFS
scripts/config --enable CONFIG_DEVTMPFS_MOUNT
scripts/config --enable CONFIG_TMPFS
scripts/config --enable CONFIG_PROC_FS
scripts/config --enable CONFIG_SYSFS
scripts/config --enable CONFIG_EXT4_FS
scripts/config --enable CONFIG_VFAT_FS
scripts/config --enable CONFIG_NLS_CODEPAGE_437
scripts/config --enable CONFIG_NLS_ISO8859_1
scripts/config --enable CONFIG_TTY
scripts/config --enable CONFIG_SERIAL_8250
scripts/config --enable CONFIG_SERIAL_8250_CONSOLE

# Disable unnecessary features to speed up build
scripts/config --disable CONFIG_DEBUG_INFO
scripts/config --disable CONFIG_DEBUG_INFO_BTF
scripts/config --disable CONFIG_DEBUG_INFO_DWARF4
scripts/config --disable CONFIG_DEBUG_INFO_DWARF5
scripts/config --disable CONFIG_GDB_SCRIPTS
scripts/config --set-str CONFIG_LOCALVERSION "-sparkos"

# Build kernel (use all available cores)
echo "Building kernel (this may take several minutes)..."
make -j$(nproc) bzImage

# Copy kernel to expected location
echo "Installing kernel..."
mkdir -p /kernel/boot
cp arch/x86/boot/bzImage /kernel/boot/vmlinuz-${KERNEL_VERSION}

# Clean up build directory to save space
cd /
rm -rf /kernel/build

echo "Kernel build complete: /kernel/boot/vmlinuz-${KERNEL_VERSION}"
ls -lh /kernel/boot/
