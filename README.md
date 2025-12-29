# SparkOS

A minimal Linux distribution designed for simplicity and portability. SparkOS features:

- **Minimal footprint**: Barebones Linux system with busybox shell
- **Portable**: dd-able disk image for USB flash drives
- **Custom init**: Lightweight C init system
- **Future-ready**: Designed to support Qt6/QML GUI and Wayland
- **Root elevation**: Uses sudo for privilege management
- **Bootstrap networking**: Wired networking with DHCP for initial setup
- Minimal installation by default: kernel, init system, busybox, git, and sudo
- DNS configured with fallback to public DNS servers (8.8.8.8, 1.1.1.1)
- WiFi and advanced networking configured later via spark CLI

## MVP Status

The current MVP provides:
- ✅ Custom init system written in C
- ✅ Working busybox shell environment
- ✅ dd-able AMD64 image creation scripts
- ✅ Minimal root filesystem structure
- ✅ Build system (Makefile)
- ✅ Wired networking configuration with DHCP
- ✅ DNS configuration with public fallback servers
- ✅ Docker container for testing
- ✅ Automated builds and publishing to GHCR
- ✅ Multi-architecture Docker images (AMD64 and ARM64)
- ✅ CI/CD pipeline for compiled release packages
- ✅ GitHub releases with pre-built binaries

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

### Using Pre-built Releases (Easiest)

