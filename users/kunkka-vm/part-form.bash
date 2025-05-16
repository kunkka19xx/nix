#!/usr/bin/env bash

# partition
echo "partitioning"
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart root ext4 512MB -8GB
parted /dev/sda -- mkpart swap linux-swap -8GB 100%
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on
echo "---ok---"


# Format
echo "formating"
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
echo "---ok---"

# Mount
echo "mounting"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
# swapon /dev/sda2 #optional
echo "---ok---"

# Gen default configuration.nix & hardware
echo "generating nixos config"
nixos-generate-config --root /mnt
echo "---ok---"
