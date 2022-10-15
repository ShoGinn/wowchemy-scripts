#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency
NO_COLOR="${NO_COLOR:-}"    # true = disable color. otherwise autodetected
__GIT_NAME="https://github.com/ShoGinn/wowchemy-scripts"
__DESTINATION_FOLDER="shoginn_scripts/"
__SETUP_FILE="${PWD}/${__DESTINATION_FOLDER}bin/setup.sh"

### Functions
##############################################################################

function __b3bp_log() {
    local log_level="${1}"
    shift

    # shellcheck disable=SC2034
    local color_debug="\\x1b[35m"
    # shellcheck disable=SC2034
    local color_info="\\x1b[32m"
    # shellcheck disable=SC2034
    local color_notice="\\x1b[34m"
    # shellcheck disable=SC2034
    local color_warning="\\x1b[33m"
    # shellcheck disable=SC2034
    local color_error="\\x1b[31m"
    # shellcheck disable=SC2034
    local color_critical="\\x1b[1;31m"
    # shellcheck disable=SC2034
    local color_alert="\\x1b[1;37;41m"
    # shellcheck disable=SC2034
    local color_emergency="\\x1b[1;4;5;37;41m"

    local colorvar="color_${log_level}"

    local color="${!colorvar:-${color_error}}"
    local color_reset="\\x1b[0m"

    if [[ "${NO_COLOR:-}" = "true" ]] || { [[ "${TERM:-}" != "xterm"* ]] && [[ "${TERM:-}" != "screen"* ]]; } || [[ ! -t 2 ]]; then
        if [[ "${NO_COLOR:-}" != "false" ]]; then
            # Don't use colors on pipes or non-recognized terminals
            color=""
            color_reset=""
        fi
    fi

    # all remaining arguments are to be printed
    local log_line=""

    while IFS=$'\n' read -r log_line; do
        echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" "${log_level}")${color_reset} ${log_line}" 1>&2
    done <<<"${@:-}"
}

function emergency() {
    __b3bp_log emergency "${@}"
    exit 1
}
function alert() {
    [[ "${LOG_LEVEL:-0}" -ge 1 ]] && __b3bp_log alert "${@}"
    true
}
function critical() {
    [[ "${LOG_LEVEL:-0}" -ge 2 ]] && __b3bp_log critical "${@}"
    true
}
function error() {
    [[ "${LOG_LEVEL:-0}" -ge 3 ]] && __b3bp_log error "${@}"
    true
}
function warning() {
    [[ "${LOG_LEVEL:-0}" -ge 4 ]] && __b3bp_log warning "${@}"
    true
}
function notice() {
    [[ "${LOG_LEVEL:-0}" -ge 5 ]] && __b3bp_log notice "${@}"
    true
}
function info() {
    [[ "${LOG_LEVEL:-0}" -ge 6 ]] && __b3bp_log info "${@}"
    true
}
function debug() {
    [[ "${LOG_LEVEL:-0}" -ge 7 ]] && __b3bp_log debug "${@}"
    true
}

### Signal trapping and backtracing
##############################################################################
if [[ "${TEST:-}" ]]; then
    LOG_LEVEL=7
    notice "Running in Test Mode (Local)"
fi

function required_tools() {
    if [[ -n ${REQUIRED_TOOLS[0]+x} ]]; then
        if [[ -z ${__internal_tool+x} ]]; then
            info "Checking for the required tools necessary to ${*}"
        fi
        for __tool in "${REQUIRED_TOOLS[@]}"; do
            if ! command -v "${__tool}" >/dev/null; then
                emergency "${__tool} is required... "
            fi
        done
    fi
}
REQUIRED_TOOLS=(
    curl
    sed
    grep
    git
    mktemp
)
required_tools "Install Scripts"

if [[ "${TEST:-}" ]]; then
    __GIT_TEMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    __GIT_TEMP_DIR="$(mktemp -d)"
    function __b3bp_cleanup_before_exit() {
        if [[ -d "${__GIT_TEMP_DIR}" ]]; then
            debug "Deleting ${__GIT_TEMP_DIR}"
            rm -rf "${__GIT_TEMP_DIR}"
        fi
        info "Cleaning up. Done"
    }
    trap __b3bp_cleanup_before_exit EXIT

fi

### Validation. Error out if the things required for your script are not present
##############################################################################

[[ "${LOG_LEVEL:-}" ]] || emergency "Cannot continue without LOG_LEVEL. "

### Runtime
##############################################################################

__git_clone() {
    info "Cloning the Repo"
    git clone -q ${__GIT_NAME%.git}.git "${__GIT_TEMP_DIR}"
    git --git-dir="${__GIT_TEMP_DIR}"/.git -c advice.detachedHead=false checkout -q main
}
__run_script() {
    # Create a temporary directory and store its name in a variable.
    # Copy the Files
    if [[ ! "${TEST:-}" ]]; then
        __git_clone
    fi
    if [[ -d "${__GIT_TEMP_DIR:-}" ]]; then
        mkdir -p "${__DESTINATION_FOLDER}"
        cp -R "${__GIT_TEMP_DIR}"/src/bin "${__DESTINATION_FOLDER}"
    else
        emergency "Temp Dir does not exist! Report this!"
    fi
    if [[ "${CI:-}" ]]; then
        debug "CI no workflows!"
    else
        cp -R "${__GIT_TEMP_DIR}"/src/.github ./
    fi
    if [[ ! "${CI:-}" ]]; then
        info "Scripts are installed!"
        notice "************************************************************"
        notice "Workflows are only installed initially and not auto-updated!"
        notice "************************************************************"
        notice "To Fully install the script you must run: ${__SETUP_FILE}"
        warning "Automatically installing the script in 5 seconds!!!"
        sleep 5
    fi
    "${__SETUP_FILE}"
}

__run_script
