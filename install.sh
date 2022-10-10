#!/usr/bin/env bash
# This file:
#
#  - Demos BASH3 Boilerplate (change this for your script)
#
# Usage:
#
#  LOG_LEVEL=7 ./main.sh -f /tmp/x -d (change this for your script)
#
# Based on a template by BASH3 Boilerplate v2.4.1
# http://bash3boilerplate.sh/#authors
#
# The MIT License (MIT)
# Copyright (c) 2013 Kevin van Zonneveld and contributors
# You are not obligated to bundle the LICENSE file with your b3bp projects as long
# as you leave these references intact in the header comments of your source files.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# Define the environment variables (and their defaults) that this script depends on
LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency
NO_COLOR="${NO_COLOR:-}"    # true = disable color. otherwise autodetected

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

function help() {
    echo "" 1>&2
    echo " ${*}" 1>&2
    echo "" 1>&2
    echo "  ${__usage:-No usage available}" 1>&2
    echo "" 1>&2

    if [[ "${__helptext:-}" ]]; then
        echo " ${__helptext}" 1>&2
        echo "" 1>&2
    fi

    exit 1
}

### Signal trapping and backtracing
##############################################################################

function __b3bp_cleanup_before_exit() {
    info "Cleaning up. Done"
}
trap __b3bp_cleanup_before_exit EXIT

function required_tools() {
    if [[ -n ${REQUIRED_TOOLS[0]+x} ]]; then
        if [[ -z ${__internal_tool+x} ]]; then
            info "Checking for the required tools necessary to ${*}"
        fi
        for __tool in "${REQUIRED_TOOLS[@]}"; do
            if ! command -v "${__tool}" >/dev/null; then
                warning "${__tool} is required... "
                exit 1
            fi
        done
    fi
}
REQUIRED_TOOLS=(
    curl
    sed
    grep
)
required_tools "Install Scripts"
### Validation. Error out if the things required for your script are not present
##############################################################################

[[ "${LOG_LEVEL:-}" ]] || emergency "Cannot continue without LOG_LEVEL. "

### Runtime
##############################################################################
__copy_file() {
    __temp_file_name="${1}"
    __temp_destination_name="${2}"
    debug "Checking if ${__temp_file_name} exists and copying to ${__temp_destination_name}"
    if [[ -e $__temp_file_name ]]; then
        cp "${__temp_file_name}" ./"${__temp_destination_name}"
    else
        error "Could not find $__temp_file_name"
        exit 1
    fi

}
__download_file() {
    __output_dir="${2}"
    debug "Downloading ${1} to ${__output_dir}"
    curl -fsSL "${1}" --output ./"${2}"

}
__run_script() {
    # Create a temporary directory and store its name in a variable.
    __git_name="https://github.com/ShoGinn/wowchemy-scripts/raw/main/"
    __make_dirs=(
        bin/build
        bin/etc
        bin/functions
        bin/netlify
        .github/workflows
    )
    __copy_files=(
        bin/setup.sh
        bin/build/hugo.sh
        bin/etc/.env.sample
        bin/etc/.replacements.template
        bin/etc/.netlify.template
        bin/functions/core.sh
        bin/functions/hugo.sh
        bin/functions/main.sh
        bin/netlify/update_hugo_version.sh
    )
    # Make the directories
    for __script_dir in "${__make_dirs[@]}"; do
        mkdir -p "${__script_dir}"
    done
    # Copy the Files
    for __script_file in "${__copy_files[@]}"; do
        __remote_file="${__git_name}""${__script_file}"
        __download_file "${__remote_file}" "${__script_file}"
        ext="${__script_file##*.}"
        if [[ $ext == "sh" ]]; then
            # __destination_file=./"${__script_file}"
            chmod +x "${__script_file}"
        fi
    done
    __workflow_files=(
        workflows/update_netlify.yml
        workflows/html_proof.yml
        workflows/release.yml
    )
    # Install the Github Workflows
    for __workflow_file in "${__workflow_files[@]}"; do
        __remote_file="${__git_name}""${__workflow_file}"
        __download_file "${__remote_file}" .github/"${__workflow_file}"
    done

    info "Scripts are installed!"
    notice "Please run the install script ${PWD}/bin/setup.sh"
}

__run_script
