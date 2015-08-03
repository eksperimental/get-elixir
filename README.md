# get-elixir

Get any release of the **[Elixir programming language](http://elixir-lang.org)**, being **_source code_** or **_precompiled binaries_**, without leaving the comfort of your command line.

## About

**get-elixir** is a script is POSIX compliant shell script which aims to help people download [Elixir releases](https://github.com/elixir-lang/elixir/releases) under any UNIX like operating system (ie. GNU/Linux, *BSD, OSX)

All you have to do is tell the script, whether you want to **download** or download-and-**unpack** the latest (or any other release), and the script will get it for you.

It is your duty, though, to [set the PATH environmental variable](http://elixir-lang.org/install.html#setting-path-environment-variable) to the directory where Elixir was extracted to.

If you are interested in only getting Elixir once, you may execute the [one-liner commands](one-liner.md) that can be directly pasted into your command line, without having to download any script.

It can also be of interest to developers who need maintain different of versions of Elixir, without the need to build them, to use in conjuntion with an Elixir version manager like [exevn](https://github.com/mururu/exenv). See the [Examples – Advanced](#examples-advanced) section for more on this.

## Installation

Open you command line terminal and paste this:

    curl -fLO https://github.com/eksperimental/get-elixir/raw/master/get-elixir.sh
    chmod +x get-elixir.sh

It will download and set the permissions to execute the script.

## Usage

```sh
./get-elixir.sh <package_type>... <options>...

./get-elixir.sh (--source | --binaries)
                [--unpack]
                [<release_number>]
                [--dir <dir>]

# other options
./get-elixir.sh (--update-script | --help | --version)
```

```sh
Package Types:
  -b, --binaries       Download precompiled binaries
  -s, --source         Download source code

Options:
 -u, --unpack         Unpacks the package(s) once downloaded
 -r, --release        Elixir release number
                      'latest' is the default option
                      Examples: 'latest', '1.0.5', '1.0.0-rc2'
 -d, --dir            Directory where you want to unpack Elixir.
                      Default value: 'elixir'

Other Options:
 -h, --help           Prints help menu
     --update-script  Replace this script by downloading the latest release
 -v, --version        Prints script version
```


## Examples

```sh
# Download the source code for the latest relase
./get-elixir.sh --source

# Download and unpack the souce code for v1.0.5,
# and unpack it in dir 'elixir-1.0.x'
./get-elixir.sh --unpack --source --release 1.0.5 --dir elixir-1.0.x/

# Download and unpack source code and precompiled binaries,
# for v1.0.0-rc2
./get-elixir.sh -u -s -b -r 1.0.0-rc2

# Install the latest in a differt directory
./get-elixir.sh unpack source latest ./elixir-new

# Get sources and compiled all in one
./get-elixir.sh unpack binaries && ./get-elixir.sh unpack source 
```

## Examples – Advanced

Lets say you want to use it in conjunction with an Elixir version manager like [exevn](https://github.com/mururu/exenv).

The following commands will download every final version released (ie. not release candidates), unpack them and update `exenv`.

_Please make sure you have followed the [exenv installation instructions](https://github.com/mururu/exenv#section_2)_

```sh
url="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
releases=$(curl -sfL "${url}" | tail -n +2 | cut -d , -f1)
for release in $releases; do
  ./get-elixir.sh --unpack --binaries --source --release "${release}" --dir "~/.exenv/versions/${version}"
done
exenv rehash
```

## Additional Commands

You have other commands available, which are:

* `./get-elixir.sh --update-script` – Updates this script from your command line.
* `./get-elixir.sh --help`          – Prints the help menu, documentaion the usage of this tool.
* `./get-elixir.sh --version`       – Prints the version number.

## More information

Please visit the [Elixir Website](http://elixir-lang.org/) for more information about the language itself, including for more information about [installing and compiling](elixir-lang.org/install.html) the it.

## Contributing

At this very early stage, [ideas are more than ever welcome]((https://github.com/eksperimental/get-elixir/issues/new).

If you think something is not working as expected, please [create a ticket](https://github.com/eksperimental/get-elixir/issues/new).

[Pull requests](https://github.com/eksperimental/get-elixir/pulls) are appreciated.

The script is POSIX compliant, so it it expected to run in any UNIX like operating system.

## Credits

Created by **Eksperimental**.

I usually contribute to various Elixir projects, and this is another way to continue doing that.

## License

Please read [LICENSE.txt](LICENSE.txt) file.
The works is unlicensed, meaning they are in the public domain.

With small pieces under the Apache License.