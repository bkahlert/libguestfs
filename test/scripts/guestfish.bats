#!/usr/bin/env bats
# bashsupport disable=BP5007

# TODO free up space; does not work otherwise on GitHub
@test "should start interactive shell by default" {
  skip
  LIBGUESTFSW_IMAGE="$BUILD_TAG" run /usr/bin/expect -df "$(make_interpretable '#!/usr/bin/expect -d' - <<EXPECT
set timeout 15
spawn ./guestfish
expect "help"
send "quit"
EXPECT
)"

  assert_success
  assert_line --partial 'Welcome to guestfish'
  # shellcheck disable=SC1112
  assert_line --partial 'Type: ‘help’ for help on commands'
}

@test "should execute script if specified" {
  skip # broken since v2

  copy_fixture tinycore.iso disk.img

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./guestfish \
    --ro \
    --add disk.img format:raw \
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
