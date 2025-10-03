#!/bin/bash
set -e

# adjust this if your Btrfs root is on a different device
DEVICE="/dev/sda1"
MOUNTPOINT="/mnt/btrfs"

echo "[*] Mounting root subvolume..."
mkdir -p "$MOUNTPOINT"
mount -o subvol=/ "$DEVICE" "$MOUNTPOINT"

echo "[*] Deleting snapshots..."
btrfs subvolume list "$MOUNTPOINT" | grep '\.snapshots' | awk '{print $9}' | sort -r | while read -r path; do
    echo "    deleting $path"
    btrfs subvolume delete "$MOUNTPOINT/$path" || true
done

echo "[*] Removing Snapper configs..."
rm -rf "$MOUNTPOINT/etc/snapper" "$MOUNTPOINT/var/lib/snapper"

echo "[*] Unmounting..."
umount "$MOUNTPOINT"

echo "[*] Rebooting..."
reboot
