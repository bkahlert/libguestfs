bkahlert/libguestfs
===================

Containerized (〜￣△￣)〜o/￣￣￣<゜)))彡 libguestfs that plays especically nice with ImgCstmzr.

Installation
------------

The following command
- builds the Docker image, and
- copies a few scripts to `~/bin`.

```shell
scripts/install.sh
```

Usage
-----

Go to any directory containing an `.img` file and type one of the following commands:
  * `guestfish` — Opens the raw image disk file using guestfish.
  * `virt-customize` — Opens the raw image disk using libguestfs' virt-customize.
  * `pi` — Opens the raw image disk using a dockerized ARM emulator that emulates a Raspberry PI.

Build
-----

If you don't have `make` installed, build normally with Docker:

```shell
docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t bkahlert/libguestfs:latest .
```

Publish
-------

```shell
docker push bkahlert/libguestfs:latest
```
