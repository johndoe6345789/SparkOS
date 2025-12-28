#!/bin/bash
# SparkOS Setup Script
# Sets up a minimal rootfs with busybox and essential utilities
# Note: This script runs on the host system and uses bash for ${BASH_SOURCE}
# The target system uses busybox sh instead.

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

# /etc/resolv.conf - DNS configuration
cat > "$ROOTFS_DIR/etc/resolv.conf" << 'EOF'
# SparkOS DNS Configuration
# Fallback to public DNS servers for reliability
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

# /etc/network/interfaces - Wired network configuration
cat > "$ROOTFS_DIR/etc/network/interfaces" << 'EOF'
# SparkOS Network Configuration
# Wired networking only for bootstrapping

# Loopback interface
auto lo
iface lo inet loopback

# Primary wired interface (DHCP)
auto eth0
iface eth0 inet dhcp
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

Default Packages:
  - Kernel (Linux)
  - Init system (custom)
  - Busybox (shell and utilities)
  - Git (for installing spark CLI)
  - Sudo (privilege elevation)

Available commands:
  ls, cd, pwd      - Navigate filesystem
  cat, less        - View files
  mkdir, rm, cp    - File operations
  mount, umount    - Mount filesystems
  ip, ifconfig     - Network configuration
  ping, wget       - Network testing
  git              - Version control
  sudo             - Run commands as root
  poweroff, reboot - System control
  help             - Show this help

Network:
  Wired networking (eth0) configured via DHCP
  DNS: 8.8.8.8, 1.1.1.1 (Google and Cloudflare)
  To check network: ping 8.8.8.8
  To test DNS: ping google.com

Next Steps:
  1. Install spark CLI: git clone <spark-repo>
  2. Use spark CLI to configure WiFi and system
  3. Install additional packages as needed

For more information: https://github.com/johndoe6345789/SparkOS
HELP
EOF

chmod +x "$ROOTFS_DIR/bin/sparkos-help"
ln -sf sparkos-help "$ROOTFS_DIR/bin/help"

# Create network initialization script
cat > "$ROOTFS_DIR/sbin/init-network" << 'EOF'
#!/bin/sh
# SparkOS Network Initialization
# Brings up wired networking for system bootstrap

echo "Initializing network..."

# Bring up loopback
ip link set lo up 2>/dev/null || ifconfig lo up 2>/dev/null

# Bring up primary wired interface with DHCP
# Try eth0 first, then other common interface names
for iface in eth0 enp0s3 enp0s8 ens33; do
    if ip link show "$iface" >/dev/null 2>&1; then
        echo "Bringing up $iface..."
        
        # Bring up the interface
        if ip link set "$iface" up 2>/dev/null || ifconfig "$iface" up 2>/dev/null; then
            # Try to get IP via DHCP using busybox udhcpc
            if command -v udhcpc >/dev/null 2>&1; then
                # Run udhcpc in background, it will daemonize itself
                udhcpc -i "$iface" -b -t 5 2>/dev/null
            fi
        else
            echo "Warning: Failed to bring up $iface"
        fi
        break
    fi
done

echo "Network initialization complete"
EOF

chmod +x "$ROOTFS_DIR/sbin/init-network"

# Create README
cat > "$ROOTFS_DIR/README.txt" << 'EOF'
SparkOS Root Filesystem
=======================

This is the root filesystem for SparkOS, a minimal Linux distribution.

Minimal System Packages:
  - Linux Kernel (with networking support)
  - SparkOS Init System (custom)
  - Busybox (shell, utilities, networking)
  - Git (for installing spark CLI)
  - Sudo (privilege elevation)

Directory Structure:
  /bin, /sbin       - Essential binaries
  /etc              - Configuration files
  /proc, /sys, /dev - Kernel interfaces
  /tmp              - Temporary files
  /usr              - User programs
  /var              - Variable data
  /root             - Root home directory
  /home             - User home directories

Network Configuration:
  /etc/network/interfaces - Wired network (DHCP)
  /etc/resolv.conf        - DNS configuration (8.8.8.8, 1.1.1.1)
  /sbin/init-network      - Network initialization script

Bootstrap Process:
  1. System boots with wired networking (DHCP)
  2. Use git to clone spark CLI repository
  3. Use spark CLI to configure WiFi and system
  4. Install additional packages via spark CLI

Note: This is a minimal system. You'll need to populate /bin and /usr/bin
with actual binaries (busybox, git, sudo) from a proper Linux system
or by cross-compiling.
EOF

echo ""
echo "Root filesystem structure created at: $ROOTFS_DIR"
echo ""
echo "Network configuration:"
echo "  - Wired networking (DHCP) configured for eth0"
echo "  - DNS: 8.8.8.8, 1.1.1.1, 8.8.4.4, 1.0.0.1"
echo "  - Network init script: /sbin/init-network"
echo ""
echo "Next steps:"
echo "  1. Build init: make init"
echo "  2. Install init: make install"
echo "  3. Copy busybox, git, and sudo binaries to rootfs/bin/"
echo "  4. Create busybox symlinks"
echo "  5. Create bootable image: sudo make image"
echo ""
echo "Minimum required binaries:"
echo "  - busybox (provides shell, networking, utilities)"
echo "  - git (for installing spark CLI)"
echo "  - sudo (for privilege elevation)"
echo ""
echo "Note: Busybox should be compiled with networking support"
echo "      (CONFIG_UDHCPC, CONFIG_IFCONFIG, CONFIG_IP, CONFIG_PING, CONFIG_WGET)"
