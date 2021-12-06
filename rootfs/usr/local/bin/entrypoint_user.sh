#!/bin/bash

source logr.sh

# see https://libguestfs.org/guestfs-faq.1.html
if [ "$(id -u)" -eq 0 ]; then
  export LIBGUESTFS_BACKEND=direct
fi

exec "$@"
