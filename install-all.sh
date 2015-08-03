#!/bin/sh

readlink_f () {
  cd "$(dirname "$1")" > /dev/null
  filename="$(basename "$1")"
  if [ -h "$filename" ]; then
    readlink_f "$(readlink "$filename")"
  else
    echo "`pwd -P`/$filename"
  fi
}

SELF=$(readlink_f "$0")
SCRIPT_PATH=$(dirname "$SELF")

##########
url="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
releases=$(curl -sfL "${url}" | tail -n +2 | cut -d , -f1)
for release in $releases; do
  "${SCRIPT_PATH}/get-elixir.sh" --unpack --binaries --source --release "${release}" --dir "~/.exenv/versions/${version}"
done
exenv rehash
