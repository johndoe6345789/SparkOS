#!/bin/bash
# Create UEFI-bootable SparkOS image with GPT partition table

set -e

mkdir -p /output /mnt/esp /mnt/root

echo "=== Creating UEFI-bootable SparkOS image with GRUB ==="

# Create 1GB disk image (larger for kernel + bootloader)
dd if=/dev/zero of=/output/sparkos.img bs=1M count=1024

# Create GPT partition table
echo "Creating GPT partition table..."
parted -s /output/sparkos.img mklabel gpt

# Create EFI System Partition (ESP) - 200MB, FAT32
echo "Creating EFI System Partition..."
parted -s /output/sparkos.img mkpart ESP fat32 1MiB 201MiB
parted -s /output/sparkos.img set 1 esp on

# Create root partition - remaining space, ext4
echo "Creating root partition..."
parted -s /output/sparkos.img mkpart primary ext4 201MiB 100%

# Set up loop device for the image
LOOP_DEV=$(losetup -f)
losetup -P $LOOP_DEV /output/sparkos.img

# Wait for partition devices
sleep 1

# Format partitions
echo "Formatting EFI System Partition (FAT32)..."
mkfs.vfat -F 32 -n "SPARKOSEFI" ${LOOP_DEV}p1

echo "Formatting root partition (ext4)..."
mkfs.ext4 -L "SparkOS" ${LOOP_DEV}p2

# Mount ESP
echo "Mounting partitions..."
mount ${LOOP_DEV}p1 /mnt/esp
mount ${LOOP_DEV}p2 /mnt/root

# Install GRUB to ESP
echo "Installing GRUB bootloader..."
mkdir -p /mnt/esp/EFI/BOOT

# Create GRUB EFI binary using grub-mkstandalone
grub-mkstandalone \
    --format=x86_64-efi \
    --output=/mnt/esp/EFI/BOOT/BOOTX64.EFI \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=/dev/null"

# Find the kernel
KERNEL_PATH=$(find /kernel/boot -name "vmlinuz-*" | head -1)
KERNEL_VERSION=$(basename $KERNEL_PATH | sed 's/vmlinuz-//')
INITRD_PATH=$(find /kernel/boot -name "initrd.img-*" | head -1)

# Copy kernel and initrd to ESP
echo "Installing kernel..."
mkdir -p /mnt/esp/boot
cp $KERNEL_PATH /mnt/esp/boot/vmlinuz
if [ -f "$INITRD_PATH" ]; then cp $INITRD_PATH /mnt/esp/boot/initrd.img; fi

# Create GRUB configuration
mkdir -p /mnt/esp/boot/grub
printf '%s\n' \
    'set timeout=3' \
    'set default=0' \
    '' \
    'menuentry "SparkOS" {' \
    '    linux /boot/vmlinuz root=LABEL=SparkOS rw init=/sbin/init console=tty1 quiet' \
    '}' \
    > /mnt/esp/boot/grub/grub.cfg

# Set up root filesystem
echo "Setting up root filesystem..."
mkdir -p /mnt/root/{bin,sbin,etc,proc,sys,dev,tmp,usr/{bin,sbin,lib,lib64},var/{log,run},root,home/spark,boot}

# Install SparkOS init
cp /build/init /mnt/root/sbin/init
chmod 755 /mnt/root/sbin/init

# Install busybox
echo "Installing busybox..."
cp /bin/busybox /mnt/root/bin/busybox
chmod 755 /mnt/root/bin/busybox

# Create busybox symlinks for essential commands
for cmd in sh ls cat echo mount umount mkdir rm cp mv chmod chown ln ps kill; do
    ln -sf busybox /mnt/root/bin/$cmd
done

# Create system configuration files
echo "sparkos" > /mnt/root/etc/hostname
echo "127.0.0.1   localhost" > /mnt/root/etc/hosts
echo "127.0.1.1   sparkos" >> /mnt/root/etc/hosts
echo "root:x:0:0:root:/root:/bin/sh" > /mnt/root/etc/passwd
echo "spark:x:1000:1000:SparkOS User:/home/spark:/bin/sh" >> /mnt/root/etc/passwd
echo "root:x:0:" > /mnt/root/etc/group
echo "spark:x:1000:" >> /mnt/root/etc/group

# Copy README to root partition
cp /build/config/image-readme.txt /mnt/root/README.txt

# Sync and unmount
echo "Finalizing image..."
sync
umount /mnt/esp
umount /mnt/root
losetup -d $LOOP_DEV

# Compress the image
echo "Compressing image..."
gzip -9 /output/sparkos.img
echo "UEFI-bootable image created: /output/sparkos.img.gz"
