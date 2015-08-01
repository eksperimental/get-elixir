#!/bin/sh

# This file contains the snippets to achive pretty much what the script does
# in a very basic way.

# Download latest stable Elixir source-code.
# curl version
version=$(curl -sfL \
https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv | \
sed '2q;d' | cut -d , -f1);
curl -fL -O \
https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz && 
tar -xzf v${version}.tar.gz && 
mkdir -p elixir && 
cp -rf elixir-${version}/* elixir && 
rm -rf elixir-${version}/ && 
echo "* [OK] Elixir v{$version} sources can be found in ./elixir/" ||
echo "* [ERROR] Elixir v{$version} couldn't not be either downloaded or unpacked"

# wget version
version=$(wget -qO- \
https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv | \
sed '2q;d' | cut -d , -f1);
wget -O v${version}.tar.gz \
https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz && 
tar -xzf v${version}.tar.gz && 
mkdir -p elixir && 
cp -rf elixir-${version}/* elixir && 
rm -rf elixir-${version}/ && 
echo "* [OK] Elixir v{$version} sources can be found in ./elixir/" ||
echo "* [ERROR] Elixir v{$version} couldn't not be either downloaded or unpacked"

##########

# Download latest stable Elixir precompiled binaries.
# curl version
version=$(curl -sfL \
https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv | \
sed '2q;d' | cut -d , -f1);
curl -fL -O \
https://github.com/elixir-lang/elixir/releases/download/v${version}/Precompiled.zip && 
mkdir -p elixir && 
unzip -o -q -d elixir Precompiled.zip &&
echo "* [OK] Elixir v{$version} sources can be found in ./elixir/" ||
echo "* [ERROR] Elixir v{$version} couldn't not be either downloaded or unpacked"

# wget version
version=$(wget -qO- \
https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv | \
sed '2q;d' | cut -d , -f1);
wget -O v${version}.tar.gz \
https://github.com/elixir-lang/elixir/releases/download/v${version}/Precompiled.zip && 
mkdir -p elixir && 
unzip -o -q -d elixir Precompiled.zip &&
echo "* [OK] Elixir's v{$version} sources can be found in ./elixir/" ||
echo "* [ERROR] Elixir v{$version} couldn't not be either downloaded or unpacked"

