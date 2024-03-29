# bkahlert/libguestfs [![Build Status](https://img.shields.io/github/actions/workflow/status/bkahlert/libguestfs/build.yml?label=Build&logo=github&logoColor=fff)](https://github.com/bkahlert/libguestfs/actions/workflows/build.yml) [![Repository Size](https://img.shields.io/github/repo-size/bkahlert/libguestfs?color=01818F&label=Repo%20Size&logo=Git&logoColor=fff)](https://github.com/bkahlert/libguestfs) [![Repository Size](https://img.shields.io/github/license/bkahlert/libguestfs?color=29ABE2&label=License&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1OTAgNTkwIiAgeG1sbnM6dj0iaHR0cHM6Ly92ZWN0YS5pby9uYW5vIj48cGF0aCBkPSJNMzI4LjcgMzk1LjhjNDAuMy0xNSA2MS40LTQzLjggNjEuNC05My40UzM0OC4zIDIwOSAyOTYgMjA4LjljLTU1LjEtLjEtOTYuOCA0My42LTk2LjEgOTMuNXMyNC40IDgzIDYyLjQgOTQuOUwxOTUgNTYzQzEwNC44IDUzOS43IDEzLjIgNDMzLjMgMTMuMiAzMDIuNCAxMy4yIDE0Ny4zIDEzNy44IDIxLjUgMjk0IDIxLjVzMjgyLjggMTI1LjcgMjgyLjggMjgwLjhjMCAxMzMtOTAuOCAyMzcuOS0xODIuOSAyNjEuMWwtNjUuMi0xNjcuNnoiIGZpbGw9IiNmZmYiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxOS4yMTIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4%3D)](https://github.com/bkahlert/libguestfs/blob/master/LICENSE)

## About

**Containerized libguestfs including virt-customize, guestfish, etc.**

* Runs as non-root user
* Multi-platform image
* Helper scripts
    * [`guestfish` *Manipulate a virtual machine / image using the guest filesystem shell*
      ![recorded terminal session demonstrating guestfish](docs/guestfish.svg "guestfish")](../../raw/master/docs/guestfish.svg)
    * [`virt-builder` *Build virtual machine images quickly*  
      ![recorded terminal session demonstrating virt-builder](docs/virt-builder.svg "virt-builder")](../../raw/master/docs/virt-builder.svg)
    * [`virt-customize` *Customize a virtual machine / image*  
      ![recorded terminal session demonstrating virt-customize](docs/virt-customize.svg "virt-customize")](../../raw/master/docs/virt-customize.svg)
    * [`pi` *Boot a virtual machine / image using a dockerized ARM emulator that emulates a Raspberry Pi*  
      ![recorded terminal session demonstrating pi](docs/pi.svg "pi")](../../raw/master/docs/pi.svg)
    * [`copy-out` *Copy files out of a virtual machine / image*  
      ![recorded terminal session demonstrating copy-out](docs/copy-out.svg "copy-out")](../../raw/master/docs/copy-out.svg)

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

- linux/amd64
- linux/arm/v7
- linux/arm64/v8
- linux/ppc64le
- linux/riscv64
- linux/s390x

## Usage

### Interactively

```shell
docker run -it --rm \
  -v "$PWD":"$PWD" \
  -w "$PWD" \
  bkahlert/libguestfs:edge \
  guestfish

><fs> add disk.img format:raw
><fs> launch
><fs> mount /dev/sda ./
><fs> ls /
><fs> copy-out /boot data
><fs> umount-all
><fs> exit
```

### Automatically

```shell
docker run -i --rm \
  -v "$PWD":"$PWD" \
  -w "$PWD" \
  bkahlert/libguestfs:edge \
  guestfish \
  --ro \
  --add disk.img format:raw \
  --mount /dev/sda:/ \
<<COMMANDS
ls /
-copy-out /boot ./
umount-all
exit
COMMANDS
```

The command requires `disk.img` in this directory, mounts it with the `guestfish` tool and executes all guestfish commands enclosed by `COMMANDS` on the
mounted `disk.img`.

In this case the directory `/boot` and its contents is copied to the current working directory.

> 💡 Did you notice the leading dash in front of the `copy-out` command? Running guestfish non-interactively the first command that gives an error causes the
> whole shell to exit. By prefixing a command with `-` guestfish will not exit if an error is encountered.

