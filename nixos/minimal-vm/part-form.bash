#!/usr/bin/env bash

DEVICE="/dev/nvme0n1"

# partition
echo "partitioning"
parted "$DEVICE" -- mklabel gpt
parted "$DEVICE" -- mkpart root ext4 512MB -8GB
parted "$DEVICE" -- mkpart swap linux-swap -8GB 100%
parted "$DEVICE" -- mkpart ESP fat32 1MB 512MB
parted "$DEVICE" -- set 3 esp on
echo "---ok---"

# Format
echo "formatting"
mkfs.ext4 -L nixos ${DEVICE}p1
mkswap -L swap ${DEVICE}p2
mkfs.fat -F 32 -n boot ${DEVICE}p3
echo "---ok---"

# Mount
echo "mounting"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
# swapon /dev/${DEVICE}p2 # optional
echo "---ok---"

# Gen default configuration.nix & hardware
echo "generating nixos config"
nixos-generate-config --root /mnt
echo "---ok---"

