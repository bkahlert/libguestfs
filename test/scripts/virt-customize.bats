#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should print help" {

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-customize

  assert_line --partial 'virt-customize(1) man page'
}

@test "should execute script" {
  skip # broken since v1.2.1

  copy_fixture cirros.img disk.img

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-customize \
    --add disk.img format:raw \
    --write /boot/test.txt:content

  cp "$BATS_CWD/scripts/guestfish" "$BATS_TEST_TMPDIR"
  chmod +x "$BATS_TEST_TMPDIR/guestfish"
  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./guestfish \
    --ro \
    --add disk.img format:raw \
    --inspector \
    <<<'copy-out /boot/test.txt ./'

  assert_file_exist 'test.txt'
  assert_file_contains 'test.txt' 'content'
}
