#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should print usage by default" {
  image "$BUILD_TAG"
  assert_output --partial 'Usage: COMMAND [ARG...]'
}

@test "should run specified command if specified" {
  image "$BUILD_TAG" printf '%s\n%s\n' "foo" "bar"
  assert_line "foo"
  assert_line "bar"
}
