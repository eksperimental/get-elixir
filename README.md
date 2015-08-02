# get-elixir

Get any release of the **[Elixir programming language](http://elixir-lang.org)**, being **_source codes_** or **_precompiled binaries_**, without leaving the comfort of your command line.

## About

get-elixir is a script is POSIX compliant shell script which aims to help people download [Elixir releases](https://github.com/elixir-lang/elixir/releases).

All you have to do is tell the script, whether you want to **`download`** or **download and `unpack`** the latest (or any other release if you wish), and the script will get it for you.

It is your duty, though, to [set the PATH environmental variable](http://elixir-lang.org/install.html#setting-path-environment-variable) to the directory where Elixir was extracted to.

If you are interested in only getting Elixir once, you can read the [one-liner article](one-liner.md) with the commands that you can copy and paste in your command line, without having to download any script.

## Installation

Open you command line terminal and paste this:

    curl -fLO get-elixir.sh https://github.com/eksperimental/get-elixir/raw/master/get-elixir.sh
    chmod +x get-elixir.sh

It will download and set the permissions to execute the script.

## Usage

    ./get-elixir.sh <command> <package_type> [<version_number>] [<dest_dir>]
    ./get-elixir.sh (unpack | download) (source | precompiled) [<version_number>] [<dest_dir>]
    ./get-elixir.sh (update-script | help | version)

* <command>       : `unpack`, `download`
* <package_type>  : `source`, `precompiled`
* <version_number : `latest`*, or any [released version](https://github.com/elixir-lang/elixir/releases)
* <dest_dir>      : `./elixir/`* or any other directory where you want the files to be unpacked.

`*` denotes default value.

The `download` <command> will only download the file, while the `unpack` <command> will download it an unpack it.
The <package_type> can be the `source` code that you can use to compile Elixir yourself, or the `precompiled` binaries. 

## Examples

    # unpack the latest source code
    ./get-elixir.sh unpack source

    # unpack the latest binaries
    ./get-elixir.sh unpack precompiled

    # unpack the precompiled binaries of v1.0.0 to dir `./elixir-1.0.0/`
    ./get-elixir.sh unpack precompiled 1.0.0 elixir-1.0.0

## Other Commands

You have other commands available, which are:

* `./get-elixir.sh update-script` – Updates this script from your command line.
* `./get-elixir.sh --help`        – Prints the help menu, documentaion the usage of this tool.
* `./get-elixir.sh --version`     – Prints the version number.

## More information

Please visit the [Elixir Website](http://elixir-lang.org/) for more information about the language itself, including for more information about [installing and compiling](elixir-lang.org/install.html) the it.

## Contributing

If you think a feature should be added or you have found something not working as expected, please [create a ticket](https://github.com/eksperimental/get-elixir/issues/new).

[Pull requests](https://github.com/eksperimental/get-elixir/pulls) are always welcome.

The script is POSIX compliant, so it it expected to run in any UNIX like operating system.

## Credits

Created by **Eksperimental**.

I usually contribute to various Elixir projects, and this is another way to continue doing that.

## License

Please read [LICENSE.txt](LICENSE.txt) file.
The works is unlicensed, so their are in the public domain.

