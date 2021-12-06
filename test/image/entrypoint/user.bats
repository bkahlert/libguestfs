#!/usr/bin/env bats
# bashsupport disable=BP5007

@test "should persist APP_USER and APP_GROUP in entrypoint.sh" {
  image "$BUILD_TAG" cat /usr/local/sbin/entrypoint.sh
  assert_line '  local -r app_user=libguestfs app_group=libguestfs'
}

@test "should change user ID to 1000 by default" {
  IMAGE_PUID='' image "$BUILD_TAG" bash -c 'echo "> $(id -u) <"'
  assert_line --partial "> 1000 <"
}

@test "should change group ID to 1000 by default" {
  IMAGE_PGID='' image "$BUILD_TAG" bash -c 'echo "> $(id -g) <"'
  assert_line --partial "> 1000 <"
}

@test "should change user ID to specified ID" {
  IMAGE_PUID="echo 2000" image "$BUILD_TAG" bash -c 'echo "> $(id -u) <"'
  assert_line --partial "> 2000 <"
}

@test "should change group ID to specified ID" {
  IMAGE_PGID="echo 2000" image "$BUILD_TAG" bash -c 'echo "> $(id -g) <"'
  assert_line --partial "> 2000 <"
}
