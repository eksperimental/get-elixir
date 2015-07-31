#!/bin/sh

# Download latest stable Elixir's source-code.
elixir_version=$(wget -qO- \
https://raw.githubusercontent.com/elixir-lang/elixir-lang.github.com/master/elixir.csv | \
sed '2q;d' | cut -d , -f1);
wget -O v${version}.tar.gz \
https://github.com/elixir-lang/elixir/archive/v${elixir_version}.tar.gz && 
tar -xzf v${version}.tar.gz && 
mkdir -p elixir && 
cp -rf elixir-${elixir_version}/* elixir && 
rm -rf elixir-${elixir_version}/ && 
echo "* Elixir's sources can be found in ./elixir/" ||
echo "* [ERROR] Elixir couldn't not be either downloaded or unpacked"