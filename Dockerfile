FROM ubuntu:20.04

# build time only options
ARG APP_USER=libguestfs
ARG APP_GROUP=$APP_USER

# build and run time options
ARG TZ=UTC
ARG PUID=1000
ARG PGID=1000
ARG LIBGUESTFS_DEBUG=0
ARG LIBGUESTFS_TRACE=0

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
    --gid "$PGID" \
    "$APP_GROUP" \
 && useradd \
    --uid $PUID \
    --gid "$APP_GROUP" \
    --shell /bin/bash \
    "$APP_USER" \
 && rm -rf /tmp/* /var/lib/apt/list/*

COPY --from=crazymax/yasu:1.17.0 / /
COPY rootfs /
RUN chmod +x \
    /usr/local/bin/entrypoint_user.sh \
    /usr/local/sbin/entrypoint.sh \
 && sed -Ei -e "s/([[:space:]]app_user=)[^[:space:]]*/\1$APP_USER/" \
            -e "s/([[:space:]]app_group=)[^[:space:]]*/\1$APP_GROUP/" \
             /usr/local/sbin/entrypoint.sh \
 && curl -LfsSo /usr/local/bin/logr.sh https://raw.githubusercontent.com/bkahlert/logr/master/logr.sh

ENV TZ="$TZ" \
    LANG="C.UTF-8" \
    PUID="$PUID" \
    PGID="$PGID" \
    LIBGUESTFS_DEBUG="$LIBGUESTFS_DEBUG" \
    LIBGUESTFS_TRACE="$LIBGUESTFS_TRACE"

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/sbin/entrypoint.sh"]
CMD ["echo", "Usage: COMMAND [ARG...]\nExample: guestfish --version"]

HEALTHCHECK --interval=5s --timeout=5s --start-period=20s CMD pgrep qemu &>1 || exit 1
