# bkahlert/libguestfs [![Build Status](https://img.shields.io/github/workflow/status/bkahlert/libguestfs/build?label=Build&logo=github&logoColor=fff)](https://github.com/bkahlert/libguestfs/actions/workflows/build-and-publish.yml) [![Repository Size](https://img.shields.io/github/repo-size/bkahlert/libguestfs?color=01818F&label=Repo%20Size&logo=Git&logoColor=fff)](https://github.com/bkahlert/libguestfs) [![Repository Size](https://img.shields.io/github/license/bkahlert/libguestfs?color=29ABE2&label=License&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1OTAgNTkwIiAgeG1sbnM6dj0iaHR0cHM6Ly92ZWN0YS5pby9uYW5vIj48cGF0aCBkPSJNMzI4LjcgMzk1LjhjNDAuMy0xNSA2MS40LTQzLjggNjEuNC05My40UzM0OC4zIDIwOSAyOTYgMjA4LjljLTU1LjEtLjEtOTYuOCA0My42LTk2LjEgOTMuNXMyNC40IDgzIDYyLjQgOTQuOUwxOTUgNTYzQzEwNC44IDUzOS43IDEzLjIgNDMzLjMgMTMuMiAzMDIuNCAxMy4yIDE0Ny4zIDEzNy44IDIxLjUgMjk0IDIxLjVzMjgyLjggMTI1LjcgMjgyLjggMjgwLjhjMCAxMzMtOTAuOCAyMzcuOS0xODIuOSAyNjEuMWwtNjUuMi0xNjcuNnoiIGZpbGw9IiNmZmYiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxOS4yMTIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4%3D)](https://github.com/bkahlert/libguestfs/blob/master/LICENSE)

* Containerized libguestfs including virt-customize, guestfish, etc.
* Scripts
  * `guestfish` — Opens the raw image disk file using guestfish.
  * `virt-customize` — Opens the raw image disk using libguestfs' virt-customize.
  * `pi` — Opens the raw image disk using a dockerized ARM emulator that emulates a Raspberry Pi.
  * [`copy-out`](https://gist.github.com/bkahlert/9ba2228f0ebb0de8dbd21b90e83f35da) — Copies whole file trees out of a raw image.


## Build locally

```shell
git clone https://github.com/bkahlert/libguestfs.git
cd libguestfs

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Image

* [Docker Hub](https://hub.docker.com/r/bkahlert/libguestfs/) `bkahlert/libguestfs`
* [GitHub Container Registry](https://github.com/users/bkahlert/packages/container/package/libguestfs) `ghcr.io/crazy-max/samba`

Following platforms for this image are available:
* linux/amd64
* linux/arm/v7
* linux/arm64/v8
* linux/riscv64
* linux/ppc64le
* linux/s390x


## Usage

```shell
docker run --rm -it \
  -v "$(pwd)/data:/data" -v "$(pwd)/disk.img:/disk.img" \
  bkahlert/libguestfs guestfish \
  --ro \
  --add /disk.img \
  --mount /dev/sda2:/ \
  --mount /dev/sda1:/boot \
<<COMMANDS
-copy-out "/boot" "data"
umount-all
exit
COMMANDS
```

The command requires `disk.img` in this directory, mounts it with 
the `guestfish` tool and executes all guestfish commands enclosed by `COMMANDS` on the mounted `disk.img`.

In this case the directory `/boot` and its contents is copied to data.


## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star the project, or to raise issues. You
can also support this project by making
a [Paypal donation](https://www.paypal.me/bkahlert) to ensure this journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:


## License

MIT. See [LICENSE](LICENSE) for more details.
