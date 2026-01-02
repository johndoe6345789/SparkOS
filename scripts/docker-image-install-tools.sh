#!/bin/bash
# Install required tools for building UEFI-bootable SparkOS image

set -e

apt-get update
apt-get install -y \
    gcc \
    g++ \
    make \
    cmake \
    qt6-base-dev \
    qt6-base-dev-tools \
    libqt6core6 \
    libqt6gui6 \
    libqt6widgets6 \
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
    udev
rm -rf /var/lib/apt/lists/*
