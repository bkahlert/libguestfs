#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' 'guestfish'
}

@test "should start interactive shell by default" {
  cat <<EXPECT > guestfish.exp && chmod +x guestfish.exp
#!/usr/bin/expect
set timeout 15
spawn "./guestfish"
expect "help"
send "quit"
interact
EXPECT

  local output && output="$(LIBGUESTFS_IMAGE="$BUILD_TAG" ./guestfish.exp 2>&1)" || true

  assert_output --partial 'Welcome to guestfish'
  # shellcheck disable=SC1112
  assert_output --partial 'Type: ‘help’ for help on commands'
}

@test "should execute script if specified" {
  cp_fixture tinycore.iso disk.img

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./guestfish \
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
