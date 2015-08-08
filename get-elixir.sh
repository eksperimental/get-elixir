#!/usr/bin/env sh

#set -x
trap "exit 1" TERM
export TOP_PID=$$


do_instantiate_vars() {
  APP_NAME="get-elixir"
  APP_VERSION="0.0.4-dev"
  APP_COMMAND="./get-elixir.sh"
  APP_URL="https://github.com/eksperimental/get-elixir"
  APP_RELEASES_URL="https://github.com/eksperimental/get-elixir/releases"
  APP_RELEASES_JSON_URL="https://api.github.com/repos/elixir-lang/elixir/releases"
  ELIXIR_CSV_URL="https://github.com/elixir-lang/elixir-lang.github.com/raw/master/elixir.csv"
  SELF="" # set at the bottom of the script
  #SCRIPT_PATH="" # set at the bottom of the script

  DEFAULT_RELEASE="latest"

  PACKAGE_TYPE=""  # <= required to be set via command options
  COMMAND="download"
  RELEASE="${DEFAULT_RELEASE}"
  DIR="elixir" #<== do no use trailing slashes
  #eval "DIR=~/.elixir"  #<== needed to expand, in case we use "~" in default $DIR
  SILENT_DOWNLOAD=1
  DOWNLOAD_COMMAND_OPTIONS="-fL"
  ASSUME_YES=1
  VERBOSE_UNPACK=1
  ASK_OVERWRITE=1
  KEEP_DIR="."

  # INTERNAL USE
  USED_EXISTING_BINARIES=1
  USED_EXISTING_SOURCE=1
  USED_EXISTING_SCRIPT=1

  SELF=$(readlink_f "$0")
  #SCRIPT_PATH=$(dirname "$SELF")

  # COMMAND OPTIONS
  CURL_OPTIONS=""
}

########################################################################
# FUNCTIONS

short_help() {
  echo "${APP_COMMAND}: missing arguments.

  Usage: ./get-elixir.sh package_type... [options...]

    ./get-elixir.sh [--binaries ] [--source] [--unpack] [--release <value>]
                    [--dir <dir>] [--keep-dir <dir>]
                    [--silent-download] [--verbose-unpack]
                    [--assume-yes | --ask-overwrite]  

  Example:
    ${APP_COMMAND} --source
    ${APP_COMMAND} --source --unpack --release 1.0.0

  Try '${APP_COMMAND} --help' for more information and additional commands."
}

help() {
  echo "${APP_NAME} version ${RELEASE}

  Get any release of the Elixir programming language,
  without leaving the comfort of your command line.

  Usage:
    ./get-elixir.sh package_type... [options...]
    ./get-elixir.sh command... [options...]

    ./get-elixir.sh [--binaries ] [--source] [--unpack] [--release <value>]
                    [--dir <dir>] [--keep-dir <dir>]
                    [--silent-download] [--verbose-unpack]
                    [--assume-yes | --ask-overwrite]
    ./get-elixir.sh --help
    ./get-elixir.sh --version
    ./get-elixir.sh --update-script
    ./get-elixir.sh --download-script [--keep-dir <dir>]
    ./get-elixir.sh --list-releases
    ./get-elixir.sh --list-final-releases

  Package Types:
    -b, --binaries          Download precompiled binaries
    -s, --source            Download source code
  
  Options:
    -u, --unpack            Unpacks the package(s) once downloaded
    -r, --release           Elixir release number
                              'latest' is the default option
                              Examples: 'latest', '1.0.5', '1.0.0-rc2'
    -d, --dir               Directory where you want to unpack Elixir.
    -k, --keep-dir          Directory where you want to keep downloaded files
                              Default value: '${DIR}'
        --silent-download   Silent download (Hide status)
        --verbose-unpack    Be verbose when unpacking files
    -y, --assume-yes        Assume 'Yes' to all confirmations, and do not prompt
        --ask-overwrite     Confirmation needed before overwritting any file.
                              This is superseeded by --assume-yes.
                              It is not recommended to use this option, unless
                              you have a specific reason to do it.

  Commands:
    -h, --help                 Prints help menu
    -v, --version              Prints script version information
        --update-script        Replace this script by downloading the latest
                                 release
        --download-script      Download the latest release of this script to
                                 the specified location (use --keep-dir)
        --list-releases        Lists all Elixir releases (final and
                                 pre-releases)
        --list-final-releases  Lists final Elixir releases

  Usage Examples:

      # Download the source code for the latest relase
      ${APP_COMMAND} --source

      # Download and unpack the souce code for v1.0.5,
      # and unpack it in dir 'elixir-1.0.x'
      ${APP_COMMAND} --source --unpack --release 1.0.5 --dir elixir-1.0.x/
      
      # Download and unpack the latest in a differt directory
      ${APP_COMMAND} --source --unpack -d ./elixir-new

      # Download and unpack source code and precompiled binaries,
      # for v1.0.0-rc2
      ${APP_COMMAND} -s -b -u -r 1.0.0-rc2


  ** For a list of available releases, run:
     ${APP_COMMAND} --list-releases"
}

