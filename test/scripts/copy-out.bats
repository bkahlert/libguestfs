#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  load _setup.sh 'copy-out'
}

@test "should copy-out / by default" {
  copy_fixture cirros.img disk.img

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./copy-out

  assert_file_exist 'disk.data/initrd.img'
  assert_file_exist 'disk.data/home/cir''ros/.profile'
}

@test "should copy-out specified path" {
  copy_fixture cirros.img disk.img

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./copy-out /home/cirros

  assert_file_not_exist 'disk.data/initrd.img'
  assert_file_exist 'disk.data/home/cir''ros/.profile'
}

@test "should copy-out from image in subdir" {
  mkdir foo
  copy_fixture cirros.img foo/disk.img

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./copy-out /home/cirros

  assert_file_exist 'foo/disk.data/home/cir''ros/.profile'
}

@test "should fail on missing disk" {

  LIBGUESTFS_IMAGE="$BUILD_TAG" run ./copy-out /home/cirros

  assert_line --partial 'No image found.'
  assert_line --partial 'Please run copy-out in a directory containing an .img file.'
}
