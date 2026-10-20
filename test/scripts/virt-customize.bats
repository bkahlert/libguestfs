#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should print help" {

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-customize

  assert_line --partial 'virt-customize(1) man page'
}

@test "should write to a guest filesystem and read it back" {
  copy_fixture cirros.img disk.img

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-customize \
    --format qcow2 \
    --add disk.img \
    --write /boot/test.txt:content

  assert_success

  cp "$BATS_CWD/scripts/guestfish" "$BATS_TEST_TMPDIR"
  chmod +x "$BATS_TEST_TMPDIR/guestfish"
  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./guestfish \
    --ro \
    --format=qcow2 \
    --add disk.img \
    --inspector \
    <<<'copy-out /boot/test.txt ./'

  assert_success
  assert_file_exist 'test.txt'
  assert_file_contains 'test.txt' 'content'
}
