#!/bin/bash

BUILD="/build"
SCRIPT="/scripts"
ROOT="/rootfs"

BOOTSTRAP_LIST="bootstrap.list"
PACKAGES_LIST="packages.list"

mkdir -p $ROOT

if [ -f "$BOOTSTRAP_LIST" ]; then
    pacstrap -K $ROOT $(cat $BOOTSTRAP_LIST)
else
    echo "Error: Bootstrap package list not found: $BOOTSTRAP_LIST"
    exit 1
fi

if [ -f "$SCRIPT/hooks/post_bootstrap.sh" ]; then
    bash "$SCRIPT/hooks/post_bootstrap.sh"
else
    echo "Error: Bootstrap hook script not found: hooks/post_bootstrap.sh"
    exit 1
fi

if [ -f "$PACKAGES_LIST" ]; then
    arch-chroot $ROOT pacman -S --noconfirm $(cat $PACKAGES_LIST)
else
    echo "Error: Packages list not found: $PACKAGES_LIST"
    exit 1
fi

if [ -f "$SCRIPT/hooks/post_install.sh" ]; then
    arch-chroot $ROOT bash "$SCRIPT/hooks/post_install.sh"
else
    echo "Error: Install hook script not found: hooks/post_install.sh"
    exit 1
fi

TAR_FILE="$BUILD/zenithos-rootfs-$(date '+%Y%m%d').tar"
TAR_ZST_FILE="$TAR_FILE.zst"

tar --numeric-owner --xattrs --acls --exclude-from=/$SCRIPT/exclude -C /$ROOT -c . -f $TAR_FILE

zstd --long -T0 -8 $TAR_FILE -o $TAR_ZST_FILE

sha256sum $TAR_ZST_FILE > $TAR_ZST_FILE.sha256

echo "Process complete. Tarball and SHA256 checksum generated:"
echo "$TAR_ZST_FILE"
echo "$TAR_ZST_FILE.sha256"