########################################################################
# HELPER FUNCTIONS : General

curl() {
  #echo "Curl function being called"
  command curl ${CURL_OPTIONS} $@
}

#posix / helper functions
readlink_f () {
  local filename
  
  cd "$(dirname "$1")" > /dev/null
  filename="$(basename "$1")"
  if [ -h "${filename}" ]; then
    readlink_f "$(readlink "${filename}")"
  else
    echo "$(pwd -P)/${filename}"
  fi
}

epoch_time() {
  #http://stackoverflow.com/questions/2445198/get-seconds-since-epoch-in-any-posix-compliant-shell
  #PATH=`getconf PATH` awk 'BEGIN{srand();printf srand()}'
  PATH=$(getconf PATH) awk 'BEGIN{srand();printf srand()}'
}

exit_script() {
  # http://stackoverflow.com/questions/9893667/is-there-a-way-to-write-a-bash-function-which-aborts-the-whole-execution-no-mat
  if [ -n "$*" ]; then
    printf '%s\n' "$*" >&2
  fi
  kill -s TERM $TOP_PID
}

confirm() {
  local reply
  
  if [ ${ASSUME_YES} -eq 1 ] || ([ ${ASSUME_YES} -eq 0 ] && [ ${ASK_OVERWRITE} -eq 0 ]); then
    reply=""
    printf '%s [Y/N]: ' "$*"
    read reply
    if printf '%s\n' "${reply}" | grep -Eq '^[yY].*'; then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}

########################################################################
# HELPER FUNCTIONS: get-elixir

sanitize_release() {
  # remove any "../"
  # and after that remove "v" from the beginning 
  printf '%s' "$1" | sed -e 's@\.\./@@g' -e 's/^v//g'
}

sanitize_dir() {
  local dir
  
  # Removes trailing "/"
  # If the results its empty, it will echo "."
  dir=$(printf '%s' "$1" | sed -e 's@/\{1,\}$@@g')
  if [ "${dir}" = "" ]; then
    printf '.'
  else
    printf '%s' "${dir}"
  fi
}

get_latest_release() {
  local release
  
  release="$(curl -sfL "${ELIXIR_CSV_URL}" | sed '2q;d' | cut -d , -f1)"
  
  if [ "${release}" != "" ]; then 
    echo "${release}"
  else
    echo "* [ERROR] Latest Elixir release number couldn't be retrieved from ${ELIXIR_CSV_URL}" >&2
    return 1
  fi
}

get_elixir_final_releases() {
  local releases
  
  releases="$(curl -sfL "${ELIXIR_CSV_URL}" | tail -n +2 | cut -d , -f1)"
  
  if [ "${releases}" != "" ]; then
    echo "${releases}"
  else
    echo "* [ERROR] Elixir's final release numbers couldn't be retrieved from" >&2
    echo "  ${ELIXIR_CSV_URL}" >&2
    return 1
  fi
}

get_elixir_releases() {
  local releases
  
  releases="$(curl -sfL "${APP_RELEASES_JSON_URL}" | grep "tag_name" | \
                    cut -d':' -f2 | sed -e 's@ \{1,\}"@@g' -e 's@\",@@g')"
  if [ "${releases}" != "" ]; then
    echo "${releases}"
  else
    echo "* [ERROR] Elixir release numbers couldn't be retrieved from" >&2
    echo "  ${APP_RELEASES_JSON_URL}" >&2
    return 1
  fi
}

get_latest_script_version() {
  local release
  
  release="$(curl -sfI "${APP_RELEASES_URL}/latest" |  grep "Location: " | \
                   tr '\r' '\0' | tr '\n' '\0' | rev | cut -d'/' -f1 | rev)"
  if [ "${release}" != "" ]; then
    sanitize_release "${release}"
  else
    echo "* [ERROR] Latest ${APP_NAME} release number couldn't be retrieved from" >&2
    echo "  ${APP_RELEASES_URL}" >&2
    return 1
  fi
}

