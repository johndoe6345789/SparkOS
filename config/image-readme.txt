SparkOS UEFI-Bootable Image

This is a UEFI-bootable disk image with:
- GPT partition table
- EFI System Partition (ESP) with FAT32 filesystem
- GRUB UEFI bootloader
- Linux kernel
- SparkOS init system
- Busybox utilities

The image can be written to a USB drive and booted on UEFI systems:
  sudo dd if=sparkos.img of=/dev/sdX bs=4M status=progress
  sudo sync

Boot options:
- UEFI boot support (tested on x86_64 systems)
- Automatic boot after 3 seconds
- Console on tty1

For more information, see: https://github.com/johndoe6345789/SparkOS
