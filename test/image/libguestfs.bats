#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should print usage" {
  image "$BUILD_TAG"
  assert_line --partial 'Usage: COMMAND [ARG...]'
  assert_container_status "$BATS_TEST_NAME" 'exited'
}

@test "should print help" {
  image "$BUILD_TAG" guestfish --help
  assert_line --partial 'guestfish: guest filesystem shell'
  assert_container_status "$BATS_TEST_NAME" 'exited'
}

@test "should execute guestfish script" {
  skip # broken since v1.2.1

  copy_fixture tinycore.iso disk.img

  image --interactive \
    --env LIBGUESTFS_DEBUG=1 \
    --env LIBGUESTFS_TRACE=1 \
    "$BUILD_TAG" \
    guestfish \
    --ro \
    --add disk.img format:raw \
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