Download the latest release package from the [GitHub Releases page](https://github.com/johndoe6345789/SparkOS/releases):

```bash
# Download the latest release (replace VERSION with actual version, e.g., v1.0.0)
wget https://github.com/johndoe6345789/SparkOS/releases/download/VERSION/sparkos-release.zip

# Extract the package
unzip sparkos-release.zip
cd sparkos/

# The init binary is already compiled and ready to use
ls -lh init

# Copy to your rootfs or use directly
cp init /path/to/your/rootfs/sbin/init
```

The release package includes:
- Pre-compiled init binary (statically linked, ready to use)
- Complete source code
- Build scripts and configuration
- Root filesystem structure
- Full documentation

### Using Docker (Recommended for Testing)

The easiest way to test SparkOS is using the pre-built Docker image from GitHub Container Registry:

```bash
# Pull and run the latest image (automatically selects the correct architecture)
docker pull ghcr.io/johndoe6345789/sparkos:latest
docker run --rm ghcr.io/johndoe6345789/sparkos:latest

# Or build locally
docker build -t sparkos:local .
docker run --rm sparkos:local

# Or use Docker Compose for even simpler testing
docker-compose up

# Build for specific architecture
docker buildx build --platform linux/amd64 -t sparkos:amd64 --load .
docker buildx build --platform linux/arm64 -t sparkos:arm64 --load .
```

The Docker image includes:
- Pre-built init system binary
- Minimal root filesystem structure
- Test environment for validation
- **Multi-architecture support**: Available for both AMD64 (x86_64) and ARM64 (aarch64) architectures

Images are automatically built and published to [GitHub Container Registry](https://github.com/johndoe6345789/SparkOS/pkgs/container/sparkos) on every push to main branch.

**Building Releases with Docker (No Root Required):**

Create release packages easily using Docker without needing root privileges or special tools:

```bash
# Build a release package for version v1.0.0
./scripts/docker-release.sh v1.0.0

# The release ZIP will be created in release/sparkos-release.zip
# This is the same artifact that GitHub Actions creates
```

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
```

### Installing to USB Drive

Once you have created the `sparkos.img` file, use the installation script to write it to a USB drive or storage device:

```bash
# Use the installation script (RECOMMENDED)
sudo ./scripts/install.sh /dev/sdX

# The script will:
# - Validate the target drive
# - Display warnings about data destruction
# - Require confirmation before proceeding
# - Show progress during installation
# - Verify successful installation
```

Replace `/dev/sdX` with your actual USB device (e.g., `/dev/sdb`, `/dev/nvme1n1`).

**⚠️ WARNING**: This will permanently erase all data on the target drive!

## Project Structure

```
SparkOS/
├── .github/             # GitHub Actions workflows
│   └── workflows/
│       └── docker-publish.yml  # Docker build and publish workflow
├── config/              # Build configuration files
│   └── build.conf       # Build parameters
├── scripts/             # Build and setup scripts
│   ├── build.sh         # Quick build script
│   ├── setup_rootfs.sh  # Root filesystem setup
│   ├── create_image.sh  # Image creation script
│   └── install.sh       # Installation script for USB drives
├── src/                 # Source code
│   └── init.c           # Custom init system
├── rootfs/              # Root filesystem (generated)
│   ├── bin/             # Essential binaries
│   ├── sbin/            # System binaries
│   ├── etc/             # Configuration files
│   └── ...              # Standard FHS directories
├── Dockerfile           # Docker image definition
├── Makefile             # Build system
└── README.md            # This file
```

## Architecture

### Init System

SparkOS uses a custom init system (`/sbin/init`) that:
- Mounts essential filesystems (proc, sys, dev, tmp)
- Initializes wired networking via DHCP
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

### Networking

SparkOS provides wired networking for initial bootstrap:
- **DHCP**: Automatic IP configuration via busybox udhcpc
- **DNS**: Fallback to public DNS servers (8.8.8.8, 8.8.4.4, 1.1.1.1, 1.0.0.1)
- **Interface**: Primary wired interface (eth0) configured automatically
- **WiFi**: Will be configured later via spark CLI after installation

## Development

### CI/CD and Docker

SparkOS uses GitHub Actions for continuous integration and delivery:

**Automated Builds:**
- Docker images are automatically built on every push to main/develop branches
- Compiled release packages are automatically built on every push to main/develop branches
- Both are also built for pull requests (testing only, not published)
- Tagged releases automatically create versioned Docker images and GitHub releases with compiled binaries
- **Multi-architecture builds**: Images are built for both AMD64 (x86_64) and ARM64 (aarch64)

**Compiled Releases:**
- Pre-compiled init binaries are available as GitHub releases for version tags
- Release packages include: compiled init binary, source code, build scripts, and documentation
- Download releases from the [GitHub Releases page](https://github.com/johndoe6345789/SparkOS/releases)
- Build artifacts are available for all workflow runs (retained for 90 days)

**Container Registry:**
- Images are published to GitHub Container Registry (GHCR)
- Pull images: `docker pull ghcr.io/johndoe6345789/sparkos:latest`
- Available tags: `latest`, `main`, `develop`, version tags (e.g., `v1.0.0`)
- Docker will automatically select the correct architecture for your platform

**Docker Development:**
```bash
# Build Docker image locally
docker build -t sparkos:dev .

# Build for multiple architectures (requires Docker Buildx)
docker buildx build --platform linux/amd64,linux/arm64 -t sparkos:multiarch .

# Test the image
docker run --rm sparkos:dev

# Or use Docker Compose
docker-compose up

# Inspect the init binary
docker run --rm sparkos:dev sh -c "ls -lh /sparkos/rootfs/sbin/init"
```

### Creating Releases

**Using Docker (Recommended - No Root Required):**

Build release packages locally using Docker without needing root privileges:

```bash
# Build a release package
./scripts/docker-release.sh v1.0.0

# The release ZIP will be in release/sparkos-release.zip
# This is identical to what GitHub Actions creates
```

**Creating a GitHub Release:**

1. **Commit and push your changes** to the main branch
2. **Create and push a version tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. **GitHub Actions will automatically:**
   - Build the init binary
   - Create the release package ZIP
   - Build and publish Docker images (AMD64 + ARM64)
   - Create a GitHub Release with the artifacts
   - Publish to GitHub Container Registry

The release will be available at:
- **GitHub Releases:** https://github.com/johndoe6345789/SparkOS/releases
- **Docker Images:** `ghcr.io/johndoe6345789/sparkos:v1.0.0`

**Manual Release Creation:**

You can also create a release manually:
1. Go to https://github.com/johndoe6345789/SparkOS/releases/new
2. Choose or create a tag (e.g., `v1.0.0`)
3. Fill in the release title and description
4. Upload the `sparkos-release.zip` (built locally with `docker-release.sh`)
5. Publish the release

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
# Required binaries (statically linked recommended)
# 1. Busybox - provides shell and most utilities including networking
cp /path/to/busybox rootfs/bin/

# 2. Git - for cloning spark CLI
cp /path/to/git rootfs/bin/
# Note: If git is dynamically linked, you'll need to copy its libraries too

# 3. Sudo - for privilege elevation
cp /path/to/sudo rootfs/bin/

# Create busybox symlinks for common utilities
cd rootfs/bin
for cmd in sh ls cat mkdir rm cp mount umount chmod chown ln \
           ip ifconfig ping wget udhcpc; do
    ln -sf busybox $cmd
done
cd ../..

# If using dynamically linked binaries, copy required libraries
ldd rootfs/bin/busybox  # Check dependencies
ldd rootfs/bin/git      # Check dependencies
ldd rootfs/bin/sudo     # Check dependencies
# Copy libraries to rootfs/lib or rootfs/lib64 as needed
```

### Testing Network Connectivity

Once booted, you can test the network:

```bash
# Check interface status
ip addr show

# Test DNS resolution
ping -c 3 google.com

# Test direct IP connectivity
ping -c 3 8.8.8.8

# Download a file
wget http://example.com/file
```

## Future Roadmap

- [ ] Qt6/QML full screen GUI
- [ ] Wayland compositor integration
- [ ] C++ CLI tools (spark command)
- [ ] Package management via spark CLI
- [ ] WiFi configuration via spark CLI
- [ ] Advanced network configuration

## Contributing

Contributions are welcome! This is an early-stage project focused on:
1. Maintaining minimal footprint
2. Clean, readable code
3. Proper documentation

## License

See LICENSE file for details.

## Notes

This is an MVP implementation. The system currently provides:
- Basic init system with network initialization
- Shell environment
- Build infrastructure
- Image creation tooling
- Wired networking configuration

To create a fully bootable system, you'll also need:
- Linux kernel binary (`vmlinuz`)
- Essential system binaries: busybox, git, sudo
- Required libraries (if using dynamically linked binaries)
- Bootloader installation (handled by scripts)

Minimum System Requirements:
- Kernel: Linux kernel with networking support
- Init: Custom SparkOS init (included)
- Shell: Busybox with networking utilities (udhcpc, ip/ifconfig, ping, wget)
- VCS: Git (for installing spark CLI)
- Security: Sudo (for privilege elevation)

After bootstrap:
1. Use wired network to clone spark CLI via git
2. Use spark CLI to configure WiFi and other system features
3. Install additional packages as needed via spark CLI