get_message_downloaded() {
  case "$1" in
    source)
      if [ ${USED_EXISTING_SOURCE} -eq 0 ]; then
        echo "Existing copy"
      else
        echo "Downloaded"
      fi
      ;;

    binaries)
      if [ ${USED_EXISTING_BINARIES} -eq 0 ]; then
        echo "Existing copy"
      else
        echo "Downloaded"
      fi
      ;;

    script)
      if [ ${USED_EXISTING_SCRIPT} -eq 0 ]; then
        echo "Existing copy"
      else
        echo "Downloaded"
      fi
      ;;
  esac
}

########################################################################
# PERMISSION RELATED FUNCTIONS

check_permissions() {
  case "${COMMAND}" in
    download|unpack)
      check_dir_write_permisions "${DIR}" ||
        return 1
      check_dir_write_permisions "${KEEP_DIR}" ||
        return 1
      return 0
    ;;
    download-script)
      check_dir_write_permisions "${KEEP_DIR}" ||  # <-- It will create a dir if it doesn't exit
        return 1
      if [ -f "${KEEP_DIR}/get-elixir.sh" ]; then
        check_file_write_permisions "${KEEP_DIR}/get-elixir.sh" ||
          return 1
      fi
      return 0
    ;;
    update-script)
      check_file_write_permisions "${SELF}" ||
        return 1
      return 0
    ;;
    *)
      echo "* Unknown command: ${COMMAND}" >&2
      return 1
    ;;
  esac
}

check_dir_write_permisions() {
  local dir
  dir="$1"
  
  mkdir -p "${dir}" 2> /dev/null
  if [ $? -eq 0 ]; then
    if [ -w "${dir}" ]; then
      return 0
    else
      echo "* [ERROR] Cannot write to directory: ${dir}: Permission denied" >&2
      return 1
    fi
  else 
    echo "* [ERROR] Cannot create directory: ${dir}: Permission denied" >&2
    return 1
  fi
}

check_file_write_permisions() {
  local file
  file="$1"

  if [ -w "${file}" ]; then
    return 0
  else
    echo "* [ERROR] Cannot write to file: ${file}: Permission denied" >&2
    return 1
  fi
}

########################################################################
# CONFIGURATION FUNCTIONS

superseed_options() {
  if [ ${ASSUME_YES} -eq 0 ]; then
    ASK_OVERWRITE=1
  fi
}

set_download_command_options() {
  if [ ${SILENT_DOWNLOAD} = 0 ]; then
    DOWNLOAD_COMMAND_OPTIONS="${DOWNLOAD_COMMAND_OPTIONS} -s"
  fi
}

get_unpack_verbose_option() {
  case "$1" in 
    unzip)
      if [ ${VERBOSE_UNPACK} -eq 0 ]; then
        printf ''
      else
        printf '%s' '-q'
      fi
      ;;

    tar)
      if [ ${VERBOSE_UNPACK} -eq 0 ]; then
        printf '%s' '-v'
      else
        printf ''
      fi
      ;;

    cp)
      if [ ${VERBOSE_UNPACK} -eq 0 ]; then
        printf '%s' '-v'
      else
        printf ''
      fi
      ;;
  esac
  return 0
}

get_unpack_overwrite_option() {
  case "$1" in 
    unzip)
      if [ ${ASK_OVERWRITE} -eq 0 ]; then
        printf ''
      else
        printf '%s' '-o'
      fi
      ;;

    tar)
      if [ ${ASK_OVERWRITE} -eq 0 ]; then
        printf '%s' '-k'
      else
        printf ''
      fi
      ;;

    cp)
      if [ ${ASK_OVERWRITE} -eq 0 ]; then
        printf '%s' '-i'
      else
        printf '%s' '-f'
      fi
      ;;
  esac
  return 0
}

########################################################################
# MAIN FUNCTIONS

