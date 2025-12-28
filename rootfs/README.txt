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
  /home/spark       - Default user home directory

Default User:
  Username: spark (UID 1000)
  Home: /home/spark
  Sudo: Full access without password
  Scripts: ~/clone-sparkos.sh for installing spark CLI

Network Configuration:
  /etc/network/interfaces - Wired network (DHCP)
  /etc/resolv.conf        - DNS configuration (8.8.8.8, 1.1.1.1)
  /sbin/init-network      - Network initialization script

Bootstrap Process:
  1. System boots as 'spark' user with wired networking (DHCP)
  2. Run ~/clone-sparkos.sh to install spark CLI
  3. Use spark CLI to configure WiFi and system
  4. Install additional packages via spark CLI
  5. Use 'sudo' for any root-level operations

Note: This is a minimal system. You'll need to populate /bin and /usr/bin
with actual binaries (busybox, git, sudo) from a proper Linux system
or by cross-compiling.
