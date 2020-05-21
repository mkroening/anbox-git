#!/usr/bin/env bash

setup_binderfs() {
    BINDERFS_PATH=/var/lib/anbox/common/binderfs
    mkdir -p $BINDERFS_PATH
    # Remove old mounts so that we start fresh without any devices allocated
    if cat /proc/mounts | grep -q "binder $BINDERFS_PATH"; then
        umount $BINDERFS_PATH
    fi
    mount -t binder binder $BINDERFS_PATH
}

# Ensure we have binderfs mounted when our kernel supports it
if cat /proc/filesystems | grep -q binder; then
    setup_binderfs
fi

exec anbox container-manager \
    --privileged \
    --daemon \
    --data-path=/var/lib/anbox