download_source() {
  local release file_name url
  release="$1"
  file_name="v${release}.tar.gz"
  url="https://github.com/elixir-lang/elixir/archive/${file_name}"

if [ -f "${KEEP_DIR}/${file_name}" ]; then
  confirm "* You are about to replace '${KEEP_DIR}/${file_name}'.
  [Y] to download and replace file / [N] to skip downloading and use existing file.
  Please Confirm"

  if [ $? -ne 0 ]; then
    echo "* Using local file."
    USED_EXISTING_SOURCE=0
    return 0
  fi
fi

  echo "* Downloading ${url}"
  curl ${DOWNLOAD_COMMAND_OPTIONS} -o "${KEEP_DIR}/${file_name}" "${url}"
  if [ ! -f "${KEEP_DIR}/${file_name}" ]; then
    echo "* [ERROR] Elixir v${RELEASE} could not be downloaded from ${url}" >&2
    if [ "${RELEASE}" != "${DEFAULT_RELEASE}" ]; then
    echo "          For a list of releases, run:" >&2
    echo "          ${APP_COMMAND} --list-releases" >&2
    fi
    return 1
  fi
  return 0
}

download_binaries() {
  local release file_name url
  
  release="$1"
  file_name="Precompiled-v${release}.zip"
  url="https://github.com/elixir-lang/elixir/releases/download/v${release}/Precompiled.zip"

if [ -f "${KEEP_DIR}/${file_name}" ]; then
  confirm "* You are about to replace '${KEEP_DIR}/${file_name}'.
  Do you confirm?"

  if [ $? -ne 0 ]; then
    echo "* Using local file."
    USED_EXISTING_BINARIES=0
    return 0
  fi
fi

  echo "* Downloading ${url}"
  curl ${DOWNLOAD_COMMAND_OPTIONS} -o "${KEEP_DIR}/${file_name}" "${url}"
  if [ ! -f "${KEEP_DIR}/${file_name}" ]; then
    echo "* [ERROR] Elixir v${RELEASE} could not be downloaded from ${url}" >&2
    if [ "${RELEASE}" != "${DEFAULT_RELEASE}" ]; then
    echo "          For a list of releases, run:" >&2
    echo "          ${APP_COMMAND} --list-releases" >&2
    fi
    return 1
  fi
  return 0
}

