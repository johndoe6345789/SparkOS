# SparkOS Architecture

## Overview

SparkOS is designed as a minimal Linux distribution with a custom init system and a modular architecture that allows for future expansion.

## System Components

### 1. Init System (`/sbin/init`)

The init system is the first process started by the kernel (PID 1). It is responsible for:

- **Mounting filesystems**: proc, sys, dev, tmp
- **Process management**: Spawning and respawning the shell
- **Signal handling**: Reaping zombie processes
- **System initialization**: Setting up the initial environment

**Implementation**: `src/init.c`
- Written in C for minimal overhead
- Statically linked for independence
- ~100 lines of clean, well-documented code

### 2. Root Filesystem

Follows the Filesystem Hierarchy Standard (FHS):

```
/
├── bin/          Essential user binaries (bash, ls, cp, etc.)
├── sbin/         System binaries (init, mount, etc.)
├── etc/          System configuration files
├── proc/         Kernel process information (virtual)
├── sys/          Kernel system information (virtual)
├── dev/          Device files (virtual)
├── tmp/          Temporary files
├── usr/
│   ├── bin/      Non-essential user binaries
│   ├── sbin/     Non-essential system binaries
│   ├── lib/      Libraries for /usr/bin and /usr/sbin
│   └── lib64/    64-bit libraries
├── var/          Variable data (logs, caches)
├── root/         Root user home directory
└── home/         User home directories
```

### 3. Build System

**Makefile**: Main build orchestration
- `make init`: Compile init system
- `make install`: Install init to rootfs
- `make image`: Create bootable image (requires root)
- `make clean`: Clean build artifacts

**Scripts**:
- `scripts/build.sh`: Quick build for development
- `scripts/setup_rootfs.sh`: Create rootfs structure
- `scripts/create_image.sh`: Create dd-able disk image

### 4. Boot Process

```
Hardware Power-On
    ↓
BIOS/UEFI
    ↓
Bootloader (syslinux)
    ↓
Linux Kernel (vmlinuz)
    ↓
Init System (/sbin/init) [PID 1]
    ↓
Mount filesystems
    ↓
Spawn bash shell
    ↓
User interaction
```

## Design Decisions

### Why Custom Init?

- **Simplicity**: No dependencies, easy to understand
- **Control**: Full control over boot process
- **Size**: Minimal footprint (<1MB statically linked)
- **Learning**: Educational value for OS development

### Why Static Linking?

- **Independence**: No library dependencies
- **Portability**: Works on any Linux system
- **Reliability**: No missing library issues

### Why Bash?

- **Familiar**: Most users know bash
- **Powerful**: Full scripting capabilities
- **Standard**: Available on virtually all Linux systems

## Future Architecture

### Planned Components

1. **Qt6/QML GUI**
   - Full-screen Wayland application
   - Android-like interface design
   - Desktop-oriented workflow

2. **Wayland Compositor**
   - Custom compositor for SparkOS
   - Minimal resource usage
   - Touch and mouse support

3. **C++ CLI Tools**
   - System management utilities
   - Package management
   - Network configuration

4. **Sudo Integration**
   - Proper privilege elevation
   - Security policies
   - Audit logging

## Security Considerations

- Static binaries reduce attack surface
- Minimal running processes
- Root filesystem can be read-only
- Future: sudo for privilege escalation
- Future: SELinux/AppArmor integration

## Performance

- Fast boot time (seconds, not minutes)
- Low memory footprint (~100MB base system)
- No unnecessary background services
- Efficient init system

## Portability

- AMD64 architecture (x86_64)
- dd-able disk images
- USB flash drive ready
- Future: ARM64 support

## Extension Points

The architecture is designed for easy extension:

1. **Init system**: Can be enhanced with service management
2. **Filesystem**: Can add more mount points and partitions
3. **Boot process**: Can integrate other bootloaders
4. **GUI**: Clean separation allows GUI to be optional

## Development Workflow

1. Modify source code in `src/`
2. Build with `make init`
3. Test init in isolation
4. Install to `rootfs/` with `make install`
5. Create test image with `sudo make image`
6. Test on real hardware or VM

## References

- Linux Kernel Documentation
- Filesystem Hierarchy Standard (FHS)
- POSIX Standards
- Qt6 Documentation
- Wayland Protocol Specification
