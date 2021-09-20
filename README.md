# bkahlert/libguestfs [![Build Status](https://img.shields.io/github/workflow/status/bkahlert/libguestfs/build?label=Build&logo=github&logoColor=fff)](https://github.com/bkahlert/libguestfs/actions/workflows/build-and-publish.yml) [![Repository Size](https://img.shields.io/github/repo-size/bkahlert/libguestfs?color=01818F&label=Repo%20Size&logo=Git&logoColor=fff)](https://github.com/bkahlert/libguestfs) [![Repository Size](https://img.shields.io/github/license/bkahlert/libguestfs?color=29ABE2&label=License&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1OTAgNTkwIiAgeG1sbnM6dj0iaHR0cHM6Ly92ZWN0YS5pby9uYW5vIj48cGF0aCBkPSJNMzI4LjcgMzk1LjhjNDAuMy0xNSA2MS40LTQzLjggNjEuNC05My40UzM0OC4zIDIwOSAyOTYgMjA4LjljLTU1LjEtLjEtOTYuOCA0My42LTk2LjEgOTMuNXMyNC40IDgzIDYyLjQgOTQuOUwxOTUgNTYzQzEwNC44IDUzOS43IDEzLjIgNDMzLjMgMTMuMiAzMDIuNCAxMy4yIDE0Ny4zIDEzNy44IDIxLjUgMjk0IDIxLjVzMjgyLjggMTI1LjcgMjgyLjggMjgwLjhjMCAxMzMtOTAuOCAyMzcuOS0xODIuOSAyNjEuMWwtNjUuMi0xNjcuNnoiIGZpbGw9IiNmZmYiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxOS4yMTIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4%3D)](https://github.com/bkahlert/libguestfs/blob/master/LICENSE)

* Containerized libguestfs including virt-customize, guestfish, etc.
* Runs as non-root user
* Multi-platform image
* Helper scripts
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
* [GitHub Container Registry](https://github.com/users/bkahlert/packages/container/package/libguestfs) `ghcr.io/bkahlert/libguestfs`

Following platforms for this image are available:
* linux/amd64
* linux/arm/v7
* linux/arm64/v8
* linux/ppc64le
* linux/riscv64
* linux/s390x

## Environment variables

* `TZ`: The timezone assigned to the container (default `UTC`)
* `PUID`: The user id to use (default `1000`)
* `PGID`: The group id to use (default `1000`)
* `LIBGUESTFS_DEBUG`: Set this to 1 in order to enable massive amounts of debug messages. If you think there is some problem inside the libguestfs appliance, then you should use this option. (default: `0`)
* `LIBGUESTFS_TRACE`: Set this to 1 and libguestfs will print out each command / API call in a format which is similar to guestfish commands. (default: `0`)

## Usage

### Interactively

```shell
docker run -it --rm \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  bkahlert/libguestfs:edge \
  guestfish

><fs> add disk.img
><fs> launch
><fs> mount /dev/sda ./
><fs> ls /
><fs> copy-out /boot data
><fs> umount-all
><fs> exit
```

### Automatically

```shell
docker run --rm \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  bkahlert/libguestfs:edge \
  guestfish \
  --ro \
  --add disk.img \
  --mount /dev/sda:/ \
<<COMMANDS
ls /
-copy-out /boot ./
umount-all
exit
COMMANDS
```

The command requires `disk.img` in this directory, mounts it with 
the `guestfish` tool and executes all guestfish commands enclosed by `COMMANDS` on the mounted `disk.img`.

In this case the directory `/boot` and its contents is copied to the current working directory.

> :bulb: Did you notice the leading dash in front of the `copy-out` command? Running guestfish non-interactively the first command that gives an error causes the whole shell to exit. By prefixing a command with `-` guestfish will not exit if an error is encountered.

> :bulb: If you prefix a command with `!` (e.g. `!id`) the command will run on the host instead of the mounted guest. Since the libguestfs tools are containerized themselves, "host" signifies the containerized libguestfs hosting Ubuntu installation — and not you actual OS.


## Troubleshooting

If you run into problems, try running your intended  steps
interactively with verbose logging turned on:

```shell
docker run -it --rm \
  -e "LIBGUESTFS_DEBUG=1" \
  -e "LIBGUESTFS_TRACE=1" \
  -v "$PWD:$PWD" \
  -w "$PWD" \
  bkahlert/libguestfs:edge \
  guestfish
```


## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star the project, or to raise issues. You
can also support this project by making
a [Paypal donation](https://www.paypal.me/bkahlert) to ensure this journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:


## License

MIT. See [LICENSE](LICENSE) for more details.
