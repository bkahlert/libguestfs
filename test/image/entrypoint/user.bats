#!/usr/bin/env bats
# bashsupport disable=BP5007
# shellcheck disable=SC2016,SC2218

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

@test "should preserve identity with a distinct application group" {
  image --env PUID=2000 --env PGID=2001 --entrypoint bash "$BUILD_TAG" -ceu '
    groupmod --new-name guestfs-group libguestfs
    sed -i "s/app_group=libguestfs/app_group=guestfs-group/" /usr/local/sbin/entrypoint.sh
    exec /usr/local/sbin/entrypoint.sh "$@"
  ' bash bash -ceu '
    printf "identity=%s:%s\n" "$(id -u)" "$(id -g)"
    case " $(id -G) " in
      *" $(getent group kvm | cut -d: -f3) "*) ;;
      *) exit 1 ;;
    esac
  '
  assert_line 'identity=2000:2001'
}

@test "should access a Docker socket with an unknown group ID" {
  socket_image 65432 '' bash -ceu '
    test -r /var/run/docker.sock
    test -w /var/run/docker.sock
    printf "identity=%s:%s\n" "$(id -u)" "$(id -g)"
    stat -c "socket=%u:%g:%a" /var/run/docker.sock
  '
  assert_line 'identity=2000:2001'
  assert_line 'socket=0:65432:660'
}

@test "should reuse an existing Docker socket group" {
  socket_image 65432 existing-socket bash -ceu '
    test -r /var/run/docker.sock
    test -w /var/run/docker.sock
    printf "identity=%s:%s\n" "$(id -u)" "$(id -g)"
    getent group 65432
    stat -c "socket=%u:%g:%a" /var/run/docker.sock
  '
  assert_line 'identity=2000:2001'
  assert_line 'existing-socket:x:65432:libguestfs'
  assert_line 'socket=0:65432:660'
}

@test "should access a Docker socket using the configured primary group" {
  socket_image 2001 '' bash -ceu '
    test -r /var/run/docker.sock
    test -w /var/run/docker.sock
    printf "identity=%s:%s\n" "$(id -u)" "$(id -g)"
    stat -c "socket=%u:%g:%a" /var/run/docker.sock
  '
  assert_line 'identity=2000:2001'
  assert_line 'socket=0:2001:660'
}

@test "should preserve identity and supplementary groups without a Docker socket" {
  image --env PUID=2000 --env PGID=2001 "$BUILD_TAG" bash -ceu '
    test ! -e /var/run/docker.sock
    printf "identity=%s:%s\n" "$(id -u)" "$(id -g)"
    case " $(id -G) " in
      *" $(getent group kvm | cut -d: -f3) "*) ;;
      *) exit 1 ;;
    esac
  '
  assert_line 'identity=2000:2001'
}

@test "should ignore a regular file at the Docker socket path" {
  image --env PUID=2000 --env PGID=2001 --entrypoint bash "$BUILD_TAG" -ceu '
    touch /var/run/docker.sock
    chown 0:65432 /var/run/docker.sock
    chmod 0600 /var/run/docker.sock
    exec /usr/local/sbin/entrypoint.sh bash -ceu "
      test ! -r /var/run/docker.sock
      test ! -w /var/run/docker.sock
      ! getent group 65432
      stat -c socket=%u:%g:%a /var/run/docker.sock
    "
  '
  assert_line 'socket=0:65432:600'
}

socket_image() {
  local socket_gid="$1" socket_group="$2"
  shift 2
  image --env PUID=2000 --env PGID=2001 \
    --env SOCKET_GID="$socket_gid" --env SOCKET_GROUP="$socket_group" \
    --entrypoint bash "$BUILD_TAG" -ceu '
      if [ "$SOCKET_GROUP" ]; then
        groupadd --gid "$SOCKET_GID" "$SOCKET_GROUP"
      fi
      perl -MSocket - /var/run/docker.sock <<"PERL"
socket(my $socket, PF_UNIX, SOCK_STREAM, 0) or die "socket: $!";
bind($socket, sockaddr_un($ARGV[0])) or die "bind: $!";
PERL
      chown "0:$SOCKET_GID" /var/run/docker.sock
      chmod 0660 /var/run/docker.sock
      exec /usr/local/sbin/entrypoint.sh "$@"
    ' bash "$@"
}
