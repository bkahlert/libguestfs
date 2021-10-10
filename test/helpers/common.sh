#!/bin/bash
#
# Common test setup

set -euo pipefail

# Delegates to echo just as if called directory
# **unless** a Bats test is being executed
# (determined by an open file descriptor 3).
#
# In case of a test, this function prints
# TAP compliant with a preceding `#` and
# Bats compliant to file descriptor 3.
#
# Globals:
#   none
# Arguments:
#   * - echo arguments
# Outputs:
#   FD3 - echo message
trace() {
  if [ $# -eq 0 ] && [ "${output-}" ]; then
    set -- "${output:-}"
  fi
  if { true >&3; } 2<>/dev/null; then
    echo '#' "$*" >&3
  else
    echo "$*"
  fi
}

# Downloads a Bats library
#
# Globals:
#   BATS_SUITE_TMPDIR
# Arguments:
#   1 - short name of the library, e.g. assert
# Returns:
#   0 - download successful
#   1 - otherwise
# Outputs:
#   STDOUT - directory containing the downloaded and extracted Bats library
#   STDERR - details, on failure
download_lib() {
  local short_name="${1?}"

  local url="https://github.com/bats-core/bats-${short_name}/tarball/master"
  local target="${BATS_SUITE_TMPDIR:?}/_libs/${short_name}"

  if [ ! -d "$target" ] || [ ! -f "$target/load.bash" ]; then
    rm -rf "${target:?}"
    mkdir -p "$target"
    (
      cd "$target" || exit
      curl --location --insecure --silent --show-error "$url" \
        | tar --extract --gunzip --strip-components=1
    )
  fi

  if [ ! -d "$target" ] || [ ! -f "$target/load.bash" ]; then
    echo "Failed to download $short_name from $url" >&2
    return 1
  fi
  echo "$target"
  return 0
}

# Loads a Bats library from /opt.
#
# Globals:
#   none
# Arguments:
#   1 - Short name of the library, e.g. assert
load_lib() {
  local short_name=${1:?}

  local file="/opt/bats-${short_name}/load.bash"
  if [ ! -f "$file" ]; then
    trace "No local copy of library ${short_name} found at ${file}. Downloading..."
    local download && download="$(download_lib "${short_name}")"
    if [ -f "${download}/load.bash" ]; then
      file="${download}/load.bash"
    fi
  fi
  if [ ! -f "$file" ]; then
    printf 'bats: %s does not exist\n' "$file" >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  source "${file}"

  patch_lib "$short_name"
}

# Applies patches to libs.
# Arguments:
#   1 - Short name of the library, e.g. assert
patch_lib() {
  local short_name=${1:?}

  case $short_name in
    assert)
      local bats_assert_line
      bats_assert_line=$(declare -f assert_line) || true
      if [ "${bats_assert_line-}" ]; then
        eval "bats_${bats_assert_line}"
        # bashsupport disable=BP5008
        assert_line() {
          local shell_option=nullglob
          if shopt -q "$shell_option"; then
            printf '%s\n' "❗ Bats' assert_line seems broken if shell option $shell_option is enabled." >&2
            printf '%s\n' "❗ Workaround: enable $shell_option only locally or use assert_output." >&2
            exit 1
          fi
          bats_assert_line "$@"
        }
      fi
      ;;
    file)
      local bats_fn bats_decl
      for bats_fn in $(set | grep -e "^assert_file_*"); do
        [[ $bats_fn == assert_file_* ]] || continue
        bats_decl=$(declare -f "$bats_fn") || true
        if [ "${bats_decl-}" ]; then
          eval "bats_$bats_decl"
          eval "$bats_fn() {
            BATSLIB_FILE_PATH_REM=\${BATSLIB_FILE_PATH_REM:-} \
            BATSLIB_FILE_PATH_ADD=\${BATSLIB_FILE_PATH_ADD:-} \
            bats_$bats_fn \"\$@\"
          }"
        fi
      done
      ;;
  esac
}

# Tests if at least one log line matches the provided arguments.
# Arguments:
#   1 - Docker container ID
#   * - assert_line arguments
assert_container_log() {
  local container=${1:?container missing} && shift
  run docker logs "$container"
  assert_line "$@"
}

# Tests the current status of a Docker container.
# Globals:
#   none
# Arguments:
#   1 - Docker container ID
#   2 - expected value
# Returns:
#   0 - statuses equal
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_container_status() {
  local actual_status && actual_status=$(docker container inspect --format "{{.State.Status}}" "$1")
  local expected_status=$2
  assert_equal "${actual_status}" "${expected_status}"
}

