#!/bin/bash

set -e

BUILD="/build"
SCRIPT="/scripts"
ROOT="/rootfs"

BOOTSTRAP_LIST="$SCRIPT/bootstrap.list"
PACKAGES_LIST="$SCRIPT/packages.list"

pacman -Sy arch-install-scripts

mkdir -p $ROOT

if [ -f "$BOOTSTRAP_LIST" ]; then
    pacstrap -K $ROOT $(cat $BOOTSTRAP_LIST)
else
    echo "Error: Bootstrap package list not found: $BOOTSTRAP_LIST"
    exit 1
fi

if [ -f "$SCRIPT/post_bootstrap.sh" ]; then
    chroot $ROOT bash "$SCRIPT/post_bootstrap.sh"
else
    echo "Error: Bootstrap hook script not found: post_bootstrap.sh"
    exit 1
fi

if [ -f "$PACKAGES_LIST" ]; then
    chroot $ROOT pacman -S --noconfirm $(cat $PACKAGES_LIST)
else
    echo "Error: Packages list not found: $PACKAGES_LIST"
    exit 1
fi

if [ -f "$SCRIPT/post_install.sh" ]; then
    chroot $ROOT bash "$SCRIPT/post_install.sh"
else
    echo "Error: Install hook script not found: post_install.sh"
    exit 1
fi

TAR_FILE="$BUILD/zenithos-rootfs.tar"
TAR_ZST_FILE="$TAR_FILE.zst"

tar --numeric-owner --xattrs --acls --exclude-from=/$SCRIPT/exclude -C /$ROOT -c . -f $TAR_FILE

zstd --long -T0 -8 $TAR_FILE -o $TAR_ZST_FILE

sha256sum $TAR_ZST_FILE > $TAR_ZST_FILE.sha256

echo "Process complete. Tarball and SHA256 checksum generated:"
echo "$TAR_ZST_FILE"
echo "$TAR_ZST_FILE.sha256"
