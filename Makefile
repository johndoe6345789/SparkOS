# SparkOS Makefile
# Builds the minimal Linux distribution

CC = gcc
CFLAGS = -Wall -O2 -static
DESTDIR = rootfs
IMAGE = sparkos.img
IMAGE_SIZE = 512M

.PHONY: all clean init image help install docker-release

all: init

help:
	@echo "SparkOS Build System"
	@echo "===================="
	@echo "Targets:"
	@echo "  make init           - Build the init system"
	@echo "  make install        - Install init to rootfs"
	@echo "  make image          - Create bootable dd-able image (requires root)"
	@echo "  make docker-release - Build release package using Docker (no root required)"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Note: Creating a bootable image requires root privileges"
	@echo "      and various tools (debootstrap, syslinux, etc.)"
	@echo ""
	@echo "For easier release building, use Docker:"
	@echo "      ./scripts/docker-release.sh v1.0.0"

init: src/init.c
	@echo "Building SparkOS init system..."
	$(CC) $(CFLAGS) -o init src/init.c
	@echo "Init system built successfully: ./init"

install: init
	@echo "Installing init to rootfs..."
	install -D -m 755 init $(DESTDIR)/sbin/init
	@echo "Init installed to $(DESTDIR)/sbin/init"

image: install
	@echo "Creating bootable image..."
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "ERROR: Image creation requires root privileges"; \
		echo "Run: sudo make image"; \
		exit 1; \
	fi
	@./scripts/create_image.sh

docker-release:
	@echo "Building release package using Docker..."
	@./scripts/docker-release.sh

clean:
	@echo "Cleaning build artifacts..."
	rm -f init
	rm -f $(IMAGE)
	rm -rf build/
	rm -rf release/
	@echo "Clean complete"
