#!/bin/bash

# Your XFS filesystem UUID:
UUID="d13f5bfc-9f48-403c-9e2a-fa262dfd63fd"
MOUNTPOINT="/mnt/base"

usage() {
    echo "Usage:"
    echo "  mbup       -> mount backup drive"
    echo "  mbup -u    -> unmount backup drive"
}

# Unmount option
if [[ "$1" == "-u" ]]; then
    echo "Unmounting backup drive from $MOUNTPOINT..."
    sudo umount "$MOUNTPOINT" && echo "Unmounted." || echo "Failed to unmount."
    exit 0
fi

# Normal mount
echo "Mounting backup drive at $MOUNTPOINT..."
sudo mount -U "$UUID" "$MOUNTPOINT"

if [[ $? -eq 0 ]]; then
    echo "Backup drive mounted successfully."
else
    echo "Failed to mount backup drive. Is it powered on and connected?"
fi
