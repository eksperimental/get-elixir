#!/bin/sh

APP_NAME="elixir-get"
APP_VERSION="0.0.1-dev"
COMMAND="./`basename $0`"
ELIXIR_CSV_URL="https://raw.githubusercontent.com/elixir-lang/elixir-lang.github.com/master/elixir.csv"
ELIXIR_RELEASE_TAG_URL=""
ELIXIR_TREE_URL=""

#DEFAULT
DEFAULT_DEST_DIR="./elixir"
DEFAULT_VERSION="latest"

#ARGS VARIABLES
ACTION=""
PACKAGE_TYPE=""
VERSION=""
DEST_DIR=""

# FUNCTIONS

sanitize_version() {
  echo $(printf '%s' "$1" | sed -e 's/^v//g')
}

sanitize_dest_dir() {
  echo $(printf '%s' "$1" | sed -e 's@/$@@g')
}

get_latest_version() {
  local version
  version=$(wget -qO- "$ELIXIR_CSV_URL" | sed '2q;d' | cut -d , -f1)
  if [ "$version" = "" ]; then 
    echo >&2 "* [ERROR] Latest Elixir version number couldn't be retrieved" &&
    exit 1
  else
    echo "$version"
  fi
}

download_source() {
  local version="$1"
  local url="https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz"
  wget -O "v${version}.tar.gz" "${url}" || (
    echo "* [ERROR] Elixir v${VERSION} could not be downloaded from ${url}" >&2 &&
    exit 1
  )
}

download_precompiled() {
  local version="$1"
  local url="https://github.com/elixir-lang/elixir/releases/download/${version}/Precompiled.zip"
  wget -O Precompiled.zip "${url}" || (
    echo "* [ERROR] Elixir v${VERSION} could not be downloaded from ${url}" >&2 &&
    exit 1
  )
}

unpack_source() {
  local version="$1"
  local dest_dir="$2"
  tar -xzf v${version}.tar.gz && 
  mkdir -p ${dest_dir} && 
  cp -rf elixir-${version}/* ${dest_dir} && 
  rm -rf elixir-${version}/ || (
    echo "* [ERROR] \"v${version}.tar.gz\" could not be unpacked to ${dest_dir}" >&2 &&
    exit 1
  )
}

unpack_precompiled() {
  local dest_dir="$1"
  mkdir -p ${dest_dir} && 
  unzip Precompiled.zip -d ${dest_dir} || (
    echo "* [ERROR] \"Precompiled.zip\" could not be unpacked to ${dest_dir}" >&2 &&
    exit 1
  )
}

short_help() {
  echo "${COMMAND}: missing arguments.

  Usage: ${COMMAND} ACTION PACKAGE_TYPE [VERSION_NUMBER] [DEST_DIR]

  Example:
  ${COMMAND} unpack source

  Try \`${COMMAND} --help\` for more information."
}

help() {
  echo "${APP_NAME} version ${VERSION}

  Get any released version of the Elixir programming language,
  without leaving the confort of your command line.
  http://elixir-lang.org

  Usage: ${COMMAND} ACTION PACKAGE_TYPE [VERSION_NUMBER] [DEST_DIR]

  Actions:
  download      Downloads the package
  unpack        Downloads the package and unpacks it
  version       Prints version
  help          Prints help menu

  Package Types:
  source        Source files
  precompiled   Precompiled files

  Version Number:
  'latest' is the default option, and it's not required to specify it
  (unless a DEST_DIR want to be used)
  Examples: 'latest', '1.0.5', '1.0.0-rc2'

  Destination Dir:
  Where you want to unpack Elixir. Default value: '${DEFAULT_DEST_DIR}'.

  Usage Examples:
  \$ ${COMMAND} unpack source
  \$ ${COMMAND} unpack source 1.0.5
  \$ ${COMMAND} download precompiled 1.0.0-rc2

  # Install the latest in a differt directory.
  \$ ${COMMAND} unpack source latest ./elixir-new

  # Get sources and compiled all in one
  \$ ${COMMAND} unpack precompiled && ${COMMAND} unpack source 

  ** For a list of available releases, plesase visit
     https://github.com/elixir-lang/elixir/releases
"
}


do_main() {
  # check for help and version
  case "$1" in
    "help"|"--help"|"-h")
      help
      exit 0
    ;;

    "version"|"--version"|"-v")
      echo "${APP_NAME} – version ${APP_VERSION}"
      exit 0
    ;;

    "clean")
      rm -rf ./elixir/ &&
      rm -rf ./v*/ &&
      rm -f Precompiled.zip &&
      rm -f v*.tar.gz &&
      rm -f v*.zip &&
      echo "Files have been removed."
    ;;
  esac

  # check for minimu no. of args
  if [ "$#" -lt 2 ]; then
    short_help >&2
    exit 1
  fi

  # Get Variables from ARGS
  ACTION="$1"
  PACKAGE_TYPE="$2"
  if [ "$3" = "" ] || [ "$3" = "$DEFAULT_VERSION" ]; then
    VERSION=$(get_latest_version)
  else
    VERSION=$(sanitize_version "$3")
  fi
  if [ "$4" = "" ] ; then
    DEST_DIR="$DEFAULT_DEST_DIR"
  else
    DEST_DIR=$(sanitize_dest_dir "$4")
  fi

  # Check for unrecognized options
  if [ "$ACTION" != "unpack" ] ||  [ "$ACTION" != "download" ]; then
    echo "* [ERROR] Unrecognized ACTION. Try 'unpack' or 'download'." >&2
    exit 1
  fi
  if [ "$PACKAGE_TYPE" != "source" ] ||  [ "$PACKAGE_TYPE" != "precompiled" ]; then
    echo "* [ERROR] Unrecognized PACKAGE_TYPE. Try 'source' or 'precompiled'." >&2
    exit 1
  fi

  # Define variables based on $VERSION
  ELIXIR_RELEASE_TAG_URL="https://github.com/elixir-lang/elixir/releases/tag/v${VERSION}"
  ELIXIR_TREE_URL="https://github.com/elixir-lang/elixir/tree/v${VERSION}"

  # Do our logic
  case "$ACTION" in
    "download")
      case "$PACKAGE_TYPE" in
        "source")
          download_source "$VERSION"
          echo "* [OK] Elixir v${VERSION} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: v${VERSION}.tar.gz"
        ;;

        "precompiled")
          download_precompiled "$VERSION"
          echo "* [OK] Elixir v${VERSION} [Precompiled]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: Precompiled.zip"
        ;;
      esac
    ;;

    "unpack")
      case "$PACKAGE_TYPE" in
        "source")
          download_source "$VERSION"
          unpack_source "$VERSION" "$DEST_DIR"
          echo "* [OK] Elixir v${VERSION} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DEST_DIR}/"
        ;;

        "precompiled")
          download_precompiled "$VERSION"
          unpack_precompiled "$DEST_DIR"
          echo "* [OK] Elixir v${VERSION} [Precompiled]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DEST_DIR}/"
        ;;
      esac
      ;;
  esac

}

do_main $*
exit 0