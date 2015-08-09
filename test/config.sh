oneTimeSetUp(){
  if [ ! -f "../${UTEST_SOURCE_FILE}" ]; then
    echo "Downloading sources (v${UTEST_RELEASE}) required to speed up Unit Test"
    ../${APP_FILE_NAME} --source --release ${UTEST_RELEASE} --keep-dir "../${UTEST_DOWNLOADED_DIR}" --silent-download
  fi
  if [ ! -f "../${UTEST_BINARIES_FILE}" ]; then
    echo "Downloading binaries (v${UTEST_RELEASE}) required to speed up Unit Testing"
    ../${APP_FILE_NAME} --binaries --release ${UTEST_RELEASE} --keep-dir "../${UTEST_DOWNLOADED_DIR}" --silent-download
  fi
  #if [ ! -f "../${UTEST_SCRIPT_FILE}" ]; then
  #  echo "Downloading ${APP_FILE_NAME}}}}} (v${UTEST_SCRIPT_VERSION}) required to speed up Unit Testing"
  #  ../${APP_FILE_NAME} --download-script --keep-dir "../${UTEST_DOWNLOADED_DIR}" --silent-download
  #fi

  TMP_DIR="${__shunit_tmpDir}"
  DIR_EXIST="${TMP_DIR}"
  DIR_NOT_EXIST="${__shunit_tmpDir}/DIR_NOT_EXIST"
  
  FILE_EXIST="${__shunit_tmpDir}/FILE"
  FILE_NOT_EXIST="${__shunit_tmpDir}/FILE_NOT_EXIST"

  DIR_EXIST_RWX="${__shunit_tmpDir}/DIR_EXIST_RWX"
  DIR_EXIST_R="${__shunit_tmpDir}/DIR_EXIST_R"
  DIR_EXIST_0="${__shunit_tmpDir}/DIR_EXIST_0"

  FILE_EXIST_RWX="${__shunit_tmpDir}/DIR_EXIST_RWX/FILE"
  FILE_EXIST_R="${__shunit_tmpDir}/DIR_EXIST_R/FILE"
  FILE_EXIST_0="${__shunit_tmpDir}/DIR_EXIST_0/FILE"

  URL_NOT_EXIST="http://localhost/URL_NOT_EXIST"

  # Create files and dirs
  touch "${FILE_EXIST}" ||
    (echo "* [ERROR] Couldn't create file in Unit Test." >&2 && exit_script)

  mkdir "${DIR_EXIST_RWX}"
  touch "${FILE_EXIST_RWX}"
  chmod 0777 "${DIR_EXIST_RWX}"

  mkdir "${DIR_EXIST_R}"
  touch "${FILE_EXIST_RWX}"
  chmod 0400 "${DIR_EXIST_R}"

  mkdir "${DIR_EXIST_0}"
  touch "${FILE_EXIST_RWX}"
  chmod 0000 "${DIR_EXIST_0}"
}

oneTimeTearDown(){
  #rm -rf "${DIR_EXIST_RWX}"
  #rm -rf "${DIR_EXIST_R}"
  #rm -rf "${DIR_EXIST_0}"
  echo ""
}

do_instantiate_permanente_vars(){
  CURL_OPTIONS="-s --connect-timeout 10 --retry 10"
}