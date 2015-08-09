#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh

#do_instantiate_vars() {
#}

test_superseed_options() {
  ASSUME_YES=0
  ASK_OVERWRITE=0
  superseed_options
  ${_ASSERT_FALSE_} "'${ASK_OVERWRITE}'"

  ASSUME_YES=1
  ASK_OVERWRITE=0
  superseed_options
  ${_ASSERT_TRUE_} "'${ASK_OVERWRITE}'"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
