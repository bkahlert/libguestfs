#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' "${BUILD_TAG:?unspecified image to test}"
}

teardown() {
  docker rm --force "$BATS_TEST_NAME" >/dev/null 2>&1 || true
  if [ -e data ] && ! rm -rf data; then
    echo "Failed to delete data. Try the following command to resolve this issue:"
    echo "docker run --rm -v '$PWD:/work' ubuntu bash -c 'chmod -R +w /work/data; rm -rf /work/data'"
    exit 1
  fi
  if [ -e disk.img ] && ! rm -f disk.img; then
    echo "Failed to delete data. Try the following command to resolve this issue:"
    echo "docker run --rm -v '$PWD:/work' ubuntu bash -c 'chmod -R +w /work/disk.img; rm -rf /work/disk.img'"
    exit 1
  fi
}

@test "should print usage" {

  run docker run -i --name "$BATS_TEST_NAME" "$BUILD_TAG"

  assert_line --partial 'Usage: COMMAND [ARG...]'
  assert_container_status "$BATS_TEST_NAME" 'exited'
}

@test "should print help" {

  run docker run -i --name "$BATS_TEST_NAME" "$BUILD_TAG" guestfish --help

  assert_line --partial 'guestfish: guest filesystem shell'
  assert_container_status "$BATS_TEST_NAME" 'exited'
}

@test "should execute guestfish script" {
  cp_fixture tinycore.iso disk.img

  run docker run -i --name "$BATS_TEST_NAME" \
        -e TZ="$(date +"%Z")" \
        -e PUID="$(id -u)" \
        -e PGID="$(id -g)" \
        -e LIBGUESTFS_DEBUG=1 \
        -e LIBGUESTFS_TRACE=1 \
        -v "$PWD:$PWD" \
        -w "$PWD" \
        "$BUILD_TAG" \
        guestfish \
        --ro \
        --add disk.img \
        --mount /dev/sda:/ \
    <<COMMANDS
copy-out "/boot/core.gz" "./"
umount-all
exit
COMMANDS

  assert_container_status "$BATS_TEST_NAME" 'exited'
  assert_file_exist 'core.gz'
  assert_file_owner_group 'core.gz' tester tester
  assert_file_size_equals 'core.gz' 10692675
}
