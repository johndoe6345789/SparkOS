#!/bin/bash
# Install required tools for building UEFI-bootable SparkOS image

set -e

apt-get update
apt-get install -y \
    gcc \
    make \
    dosfstools \
    mtools \
    e2fsprogs \
    parted \
    gdisk \
    grub-efi-amd64-bin \
    grub-common \
    wget \
    busybox-static \
    kmod
rm -rf /var/lib/apt/lists/*
