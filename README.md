# get-elixir
Get any release of the Elixir programming language, without leaving the comfort of your command line.

## About

get-elixir is a shell script which aims to help people download and unpack
the Elixir programming language from source, downloading it from the
[released version](https://github.com/elixir-lang/elixir/releases).

All you have to do is tell the script, whether you want to **download** or **download and unpack** the latest 
(or any other release if you wish) release of Elixir, and the script will get it for you.

It is your dury, though, to [set the PATH environmental variable](http://elixir-lang.org/install.html#setting-path-environment-variable) to the directory where Elixir was extracted to.

## Installation

You can simply run from your command line
```sh
curl -fLO get-elixir.sh https://github.com/eksperimental/get-elixir/raw/master/get-elixir.sh
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

Where you can **download** and **unpack** the latest source codes released by doing:

To dowload and unpack the sources...

```sh
./get-elixir.sh unpack source
```

...the latest precompiled version

```sh
./get-elixir.sh unpack precompiled
```

You can also just download [any version that has been released](https://github.com/elixir-lang/elixir/releases).

```sh
# unpack the precompiled binaries of v1.0.0 to dir `./elixir-1.0.0/`
./get-elixir.sh unpack precompiled 1.0.0 elixir-1.0.0
```

And you can update this very same script from your command line:

```sh
./get-elixir.sh update-script
```

## License

Please read [LICENSE.txt](LICENSE.txt) file.
The works is unlicensed, so their are in the public domain.