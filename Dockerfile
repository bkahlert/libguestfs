FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -qq --no-install-recommends \
            libguestfs-tools \
            qemu-utils \
            linux-image-generic

ENV LIBGUESTFS_DEBUG=0 \
    LIBGUESTFS_TRACE=0 \
    LIBGUESTFS_BACKEND=direct

WORKDIR /data

CMD ["/usr/bin/guestfish", "-h"]