> 💡 If you prefix a command with `!` (e.g. `!id`) the command will run on the host instead of the mounted guest. Since the libguestfs tools are containerized
> themselves, "host" signifies the containerized libguestfs hosting Ubuntu installation — and not you actual OS.

## Configuration

This image can be configured using the following options of which all but `APP_USER` and `APP_GROUP` exist as both—build argument and environment variable.  
You should go for build arguments if you want to set custom defaults you don't intend to change (often). Environment variables will overrule any existing
configuration on each container start.

- `APP_USER` Name of the main user (default: `libguestfs`)
- `APP_GROUP` Name of the main user's group (default: `libguestfs`)
- `DEBUG` Whether to log debug information (default: `0`)
- `TZ` Timezone the container runs in (default: `UTC`)
- `LANG` Language/locale to use (default: `C.UTF-8`)
- `PUID` User ID of the `libguestfs` user (default: `1000`)
- `PGID` Group ID of the `libguestfs` group (default: `1000`)
- `LIBGUESTFS_DEBUG` Set this to 1 in order to enable massive amounts of debug messages. If you think there is some problem inside the libguestfs appliance,
  then you should use this option. (default: `0`)
- `LIBGUESTFS_TRACE` Set this to 1 and libguestfs will print out each command / API call in a format which is similar to guestfish commands. (default: `0`)

```shell
# Build single image with build argument TZ
docker buildx bake --set "*.args.TZ=$(date +"%Z")"

# Build multi-platform image with build argument TZ
docker buildx bake image-all --set "*.args.TZ=$(date +"%Z")"

# Start container with environment variable TZ
docker run --rm \
  -e TZ="$(date +"%Z")" \
  -v "$(pwd):$(pwd)" \
  -w "$(pwd)" \
  libguestfs:local
```

## Testing

```shell
git clone https://github.com/bkahlert/libguestfs.git
cd libguestfs

# Use Bats wrapper to run tests
curl -LfsS https://git.io/batsw |
 DOCKER_BAKE="--set '*.tags=test'" bash -s -- --batsw:-e --batsw:BUILD_TAG=test test
```

[Bats Wrapper](https://github.com/bkahlert/bats-wrapper) is a self-contained wrapper to run tests based on the Bash testing
framework [Bats](https://github.com/bats-core/bats-core).

> 💡 To accelerate testing, the Bats Wrapper checks if any test is prefixed with a capital X and if so, only runs those tests.

## Troubleshooting

If you run into problems, try running your intended steps interactively with verbose logging turned on:

```shell
docker run -it --rm \
  -e "LIBGUESTFS_DEBUG=1" \
  -e "LIBGUESTFS_TRACE=1" \
  -v "$PWD":"$PWD" \
  -w "$PWD" \
  bkahlert/libguestfs:edge \
  guestfish
```

To debug the image the following lines might become handy:

```shell
# build local image with specified tag
docker buildx bake --set '*.tags=test'

# copy something to test with
cp test/fixtures/tinycore.iso disk.img

# start container interactively with a bash
docker run \
  -e LIBGUESTFS_DEBUG=1 \
  -e LIBGUESTFS_TRACE=1 \
  -e DEBUG=1 \
  -e TZ=CET \
  -e PUID=68039910 \
  -e PGID=584555228 \
  -e TERM=xterm-256color \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":"$PWD" \
  -w "$PWD" \
  --interactive \
  --tty \
  --rm \
  --entrypoint /bin/bash \
  --name libguestfs-test \
  test

# fixes (normally performed by entrypoint.sh)
chmod 0644 /boot/vmlinuz*
usermod -a -G kvm "$(whoami)"

# run guestfish interactively
guestfish
# or as root: (see entrypoint_user.sh for details)
LIBGUESTFS_BACKEND=direct guestfish

# run guestfish using the original entrypoint
entrypoint.sh guestfish \
  --ro \
  --add disk.img format:raw \
  --mount /dev/sda:/ \
<<COMMANDS
ls /
-copy-out /boot ./
umount-all
exit
COMMANDS 
```

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star the project, or to raise issues. You can also support this project by making
a [PayPal donation](https://www.paypal.me/bkahlert) to ensure this journey continues indefinitely!

Thanks again for your support, it's much appreciated! :pray:

## License

MIT. See [LICENSE](LICENSE) for more details.
