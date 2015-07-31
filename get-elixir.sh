#!/bin/sh

APP_NAME="elixir-get"
APP_VERSION="0.0.1"
APP_COMMAND="./get-elixir.sh"
ELIXIR_CSV_URL="https://raw.githubusercontent.com/elixir-lang/elixir-lang.github.com/master/elixir.csv"
ELIXIR_RELEASES_URL="https://github.com/elixir-lang/elixir/releases"
ELIXIR_RELEASE_TAG_URL=""
ELIXIR_TREE_URL=""

#DEFAULT
DEFAULT_DEST_DIR="elixir"
DEFAULT_VERSION="latest"

#ARGS VARIABLES
COMMAND=""
PACKAGE_TYPE=""
VERSION=""
DEST_DIR=""

# FUNCTIONS

short_help() {
  echo "${APP_COMMAND}: missing arguments.

  Usage: ./get-elixir.sh (unpack | download) (source | precompiled)
                         [<version_number> | latest] [<dest_dir>]

  Example:
    ${APP_COMMAND} unpack source

  Try '${APP_COMMAND} --help' for more information."
}

help() {
  echo "${APP_NAME} version ${VERSION}

  Get any release of the Elixir programming language,
  without leaving the comfort of your command line.

  Usage: ./get-elixir.sh <command> <package_type> [<version_number>]
                         [<dest_dir>]

  Commands:
    download      Downloads the package
    unpack        Downloads the package and unpacks it

  Package Types:
    source        Source files
    precompiled   Precompiled files

  Version Number:
    'latest' is the default option, and it's not required to specify it
    (unless a DEST_DIR want to be used)
    Examples: 'latest', '1.0.5', '1.0.0-rc2'

  Destination Dir:
    Where you want to unpack Elixir. Default value: '${DEFAULT_DEST_DIR}'.

  Options:
    --version     Prints version
    --help        Prints help menu

  Usage Examples:

      ${APP_COMMAND} unpack source
      ${APP_COMMAND} unpack source 1.0.5
      ${APP_COMMAND} download precompiled 1.0.0-rc2

      # Install the latest in a differt directory
      ${APP_COMMAND} unpack source latest ./elixir-new

      # Get sources and compiled all in one
      ${APP_COMMAND} unpack precompiled && ${APP_COMMAND} unpack source 

  ** For a list of available releases, plesase visit:
     ${ELIXIR_RELEASES_URL}"
}

sanitize_version() {
  printf '%s' "$1" | sed -e 's/^v//g'
}

sanitize_dest_dir() {
  printf '%s' "$1" | sed -e 's@/$@@g'
}

get_latest_version() {
  local version
  version=$(curl -s -fL "${ELIXIR_CSV_URL}" | sed '2q;d' | cut -d , -f1)
  if [ "${version}" = "" ]; then 
    echo "* [ERROR] Latest Elixir version number couldn't be retrieved from ${ELIXIR_CSV_URL}" >&2
    exit 1
  else
    echo "${version}"
  fi
}

download_source() {
  local version="$1"
  local url="https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz"
  echo "* Downloading ${url}"
  curl -fL -o "v${version}.tar.gz" "${url}"
  if [ ! -f "v${version}.tar.gz" ]; then
    echo "* [ERROR] Elixir v${VERSION} could not be downloaded from ${url}" >&2
    if [ "${VERSION}" != "${DEFAULT_VERSION}" ]; then
    echo "          Please make sure version number is a valid one, by checking:" >&2
    echo "          ${ELIXIR_RELEASES_URL}" >&2
    fi
    exit 1
  fi
}

