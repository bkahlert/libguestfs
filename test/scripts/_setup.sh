#!/usr/bin/env bash

set -euo pipefail

declare -r bats_test_basename="${BATS_TEST_FILENAME%.*}"
declare -r script="${bats_test_basename##*/}"

assert_file_exist "$BATS_CWD/scripts/$script"
cp "$BATS_CWD/scripts/$script" "$BATS_TEST_TMPDIR"
chmod +x "$BATS_TEST_TMPDIR/$script"
assert_file_executable "$BATS_TEST_TMPDIR/$script"
