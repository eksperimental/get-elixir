#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh
. ./config.sh

test_confirm() {
  local actual
  ASSUME_YES=0
  ASK_OVERWRITE=1
  confirm "Please answer YES"
  actual=$?
  assertSame 0 "${actual}"

  #ASSUME_YES=1
  #ASK_OVERWRITE=0
  #confirm "please answer NO"
  #local actual=$?
  #assertSame 1 "${actual}"
}

test_epoch_time() {
  local t t_only_numbers 
  t=$(epoch_time)

  # check length
  assertEquals "Should be 10 digits" 10 ${#t}
  
  # check only numbers
  t_only_numbers="$(printf '%s', \"${t}\" | sed 's@[^0-9]@@g')"
  assertEquals "Only numbers are allowed in time" "${t_only_numbers}" "${t}" 
}

test_sanitize_release() {
  assertEquals "1.0.0" "$(sanitize_release "1.0.0")"
  assertEquals "1.0.0" "$(sanitize_release "v1.0.0")"
  assertEquals "" "$(sanitize_release "")"

  assertEquals "./v1.0.0" "$(sanitize_release "./v1.0.0")"
  assertEquals "1.0.0" "$(sanitize_release "../v1.0.0")"
  assertEquals "1.0.0/v" "$(sanitize_release "../v1.0.0/../v")"
}

test_sanitize_dir() {
  assertEquals "~/foo/bar" "$(sanitize_dir "~/foo/bar")"
  assertEquals "/foo/bar" "$(sanitize_dir "/foo/bar")"

  assertEquals "~/foo/bar" "$(sanitize_dir "~/foo/bar/")"
  assertEquals "~/foo/bar" "$(sanitize_dir "~/foo/bar////")"
  assertEquals "." "$(sanitize_dir ".")"
  #Returns "." when the results would be empty
  assertEquals "." "$(sanitize_dir "/")"
  assertEquals "." "$(sanitize_dir "///")"
}

#test_readlink_f() {
#}

#test_exit_script() {
#}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
