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
with actual binaries (bash, coreutils, etc.) from a proper Linux system
or by cross-compiling.
