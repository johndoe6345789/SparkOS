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
    kmod \
    udev \
    bc \
    bison \
    flex \
    libelf-dev \
    libssl-dev \
    xz-utils \
    cpio
rm -rf /var/lib/apt/lists/*
