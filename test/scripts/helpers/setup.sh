#!/bin/bash

set -euo pipefail

export SCRIPT="${2:?}"

load "${BATS_TEST_DIRNAME}/../helpers/common.sh"
load_lib 'support'
load_lib 'assert'
load_lib 'file'

assert [ -f "${BATS_CWD}/scripts/${SCRIPT}" ]
cp "${BATS_CWD}/scripts/${SCRIPT}" "${BATS_TEST_TMPDIR}/${SCRIPT}"
cd "$BATS_TEST_TMPDIR" || exit 1
chmod +x "${SCRIPT}"
assert [ -x "${SCRIPT}" ]
