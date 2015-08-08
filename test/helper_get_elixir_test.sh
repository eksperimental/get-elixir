#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh
. ./config.sh

test_get_latest_release() {
  startSkipping
  ${_ASSERT_NOT_NULL_} '"$(get_latest_release 2> /dev/null)"'
  get_latest_release >/dev/null 2>&1
  ${_ASSERT_TRUE_} $?

  ELIXIR_CSV_URL="http://localhost/foo.csv"
  ${_ASSERT_NULL_} '"$(get_latest_release 2> /dev/null)"'
  get_latest_release >/dev/null 2>&1
  ${_ASSERT_FALSE_} $?
  do_instantiate_vars
}

test_get_elixir_final_releases() {
  do_instantiate_vars
  
  ${_ASSERT_NOT_NULL_} '"$(get_elixir_final_releases)"'
  get_elixir_final_releases >/dev/null 2>&1
  ${_ASSERT_TRUE_} $?

  ELIXIR_CSV_URL="http://localhost/foo.csv"
  ${_ASSERT_NULL_} '"$(get_elixir_final_releases 2> /dev/null)"'
  get_elixir_final_releases >/dev/null 2>&1
  ${_ASSERT_FALSE_} $?
  do_instantiate_vars

  # file exists, but it doesn't contain the data we need
  ELIXIR_CSV_URL="https://github.com/harthur/devtools-dashboard/raw/master/data/release.csv"
  ${_ASSERT_NOT_NULL_} '"$(get_elixir_final_releases 2> /dev/null)"'
  get_elixir_final_releases >/dev/null 2>&1
  ${_ASSERT_TRUE_} "'[ get_elixir_final_releases >/dev/null 2>&1 ]'"
  do_instantiate_vars
}

test_get_elixir_releases() {
  endSkipping
  do_instantiate_vars

  ${_ASSERT_NOT_NULL_} '"$(get_elixir_releases)"'
  get_elixir_releases >/dev/null 2>&1
  ${_ASSERT_TRUE_} $?

  APP_RELEASES_JSON_URL="http://localhost/foo.json"
  ${_ASSERT_NULL_} '"$(get_elixir_releases 2> /dev/null)"'
  get_elixir_releases >/dev/null 2>&1
  ${_ASSERT_FALSE_} $?
  do_instantiate_vars

  # file exists, but it doesn't contain the data we need
  APP_RELEASES_JSON_URL="https://github.com/mozilla/contribute.json/blob/master/package.json"
  ${_ASSERT_NULL_} '"$(get_elixir_releases 2> /dev/null)"'
  get_elixir_releases >/dev/null 2>&1
  ${_ASSERT_TRUE_} "'[ get_elixir_releases >/dev/null 2>&1 ]'"
  do_instantiate_vars
}


# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
