#!/bin/bash
# SparkOS Setup Script
# Sets up a minimal rootfs with busybox and essential utilities

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOTFS_DIR="$PROJECT_ROOT/rootfs"

echo "SparkOS Root Filesystem Setup"
echo "=============================="
echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$ROOTFS_DIR"/{bin,sbin,etc,proc,sys,dev,tmp,usr/{bin,sbin,lib,lib64},var,root,home}
mkdir -p "$ROOTFS_DIR/etc"/{init.d,network}
mkdir -p "$ROOTFS_DIR/var"/{log,run}

# Set permissions
chmod 1777 "$ROOTFS_DIR/tmp"
chmod 700 "$ROOTFS_DIR/root"

# Create basic config files
echo "Creating configuration files..."

# /etc/hostname
echo "sparkos" > "$ROOTFS_DIR/etc/hostname"

# /etc/hosts
cat > "$ROOTFS_DIR/etc/hosts" << 'EOF'
127.0.0.1   localhost
127.0.1.1   sparkos
::1         localhost ip6-localhost ip6-loopback
EOF

# /etc/passwd
cat > "$ROOTFS_DIR/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/sh
EOF

# /etc/group
cat > "$ROOTFS_DIR/etc/group" << 'EOF'
root:x:0:
EOF

# /etc/fstab
cat > "$ROOTFS_DIR/etc/fstab" << 'EOF'
# <file system> <mount point> <type> <options> <dump> <pass>
proc            /proc         proc    defaults          0 0
sysfs           /sys          sysfs   defaults          0 0
devtmpfs        /dev          devtmpfs defaults         0 0
tmpfs           /tmp          tmpfs   defaults          0 0
EOF

# /etc/profile
cat > "$ROOTFS_DIR/etc/profile" << 'EOF'
# SparkOS System Profile

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PS1='SparkOS:\w\$ '
export HOME=/root
export TERM=linux

# Welcome message
echo "Welcome to SparkOS!"
echo "Type 'help' for available commands"
echo ""
EOF

# Create .profile for root (busybox uses .profile instead of .bashrc)
cat > "$ROOTFS_DIR/root/.profile" << 'EOF'
# SparkOS Root Shell Configuration

# Set prompt
PS1='SparkOS:\w# '

# Aliases
alias ll='ls -lah'
alias ..='cd ..'

# Environment
export EDITOR=vi
export PAGER=less
EOF

# Create a simple help script
cat > "$ROOTFS_DIR/bin/sparkos-help" << 'EOF'
#!/bin/sh
cat << 'HELP'
SparkOS - Minimal Linux Distribution
====================================

Available commands:
  ls, cd, pwd      - Navigate filesystem
  cat, less        - View files
  mkdir, rm, cp    - File operations
  mount, umount    - Mount filesystems
  poweroff, reboot - System control
  help             - Show this help

This is a minimal system. To extend functionality:
  1. Mount additional filesystems
  2. Install packages (if package manager available)
  3. Build from source

For more information: https://github.com/johndoe6345789/SparkOS
HELP
EOF

chmod +x "$ROOTFS_DIR/bin/sparkos-help"
ln -sf sparkos-help "$ROOTFS_DIR/bin/help"

# Create README
cat > "$ROOTFS_DIR/README.txt" << 'EOF'
SparkOS Root Filesystem
=======================

This is the root filesystem for SparkOS, a minimal Linux distribution.

Directory Structure:
  /bin, /sbin       - Essential binaries
  /etc              - Configuration files
  /proc, /sys, /dev - Kernel interfaces
  /tmp              - Temporary files
  /usr              - User programs
  /var              - Variable data
  /root             - Root home directory
  /home             - User home directories

Note: This is a minimal system. You'll need to populate /bin and /usr/bin
with actual binaries (busybox, etc.) from a proper Linux system
or by cross-compiling.
EOF

echo ""
echo "Root filesystem structure created at: $ROOTFS_DIR"
echo ""
echo "Next steps:"
echo "  1. Build init: make init"
echo "  2. Install init: make install"
echo "  3. Copy busybox to rootfs/bin/ and create symlinks"
echo "  4. Create bootable image: sudo make image"
echo ""
echo "Note: You'll need to populate the rootfs with busybox binary"
echo "      before creating a bootable image."
