# get-elixir
Get any release of the Elixir programming language, without leaving the comfort of your command line.

## About

get-elixir is a shell script which aims to help people download and unpack
the Elixir programming language from source, downloading it from the
[released version](https://github.com/elixir-lang/elixir/releases).

## Installation

You can simply run from your command line
```sh
curl -fL -o get-elixir.sh https://raw.githubusercontent.com/eksperimental/get-elixir/master/get-elixir.sh
chmod +x get-elixir.sh
```
or clone it 

```sh
git clone https://github.com/eksperimental/get-elixir
cd get-elixir
```

## Usage

```sh
./get-elixir.sh <command> <package_type> [<version_number>] [<dest_dir>]
```

Where you can download and unpack the latest source codes released by doing:
`./get-elixir.sh unpack source`

or the latest precompiled
`./get-elixir.sh unpack precompiled`

You can also just download [any version that has been released](https://github.com/elixir-lang/elixir/releases).
`./get-elixir.sh unpack precompiled 1.0.0 elixir-1.0.0`
will unpack the precompiled files of v1.0.0 in the directory `elixir-1.0.0`

## License

Please read [LICENSE.txt] file.
The works is unlicensed, so their are in the public domain.

