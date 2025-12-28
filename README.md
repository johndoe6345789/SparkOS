# SparkOS

A minimal Linux distribution designed for simplicity and portability. SparkOS features:

- **Minimal footprint**: Barebones Linux system with busybox shell
- **Portable**: dd-able disk image for USB flash drives
- **Custom init**: Lightweight C init system
- **Future-ready**: Designed to support Qt6/QML GUI and Wayland
- **Root elevation**: Uses sudo for privilege management
- Wired networking only at first to bootstrap system, once you have installed spark command, the spark cli will configure the rest of the system imcl wifi.
- Next to nothing installed by default, just kernel, init system, busybox, sudo and git.

## MVP Status

The current MVP provides:
- ✅ Custom init system written in C
- ✅ Working busybox shell environment
- ✅ dd-able AMD64 image creation scripts
- ✅ Minimal root filesystem structure
- ✅ Build system (Makefile)

## Prerequisites

To build SparkOS, you need:

- GCC compiler
- GNU Make
- Linux system (for building)

To create bootable images (optional):
- Root privileges
- `syslinux` bootloader
- `parted` partitioning tool
- `losetup` for loop devices
- `mkfs.ext4` filesystem tools

## Quick Start

### Building the Init System

```bash
# Build the init binary
make init

# Or use the quick build script
./scripts/build.sh
```

### Setting Up Root Filesystem

```bash
# Create the root filesystem structure
./scripts/setup_rootfs.sh

# Install init to rootfs
make install
```

### Creating a Bootable Image (Advanced)

⚠️ **Warning**: Creating bootable images requires root privileges and proper tools.

```bash
# Install required tools (Ubuntu/Debian)
sudo apt-get install syslinux parted

# Build everything and create image
make all
sudo make image

# Write to USB drive (CAUTION: destroys all data on target!)
sudo dd if=sparkos.img of=/dev/sdX bs=4M status=progress
```

Replace `/dev/sdX` with your actual USB device (e.g., `/dev/sdb`).

## Project Structure

```
SparkOS/
├── config/              # Build configuration files
│   └── build.conf       # Build parameters
├── scripts/             # Build and setup scripts
│   ├── build.sh         # Quick build script
│   ├── setup_rootfs.sh  # Root filesystem setup
│   └── create_image.sh  # Image creation script
├── src/                 # Source code
│   └── init.c           # Custom init system
├── rootfs/              # Root filesystem (generated)
│   ├── bin/             # Essential binaries
│   ├── sbin/            # System binaries
│   ├── etc/             # Configuration files
│   └── ...              # Standard FHS directories
├── Makefile             # Build system
└── README.md            # This file
```

## Architecture

### Init System

SparkOS uses a custom init system (`/sbin/init`) that:
- Mounts essential filesystems (proc, sys, dev, tmp)
- Spawns a busybox sh login shell
- Handles process reaping
- Respawns shell on exit

### Root Filesystem

Follows the Filesystem Hierarchy Standard (FHS):
- `/bin`, `/sbin`: Essential binaries
- `/etc`: System configuration
- `/proc`, `/sys`, `/dev`: Kernel interfaces
- `/tmp`: Temporary files
- `/usr`: User programs and libraries
- `/var`: Variable data
- `/root`: Root user home
- `/home`: User home directories

## Development

### Building Components

```bash
# Build init system only
make init

# Install to rootfs
make install

# Clean build artifacts
make clean

# Show help
make help
```

### Adding Binaries to Root Filesystem

To create a fully functional system, you need to populate the rootfs with binaries:

```bash
# Example: Add busybox (statically linked is best)
cp /bin/busybox rootfs/bin/

# Create busybox symlinks for common utilities
cd rootfs/bin
for cmd in sh ls cat mkdir rm cp mount umount chmod chown ln; do
    ln -sf busybox $cmd
done
cd ../..

# If using dynamically linked busybox, copy required libraries
ldd rootfs/bin/busybox  # Check dependencies
# Copy libraries to rootfs/lib or rootfs/lib64
```

## Future Roadmap

- [ ] Qt6/QML full screen GUI
- [ ] Wayland compositor integration
- [ ] C++ CLI tools
- [ ] Package management
- [ ] sudo integration
- [ ] Network configuration
- [ ] Android-like UI/UX

## Contributing

Contributions are welcome! This is an early-stage project focused on:
1. Maintaining minimal footprint
2. Clean, readable code
3. Proper documentation

## License

See LICENSE file for details.

## Notes

This is an MVP implementation. The system currently provides:
- Basic init system
- Shell environment
- Build infrastructure
- Image creation tooling

To create a fully bootable system, you'll also need:
- Linux kernel binary (`vmlinuz`)
- Essential system binaries and libraries
- Bootloader installation (handled by scripts)
A single binary on top of Linux / Wayland that manages the OS, C++ CLI and Qt6/QML Full screen GUI. Android like design but more desktop orientated. A distribution that can be dd'ed to a USB flash drive. Root elevation powered by sudo. This project will need to set up a barebones distro (doesn't really need to be based on another, to keep things clean)

MVP is just a to get to a shell prompt with sudo support. Install minimum on system using busybox for minimal footprint.

We should try to build the system with github actions if possible.

This OS is not designed to use any of the other window managers.

Example:

$ spark gui

$ spark install package mypackage

$ spark remove package mypackage

$ spark run mypackage

Spark command will be expanded to multiple domains, gaming, server admin, you name it.
