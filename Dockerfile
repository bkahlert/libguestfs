FROM ubuntu:latest

ARG VCS_REF
ARG BUILD_VERSION

LABEL maintainer="Björn Kahlert <mail@bkahlert.com" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="bkahlert/libguestfs" \
      org.label-schema.description="Containerized (〜￣△￣)〜o/￣￣￣<゜)))彡 libguestfs that plays especically nice with ImgCstmzr" \
      org.label-schema.url="https://bkahlert.com/" \
      org.label-schema.vcs-url="https://github.com/bkahlert/libguestfs" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.docker.cmd="docker run --rm --name guestfish -it \
--mount type=bind,source=$(pwd)/shared/,target=/shared \
--mount type=bind,source=$(pwd)/disk.img,target=/images/disk.img \
--entrypoint /bin/bash bkahlert/libguestfs" \
      org.label-schema.docker.cmd.debug="docker run --rm --name guestfish -it --entrypoint /bin/bash bkahlert/libguestfs" \
      org.label-schema.usage="README.md"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
          libguestfs-tools \
          qemu-utils \
          linux-image-generic

ENV LIBGUESTFS_DEBUG=0 \
    LIBGUESTFS_TRACE=0 \
    LIBGUESTFS_BACKEND=direct \
    GUESTFISH_PS1='(〜￣△￣)〜o/￣￣￣<゜)))彡 '

ENTRYPOINT ["/usr/bin/guestfish"]
CMD ["-h"]
