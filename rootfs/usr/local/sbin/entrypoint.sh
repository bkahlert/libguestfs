#!/usr/bin/env bash

source logr.sh

# Fixes permissions to stdout and stderr.
# see https://github.com/containers/conmon/pull/112
fix_std_permissions() {
  chmod -R 0777 /proc/self/fd/1 /proc/self/fd/2 || logr error "failed to change permissions of stdout and stderr"
}

# Updates the group ID of the specified group.
# Arguments:
#   1 - name of the group
#   2 - ID of the group
update_group_id() {
  local -r group=${1:?group missing}
  local -r -i gid=${2:?gid missing}
  [ "$gid" -eq "$gid" ] 2>/dev/null || logr error --code "$EX_DATAERR" "invalid group ID $gid"
  if [ "$gid" ] && [ "$gid" != "$(id -g "${group}")" ]; then
    sed -i -e "s/^${group}:\([^:]*\):[0-9]*/${group}:\1:${gid}/" /etc/group
    sed -i -e "s/^${group}:\([^:]*\):\([0-9]*\):[0-9]*/${group}:\1:\2:${gid}/" /etc/passwd
  fi
}

# Updates the user ID of the specified user.
# Arguments:
#   1 - name of the user
#   2 - ID of the user
update_user_id() {
  local -r user=${1:?user missing}
  local -r uid=${2:?uid missing}
  [ "$uid" -eq "$uid" ] 2>/dev/null || logr error --code "$EX_DATAERR" "invalid user ID $uid"
  if [ "$uid" ] && [ "$uid" != "$(id -u "${user}")" ]; then
    sed -i -e "s/^${user}:\([^:]*\):[0-9]*:\([0-9]*\)/${user}:\1:${uid}:\2/" /etc/passwd
  fi
}

# Fixes the home permissions for the specified user.
# Arguments:
#   1 - name of the user
fix_home_permissions() {
  local -r user=${1:?user missing}
  local -r home="/home/$user"
  mkdir -p "$home"
  chown -R "$user" "$home"
  chmod -R u+rw "$home"
}

# Updates the timezone.
# Arguments:
#   1 - timezone
update_timezone() {
  local -r timezone=${1:?timezone missing}
  ln -snf "/usr/share/zoneinfo/$timezone" /etc/localtime
  printf '%s\n' "$timezone" >/etc/timezone
}

# Sets the specified configuration keyword values in sshd_config.
# If a keyword is present, its value will be updated.
# If a keyword commented out, it will be commented in and its value will be updated.
# If a keyword is not present, it will be added with its value to the end of the file.
#
# Arguments:
#   List of key value pairs, e.g. "foo=bar"
set_sshd_config() {
  local option
  for option in "$@"; do
    logr info "SSH daemon config: setting $option"
    local key="${option%%=*}"
    local value="${option#*=}"
    if [ ! "$key" ]; then
      logr warn "SSH daemon config: skipping invalid key in ${option}"
      continue
    fi
    if sed \
      --expression 's/#?[[:space:]]*'${key}' .*$/'${key}' '${value}'/g' \
      --in-place \
      --regexp-extended \
      /etc/ssh/sshd_config; then
      logr success "SSH daemon config: $key set to $value"
    else
      logr error "SSH daemon config: failed to set $key to $value"
    fi
  done
}

# Enables SSH public key authentication and
# disables password authentication for the specified user.
# Arguments:
#   1 - name of the user
#   2 - public key
use_ssh_public_key_authentication() {
  local -r user="${1:?user missing}"
  local -r public_key="${2:?public key missing}"

  mkdir -p "/home/${user}/.ssh"

  logr task "setting authorized key for $user to ${public_key:0:10}..." \
    -- bash -c "echo '$public_key' >'/home/$user/.ssh/authorized_keys'"
  logr task "setting random password for $user" \
    -- bash -c "echo '$user:$(tr -dc '[:alnum:]' </dev/urandom 2>/dev/null | dd bs=4 count=8 2>/dev/null)' | chpasswd"

  logr task "disabling password authentication" \
    -- set_sshd_config \
    'ChallengeResponseAuthentication=no' \
    'PasswordAuthentication=no'
}

# Enables SSH password authentication and
# disables public key authentication for the specified user.
# Arguments:
#   1 - name of the user
#   2 - password (default: $user)
use_ssh_password_authentication() {
  local -r user="${1:?user missing}"
  local -r password="${2:-${user}}"

  logr task "setting password for $user to ${password:0:2}..." \
    -- bash -c "echo '$user:$password' | chpasswd"
  logr task "removing authorized key from $user" \
    -- bash -c "[ ! -f '/home/$user/.ssh/authorized_keys' ] || rm '/home/$user/.ssh/authorized_keys'"

  logr task "enabling password authentication" \
    -- set_sshd_config \
    'ChallengeResponseAuthentication=yes' \
    'PasswordAuthentication=yes'
}

