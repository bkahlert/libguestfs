#!/bin/bash

touch disk.img
docker run -i --rm \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -e XDG_CACHE_HOME="/virt-builder-cache" \
  -v "${TMPDIR%/*}:/virt-builder-cache" \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  "${BUILD_TAG:-bkahlert/libguestfs}" \
  virt-builder \
  cirros-0.3.5 \
  --no-check-signature \
  -o disk.img --format qcow2 \
  --size 50M \
  --hostname "libguestfs-fixture"
