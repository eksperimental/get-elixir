#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh
. ./config.sh

setUp(){
  do_instantiate_vars
  KEEP_DIR="${DIR_EXIST}"
}

#test_download_source() {
#  local release result file modification_time modification_time_2
#  release="1.0.5"
#  file="${KEEP_DIR}/v${release}.tar.gz"
#
#  echo "Download file (no local copy exists)"
#  download_source "${release}" 2> /dev/null
#  #download_source "${release}" >/dev/null 2>&1
#  result=$?
#  ${_ASSERT_TRUE_} "'${result}'"
#  ${_ASSERT_TRUE_} "'[ -f ${file} ]'"
#
#  echo "Download file (now a local copy exists), then keep it"
#  do_instantiate_vars && KEEP_DIR="${DIR_EXIST}"
#  assume_no
#  modification_time="$(stat -c '%Y' "${file}")"
#  echo "modification_time: ${modification_time}"
#  ${_ASSERT_NOT_NULL_} "'${modification_time}'"
#  download_source "${release}" 2> /dev/null
#  result=$?
#  ${_ASSERT_TRUE_} $result
#  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
#  modification_time_2="$(stat -c '%Y' "${file}")"
#  ${_ASSERT_EQUALS_} "'${modification_time}'" "'${modification_time_2}'"
#
#  echo "Download file (now a local copy exists) and replace it"
#  do_instantiate_vars && KEEP_DIR="${DIR_EXIST}"
#  assume_yes
#  modification_time="$(stat -c '%Y' "${file}")"
#  ${_ASSERT_NOT_NULL_} "'${modification_time}'"
#  download_source "${release}" 2> /dev/null
#  result=$?
#  ${_ASSERT_TRUE_} $result
#  modification_time_2="$(stat -c '%Y' "${file}")"
#  ${_ASSERT_TRUE_} "'[ ${modification_time} -lt ${modification_time_2} ]'"
#}
#
#
#test_download_binaries(){
#  local release result file modification_time modification_time_2
#  release="1.0.5"
#  file="${KEEP_DIR}/Precompiled-v${release}.zip"
#
#  echo "Download file (no local copy exists)"
#  download_binaries "${release}" 2> /dev/null
#  #download_binaries "${release}" >/dev/null 2>&1
#  result=$?
#  ${_ASSERT_TRUE_} "'${result}'"
#  ${_ASSERT_TRUE_} "'[ -f ${file} ]'"
#
#  echo "Download file (now a local copy exists), then keep it"
#  do_instantiate_vars && KEEP_DIR="${DIR_EXIST}"
#  assume_no
#  modification_time="$(stat -c '%Y' "${file}")"
#  echo "modification_time: ${modification_time}"
#  ${_ASSERT_NOT_NULL_} "'${modification_time}'"
#  download_binaries "${release}" 2> /dev/null
#  result=$?
#  ${_ASSERT_TRUE_} $result
#  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
#  modification_time_2="$(stat -c '%Y' "${file}")"
#  ${_ASSERT_EQUALS_} "'${modification_time}'" "'${modification_time_2}'"
#
#  echo "Download file (now a local copy exists) and replace it"
#  do_instantiate_vars && KEEP_DIR="${DIR_EXIST}"
#  assume_yes
#  modification_time="$(stat -c '%Y' "${file}")"
#  ${_ASSERT_NOT_NULL_} "'${modification_time}'"
#  download_binaries "${release}" 2> /dev/null
#  result=$?
#  ${_ASSERT_TRUE_} $result
#  modification_time_2="$(stat -c '%Y' "${file}")"
#  ${_ASSERT_TRUE_} "'[ ${modification_time} -lt ${modification_time_2} ]'"
#}  

