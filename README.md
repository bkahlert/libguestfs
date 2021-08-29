# bkahlert/libguestfs [![Build Status](https://img.shields.io/github/workflow/status/bkahlert/libguestfs/build%20and%20publish?label=Build&logo=github&logoColor=fff)](https://github.com/bkahlert/libguestfs/actions/workflows/build.yml) [![Repository Size](https://img.shields.io/github/repo-size/bkahlert/libguestfs?color=01818F&label=Repo%20Size&logo=Git&logoColor=fff)](https://github.com/bkahlert/libguestfs) [![Repository Size](https://img.shields.io/github/license/bkahlert/libguestfs?color=29ABE2&label=License&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1OTAgNTkwIiAgeG1sbnM6dj0iaHR0cHM6Ly92ZWN0YS5pby9uYW5vIj48cGF0aCBkPSJNMzI4LjcgMzk1LjhjNDAuMy0xNSA2MS40LTQzLjggNjEuNC05My40UzM0OC4zIDIwOSAyOTYgMjA4LjljLTU1LjEtLjEtOTYuOCA0My42LTk2LjEgOTMuNXMyNC40IDgzIDYyLjQgOTQuOUwxOTUgNTYzQzEwNC44IDUzOS43IDEzLjIgNDMzLjMgMTMuMiAzMDIuNCAxMy4yIDE0Ny4zIDEzNy44IDIxLjUgMjk0IDIxLjVzMjgyLjggMTI1LjcgMjgyLjggMjgwLjhjMCAxMzMtOTAuOCAyMzcuOS0xODIuOSAyNjEuMWwtNjUuMi0xNjcuNnoiIGZpbGw9IiNmZmYiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxOS4yMTIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4%3D)](https://github.com/bkahlert/libguestfs/blob/master/LICENSE)

Containerized libguestfs including guestfish (〜￣△￣)〜o/￣￣￣<゜)))彡

## Installation

The following command
- builds the Docker image, and
- copies a few scripts to `~/bin` (see [Usage](#Usage)).

```shell
scripts/install.sh
```

## Usage

Go to any directory containing an `.img` file and type one of the following commands:
  * `guestfish` — Opens the raw image disk file using guestfish.
  * `virt-customize` — Opens the raw image disk using libguestfs' virt-customize.
  * `pi` — Opens the raw image disk using a dockerized ARM emulator that emulates a Raspberry Pi.
  * [`copy-out`](https://gist.github.com/bkahlert/9ba2228f0ebb0de8dbd21b90e83f35da) — Copies whole file trees out of a raw image.

## Build

If you don't have `make` installed, build normally with Docker:

```shell
docker build . --file Dockerfile --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --tag bkahlert/libguestfs:$(date +%s)
```

## Publish

```shell
docker push bkahlert/libguestfs
```
