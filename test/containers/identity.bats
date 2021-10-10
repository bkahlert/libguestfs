#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' "$BUILD_TAG?unspecified image to test}"
}

teardown() {
  docker rm --force "$BATS_TEST_NAME" >/dev/null 2>&1 || true
}

@test "should change user ID to 1000 by default" {
  run docker run --name "$BATS_TEST_NAME" "$BUILD_TAG" id
  assert_line --partial 'uid=1000'
}

@test "should change user ID to specified ID" {
  run docker run -e PUID=2000 --name "$BATS_TEST_NAME" "$BUILD_TAG" id
  assert_line --partial 'uid=2000'
}

@test "should change group ID to 1000 by default" {
  run docker run --name "$BATS_TEST_NAME" "$BUILD_TAG" id
  assert_line --partial 'gid=1000'
}

@test "should change group ID to specified ID" {
  run docker run -e PGID=2000 --name "$BATS_TEST_NAME" "$BUILD_TAG" id
  assert_line --partial 'gid=2000'
}
