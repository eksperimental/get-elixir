#!/usr/bin/env sh

trap "exit 1" TERM
export TOP_PID=$$

APP_NAME="get-elixir"
APP_VERSION="0.0.4-dev"
APP_COMMAND="./get-elixir.sh"
APP_REPO_USER="eksperimental"
APP_URL="https://github.com/${APP_REPO_USER}/${APP_NAME}"
#APP_GIT_URL="${APP_URL}.git"
#APP_SCRIPT_URL="${APP_URL}/raw/master/get-elixir.sh"
#APP_SCRIPT=$(basename "${APP_SCRIPT_URL}")
APP_RELEASES_URL="https://github.com/${APP_REPO_USER}/${APP_NAME}/releases"
APP_RELEASES_JSON_URL="https://api.github.com/repos/elixir-lang/elixir/releases"
ELIXIR_CSV_URL="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
ELIXIR_RELEASES_URL="https://github.com/elixir-lang/elixir/releases"
#ELIXIR_RELEASE_TAG_URL=""
#ELIXIR_TREE_URL=""
SELF=""
SCRIPT_PATH=""

#DEFAULT
DEFAULT_COMMAND="download"
DEFAULT_DIR="elixir"
DEFAULT_RELEASE="latest"

#ARGS VARIABLES
COMMAND=""
PACKAGE_TYPE=""
RELEASE=""
DIR=""


# FUNCTIONS

short_help() {
  echo "${APP_COMMAND}: missing arguments.

  Usage: ./get-elixir.sh (--source | --binaries)
                         [--unpack]
                         [<release_number>]
                         [--dir <dir>]

  Example:
    ${APP_COMMAND} unpack source

  Try '${APP_COMMAND} --help' for more information."
}

