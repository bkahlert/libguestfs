#!/usr/bin/env bats

@test "should change LANG to C.UTF-8 by default" {
  image "$BUILD_TAG" bash -c 'echo "> $LANG <"'
  assert_line --partial "> C.UTF-8 <"
}

@test "should change LANG to specified lang" {
  image -e "LANG=C" "$BUILD_TAG" bash -c 'echo "> $LANG <"'
  assert_line --partial "> C <"
}
