#!/bin/sh

trap "exit 1" TERM
export TOP_PID=$$

APP_NAME="get-elixir"
APP_VERSION="0.0.3-dev"
APP_COMMAND="./get-elixir.sh"
APP_REPO_USER="eksperimental"
APP_URL="https://github.com/${APP_REPO_USER}/${APP_NAME}"
APP_GIT_URL="${APP_URL}.git"
APP_SCRIPT_URL="${APP_URL}/raw/master/get-elixir.sh"
APP_SCRIPT=$(basename "${APP_SCRIPT_URL}")
APP_RELEASES_URL="https://github.com/${APP_REPO_USER}/${APP_NAME}/releases"
ELIXIR_CSV_URL="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
ELIXIR_RELEASES_URL="https://github.com/elixir-lang/elixir/releases"
ELIXIR_RELEASE_TAG_URL=""
ELIXIR_TREE_URL=""
SCRIPT_PATH="$(dirname "$0")/${APP_SCRIPT}"

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

  Usage: ./get-elixir.sh (unpack | download) (source | binaries)
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
    binaries         Precompiled binaries
    source           Source code
    binaries_source  Precompiled binaries and source code

  Version Number:
    'latest' is the default option, and it's not required to specify it
    (unless a <dest_dir> wants to be used)
    Examples: 'latest', '1.0.5', '1.0.0-rc2'

  Destination Dir:
    Where you want to unpack Elixir. Default value: '${DEFAULT_DEST_DIR}'.

  Options:
    --help           Prints help menu
    --update-script  Replace this script by downloading the latest version
    --version        Prints version

  Usage Examples:

      ${APP_COMMAND} unpack source
      ${APP_COMMAND} unpack source 1.0.5
      ${APP_COMMAND} download binaries 1.0.0-rc2

      # Install the latest in a differt directory
      ${APP_COMMAND} unpack source latest ./elixir-new

      # Get sources and compiled all in one
      ${APP_COMMAND} unpack binaries && ${APP_COMMAND} unpack source 

  ** For a list of available releases, plesase visit:
     ${ELIXIR_RELEASES_URL}"
}

exit_script() {
  # http://stackoverflow.com/questions/9893667/is-there-a-way-to-write-a-bash-function-which-aborts-the-whole-execution-no-mat
  kill -s TERM $TOP_PID
}

sanitize_version() {
  # remove v from version,
  # and after that, any "../"
  printf '%s' "$1" | sed -e 's/^v//g;s@^\.\./@@g;'
}

sanitize_dest_dir() {
  printf '%s' "$1" | sed -e 's@/$@@g'
}

get_elixir_final_release_versions() {
  local versions
  versions=$(curl -sfL "${ELIXIR_CSV_URL}" | tail -n +2 | cut -d , -f1)
  if [ "${versions}" = "" ]; then
    echo "* [ERROR] Elixir's final release version numbers couldn't be retrieved from ${ELIXIR_CSV_URL}" >&2
    exit_script
  else
    echo "${versions}"
  fi
}

get_latest_version() {
  local version
  version=$(curl -sfL "${ELIXIR_CSV_URL}" | sed '2q;d' | cut -d , -f1)
  if [ "${version}" = "" ]; then 
    echo "* [ERROR] Latest Elixir version number couldn't be retrieved from ${ELIXIR_CSV_URL}" >&2
    exit_script
  else
    echo "${version}"
  fi
}

get_latest_script_version() {
  #version=$(curl -s -fL "${APP_RELEASES_URL}" | grep browser_download_url | head -n 1 | cut -d '"' -f 4)
  local version=$(curl -sfI "${APP_RELEASES_URL}/latest" |  grep "Location: " | tr '\r' '\0' | tr '\n' '\0' | rev | cut -d"/" -f1 | rev)
  if [ "${version}" = "" ]; then
    echo "* [ERROR] Latest ${APP_NAME} version number couldn't be retrieved from ${APP_RELEASES_URL}" >&2
    exit_script
  else
    echo "$(sanitize_version "${version}")"
  fi
}

download_source() {
  local version="$1"
  local url="https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz"
  echo "* Downloading ${url}"
  curl -fL -O "${url}"
  if [ ! -f "v${version}.tar.gz" ]; then
    echo "* [ERROR] Elixir v${VERSION} could not be downloaded from ${url}" >&2
    if [ "${VERSION}" != "${DEFAULT_VERSION}" ]; then
    echo "          Please make sure version number is a valid one, by checking:" >&2
    echo "          ${ELIXIR_RELEASES_URL}" >&2
    fi
    exit_script
  fi
}

download_binaries() {
  local version="$1"
  local url="https://github.com/elixir-lang/elixir/releases/download/v${version}/Precompiled.zip"
  echo "* Downloading ${url}"
  curl -fL -O "${url}"
  if [ ! -f Precompiled.zip ]; then
    echo "* [ERROR] Elixir v${VERSION} could not be downloaded from ${url}" >&2
    if [ "${VERSION}" != "${DEFAULT_VERSION}" ]; then
    echo "          Please make sure version number is a valid one, by finding it in:" >&2
    echo "          ${ELIXIR_RELEASES_URL}" >&2
    fi
    exit_script
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
    exit_script
  )
}

