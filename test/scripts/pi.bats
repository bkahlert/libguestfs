#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' 'pi'
}

@test "should print help" {

  run ./pi

  assert_line --partial 'No image found.'
  assert_line --partial 'Please run pi in a directory containing an .img file.'
}

@test "should boot" {
  cp_fixture cirros.img disk.img

  run ./pi

  assert_line --partial 'CPU: ARMv6-compatible processor'
}
