oneTimeSetUp(){
  DIR_EXIST="${__shunit_tmpDir}"
  DIR_NOT_EXIST="${__shunit_tmpDir}/DIR_NOT_EXIST"
  
  FILE_EXIST="${__shunit_tmpDir}/FILE"
  FILE_NOT_EXIST="${__shunit_tmpDir}/FILE_NOT_EXIST"

  DIR_EXIST_RWX="${__shunit_tmpDir}/DIR_EXIST_RWX"
  DIR_EXIST_R="${__shunit_tmpDir}/DIR_EXIST_R"
  DIR_EXIST_0="${__shunit_tmpDir}/DIR_EXIST_0"

  FILE_EXIST_RWX="${__shunit_tmpDir}/DIR_EXIST_RWX/FILE"
  FILE_EXIST_R="${__shunit_tmpDir}/DIR_EXIST_R/FILE"
  FILE_EXIST_0="${__shunit_tmpDir}/DIR_EXIST_0/FILE"

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

setUp() {
  CURL_OPTIONS="--connect-timeout 5 --retry 0"
  #CURL_OPTIONS=""
}