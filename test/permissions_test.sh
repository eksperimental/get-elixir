#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh
. ./config.sh

# Helpers
setDirRWX(){
  DIR="${DIR_EXIST_RWX}"
  KEEP_DIR="${DIR_EXIST_RWX}"
}

setDirR(){
  DIR="${DIR_EXIST_R}"
  KEEP_DIR="${DIR_EXIST_R}"
}

setDir0(){
  DIR="${DIR_EXIST_0}"
  KEEP_DIR="${DIR_EXIST_0}"
}

# Tests
test_check_dir_write_permissions() {
  check_dir_write_permisions "${DIR_EXIST}" 2> /dev/null
  ${_ASSERT_TRUE_} $?

  check_dir_write_permisions "${DIR_NOT_EXIST}" 2> /dev/null
  ${_ASSERT_TRUE_} '"Write to a non-existant dir, but inside a dir with write access"' $?
  # clean, bc the dir has been created
  rmdir "${DIR_NOT_EXIST}"

  setDirRWX
  check_dir_write_permisions "${DIR}" 2> /dev/null
  assertTrue $?

  setDirR
  check_dir_write_permisions "${DIR}" 2> /dev/null
  ${_ASSERT_FALSE_} $?

  setDir0
  check_dir_write_permisions "${DIR}" 2> /dev/null
  ${_ASSERT_FALSE_} $?
}

test_check_file_write_permissions() {
  check_file_write_permisions "${FILE_EXIST}" #2> /dev/null
  ${_ASSERT_TRUE_} $?

  check_file_write_permisions "${FILE_NOT_EXIST}" 2> /dev/null
  ${_ASSERT_FALSE_} $?

  setDirRWX
  check_file_write_permisions "${FILE_EXIST_RWX}" 2> /dev/null
  ${_ASSERT_TRUE_} $?

  setDirR
  check_dir_write_permisions "${FILE_EXIST_R}" 2> /dev/null
  ${_ASSERT_FALSE_} $?

  setDir0
  check_dir_write_permisions "${FILE_EXIST_0}" 2> /dev/null
  ${_ASSERT_FALSE_} $?
}

test_check_permissions_RWX() {
  setDirRWX

  COMMAND="download"
  check_permissions 2> /dev/null
  ${_ASSERT_TRUE_} $?

  COMMAND="unpack"
  check_permissions 2> /dev/null
  ${_ASSERT_TRUE_} $?

  COMMAND="download-script"
  check_permissions 2> /dev/null
  ${_ASSERT_TRUE_} $?

  COMMAND="update-script"
  check_permissions 2> /dev/null
  ${_ASSERT_TRUE_} $?

  COMMAND="foo"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?
}

test_check_permissions_R() {
  setDirR

  COMMAND="download"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?

  COMMAND="unpack"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?

  COMMAND="download-script"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?

  COMMAND="update-script"
  check_permissions 2> /dev/null
  ${_ASSERT_TRUE_} $?

  COMMAND="foo"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?
}

test_check_permissions_0() {
  setDir0

  COMMAND="download"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?

  COMMAND="unpack"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?

  COMMAND="download-script"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?

  COMMAND="update-script"
  check_permissions 2> /dev/null
  ${_ASSERT_TRUE_} $?

  COMMAND="foo"
  check_permissions 2> /dev/null
  ${_ASSERT_FALSE_} $?
}


# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