download_precompiled() {
  local version="$1"
  local url="https://github.com/elixir-lang/elixir/releases/download/v${version}/Precompiled.zip"
  echo "* Downloading ${url}"
  curl -fL -o Precompiled.zip "${url}"
  if [ ! -f Precompiled.zip ]; then
    echo "* [ERROR] Elixir v${VERSION} could not be downloaded from ${url}" >&2
    if [ "${VERSION}" != "${DEFAULT_VERSION}" ]; then
    echo "          Please make sure version number is a valid one, by finding it in:" >&2
    echo "          ${ELIXIR_RELEASES_URL}" >&2
    fi
    exit 1
  fi
}

unpack_source() {
  local version="$1"
  local dest_dir="$2"
  tar -xzf v${version}.tar.gz && 
  mkdir -p ${dest_dir} && 
  cp -rf elixir-${version}/* ${dest_dir} && 
  rm -rf elixir-${version}/ || (
    echo "* [ERROR] \"v${version}.tar.gz\" could not be unpacked to ${dest_dir}" >&2
    echo "          Check the file permissions." >&2
    exit 1
  )
}

unpack_precompiled() {
  local dest_dir="$1"
  mkdir -p ${dest_dir} && 
  unzip -o -q -d ${dest_dir} Precompiled.zip || (
    echo "* [ERROR] \"Precompiled.zip\" could not be unpacked to ${dest_dir}" >&2
    echo "          Check the file permissions." >&2
    exit 1
  )
}

do_main() {
  # check for help and version
  case "$1" in
    "help" | "--help" | "-h")
      help
      exit 0
    ;;

    "version" | "--version" | "-v")
      echo "${APP_NAME} – version ${APP_VERSION}"
      exit 0
    ;;
  esac

  # check for minimun number of args
  if [ "$#" -lt 2 ]; then
    short_help >&2
    exit 1
  fi

  # Get Variables from ARGS
  COMMAND="$1"
  PACKAGE_TYPE="$2"
  if [ "$3" = "" ] || [ "$3" = "${DEFAULT_VERSION}" ]; then
    echo "* Retrieving version number of latest Elixir release..."
    VERSION=$(get_latest_version)
  else
    VERSION=$(sanitize_version "$3")
  fi

  if [ "$4" = "" ] ; then
    DEST_DIR="${DEFAULT_DEST_DIR}"
  else
    DEST_DIR=$(sanitize_dest_dir "$4")
  fi

  # Check for unrecognized options
  if [ "${COMMAND}" != "unpack" ] &&  [ "${COMMAND}" != "download" ]; then
    echo "* [ERROR] Unrecognized ACTION \"${COMMAND}\". Try 'unpack' or 'download'." >&2
    exit 1
  fi
  
  if [ "${PACKAGE_TYPE}" != "source" ] &&  [ "${PACKAGE_TYPE}" != "precompiled" ]; then
    echo "* [ERROR] Unrecognized PACKAGE_TYPE \"${PACKAGE_TYPE}\". Try 'source' or 'precompiled'." >&2
    exit 1
  fi

  # Define variables based on $VERSION
  ELIXIR_RELEASE_TAG_URL="https://github.com/elixir-lang/elixir/releases/tag/v${VERSION}"
  ELIXIR_TREE_URL="https://github.com/elixir-lang/elixir/tree/v${VERSION}"

  # Do our logic
  case "${COMMAND}" in
    "download")
      case "${PACKAGE_TYPE}" in
        "source")
          download_source "${VERSION}"
          echo "* [OK] Elixir v${VERSION} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: v${VERSION}.tar.gz"
        ;;

        "precompiled")
          download_precompiled "${VERSION}"
          echo "* [OK] Elixir v${VERSION} [Precompiled]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: Precompiled.zip"
        ;;
      esac
    ;;

    "unpack")
      case "${PACKAGE_TYPE}" in
        "source")
          download_source "${VERSION}"
          unpack_source "${VERSION}" "${DEST_DIR}"
          echo "* [OK] Elixir v${VERSION} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DEST_DIR}/"
        ;;

        "precompiled")
          download_precompiled "${VERSION}"
          unpack_precompiled "${DEST_DIR}"
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