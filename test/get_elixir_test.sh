#!/usr/bin/env bash
#!/bin/sh

#set -e
#set -x
. ../get-elixir.sh


# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ../shunit2
