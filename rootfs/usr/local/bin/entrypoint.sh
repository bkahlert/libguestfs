#!/bin/bash

set -euo pipefail

# Fix access rights to stdout and stderr
chown "${PUID}:${PGID}" /proc/self/fd/1 /proc/self/fd/2 || true

# Update UID and GID
if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g libguestfs)" ]; then
#  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^libguestfs:\([^:]*\):[0-9]*/libguestfs:\1:${PGID}/" /etc/group
  sed -i -e "s/^libguestfs:\([^:]*\):\([0-9]*\):[0-9]*/libguestfs:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u libguestfs)" ]; then
#  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^libguestfs:\([^:]*\):[0-9]*:\([0-9]*\)/libguestfs:\1:${PUID}:\2/" /etc/passwd
fi

# Get ownership of home
mkdir -p /home/libguestfs
chown -R libguestfs /home/libguestfs
chmod -R u+rw /home/libguestfs

# Get ownership of data
mkdir -p /data
chown -R libguestfs /data
chmod -R u+rw /data

# Get ownership of disk.img
[ -e /disk.img ] || touch /disk.img
chown -R libguestfs /disk.img
chmod -R u+rw /disk.img

# Timezone
export TZ=${TZ:-UTC}
ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
echo "${TZ}" > /etc/timezone

# see https://libguestfs.org/guestfs-faq.1.html#where-can-i-get-the-latest-binaries-for
chmod 0644 /boot/vmlinuz*
usermod -a -G kvm libguestfs

# From here, step down to libguestfs user
yasu libguestfs:libguestfs entrypoint_user.sh "$@"
