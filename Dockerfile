FROM ubuntu:23.10

# build time only options
ARG LOGR_VERSION=0.6.2
ARG APP_USER=libguestfs
ARG APP_GROUP=$APP_USER

# build and run time options
ARG DEBUG=0
ARG TZ=UTC
ARG LANG=C.UTF-8
ARG PUID=1000
ARG PGID=1000
ARG LIBGUESTFS_DEBUG=0
ARG LIBGUESTFS_TRACE=0

# dependencies
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    ca-certificates \
    dumb-init \
    curl \
    libguestfs-tools \
    linux-image-generic \
    qemu-utils \
    tzdata \
 && rm -rf /tmp/* /var/lib/apt/list/*

# app setup
COPY --from=crazymax/yasu:1.17.0 / /
COPY rootfs /
RUN chmod +x \
    /usr/local/sbin/entrypoint.sh \
    /usr/local/bin/entrypoint_user.sh \
 && sed -Ei -e "s/([[:space:]]app_user=)[^[:space:]]*/\1$APP_USER/" \
            -e "s/([[:space:]]app_group=)[^[:space:]]*/\1$APP_GROUP/" \
             /usr/local/sbin/entrypoint.sh \
 && curl -LfsSo /usr/local/bin/logr.sh https://github.com/bkahlert/logr/releases/download/v${LOGR_VERSION}/logr.sh

# env setup
ENV DEBUG="$DEBUG" \
    TZ="$TZ" \
    LANG="$LANG" \
    PUID="$PUID" \
    PGID="$PGID" \
    LIBGUESTFS_DEBUG="$LIBGUESTFS_DEBUG" \
    LIBGUESTFS_TRACE="$LIBGUESTFS_TRACE"

# user setup
RUN (\
  groupadd --gid "$PGID" "$APP_GROUP" 2>/dev/null \
    || groupmod --new-name "$APP_GROUP" "$(getent group "$PGID" | cut -d: -f1)" \
  )\
  && (\
    useradd --comment "app user" --shell /bin/bash --uid "$PUID" --gid "$APP_GROUP" "$APP_USER" 2>/dev/null \
    || usermod --comment "app user" --shell /bin/bash --login "$APP_USER" --home "/home/$APP_USER" --move-home "$(id -nu "$PUID")" \
  )

# finalization
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/sbin/entrypoint.sh"]
CMD ["echo", "Usage: COMMAND [ARG...]\nExample: guestfish --version"]

HEALTHCHECK --interval=5s --timeout=5s --start-period=20s CMD pgrep qemu &>1 || exit 1
