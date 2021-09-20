FROM ubuntu:20.04

ENV TZ=UTC \
    PUID=1000 \
    PGID=1000 \
    LIBGUESTFS_DEBUG=0 \
    LIBGUESTFS_TRACE=0

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    ca-certificates \
    dumb-init \
    curl \
    libguestfs-tools \
    linux-image-generic \
    qemu-utils \
    tzdata \
 && groupadd \
    --gid ${PGID} \
    libguestfs \
 && useradd \
    --uid ${PUID} \
    --gid libguestfs \
    --shell /bin/bash \
    libguestfs \
 && rm -rf /tmp/* /var/lib/apt/list/*

COPY --from=crazymax/yasu:latest / /
COPY rootfs /
RUN chmod +x \
    /usr/local/bin/entrypoint.sh \
    /usr/local/bin/entrypoint-user.sh

WORKDIR /
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["echo", "Usage: COMMAND [ARG...]\nExample: guestfish --version"]

HEALTHCHECK --interval=5s --timeout=5s --start-period=20s \
  CMD pgrep qemu &>1 || exit 1
