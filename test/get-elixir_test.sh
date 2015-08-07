#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh


oneTimeSetUp(){
  DIR_EXISTS_RWX="${__shunit_tmpDir}/DIR_EXISTS_RWX"
  DIR_EXISTS_R="${__shunit_tmpDir}/DIR_EXISTS_R"
  DIR_EXISTS_0="${__shunit_tmpDir}/DIR_EXISTS_0"

  mkdir "${DIR_EXISTS_RWX}"
  touch "${DIR_EXISTS_RWX}/file"
  chmod 0777 "${DIR_EXISTS_RWX}"

  mkdir "${DIR_EXISTS_R}"
  touch "${DIR_EXISTS_RWX}/file"
  chmod 0400 "${DIR_EXISTS_R}"

  mkdir "${DIR_EXISTS_0}"
  touch "${DIR_EXISTS_RWX}/file"
  chmod 0000 "${DIR_EXISTS_0}"
}

oneTimeTearDown(){
  rm -rf "${DIR_EXISTS_RWX}"
  rm -rf "${DIR_EXISTS_R}"
  rm -rf "${DIR_EXISTS_0}"
}


testShortHelp() {
  expected=$(short_help)
  actual=$(../get-elixir.sh 2>&1)
  assertEquals "short_help" "${expected}" "${actual}" 
}

testConfirm() {
  ASSUME_YES=0
  ASK_OVERWRITE=1
  confirm "message"
  local actual=$?
  assertSame 0 "${actual}"
}

#############
# PERMISIONS

setDirRWX(){
  DIR="${DIR_EXISTS_RWX}"
  KEEP_DIR="${DIR_EXISTS_RWX}"
}

setDirR(){
  DIR="${DIR_EXISTS_R}"
  KEEP_DIR="${DIR_EXISTS_R}"
}

setDir0(){
  DIR="${DIR_EXISTS_0}"
  KEEP_DIR="${DIR_EXISTS_0}"
}

testCheckPermissionFunctions() {
  setDirRWX
  #set -x
  check_dir_write_permisions "${DIR}" 2> /dev/null
  ${_ASSERT_TRUE_} $?

  check_dir_write_permisions "${DIR}/dir_does_not_exist" 2> /dev/null
  ${_ASSERT_TRUE_} '"Write to a non-existant dir, but inside a dir with write access"' $?

  check_file_write_permisions "${DIR}/file" 2> /dev/null
  ${_ASSERT_TRUE_} $?

  check_file_write_permisions "${DIR}/file_does_not_exist" 2> /dev/null
  ${_ASSERT_FALSE_} $?
}

testCheckPermissionsRWX() {
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
}

testCheckPermissionsR() {
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
}

testCheckPermissions0() {
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
}


# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
