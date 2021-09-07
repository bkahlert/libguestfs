FROM ubuntu:20.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
            libguestfs-tools \
            qemu-utils \
            linux-image-generic

ENV LIBGUESTFS_DEBUG=0 \
    LIBGUESTFS_TRACE=0 \
    LIBGUESTFS_BACKEND=direct

WORKDIR /

CMD ["/usr/bin/guestfish", "-h"]
