#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh

test_short_help() {
  expected=$(short_help)
  actual=$("../${APP_FILE_NAME}" 2>&1)
  assertEquals "short_help" "${expected}" "${actual}" 
}

#test_help() {
#  
#}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
