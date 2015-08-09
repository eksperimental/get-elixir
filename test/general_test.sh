#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh
. ./config.sh

setUp(){
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
}

test_download_source() {
  local release result file mtime mtime_2
  release="1.0.5"
  file="${KEEP_DIR}/v${release}.tar.gz"

  echo "Download file (no local copy exists)"
  download_source "${release}" 2> /dev/null
  #download_source "${release}" >/dev/null 2>&1
  result=$?
  ${_ASSERT_TRUE_} "'${result}'"
  ${_ASSERT_TRUE_} "'[ -f ${file} ]'"

  echo "Download file (now a local copy exists), then keep it"
  do_instantiate_vars
  KEEP_DIR="${DIR_EXIST}"
  assume_no
  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"
  download_source "${release}" 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  ${_ASSERT_EQUALS_} "'${mtime}'" "'${mtime_2}'"

  echo "Download file (now a local copy exists) and replace it"
  do_instantiate_vars
  KEEP_DIR="${DIR_EXIST}"
  assume_yes
  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"
  download_source "${release}" 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  mtime_2="$(stat -c '%Y' "${file}")"
  ${_ASSERT_TRUE_} "'[ ${mtime} -lt ${mtime_2} ]'"
}


test_download_binaries(){
  local release result file mtime mtime_2
  release="1.0.5"
  file="${KEEP_DIR}/Precompiled-v${release}.zip"

  #*************************
  echo "Download file (no local copy exists)"
  rm -f ${file} 2> /dev/null
  download_binaries "${release}" 2> /dev/null
  #download_binaries "${release}" >/dev/null 2>&1
  result=$?
  ${_ASSERT_TRUE_} "'${result}'"
  ${_ASSERT_TRUE_} "'[ -f ${file} ]'"

  #*************************
  echo "Download file (now a local copy exists), then keep it"
  cp "../${UTEST_BINARIES_FILE}" "${file}"
  do_instantiate_vars
  KEEP_DIR="${DIR_EXIST}"
  assume_no
  mtime="$(stat -c '%Y' "${file}")"
  #echo "mtime: ${mtime}"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"
  download_binaries "${release}" 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  ${_ASSERT_EQUALS_} "'${mtime}'" "'${mtime_2}'"

  #*************************
  echo "Download file (now a local copy exists) and replace it"
  cp "../${UTEST_BINARIES_FILE}" "${file}"
  do_instantiate_vars
  KEEP_DIR="${DIR_EXIST}"
  assume_yes
  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"
  download_binaries "${release}" 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  mtime_2="$(stat -c '%Y' "${file}")"
  ${_ASSERT_TRUE_} "'[ ${mtime} -lt ${mtime_2} ]'"
}  

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


test_do_download_script(){
  local output result file script_url
  script_url="${APP_URL}/raw/v${UTEST_SCRIPT_VERSION}/${APP_FILE_NAME}"
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"

  # Test:
  # download successfull
  # donwload but get 404 page
  # cannot download, server does not exist

  #****************************
  echo "Download script: files does not exist locally"
  do_instantiate_vars
  rm -f "${file}"
  
  do_download_script "${script_url}" "${file}" 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"

  #****************************
  echo "Download script: files does not exist locally, and folder containing it doesnt exist either."
  do_instantiate_vars
  
  do_download_script "${script_url}" "${KEEP_DIR}/foo/foo/foo/${APP_FILE_NAME}" 2> /dev/null
  result=$?
  # This function does not create the needed folders with `mkdir -p`
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${KEEP_DIR}/foo/foo/foo/${APP_FILE_NAME}" ]'"
  rmdir -f "${KEEP_DIR}/foo/foo/foo/"

  #****************************
  echo "Download script: files DOES exist locally"
  do_instantiate_vars
  echo "xxxx" > "${file}"
  
  #CURL_OPTIONS="--connect-timeout 10 --retry 5"
  do_download_script "${script_url}" "${file}" 2> /dev/null
  result=$?
  echo "result: ${result}"
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"

  #****************************
  echo "Download script: 404 page"
  do_instantiate_vars
  rm -f "${file}"

  do_download_script "${script_url}/give_me_a_404" "${file}" 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"

  #****************************
  echo "Download script: unable to connect to server"
  do_instantiate_vars
  rm -f "${file}"

  do_download_script "${URL_NOT_EXIST}" "${file}" 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"
}

