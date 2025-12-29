#!/bin/bash
# Download a minimal Linux kernel for UEFI image

set -e

mkdir -p /kernel
apt-get update
apt-get download linux-image-generic
dpkg -x linux-image-*.deb /kernel
rm -rf /var/lib/apt/lists/* linux-image-*.deb
