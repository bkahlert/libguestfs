#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' 'guestfish'
}

@test "should print help" {

  LIBGUESTFS_IMAGE="${BUILD_TAG}" run ./guestfish

  assert_line --partial 'guestfish: guest filesystem shell'
}

@test "should execute script" {
  cp_fixture tinycore.iso disk.img

  LIBGUESTFS_IMAGE="${BUILD_TAG}" run ./guestfish \
    --ro \
    --add disk.img \
    --mount /dev/sda:/ \
    <<COMMANDS
copy-out "/boot/core.gz" "./"
umount-all
exit
COMMANDS

  assert_file_exist 'core.gz'
  assert_file_owner_group 'core.gz' tester tester
  assert_file_size_equals 'core.gz' 10692675
}