unpack_source() {
  local release dir file_name verbose_tar overwrite_tar overwrite_cp tmp_dir
  
  release="$1"
  dir="$2"
  file_name="v${release}.tar.gz"
  verbose_tar="$(get_unpack_verbose_option tar)"
  overwrite_tar="$(get_unpack_overwrite_option tar)"
  overwrite_cp="$(get_unpack_overwrite_option cp)"
  tmp_dir="/tmp/${APP_NAME}-$(epoch_time)"

  mkdir -p "${dir}" &&
  mkdir -p "${tmp_dir}" &&
  #echo tar -C "${tmp_dir}" ${verbose_tar} ${overwrite_tar} -xz -f "${KEEP_DIR}/${file_name}" && 
  tar -C "${tmp_dir}" ${verbose_tar} ${overwrite_tar} -xz -f "${KEEP_DIR}/${file_name}" && 
  #echo "cp -r ${overwrite_cp} ${tmp_dir}/elixir-${release}/*" "${dir}" &&
  cp -r ${overwrite_cp} "${tmp_dir}/elixir-${release}"/* "${dir}"

  if [ $? -ne 0 ]; then
    echo "* [ERROR] \"${KEEP_DIR}/${file_name}\" could not be unpacked to ${dir}" >&2
    echo "          Check the file permissions or for a tar.gz corrupt file." >&2
    return 1
  fi
  
  rm -rf "${tmp_dir}"
}

unpack_binaries() {
  local release dir file verbose_unzip overwrite_unzip
  
  release="$1"
  dir="$2"
  file="Precompiled-v${release}.zip"
  verbose_unzip="$(get_unpack_verbose_option unzip)"
  overwrite_unzip="$(get_unpack_overwrite_option unzip)"
  
  mkdir -p "${dir}" && 
  #echo unzip ${verbose_unzip} ${overwrite_unzip} -d "${dir}" "${file}" &&
  unzip ${verbose_unzip} ${overwrite_unzip} -d "${dir}" "${file}"
  
  if [ $? -ne 0 ]; then
    echo "* [ERROR] \"${file}\" could not be unpacked to ${dir}" >&2
    echo "          Check the file permissions." >&2
    return 1
  fi
}

do_download_script() {
  local remote_script_url local_dest
  remote_script_url="$1"
  local_dest="$2"

  curl ${DOWNLOAD_COMMAND_OPTIONS} -o "${local_dest}" "${remote_script_url}"
  if [ $? -ne 0 ] || [ ! -f "${local_dest}" ]; then
    echo "* [ERROR] ${APP_NAME} could not be downloaded from" >&2
    echo "          ${remote_script_url}" >&2
    return 1
  fi
  return 0
}

download_script() {
  local latest_script_version file_name remote_script_url
  
  echo "* Retrieving latest ${APP_NAME} release number..."
  latest_script_version=$(get_latest_script_version)
  test -z "${latest_script_version}" &&
    return 1
  file_name="get-elixir.sh"
  remote_script_url="${APP_URL}/raw/v${latest_script_version}/${file_name}"

if [ -f "${KEEP_DIR}/${file_name}" ]; then
  confirm "* You are about to replace '${KEEP_DIR}/${file_name}'.
  Do you confirm?"

  if [ $? -ne 0 ]; then
    echo "* Using local file."
    USED_EXISTING_SCRIPT=0
    return 0
  fi
fi

  echo "* Downloading ${remote_script_url}"
  do_download_script "${remote_script_url}" "${KEEP_DIR}/${file_name}" ||
    return 1
  return 0
}

update_script() {
  local latest_script_version remote_script_url

  echo "* Retrieving latest ${APP_NAME} release number..."
  latest_script_version=$(get_latest_script_version)
  test -z "${latest_script_version}" &&
    return 1
  remote_script_url="${APP_URL}/raw/v${latest_script_version}/get-elixir.sh"
  
if [ "${latest_script_version}" != "${APP_VERSION}" ]; then
  confirm "* You are about to replace '${SELF}'.
  Current version: ${APP_VERSION} / Remote version:  ${latest_script_version}
  Do you confirm?"

  if [ $? -eq 0 ]; then
    do_download_script "${remote_script_url}" "${SELF}" ||
      return 1
    chmod +x "${local_dest}"
    echo "* [OK] ${APP_NAME} succesfully updated."
  else
    echo "* Updating script has been cancelled."
    return 1
  fi
else
  echo "* [OK] ${APP_COMMAND} is already the newest version."
  return 0
fi
}

########################################################################
# Main functions

do_parse_options() {
  local POS SKIP
  
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
      --verbose-unpack)
          VERBOSE_UNPACK=0
          ;;
      --ask-overwrite)
          ASK_OVERWRITE=0
          ;;
      --download-script)
          COMMAND="download-script"
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
          elif [ "${PACKAGE_TYPE}" = "source" ]; then
            PACKAGE_TYPE="binaries_source"
          fi
          ;;
      -r|--release)
          POS=$((POS + 1))
          eval "RELEASE=\${$POS}"
          RELEASE="$(sanitize_release "${RELEASE}")"
          ;;
      -d|--dir)
          POS=$((POS + 1))
          eval "DIR=\${$POS}"
          # expand dir
          eval "DIR=${DIR}"
          DIR="$(sanitize_dir "${DIR}")"
          ;;
      -k|--keep-dir)
          POS=$((POS + 1))
          eval "KEEP_DIR=\${$POS}"
          # expand dir
          eval "KEEP_DIR=${KEEP_DIR}"
          KEEP_DIR="$(sanitize_dir "${KEEP_DIR}")"
          ;;
      *)
          # TODO: break on unrecognized option
          eval "local option=\${$POS}"
          echo "* [ERROR] Unrecognized option ${option}" >&2
          return 1
          break
          ;;
    esac
    POS=$((POS + SKIP))
  done
}

do_setup_options() {
  do_parse_options "$@" ||
    return 1
  superseed_options ||
    return 1
  set_download_command_options ||
    return 1
}

do_main() {
  # Show short_help if no options provided
  if [ $# = 0 ]; then
    short_help >&2
    exit 1
  fi

  # set all variables
  do_setup_options "$@" ||
    exit 1

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
    download-script)
      check_permissions "${COMMAND}" ||
        exit 1

      download_script ||
        exit 1

      local downloaded_script
      downloaded_script=$(get_message_downloaded "script")
      echo "* [OK] ${downloaded_script}: ${KEEP_DIR}/get-elixir.sh"
      return 0
    ;;
    update-script)
      check_permissions "${COMMAND}" ||
        exit 1

      update_script
      return 0
    ;;
    list-releases)
      get_elixir_releases ||
        exit 1
      return 0
    ;;
    list-final-releases)
      get_elixir_final_releases ||
        exit 1
      return 0
    ;;
  esac

  # Check for needed commands
  if [ "${PACKAGE_TYPE}" = "" ]; then
    echo "* [ERROR] Unrecognized package type. Try '--binaries' or '--source'." >&2
    exit 1
  fi

  # we check permissions before doing any http request
  check_permissions "${COMMAND}" ||
    exit 1
  
  # Get latest release if needed
  if [ "${RELEASE}" = "latest" ]; then
    echo "* Retrieving latest Elixir release number..."
    RELEASE=$(get_latest_release)
    test -z "${RELEASE}" &&
      exit 1
  fi

  # Define variables based on $RELEASE
  #ELIXIR_RELEASE_TAG_URL="https://github.com/elixir-lang/elixir/releases/tag/v${RELEASE}"
  ELIXIR_TREE_URL="https://github.com/elixir-lang/elixir/tree/v${RELEASE}"

  # Do our logic
  local downloaded_binaries downloaded_source
  case "${COMMAND}" in
    download)
      case "${PACKAGE_TYPE}" in
        "binaries")
          download_binaries "${RELEASE}" ||
            exit 1
          
          downloaded_binaries=$(get_message_downloaded "binaries")
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       ${downloaded_binaries}: ${KEEP_DIR}/Precompiled-v${RELEASE}.zip"
        ;;

        source)
          download_source "${RELEASE}" ||
            exit 1
          
          downloaded_source=$(get_message_downloaded "source")
          echo "* [OK] Elixir v${RELEASE} [source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       ${downloaded_source}: ${KEEP_DIR}/v${RELEASE}.tar.gz"
        ;;

        binaries_source)
          download_binaries "${RELEASE}" ||
            exit 1
          download_source "${RELEASE}" ||
            exit 1

          downloaded_binaries=$(get_message_downloaded "binaries")
          downloaded_source=$(get_message_downloaded "source")
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries & source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       ${downloaded_binaries}: ${KEEP_DIR}/Precompiled-v${RELEASE}.zip"
          echo "       ${downloaded_source}: ${KEEP_DIR}/v${RELEASE}.tar.gz"
        ;;
      esac
    ;;

    "unpack")
      case "${PACKAGE_TYPE}" in
        "binaries")
          download_binaries "${RELEASE}" ||
            exit 1
          unpack_binaries "${RELEASE}" "${DIR}" ||
            exit 1
          
          downloaded_binaries=$(get_message_downloaded "binaries")
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       ${downloaded_binaries}: ${KEEP_DIR}/Precompiled-v${RELEASE}.zip"
          echo "       Unpacked: ${DIR}/"
        ;;

        "source")
          download_source "${RELEASE}" ||
            exit 1
          unpack_source "${RELEASE}" "${DIR}" ||
            exit 1
          
          downloaded_source=$(get_message_downloaded "source")
          echo "* [OK] Elixir v${RELEASE} [Source]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       ${downloaded_source}: ${KEEP_DIR}/v${RELEASE}.tar.gz"
          echo "       Unpacked: ${DIR}/"
        ;;

        "binaries_source")
          download_binaries "${RELEASE}" ||
            exit 1
          unpack_binaries "${RELEASE}" "${DIR}" ||
            exit 1 
          download_source "${RELEASE}" ||
            exit 1
          unpack_source "${RELEASE}" "${DIR}" ||
            exit 1

          downloaded_binaries=$(get_message_downloaded "binaries")
          downloaded_source=$(get_message_downloaded "source")
          echo "* [OK] Elixir v${RELEASE} [precompiled binaries & source code]"
          echo "       ${ELIXIR_TREE_URL}"
          echo "       ${downloaded_binaries}: ${KEEP_DIR}/Precompiled-v${RELEASE}.zip"
          echo "       ${downloaded_source}: ${KEEP_DIR}/v${RELEASE}.tar.gz"
          echo "       Unpacked: ${DIR}/"
        ;;
      esac
      ;;
  esac
}

do_instantiate_vars

# Note: This is the only easy way I found that it is 
# possible to find out whether the file is being
# sourced by other script, or exectuted directedly.
# So, if you ever want to source this scrpit, make sure the name of your calling
# file is the same as this one.

SCRIPT_CALLED="$(basename "$0")"
SCRIPT_SOURCED="$(basename ${APP_COMMAND})"
if [ "${SCRIPT_CALLED}" = "${SCRIPT_SOURCED}" ]; then
  do_main "$@"
  exit 0
fi
