#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh
. ./config.sh

setUp(){
  do_instantiate_vars
  #startSkipping
}

# do not output anything
# get_elixir_final_releases >/dev/null 2>&1

test_get_latest_release() {
  local output result

  output="$(get_latest_release 2> /dev/null)"
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_NOT_NULL_} '"${output}"'

  ELIXIR_CSV_URL="http://localhost/foo.csv"
  output="$(get_latest_release)"
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_NULL_} '"${output}"'
}

test_get_elixir_final_releases() {
  local output result
  
  output="$(get_elixir_final_releases 2> /dev/null)"
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_NOT_NULL_} '"${output}"'

  ELIXIR_CSV_URL="http://localhost/foo.csv"
  output="$(get_elixir_final_releases 2> /dev/null)"
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_NULL_} '"${output}"'
  do_instantiate_vars

  # file exists, but it doesn't contain the data we need
  ELIXIR_CSV_URL="https://github.com/harthur/devtools-dashboard/raw/master/data/release.csv"
  output="$(get_elixir_final_releases 2> /dev/null)"
  result=$?
  # It shold return TRUE, becase in our function we just parse a specific line and column,
  # So it still retrieves it.
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_NOT_NULL_} '"${output}"'
}

test_get_elixir_releases() {
  local output result

  output="$(get_elixir_releases 2> /dev/null)"
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_NOT_NULL_} '"${output}"'

  APP_RELEASES_JSON_URL="http://localhost/foo.json"
  output="$(get_elixir_releases 2> /dev/null)"
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_NULL_} '"${output}"'
  do_instantiate_vars

  # file exists, but it doesn't contain the data we need
  APP_RELEASES_JSON_URL="https://github.com/mozilla/contribute.json/raw/master/package.json"
  # It should return false, because we are greping "tag_name" and thres is not such a string in this URL
  output="$(get_elixir_releases 2> /dev/null)"
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_NULL_} '"${output}"'
}

test_get_latest_script_version() {
  local output result
 
  output="$(get_latest_script_version 2> /dev/null)"
  result=$?
  ${_ASSERT_TRUE_} $result
  ${_ASSERT_NOT_NULL_} '"${output}"'

  # URL exists, but it doesn't contain the data we need
  APP_RELEASES_URL="http://localhost/foo/bar/"
  output="$(get_latest_script_version 2> /dev/null)"
  result=$?
  ${_ASSERT_FALSE_} $result
  ${_ASSERT_NULL_} '"${output}"'
}

# This test is too basic, we should test the message, when we run the
# commands: download, unpack, update-script, download-script
test_get_message_downloaded() {
  local output result
  
  ${_ASSERT_EQUALS_} '"Downloaded"' '"$(get_message_downloaded binaries)"'
  ${_ASSERT_EQUALS_} '"Downloaded"' '"$(get_message_downloaded source)"'
  ${_ASSERT_EQUALS_} '"Downloaded"' '"$(get_message_downloaded script)"'

  USED_EXISTING_BINARIES=0
  USED_EXISTING_SOURCE=0
  USED_EXISTING_SCRIPT=0

  ${_ASSERT_EQUALS_} '"Existing copy"' '"$(get_message_downloaded binaries)"'
  ${_ASSERT_EQUALS_} '"Existing copy"' '"$(get_message_downloaded source)"'
  ${_ASSERT_EQUALS_} '"Existing copy"' '"$(get_message_downloaded script)"'
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
#test_get_latest_release