# Tests the owner of a file.
# The original implementation suffers from its reliance on sudo.
# see https://github.com/bats-core/bats-file#assert_file_permission
# Globals:
#   none
# Arguments:
#   1 - Docker container ID
#   2 - expected value
# Returns:
#   0 - statuses equal
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_file_owner_group() {
  local file="$1"
  local user="$2"
  local group="$3"

  run ls -l "$file" # total 10444 -rw-r--r-- 1 tester tester 10692675 Sep 25 17:29 core.gz

  local s='\s+'
  local regexp='.*\d+'                             # hard links
  regexp="${regexp}${s}${user}"                    # file owner
  regexp="${regexp}${s}${group}"                   # file group
  regexp="${regexp}${s}"'\d+'                      # file size
  regexp="${regexp}${s}"'\w+'"${s}"'\d+\s+\d+:\d+' # date and time
  regexp="${regexp}${s}${file}"                    # file name
  assert_output --regexp "${regexp}"
}

# Calls the specified command once a seconds for at most the
# specified amount of time and returns 0 if the command succeeds within time.
assert_within() {
  local -i time=${1%s} && shift
  [ ! "${1-}" = "--" ] || shift
  local -a cmdline=("$@")

  local -i timeout=$((SECONDS + time))
  while true; do
    run "${cmdline[@]}"
    [ ! "${status-}" -eq 0 ] || { assert_success; return 0; }
    [ "$SECONDS" -le "$timeout" ] || { assert_success; break; }
    sleep 1
  done
  echo " $(tput setaf 1)✘$(tput sgr0) '${cmdline[*]}' did not succeed within ${time}s"
  exit 1
}

# Prints the IP of the specified container.
#   1 - Docker container ID
container_ip() {
  docker inspect "${1:?container missing}" | jq --join-output '.[].NetworkSettings.Networks.bridge.IPAddress'
}

# Finds the absolute path for the given fixture.
# The search starts with the current test's fixture directory (e.g. test/foo/fixture)
# and if no fixture is found, continues with the parent directory (e.g. test/fixture)
# until the parent of the test directory (e.g. fixture) is reached.
#
# Arguments:
#   1 - name of the fixture
#   2 - the directory in which to look for (default: $BATS_TEST_DIRNAME)
# Outputs:
#   STDOUT - absolute path of the given fixture
#   STDERR - details on failure
fixture() {
  local dir="${2:-${BATS_TEST_DIRNAME:?}}"
  if [ ! "${dir#${BATS_CWD:?}}" ]; then
    echo "Cannot find fixture $1" >&2
    exit 1
  fi

  if [ -e "$dir/fixtures/$1" ]; then
    echo "$dir/fixtures/$1"
    return 0
  fi

  fixture "$1" "${dir%/*}"
}

# Creates a copy of the given fixture at the given target.
# See `fixture`
#
# Arguments:
#   1 - name of the fixture
#   2 - target
# Outputs:
#   STDERR - details on failure
cp_fixture() {
  cp "$(fixture "${1:?}")" "${2:?}"
}

# Tests if this test run was invoked via BashSupport Pro.
# Globals:
#   BASH_SOURCE
#   BATS_SHELL
# Returns:
#   0 - successful
#   1 - not successful
test_bashsupport_pro() {
  local i
  for i in "${!BASH_SOURCE[@]}"; do
    [[ ${BASH_SOURCE[i]} =~ IntelliJ|intellij && ${BASH_SOURCE[i]} =~ "bashsupport-pro" ]] || continue
    return 0
  done
  return 1
}

# Tests if the currently running Bats has the required minimal version.
# Returns:
#   0 - successful
#   1 - not successful
test_min_bats_version() {
  local version
  version=$(bats --version) 2>/dev/null
  version=${version#Bats }
  [[ ${version} == 1.4* ]]
}

# Sanity checks
main() {

  ! test_min_bats_version || return 0

  if test_bashsupport_pro; then
    # shellcheck disable=SC2016
    printf '%s' '
❗ You are running these tests with a version of BashSupport Pro that uses an outdated Bats.

You can workaround this problem by using the Bats wrapper `batsw` instead:
1. Open the outdated bats binary in a text editor.
   It should be printed at the very top of the test output.
2. Paste the following lines right after the first line.

current_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
formatter="${current_dir%/bats-core/*}/bats-core/libexec/bats-core/bats-format-bashpro"
if [ ! -f "$formatter" ]; then echo "Could not find BashSupport Pro formatter at $formatter" >&2; exit 1; fi

project_dir=$PWD
while true; do
  if [ ! "${project_dir}" ]; then echo "Could not find BashSupport Pro formatter at $formatter" >&2; exit 1; fi
  if [ ! -f "${project_dir}/batsw" ]; then project_dir="${project_dir%/*}"; continue; fi
  break
done
[ -x "${project_dir}/batsw" ] || chmod +x "${project_dir}/batsw"
cd "${project_dir}" && ./batsw --quiet --inject "libexec/bats-core/bats-format-junit=$(cat "$formatter")" "${@//bashpro/junit}"
exit

3. Run the tests again
' >&2
  else
    # shellcheck disable=SC2016
    printf '%s' '
❗ You are running these tests with an outdated version of Bats.

Please update or use the Bats wrapper `batsw`.
' >&2
  fi

  exit

}

main "$@"
