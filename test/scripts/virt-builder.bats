#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should print help" {

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-builder

  # shellcheck disable=SC1112
  assert_line --partial 'Use ‘--list’ to list available template'
}

@test "should execute script" {

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-builder \
    --list \
    --list-format long \
    --no-check-signature

  assert_line --partial 'os-version: '
  assert_line --partial 'Full name: '
  assert_line --partial 'Architecture: '
  assert_line --partial 'Minimum/default size: '
  assert_line --partial 'Download size: '
}

@test "should build and customize an image from a local template" {
  copy_fixture cirros.img template.qcow2
  cat >index <<'INDEX'
[cirros-smoke]
name=CirrOS smoke test
arch=x86_64
file=template.qcow2
format=qcow2
size=52428800
INDEX

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run ./virt-builder cirros-smoke \
    --source "file://$PWD/index" \
    --no-check-signature \
    --no-cache \
    --no-network \
    --arch x86_64 \
    --format raw \
    --output built.img \
    --write /boot/builder-smoke.txt:builder-content

  assert_success
  assert_file_exist built.img

  LIBGUESTFSW_IMAGE="$BUILD_TAG" run bash "$BATS_CWD/scripts/guestfish" \
    --ro \
    --format=raw \
    --add built.img \
    --inspector \
    <<<'cat /boot/builder-smoke.txt'

  assert_success
  assert_output builder-content
}
