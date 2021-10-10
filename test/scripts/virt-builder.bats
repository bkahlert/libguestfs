#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' 'virt-builder'
}

@test "should print help" {

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./virt-builder

  # shellcheck disable=SC1112
  assert_line --partial 'Use ‘--list’ to list available template'
}

@test "should execute script" {

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./virt-builder \
    --list \
    --list-format long \
    --no-check-signature

  assert_line --partial 'os-version: '
  assert_line --partial 'Full name: '
  assert_line --partial 'Architecture: '
  assert_line --partial 'Minimum/default size: '
  assert_line --partial 'Download size: '
}
