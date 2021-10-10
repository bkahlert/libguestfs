#!/bin/bash

set -euo pipefail

export IMAGE_ID=${2:?}
load "${BATS_TEST_DIRNAME}/../helpers/common.sh"

load_lib support
load_lib assert
load_lib file

assert [ "${IMAGE_ID-}" ]
cd "$BATS_TEST_TMPDIR" || exit 1
