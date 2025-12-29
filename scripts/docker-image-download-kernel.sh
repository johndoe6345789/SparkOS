#!/bin/bash
# Download a minimal Linux kernel for UEFI image

set -e

mkdir -p /kernel
apt-get update
apt-get download linux-image-generic

# The linux-image-generic is a metapackage, we need to get the actual kernel
KERNEL_VERSION=$(apt-cache depends linux-image-generic | grep Depends | grep linux-image | head -1 | awk '{print $2}')
apt-get download $KERNEL_VERSION

# Extract the actual kernel package (not the metapackage)
dpkg -x ${KERNEL_VERSION}*.deb /kernel
rm -rf /var/lib/apt/lists/* linux-image-*.deb
