#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  export EX_DATAERR=65
}

@test "should print output to STDOUT" {
  image --stdout-only "$BUILD_TAG" guestfish --help
  assert_line --partial "guestfish: guest filesystem shell"
}

@test "should not print logs by default" {
  image --stderr-only "$BUILD_TAG" guestfish --help
  assert_output ""
}

@test "should print logs to STDERR with enabled DEBUG" {
  image --stderr-only --env DEBUG=1 "$BUILD_TAG" guestfish --help
  assert_line --partial "updating timezone to UTC"
}

@test "should print logs if errors occur" {
  image --code=$EX_DATAERR --stderr-only --env DEBUG=1 --env PUID=invalid "$BUILD_TAG" guestfish --help
  assert_line --partial "invalid user ID invalid"
}

@test "should print logs if errors occur with disabled DEBUG" {
  image --code=$EX_DATAERR --stderr-only --env DEBUG=0 --env PUID=invalid "$BUILD_TAG" guestfish --help
  refute_line --partial "updating timezone to UTC"
  assert_line --partial "invalid user ID invalid"
}

@test "should use rich console if terminal is connected" {
  TERM=xterm image --env DEBUG=1 --tty "$BUILD_TAG" guestfish --help
  assert_line --partial ''
  refute_line " ⚙ updating timezone to UTC"
}

@test "should use plain console if no terminal is connected" {
  TERM=xterm image --env DEBUG=1 "$BUILD_TAG" guestfish --help
  refute_line --partial ''
  assert_line "   updating timezone to UTC"
  assert_line " ✔ updating timezone to UTC"
}


@test "should replace entrypoint with user entrypoint" {
  image --env DEBUG=1 "$BUILD_TAG" guestfish
  refute_line --partial "entrypoint.sh"
}

@test "should replace user entrypoint with user process" {
  image --env DEBUG=1 "$BUILD_TAG" guestfish
  refute_line --partial "entrypoint_user.sh"
}