test_unpack_source() {
  local dir file no_files
  file="${KEEP_DIR}/v${UTEST_RELEASE}.tar.gz"

  #****************************
  echo "Unpack source (file exists in KEEP_DIR, ${dir} does not exist)"
  dir="${DIR_EXIST}/somedir"
  cp "../${UTEST_SOURCE_FILE}" "${file}"
  rm -rf ${dir} 2> /dev/null
  
  unpack_source "${UTEST_RELEASE}" "${dir}"
  result=$?
  ${_ASSERT_TRUE_} "'${result}'"
  ${_ASSERT_TRUE_} "'[ -d ${dir} ]'"
  ${_ASSERT_TRUE_} "'[ -f ${dir}/bin/elixir ]'"
  no_files="$(ls -afq ${dir} 2> /dev/null | wc -l)" 
  ${_ASSERT_TRUE_} "'[ ${no_files} -gt 2 ]'"


  #****************************
  echo "Unpack source (${file} does not exist, unpack Dir DOES not exist)"
  dir="${DIR_NOT_EXIST}"
  cp "../${UTEST_SOURCE_FILE}" "${file}"
  rm "${file}" 2> /dev/null
  rm -rf ${dir} 2> /dev/null

  unpack_source "${UTEST_RELEASE}" "${dir}"  2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} "'${result}'"
  # ${dir} should still not exist
  ${_ASSERT_FALSE_} "'[ -d ${dir} ]'"
  # but file must not been present
  ${_ASSERT_FALSE_} "'[ -f ${dir}/bin/elixir ]'"
  no_files="$(ls -afq ${dir} 2> /dev/null | wc -l)" 
  ${_ASSERT_FALSE_} "'[ ${no_files} -gt 2 ]'"

  #****************************
  echo "Unpack source (${file} DOES exist, but it's corrupted. Dir does not exist)"
  dir="${DIR_NOT_EXIST}"
  echo "xxxxxxx" > "${file}"
  rm -rf ${dir} 2> /dev/null

  unpack_source "${UTEST_RELEASE}" "${dir}"  2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} "'${result}'"
  # ${dir} should have been created after attempting to unpack
  ${_ASSERT_TRUE_} "'[ -d ${dir} ]'"
  # but file must not been present
  ${_ASSERT_FALSE_} "'[ -f ${dir}/bin/elixir ]'"
  no_files="$(ls -afq ${dir} 2> /dev/null | wc -l)" 
  ${_ASSERT_FALSE_} "'[ ${no_files} -gt 2 ]'"
}

test_unpack_binaries() {
  local dir file no_files
  file="${KEEP_DIR}/Precompiled-v${UTEST_RELEASE}.zip"

  #****************************
  echo "Unpack binaries (file exists in KEEP_DIR, ${dir} does not exist)"
  dir="${DIR_EXIST}/somedir"
  cp "../${UTEST_BINARIES_FILE}" "${file}"
  rm -rf ${dir} 2> /dev/null
  
  unpack_binaries "${UTEST_RELEASE}" "${dir}"
  result=$?
  ${_ASSERT_TRUE_} "'${result}'"
  ${_ASSERT_TRUE_} "'[ -d ${dir} ]'"
  ${_ASSERT_TRUE_} "'[ -f ${dir}/bin/elixir ]'"
  no_files="$(ls -afq ${dir} 2> /dev/null | wc -l)" 
  ${_ASSERT_TRUE_} "'[ ${no_files} -gt 2 ]'"

  #****************************
  echo "Unpack binaries (${file} does not exist, unpack Dir DOES not exist)"
  dir="${DIR_NOT_EXIST}"
  cp "../${UTEST_BINARIES_FILE}" "${file}"
  rm "${file}" 2> /dev/null
  rm -rf ${dir} 2> /dev/null

  unpack_binaries "${UTEST_RELEASE}" "${dir}"  2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} "'${result}'"
  # ${dir} should still not exist
  ${_ASSERT_FALSE_} "'[ -d ${dir} ]'"
  # but file must not been present
  ${_ASSERT_FALSE_} "'[ -f ${dir}/bin/elixir ]'"
  no_files="$(ls -afq ${dir} 2> /dev/null | wc -l)" 
  ${_ASSERT_FALSE_} "'[ ${no_files} -gt 2 ]'"

  #****************************
  echo "Unpack binaries (${file} DOES exist, but it's corrupted. Dir does not exist)"
  dir="${DIR_NOT_EXIST}"
  echo "xxxxxxx" > "${file}"
  rm -rf ${dir} 2> /dev/null

  unpack_binaries "${UTEST_RELEASE}" "${dir}"  2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} "'${result}'"
  # ${dir} should have been created after attempting to unpack
  ${_ASSERT_TRUE_} "'[ -d ${dir} ]'"
  # but file must not been present
  ${_ASSERT_FALSE_} "'[ -f ${dir}/bin/elixir ]'"
  no_files="$(ls -afq ${dir} 2> /dev/null | wc -l)" 
  ${_ASSERT_FALSE_} "'[ ${no_files} -gt 2 ]'"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
