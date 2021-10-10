#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load 'helpers/setup.sh' "$BUILD_TAG?unspecified image to test}"
}

teardown() {
  docker rm --force "$BATS_TEST_NAME" >/dev/null 2>&1 || true
}

@test "should persist APP_USER and APP_GROUP in entrypoint.sh" {
  run docker run --name "$BATS_TEST_NAME" --entrypoint bash "$BUILD_TAG" -c 'cat /usr/local/sbin/entrypoint.sh'
  assert_line '  local -r app_user=libguestfs app_group=libguestfs'
}