help() {
  echo "${APP_NAME} version ${RELEASE}

  Get any release of the Elixir programming language,
  without leaving the comfort of your command line.

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
                         Default value: '${DEFAULT_DIR}'
  
  Secondary Options:
    -h, --help                 Prints help menu
        --update-script        Replace this script by downloading the latest release
        --list-releases        Lists all Elixir releases (final and pre-releases)
        --list-final-releases  Lists final Elixir releases
    -v, --version              Prints script version

  Usage Examples:

      # Download the source code for the latest relase
      ${APP_COMMAND} --source

      # Download and unpack the souce code for v1.0.5,
      # and unpack it in dir 'elixir-1.0.x'
      ${APP_COMMAND} --unpack --source --release 1.0.5 --dir elixir-1.0.x/
      
      # Download and unpack source code and precompiled binaries,
      # for v1.0.0-rc2
      ${APP_COMMAND} -u -s -b -r 1.0.0-rc2

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

sanitize_release() {
  # remove v from release,
  # and after that, any "../"
  printf '%s' "$1" | sed -e 's/^v//g;s@^\.\./@@g;'
}

sanitize_dir() {
  printf '%s' "$1" | sed -e 's@/$@@g'
}

get_latest_release() {
  local release
  release=$(curl -sfL "${ELIXIR_CSV_URL}" | sed '2q;d' | cut -d , -f1)
  if [ "${release}" = "" ]; then 
    echo "* [ERROR] Latest Elixir release number couldn't be retrieved from ${ELIXIR_CSV_URL}" >&2
    exit_script
  else
    echo "${release}"
  fi
}

get_elixir_final_releases() {
  local releases
  releases=$(curl -sfL "${ELIXIR_CSV_URL}" | tail -n +2 | cut -d , -f1)
  if [ "${releases}" = "" ]; then
    echo "* [ERROR] Elixir's final release numbers couldn't be retrieved from" >&2
    echo "  ${ELIXIR_CSV_URL}" >&2
    exit_script
  else
    echo "${releases}"
  fi
}

get_elixir_releases() {
  local releases
  releases=$(curl -sfL "${APP_RELEASES_JSON_URL}" | grep "tag_name" | cut -d':' -f2 | sed 's@ \{1,\}"@@g' | sed 's@",@@g')
  if [ "${releases}" = "" ]; then
    echo "* [ERROR] Elixir release numbers couldn't be retrieved from" >&2
    echo "  ${APP_RELEASES_JSON_URL}" >&2
    exit_script
  else
    echo "${releases}"
  fi
}

get_latest_script_version() {
  local release=$(curl -sfI "${APP_RELEASES_URL}/latest" |  grep "Location: " | tr '\r' '\0' | tr '\n' '\0' | rev | cut -d'/' -f1 | rev)
  if [ "${release}" = "" ]; then
    echo "* [ERROR] Latest ${APP_NAME} release number couldn't be retrieved from" >&2
    echo "  ${APP_RELEASES_URL}" >&2
    exit_script
  else
    sanitize_release "${release}"
  fi
}

download_source() {
  local release="$1"
  local url="https://github.com/elixir-lang/elixir/archive/v${release}.tar.gz"
  echo "* Downloading ${url}"
  curl -fL -O "${url}"
  if [ ! -f "v${release}.tar.gz" ]; then
    echo "* [ERROR] Elixir v${RELEASE} could not be downloaded from ${url}" >&2
    if [ "${RELEASE}" != "${DEFAULT_RELEASE}" ]; then
    echo "          Please make sure release number is a valid one, by checking:" >&2
    echo "          ${ELIXIR_RELEASES_URL}" >&2
    fi
    exit_script
  fi
}

download_binaries() {
  local release="$1"
  local url="https://github.com/elixir-lang/elixir/releases/download/v${release}/Precompiled.zip"
  echo "* Downloading ${url}"
  curl -fL -o "Precompiled-v${release}.zip" "${url}"
  if [ ! -f "Precompiled-v${release}.zip" ]; then
    echo "* [ERROR] Elixir v${RELEASE} could not be downloaded from ${url}" >&2
    if [ "${RELEASE}" != "${DEFAULT_RELEASE}" ]; then
    echo "          Please make sure release number is a valid one, by finding it in:" >&2
    echo "          ${ELIXIR_RELEASES_URL}" >&2
    fi
    exit_script
  fi
}

unpack_source() {
  local release="$1"
  local dir="$2"
  tar -xzf "v${release}.tar.gz" && 
  mkdir -p "${dir}" && 
  cp -rf elixir-"${release}"/* "${dir}" && 
  rm -rf elixir-"${release}"/ || (
    echo "* [ERROR] \"v${release}.tar.gz\" could not be unpacked to ${dir}" >&2
    echo "          Check the file permissions." >&2
    exit_script
  )
}

unpack_binaries() {
  local dir="$1"
  local file="Precompiled-v${release}.zip"
  mkdir -p "${dir}" && 
  unzip -o -q -d "${dir}" "${file}" || (
    echo "* [ERROR] \"${file}\" could not be unpacked to ${dir}" >&2
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
  Current version: ${APP_VERSION} / Newest version:  ${latest_script_version}
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
  local reply=""
  printf '%s [Y/N]: ' "${1}"
  read reply
  if printf '%s\n' "${reply}" | grep -Eq '^[yY].*'; then
    return 0
  else
    return 1
  fi
}

readlink_f () {
  cd "$(dirname "$1")" > /dev/null
  local filename="$(basename "$1")"
  if [ -h "${filename}" ]; then
    readlink_f "$(readlink "${filename}")"
  else
    echo "$(pwd -P)/${filename}"
  fi
}

do_parse_options() {
  # ./get-elixir.sh 
  #   (--unpack | -u)
  #   (--source | -s | --binaries | -b)
  #   (--release | -r) <release_number>
  #   (--dir| -d) <dir>
  #   ...
  #   (--help | -h)
  #   (--version | -v)
  #   (--update-script)
  
  POS=1
  while [ $POS -le $# ]; do
    SKIP=1
    eval "CURRENT=\${$POS}"
    case "${CURRENT}" in
      -h|--help)
          COMMAND="help"
          break;
          ;;
      -v|--version)
          COMMAND="version"
          break
          ;;
      --update-script)
          COMMAND="update-script"
          break
          ;;
      --list-releases)
          COMMAND="list-releases"
          break;
          ;;
      --list-final-releases)
          COMMAND="list-final-releases"
          break;
          ;;
      -u|--unpack)
          COMMAND="unpack"
          ;;
      -s|--source)
          if [ "${PACKAGE_TYPE}" = "" ]; then
            PACKAGE_TYPE="source"
          elif [ "${PACKAGE_TYPE}" = "binaries" ]; then
            PACKAGE_TYPE="binaries_source"
          fi
          ;;
      -b|--binaries)
          if [ "${PACKAGE_TYPE}" = "" ]; then
            PACKAGE_TYPE="binaries"
          elif [ "${PACKAGE_TYPE}" = "binaries" ]; then
            PACKAGE_TYPE="binaries_source"
          fi
          ;;
      -r|--release)
          POS=$((POS + 1))
          eval "RELEASE=\${$POS}"
          RELEASE="$(sanitize_release "${RELEASE}")"
          SKIP=2
          ;;
      -d|--dir)
          POS=$((POS + 1))
          eval "DIR=\${$POS}"
          # expand dir
          eval "DIR=${DIR}"
          DIR="$(sanitize_dir "${DIR}")"
          SKIP=2
          ;;
      *)
          # MAYBE: break on unrecognized option
          break
          ;;
    esac
    POS=$((POS + SKIP))
  done
}

do_default_options() {
  if [ "${COMMAND}" = "" ]; then
    RELEASE="${DEFAULT_COMMAND}"
  fi

  if [ "${RELEASE}" = "" ]; then
    RELEASE="${DEFAULT_RELEASE}"
  fi

  if [ "${DIR}" = "" ] ; then
    # expand dir
    eval "DIR=${DEFAULT_DIR}"
    DIR="$(sanitize_dir "${DIR}")"
  fi
}


do_main() {
  # Show short_help if no options provided
  if [ $# = 0 ]; then
    short_help >&2
    exit_script
  fi

  do_parse_options "$@"
  do_default_options

  # check for options that should return inmediately
  case "${COMMAND}" in
    help)
      help
      return 0
    ;;

    update-script)
      update_script
      return 0
    ;;

    version)
      echo "${APP_NAME} – version ${APP_VERSION}"
      return 0
    ;;

    list-releases)
      get_elixir_releases
      return 0
    ;;

    list-final-releases)
      get_elixir_final_releases
      return 0
    ;;
  esac

  # Check for needed commands
  if [ "${COMMAND}" = "" ]; then
    echo "* [ERROR] Unrecognized <command> \"${COMMAND}\". Try 'unpack' or 'download'." >&2
    exit_script
  elif [ "${PACKAGE_TYPE}" = "" ]; then
    echo "* [ERROR] Unrecognized <package_type> \"${PACKAGE_TYPE}\". Try 'binaries' or 'source'." >&2
    exit_script
  fi

  # Get latest release if needed
  if [ "${RELEASE}" = "latest" ]; then
    echo "* Retrieving version number of latest Elixir release..."
    RELEASE=$(get_latest_release)
  fi

  # Define variables based on $RELEASE
  #ELIXIR_RELEASE_TAG_URL="https://github.com/elixir-lang/elixir/releases/tag/v${RELEASE}"
  ELIXIR_TREE_URL="https://github.com/elixir-lang/elixir/tree/v${RELEASE}"

  # Do our logic
  case "${COMMAND}" in
    "download")
      case "${PACKAGE_TYPE}" in
        "binaries")
          download_binaries "${RELEASE}"
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: Precompiled.zip"
        ;;

        "source")
          download_source "${RELEASE}"
          echo "* [OK] Elixir v${RELEASE} [source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: v${RELEASE}.tar.gz"
        ;;

        "binaries_source")
          download_binaries "${RELEASE}"
          download_source "${RELEASE}"
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries & source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Downloaded: Precompiled.zip, v${RELEASE}.tar.gz"
        ;;
      esac
    ;;

    "unpack")
      # TODO: CONFIRM files are gonna be replace if DIR is not empty
      # TODO: create an option to skip this confirmation
      case "${PACKAGE_TYPE}" in
        "binaries")
          download_binaries "${RELEASE}"
          unpack_binaries "${DIR}"
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DIR}/"
        ;;

        "source")
          download_source "${RELEASE}"
          unpack_source "${RELEASE}" "${DIR}"
          echo "* [OK] Elixir v${RELEASE} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DIR}/"
        ;;

        "binaries_source")
          download_binaries "${RELEASE}"
          unpack_binaries "${DIR}"
          download_source "${RELEASE}"
          unpack_source "${RELEASE}" "${DIR}"
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries & source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       Files have been unpacked to: ${DIR}/"
        ;;
      esac
      ;;
  esac
}

SELF=$(readlink_f "$0")
SCRIPT_PATH=$(dirname "$SELF")
do_main "$@"
exit 0