unpack_binaries() {
  local dest_dir="$1"
  mkdir -p ${dest_dir} && 
  unzip -o -q -d ${dest_dir} Precompiled.zip || (
    echo "* [ERROR] \"Precompiled.zip\" could not be unpacked to ${dest_dir}" >&2
    echo "          Check the file permissions." >&2
    exit_script
  )
}

update_script() {
  echo "* Retrieving version number of latest ${APP_NAME} release..."
  local latest_script_version=$(get_latest_script_version)
  local remote_script_url="${APP_URL}/raw/v${latest_script_version}/get-elixir.sh"
  
  if [ "${latest_script_version}" != "${APP_VERSION}" ]; then
    confirm "* You are about to replace '${SCRIPT_PATH}'.
  Current version: ${APP_VERSION} / New version:  ${latest_script_version}
  Do you confirm?" && (
      curl -fL -o "${SCRIPT_PATH}" "${remote_script_url}" && (
        chmod +x "${SCRIPT_PATH}"
        echo "* [OK] ${APP_NAME} succesfully updated."
        return 0
      ) || (
        echo "* [ERROR] ${APP_NAME} could not be downloaded from" >&2
        echo "          ${remote_script_url}" >&2
        exit_script
      )
    ) || (
      echo "* Updating script has been cancelled."
      return 1
    )
  else
    echo "* [OK] ${APP_COMMAND} is already the newest version."
    return 0
  fi
}

confirm() {
  local response=""
  read -p "${1} [Y/N]: " response
  #echo ${response}
  if printf "%s\n" "${response}" | grep -Eq "^[yY].*"; then
    return 0
  else
    return 1
  fi
}

do_main() {
  # check for help and version
  case "$1" in
    "help" | "--help" | "-h")
      help
      return 0
    ;;

    "update-script" | "--update-script")
      update_script
      return 0
    ;;

    "version" | "--version" | "-v")
      echo "${APP_NAME} – version ${APP_VERSION}"
      return 0
    ;;
  esac

  # check for minimun number of args
  if [ "$#" -lt 2 ]; then
    short_help >&2
    exit_script
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
    eval "DEST_DIR=${DEFAULT_DEST_DIR}"
  else
    eval "DEST_DIR=$4"
  fi
  DEST_DIR=$(sanitize_dest_dir "$DEST_DIR")

  # Check for unrecognized options
  if [ "${COMMAND}" != "unpack" ] &&  [ "${COMMAND}" != "download" ]; then
    echo "* [ERROR] Unrecognized <action> \"${COMMAND}\". Try 'unpack' or 'download'." >&2
    exit_script
  fi
  
  if [ "${PACKAGE_TYPE}" != "binaries" ] && [ "${PACKAGE_TYPE}" != "source" ] && [ "${PACKAGE_TYPE}" != "binaries_source" ]; then
    echo "* [ERROR] Unrecognized <package_type> \"${PACKAGE_TYPE}\". Try 'binaries', 'source' or 'binaries_source'." >&2
    exit_script
  fi

  # Define variables based on $VERSION
  ELIXIR_RELEASE_TAG_URL="https://github.com/elixir-lang/elixir/releases/tag/v${VERSION}"
  ELIXIR_TREE_URL="https://github.com/elixir-lang/elixir/tree/v${VERSION}"

  # Do our logic
  case "${COMMAND}" in
    "download")
      case "${PACKAGE_TYPE}" in
        "binaries")
          download_binaries "${VERSION}"
          echo "* [OK] Elixir v${VERSION} [precompiled binaries]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: Precompiled.zip"
        ;;

        "source")
          download_source "${VERSION}"
          echo "* [OK] Elixir v${VERSION} [source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: v${VERSION}.tar.gz"
        ;;

        "binaries_source")
          download_binaries "${VERSION}"
          download_source "${VERSION}"
          echo "* [OK] Elixir v${VERSION} [precompiled binaries & source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: Precompiled.zip, v${VERSION}.tar.gz"
        ;;
      esac
    ;;

    "unpack")
      case "${PACKAGE_TYPE}" in
        "binaries")
          download_binaries "${VERSION}"
          unpack_binaries "${DEST_DIR}"
          echo "* [OK] Elixir v${VERSION} [precompiled binaries]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DEST_DIR}/"
        ;;

        "source")
          download_source "${VERSION}"
          unpack_source "${VERSION}" "${DEST_DIR}"
          echo "* [OK] Elixir v${VERSION} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DEST_DIR}/"
        ;;

        "binaries_source")
          download_binaries "${VERSION}"
          unpack_binaries "${DEST_DIR}"
          download_source "${VERSION}"
          unpack_source "${VERSION}" "${DEST_DIR}"
          echo "* [OK] Elixir v${VERSION} [precompiled binaries & source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DEST_DIR}/"
        ;;
      esac
      ;;
  esac
}

do_main $*
exit 0