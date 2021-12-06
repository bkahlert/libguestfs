#!/usr/bin/env bats

@test "should change timezone to UTC by default" {
  image "$BUILD_TAG" bash -c 'date +"%Z"'
  assert_line --partial UTC
}

@test "should change timezone to specified timezone" {
  image -e "TZ=CEST" "$BUILD_TAG" bash -c 'date +"%Z"'
  assert_line --partial CEST
}
