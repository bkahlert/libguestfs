#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should print help" {

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./virt-customize

  assert_line --partial 'virt-customize(1) man page'
}

@test "should execute script" {
  copy_fixture cirros.img disk.img

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./virt-customize \
    --add disk.img \
    --write /boot/test.txt:content

  cp "$BATS_CWD/scripts/guestfish" "$BATS_TEST_TMPDIR/guestfish"
  chmod +x "$BATS_TEST_TMPDIR/guestfish"
  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./guestfish \
    --ro \
    --add disk.img \
    --inspector \
    <<< 'copy-out /boot/test.txt ./'

  assert_file_exist 'test.txt'
  assert_file_contains 'test.txt' 'content'
}
