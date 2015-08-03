#!/bin/sh

url="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
versions=$(curl -sfL "${url}" | tail -n +2 | cut -d , -f1)
for version in $versions; do
  ./get-elixir.sh unpack binaries_source "${version}" "~/.exenv/versions/${version}"
done
exenv rehash
