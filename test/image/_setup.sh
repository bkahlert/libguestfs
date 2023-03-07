#!/usr/bin/env bash

set -uo pipefail

[ "${BUILD_TAG-}" ] || fail "unspecified image to test"

export IMAGE_PUID="id -u"
export IMAGE_PGID="id -g"

# Runs the specified Docker image with app specific defaults
# and the specified options.
# bashsupport disable=BP2001
# shellcheck disable=SC2034
image() {
  local args=() expected_status=0 expected_state=exited filter
  while (($#)); do
    case $1 in
      --stdout-only)
        filter=1 && shift
        ;;
      --stderr-only)
        filter=2 && shift
        ;;
      --code=*)
        expected_status=${1#*=} && shift
        ;;
      -d)
        expected_state=running && args+=("$1") && shift
        ;;
      *)
        args+=("$1") && shift
        ;;
    esac
  done
  set -- "${args[@]}"
  [ $# -gt 0 ] || fail 'IMAGE missing'
  output=$(
    exec 2>&1
    [ ! "${filter-}" = 1 ] || exec 2>/dev/null
    [ ! "${filter-}" = 2 ] || exec 1>/dev/null

    docker run --name "${BATS_TEST_NAME?must be only called from within a running test}" \
      ${IMAGE_PUID+-e PUID="$($IMAGE_PUID)"} \
      ${IMAGE_PGID+-e PGID="$($IMAGE_PGID)"} \
      -e TERM="$TERM" \
      -v "$PWD":"$PWD" \
      -w "$PWD" \
      "$@"
  ) || status=$?
  [ "${status-}" ] || status=0
  batsw_separate_lines lines output
  assert_status "$expected_status"
  assert_container_status "$BATS_TEST_NAME" "$expected_state"
}

# Cleans up an eventually still running container.
teardown() {
  docker rm --force "${BATS_TEST_NAME?must be only called from within a running test}" >/dev/null 2>&1 || true
}
