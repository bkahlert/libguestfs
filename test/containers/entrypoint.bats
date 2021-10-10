#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' "$BUILD_TAG?unspecified image to test}"
}

teardown() {
  docker rm --force "$BATS_TEST_NAME" >/dev/null 2>&1 || true
}

@test "should print usage by default" {
  local container && container=$(docker run -d --name "$BATS_TEST_NAME" "$BUILD_TAG")
  assert_within 10s -- assert_container_log "$container" --partial 'Usage: COMMAND [ARG...]'
}

@test "should run specified command if specified" {
  run docker run --name "$BATS_TEST_NAME" "$BUILD_TAG" printf '%s\n%s\n' "foo" "bar"
  assert_line "foo"
  assert_line "bar"
}

@test "should print output to STDOUT" {
  local output && output=$(docker run --name "$BATS_TEST_NAME" "$BUILD_TAG" printf foo 2>/dev/null)
  assert_output "foo"
}

@test "should print logs to STDERR" {
  local output && output=$(docker run --name "$BATS_TEST_NAME" "$BUILD_TAG" printf foo 2>&1 1>/dev/null)
  assert_output --partial "updating timezone to UTC"
}

@test "should use rich console if terminal is connected" {
  TERM=xterm run docker run --tty --name "$BATS_TEST_NAME" "$BUILD_TAG" pwd
  assert_line --partial ''
  refute_line " ⚙ updating timezone to UTC"
}

@test "should use plain console if no terminal is connected" {
  run docker run --name "$BATS_TEST_NAME" "$BUILD_TAG" pwd
  refute_line --partial ''
  assert_line " ⚙ updating timezone to UTC"
  assert_line " ✔ updating timezone to UTC"
}
