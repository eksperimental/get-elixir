#!/usr/bin/env sh

trap "exit 1" TERM
export TOP_PID=$$

APP_NAME="get-elixir"
APP_VERSION="0.0.4-dev"
APP_COMMAND="./get-elixir.sh"
APP_URL="https://github.com/eksperimental/get-elixir"
APP_RELEASES_URL="https://github.com/eksperimental/get-elixir/releases"
APP_RELEASES_JSON_URL="https://api.github.com/repos/elixir-lang/elixir/releases"
ELIXIR_CSV_URL="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
ELIXIR_RELEASES_URL="https://github.com/elixir-lang/elixir/releases"
SELF="" # set at the bottom of the script
SCRIPT_PATH="" # set at the bottom of the script

DEFAULT_RELEASE="latest"

#ARGS VARIABLES + DEFAULT 
do_instantiate_vars() {
  PACKAGE_TYPE=""  # <= required to be set via command options
  COMMAND="download"
  RELEASE="${DEFAULT_RELEASE}"
  DIR="elixir" #<== do no use trailing slashes
  #eval "DIR=~/.elixir"  #<== needed to expand, in case we use "~" in default dir
  SILENT_DOWNLOAD=1
  DOWNLOAD_COMMAND_OPTIONS="-fL"
  ASSUME_YES=1
  VERBOSE_UNPACK=1
  CONFIRM_OVERWRITE=0
}

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
                         Default value: '${DIR}'
  
  Secondary Options:
    -h, --help                 Prints help menu
        --update-script        Replace this script by downloading the latest release
        --list-releases        Lists all Elixir releases (final and pre-releases)
        --list-final-releases  Lists final Elixir releases
        --silent-download      Silent download (Hide status)
        --verbose-unpack       Be verbose when unpacking files
        --confirm-overwrite    Confirm before overwritting any file.
                               This is superseeded by --assume-yes
    -y, --assume-yes           Assume 'Yes' to all confirmations, and do not prompt
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

  ** For a list of available releases, run:
     ${APP_COMMAND} --list-releases"
}

#posix functions
readlink_f () {
  cd "$(dirname "$1")" > /dev/null
  local filename="$(basename "$1")"
  if [ -h "${filename}" ]; then
    readlink_f "$(readlink "${filename}")"
  else
    echo "$(pwd -P)/${filename}"
  fi
}

epoch_time() {
  #http://stackoverflow.com/questions/2445198/get-seconds-since-epoch-in-any-posix-compliant-shell
  PATH=`getconf PATH` awk 'BEGIN{srand();print srand()}'
}

exit_script() {
  # http://stackoverflow.com/questions/9893667/is-there-a-way-to-write-a-bash-function-which-aborts-the-whole-execution-no-mat
  kill -s TERM $TOP_PID
}

confirm() {
  if [ "${ASSUME_YES}" = 0 ]; then
    return 0
  else
    local reply=""
    printf '%s [Y/N]: ' "${1}"
    read reply
    if printf '%s\n' "${reply}" | grep -Eq '^[yY].*'; then
      return 0
    else
      return 1
    fi
  fi
}


# get-elixir functions 

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

set_download_command_options() {
  if [ "${SILENT_DOWNLOAD}" = 0 ]; then
    DOWNLOAD_COMMAND_OPTIONS="${DOWNLOAD_COMMAND_OPTIONS} -s"
  fi
  return 0
}

get_unpack_verbose_option() {
  case "$1" in 
    unzip)
      if [ ${VERBOSE_UNPACK} -eq 0 ]; then
        echo ""
      else
        echo "-q"
      fi
      ;;

    tar)
      if [ ${VERBOSE_UNPACK} -eq 0 ]; then
        echo "-v"
      else
        echo ""
      fi
      ;;
  esac
  return 0
}

get_unpack_overwrite_option() {
  case "$1" in 
    unzip)
      if [ ${CONFIRM_OVERWRITE} -eq 0 ]; then
        echo "-o"
      else
        echo ""
      fi
      ;;

    tar)
      if [ ${CONFIRM_OVERWRITE} -eq 0 ]; then
        echo "-f"
      else
        echo ""
      fi
      ;;

    tar)
      if [ ${CONFIRM_OVERWRITE} -eq 0 ]; then
        echo "-i"
      else
        echo ""
      fi
      ;;
  esac
  return 0
}

