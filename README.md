# get-elixir

Get any release of the **[Elixir programming language](http://elixir-lang.org)**, being **_source code_** or **_precompiled binaries_**, without leaving the comfort of your command line.

## About

**get-elixir** is a script is POSIX shell script which aims to help people download [Elixir releases](https://github.com/elixir-lang/elixir/releases) under any UNIX like operating system (ie. GNU/Linux, *BSD, OSX)

All you have to do is tell the script, whether you want to **download** or download-and-**unpack** the latest (or any other release), and the script will get it for you.

It is your duty, though, to [set the PATH environmental variable](http://elixir-lang.org/install.html#setting-path-environment-variable) to the directory where Elixir was extracted to.

If you are interested in only getting Elixir once, you may execute the [one-liner commands](one-liner.md) that can be directly pasted into your command line, without having to download any script.

It can also be of interest to developers who need maintain different of versions of Elixir, without the need to build them, to use in conjuntion with an Elixir version manager like [exevn](https://github.com/mururu/exenv). See the [Examples – Advanced](#examples-advanced) section for more on this.

It is the aim of the project to provide a tool where no high-tecnical knowledge is required.

## Installation

Open you command line terminal and paste this:

    curl -fLO https://github.com/eksperimental/get-elixir/raw/master/get-elixir.sh
    chmod +x get-elixir.sh

It will download and set the permissions to execute the script.

## Usage

```sh
./get-elixir.sh <package_type>... [<options>...]

./get-elixir.sh (--source | --binaries)
                [--unpack]
                [--release <release_number>]
                [--dir <dir>]
```

```sh
Usage: ./get-elixir.sh <package_type>... <options>...

Package Types:
  -b, --binaries       Download precompiled binaries
  -s, --source         Download source code

Main Options:
  -u, --unpack         Unpacks the package(s) once downloaded
  -r, --release        Elixir release number
                       'latest' is the default option
                       Examples: 'latest', '1.0.5', '1.0.0-rc2'
  -d, --dir            Directory where you want to unpack Elixir.
                       Default value: '${DIR}'

Secondary Options:
  -h, --help                 Prints help menu
  -v, --version              Prints script version information
      --update-script        Replace this script by downloading the latest release
      --download-script      Download the latest release of this script to the
                             specified location (use --keep-dir)
      --list-releases        Lists all Elixir releases (final and pre-releases)
      --list-final-releases  Lists final Elixir releases
      --silent-download      Silent download (Hide status)
      --verbose-unpack       Be verbose when unpacking files
  -k, --keep-dir             Directory where you want to keep downloaded files
  -y, --assume-yes           Assume 'Yes' to all confirmations, and do not prompt
      --ask-overwrite        Confirmation needed before overwritting any file.
                             This is superseeded by --assume-yes.
                             It is not recommended to use this option, unless you
                             have a specific reason to do it.
```


## Examples

```sh
# Download the source code for the latest relase
./get-elixir.sh --source

# Download and unpack the souce code for v1.0.5,
# and unpack it in dir 'elixir-1.0.x'
./get-elixir.sh --source --unpack --release 1.0.5 --dir elixir-1.0.x/

# Download and unpack the latest in a differt directory
./get-elixir.sh --source --unpack -d ./elixir-new

# Download and unpack source code and precompiled binaries,
# for v1.0.0-rc2
./get-elixir.sh -s -b -u -r 1.0.0-rc2
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

## Additional Options

* --help                 – Prints help menu
* --version              – Prints script version information
* --update-script        – Replace this script by downloading the latest release
* --download-script      – Download the latest release of this script to the
*                          specified location (use --keep-dir)
* --list-releases        – Lists all Elixir releases (final and pre-releases)
* --list-final-releases  – Lists final Elixir releases
* --silent-download      – Silent download (Hide status)
* --verbose-unpack       – Be verbose when unpacking files
* --keep-dir             – Directory where you want to keep downloaded files
* --assume-yes           – Assume 'Yes' to all confirmations, and do not prompt
* --ask-overwrite        – Confirmation needed before overwritting any file.
                           This is superseeded by --assume-yes.
                           It is not recommended to use this option, unless you
                           have a specific reason to do it.

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