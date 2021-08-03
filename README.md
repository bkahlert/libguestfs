bkahlert/libguestfs
===================

Containerized libguestfs including guestfish (〜￣△￣)〜o/￣￣￣<゜)))彡

Installation
------------

The following command
- builds the Docker image, and
- copies a few scripts to `~/bin` (see [Usage](#Usage)).

```shell
scripts/install.sh
```

Usage
-----

Go to any directory containing an `.img` file and type one of the following commands:
  * `guestfish` — Opens the raw image disk file using guestfish.
  * `virt-customize` — Opens the raw image disk using libguestfs' virt-customize.
  * `pi` — Opens the raw image disk using a dockerized ARM emulator that emulates a Raspberry Pi.
  * [`copy-out`](https://gist.github.com/bkahlert/9ba2228f0ebb0de8dbd21b90e83f35da) — Copies whole file trees out of a raw image.

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