# Fixes SSH permissions for the specified user and group.
# Arguments:
#   1 - name of the user
#   2 - name of the group
fix_ssh_permissions() {
  local -r user="${1:?user missing}"
  local -r group="${2:?group missing}"
  local ssh_dir="/home/$user/.ssh"

  [ -d "$ssh_dir" ] || return 0

  logr task "changing ownership of $ssh_dir to $user:$group" \
    -- chown -R "$user:$group" "$ssh_dir"
  logr task "changing permissions of $ssh_dir to 0700" \
    -- chmod -R 0700 "$ssh_dir"
  for key_file in "/home/${user}/.ssh/key_file_"*; do
    if [ -f "${key_file}" ]; then
      logr task "changing permissions of private key $key_file to 0600" -- chmod -R 0600 "$key_file"
    fi
  done
  for pub_key_file in "$ssh_dir/"*.pub; do
    if [ -f "$pub_key_file" ]; then
      logr task "changing permissions of public key $pub_key_file to 0644" -- chmod -R 0644 "${pub_key_file}"
    fi
  done
}

# Starts supervisord and waits for the given processes to start.
# The actual service configuration is located at /etc/supervisor/supervisord.conf.
# Globals:
#   SUPERVISOR_PID - will be set to the PID of the running supervisord
# Arguments:
#   * - processes to wait for
# Outputs:
#   1 - PID of the supervisord process
start_processes() {
  local pidfile=/var/run/supervisord.pid
  /usr/bin/supervisord \
    --pidfile="$pidfile" \
    --configuration "/etc/supervisor/supervisord.conf" &

  for process in "$@"; do
    wait_for_process "$process"
  done

  # shellcheck disable=SC2034
  # bashsupport disable=BP2001,BP5006
  printf -v SUPERVISOR_PID %s "$(cat "$pidfile")"
}

# Waits for the specified process.
# Arguments:
#   1 - name of the process
#   2 - max time to wait in seconds (default: 30)
# Returns:
#   0 - process started in time
#   1 - process failed to start in time
wait_for_process() {
  local -r process_name="$1"
  local -r -i max_time_wait="${2:-30}"
  local waited_sec=0
  while ! pgrep "$process_name" >/dev/null; do
    logr task "waiting $((max_time_wait - waited_sec))s for process ${process_name}" >&2
    sleep 1
    waited_sec=$((waited_sec + 1))
    [ "$waited_sec" -lt "$max_time_wait" ] || logr fail "$process_name did not start in time"
  done
  logr success "$process_name is running" >&2
}


# take ownership of /disk.img
fix_disk() {
  local -r user="${1:?user missing}"
  if [ -f /disk.img ]; then
    chown -R "$user" /disk.img
    chmod -R u+rw /disk.img
  fi
}

# see https://libguestfs.org/guestfs-faq.1.html#where-can-i-get-the-latest-binaries-for
fix_vmlinuz() {
  local -r user="${1:?user missing}"
  chmod 0644 /boot/vmlinuz*
  usermod -a -G kvm "$user"
}


# Entrypoint for this container that updates system settings
# in order to reflect the configuration made by environment variables.
# Arguments:
#   * - Runs the passed arguments as a command line with dropped permissions.
#       If no arguments were passed runs as a service.
main() {
  local -r app_user='' app_group=''

  # redirect entrypoint standard output to FD3 = /dev/null
  exec 3>/dev/null
  # ... and only print it to standard error if DEBUG=1 (errors will always be printed)
  [ "${DEBUG:-0}" = 0 ] || exec 3>&2
  {
    [ ! "${TZ-}" ] || logr task "updating timezone to $TZ" -- update_timezone "$TZ"
    [ ! "${PGID-}" ] || logr task "updating ID of group $app_group to $PGID" -- update_group_id "$app_group" "$PGID"
    [ ! "${PUID-}" ] || logr task "updating ID of user $app_user to $PUID" -- update_user_id "$app_user" "$PUID" || logr fail "failed to update ID of user $app_user to $PUID"
    logr task "fixing permissions of stdout and stderr" -- fix_std_permissions
    logr task "fixing permissions of home directory for $app_user" -- fix_home_permissions "$app_user"
    logr task "fixing permissions of .ssh directory for $app_user" -- fix_ssh_permissions "$app_user" "$app_group"

    logr task "fixing permissions of /disk.img" -- fix_disk "$app_user"
    logr task "fixing permissions of /boot/vmlinuz*" -- fix_vmlinuz "$app_user"

    logr info "changing to $app_user:$app_group"
    esc cursor_show
  } >&3
  exec 3>&-

  exec yasu "$app_user:$app_group" entrypoint_user.sh "$@"
}

main "$@"