download_source() {
  local release="$1"
  local url="https://github.com/elixir-lang/elixir/archive/v${release}.tar.gz"
  echo "* Downloading ${url}"
  curl ${DOWNLOAD_COMMAND_OPTIONS} -O "${url}"
  if [ ! -f "v${release}.tar.gz" ]; then
    echo "* [ERROR] Elixir v${RELEASE} could not be downloaded from ${url}" >&2
    if [ "${RELEASE}" != "${DEFAULT_RELEASE}" ]; then
    echo "          Please make sure the release number is a valid one, by running:" >&2
    echo "          ${APP_COMMAND} --list-releases" >&2
    fi
    exit_script
  fi
}

download_binaries() {
  local release="$1"
  local url="https://github.com/elixir-lang/elixir/releases/download/v${release}/Precompiled.zip"
  echo "* Downloading ${url}"
  curl ${DOWNLOAD_COMMAND_OPTIONS} -o "Precompiled-v${release}.zip" "${url}"
  if [ ! -f "Precompiled-v${release}.zip" ]; then
    echo "* [ERROR] Elixir v${RELEASE} could not be downloaded from ${url}" >&2
    if [ "${RELEASE}" != "${DEFAULT_RELEASE}" ]; then
    echo "          Please make sure the release number is a valid one, by running:" >&2
    echo "          ${APP_COMMAND} --list-releases" >&2
    fi
    exit_script
  fi
}

unpack_source() {
  local release="$1"
  local dir="$2"
  local verbose="$(get_unpack_verbose_option tar)"
  local overwrite="$(get_unpack_overwrite_option cp)"
  mkdir -p "${dir}" &&
  #local tmp_dir="${dir}/.${APP_NAME}-$(epoch_time)"
  local tmp_dir="/tmp/${APP_NAME}-$(epoch_time)"
  mkdir -p "${tmp_dir}" &&
  tar -C "${tmp_dir}" -xzf ${verbose} "v${release}.tar.gz" && 
  echo "cp -r ${overwrite_cp} ${tmp_dir}/elixir-${release}/*" "${dir}" &&
  cp -r ${overwrite_cp} "${tmp_dir}/elixir-${release}"/* "${dir}" || (
    echo "* [ERROR] \"v${release}.tar.gz\" could not be unpacked to ${dir}" >&2
    echo "          Check the {release permissions." >&2
    exit_script
  )
  rm -rf "${tmp_dir}"
}

unpack_binaries() {
  local dir="$1"
  local file="Precompiled-v${release}.zip"
  local verbose="$(get_unpack_verbose_option unzip)"
  local overwrite="$(get_unpack_overwrite_option unzip)"
  mkdir -p "${dir}" && 
  unzip ${verbose} ${overwrite} -d "${dir}" "${file}" || (
    echo "* [ERROR] \"${file}\" could not be unpacked to ${dir}" >&2
    echo "          Check the file permissions." >&2
    exit_script
  )
}

update_script() {
  echo "* Retrieving latest ${APP_NAME} release number..."
  local latest_script_version=$(get_latest_script_version)
  local remote_script_url="${APP_URL}/raw/v${latest_script_version}/get-elixir.sh"
  
  if [ "${latest_script_version}" != "${APP_VERSION}" ]; then
    confirm "* You are about to replace '${SELF}'.
  Current version: ${APP_VERSION} / Newest version:  ${latest_script_version}
  Do you confirm?" && (
      curl ${DOWNLOAD_COMMAND_OPTIONS} -o "${SELF}" "${remote_script_url}" && (
        chmod +x "${SELF}"
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

do_parse_options() {
  POS=1
  while [ $POS -le $# ]; do
    SKIP=1
    eval "CURRENT=\${$POS}"
    case "${CURRENT}" in
      # Options that do not combine with no other options
      -h|--help)
          COMMAND="help"
          break;
          ;;
      -v|--version)
          COMMAND="version"
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

       # Options that do combine with other options
      --silent-download)
          SILENT_DOWNLOAD=0
          ;;
      -y|--assume-yes)
          ASSUME_YES=0
          ;;
      --vebose-unpack)
          VERBOSE_UNPACK=0
          ;;
      --confirm-overwrite)
          CONFIRM_OVERWRITE=0
          ;;
      --update-script)
          COMMAND="update-script"
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

superseed_options() {
  if [ "${ASSUME_YES}" = 0 ]; then
    CONFIRM_OVERWRITE=1
  fi
}

do_main() {
  # Show short_help if no options provided
  if [ $# = 0 ]; then
    short_help >&2
    exit_script
  fi

  do_instantiate_vars
  do_parse_options "$@"
  superseed_options
  set_download_command_options
  
  # check for options that should return inmediately
  case "${COMMAND}" in
    help)
      help
      return 0
    ;;
    version)
      echo "${APP_NAME} – version ${APP_VERSION}"
      return 0
    ;;
    update-script)
      update_script
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
    echo "* Retrieving latest Elixir release number..."
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