test_download_script() {
  local output result file mtime mtime_2

  # Test
  # script is not preset in dir
  # script is present in dir: assume_yes
  # script is present in dir: assume_no
  # unable to download lastest release no.
  # unable to download script

  #****************************
  echo "Download script, where the destination folder doesn't exist"
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}/foo/bar"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  rm -f "${file}" 2> /dev/null

  download_script  2> /dev/null
  result=$?
  echo "result: $result"
  # file cannot be created
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"

  #****************************
  echo "Download script, where no script in the destination dir."
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  rm -f "${file}"

  download_script  2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"

  #****************************
  echo "Download script: script exists: assume_yes"
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  echo "xxxxxx" > "${file}"
  assume_yes

  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"
  download_script  2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  ${_ASSERT_TRUE_} "'[ ${mtime} -lt ${mtime_2} ]'"

  #****************************
  echo "Download script: script exists: assume_no"
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  echo "xxxxxx" > "${file}"
  assume_no

  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"
  download_script 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  ${_ASSERT_TRUE_} "'[ ${mtime} -eq ${mtime_2} ]'"

  #****************************
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  rm -f "${file}"
  assume_no

  echo "Download script: unable to connect to server"
  APP_URL="${URL_NOT_EXIST}"
  download_script 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"

  echo "Download script: 404"
  APP_URL="http://github.com/give_me_a_404"
  download_script 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"

  #****************************
  echo "Download script: unable to get latest release number"
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  rm -f "${file}"
  APP_RELEASES_URL="${URL_NOT_EXIST}"
  assume_no

  download_script 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"
}

test_update_script() {
  local output result file mtime mtime_2 e_time

  # Test

  # unable to download lastest release no.
  # already newest version
  # update ok: assume_no - update cancelled
  # update ok: assume_yes - permissions OK
  # update ok: assume_yes - permission ERROR
  # unable to download script

  # Configuration for the whole test
  # copy script and update mtime to past
  cp "${SELF}" "${TMP_DIR}/${APP_FILE_NAME}"
  cp "${SELF}" "${TMP_DIR}/${APP_FILE_NAME}.read_only"
  chmod 444 "${TMP_DIR}/${APP_FILE_NAME}.read_only"
  e_time="$(epoch_time)"
  e_time=$((e_time - 1000))
  touch -m ${e_time} "${TMP_DIR}/${APP_FILE_NAME}"

  echo "Update script: unable to download lastest release no."
  do_instantiate_vars
  APP_RELEASES_URL="${URL_NOT_EXIST}"
  APP_VERSION="0.0.0"

  update_script 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result

  #****************************

  echo "Update script: already newest version"
  do_instantiate_vars
  APP_VERSION="$(get_latest_script_version)"

  update_script 2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result

  #****************************
  echo "Update script: assume_no - update is cancelled"
  do_instantiate_vars
  APP_VERSION="0.0.0"
  assume_no
  file="${TMP_DIR}/${APP_FILE_NAME}"
  SELF="${file}"

  # change mtime to past
  touch -m ${e_time} "${file}"
  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"

  update_script  2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result

  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  # mtime shoudln't have changed
  ${_ASSERT_TRUE_} "'[ ${mtime} -eq ${mtime_2} ]'"


  #****************************
  echo "Update script: update ok: assume_yes - permissions OK"
  do_instantiate_vars
  APP_VERSION="0.0.0"
  assume_yes
  file="${TMP_DIR}/${APP_FILE_NAME}"
  SELF="${file}"

  # change mtime to past
  touch -m ${e_time} "${file}"
  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"

  update_script  2> /dev/null
  result=$?
  ${_ASSERT_TRUE_} $result

  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  # mtime should have changed
  ${_ASSERT_TRUE_} "'[ ${mtime} -lt ${mtime_2} ]'"

  #****************************
  echo "Update script: update ok: assume_yes - permission ERROR"
  do_instantiate_vars
  APP_VERSION="0.0.0"
  assume_yes
  file="${TMP_DIR}/${APP_FILE_NAME}.read_only"
  SELF="${file}"

  # change mtime to past
  touch -m ${e_time} "${file}"
  mtime="$(stat -c '%Y' "${file}")"
  ${_ASSERT_NOT_NULL_} "'${mtime}'"

  update_script  2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result

  ${_ASSERT_TRUE_} "'[ -f "${file}" ]'"
  mtime_2="$(stat -c '%Y' "${file}")"
  # mtime should have not changed
  ${_ASSERT_TRUE_} "'[ ${mtime} -eq ${mtime_2} ]'"

  #****************************
  # Unable to download script
  do_instantiate_vars
  KEEP_DIR="${TMP_DIR}"
  file="${KEEP_DIR}/${APP_FILE_NAME}"
  rm -f "${file}"
  assume_no

  echo "Update script: unable to connect to server"
  APP_URL="${URL_NOT_EXIST}"
  update_script 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"

  echo "Update script: 404"
  APP_URL="http://github.com/give_me_a_404"
  update_script 2> /dev/null
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_FALSE_} "'[ -f "${file}" ]'"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
