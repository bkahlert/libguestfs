#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "Xshould start interactive shell by default" {

  LIBGUESTFSW_IMAGE="$BUILD_TAG" expect <<EXPECT
set timeout 15
spawn ./guestfish
expect "help"
EXPECT
trace
  assert_success
  assert_line --partial 'Welcome to guestfish'
  # shellcheck disable=SC1112
  assert_line --partial 'Type: ‘help’ for help on commands'
}

@test "should execute script if specified" {
  copy_fixture tinycore.iso disk.img

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./guestfish \
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
