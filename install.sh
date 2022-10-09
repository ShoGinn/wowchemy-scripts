#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

### Parse commandline options
##############################################################################

# Commandline options. This defines the usage page, and is used to parse cli
# opts & defaults from. The parsing is unforgiving so be precise in your syntax
# - A short option must be preset for every long option; but every short option
#   need not have a long option
# - `--` is respected as the separator between options and arguments
# - We do not bash-expand defaults, so setting '~/app' as a default will not resolve to ${HOME}.
#   you can use bash variables to work around this (so use ${HOME} instead)

# shellcheck disable=SC2015
[[ "${__usage+x}" ]] || read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
  -i --install     Install the Wowchemy Scripts.
  -u --update      Update the Scripts the the Latest Version.
  -v               Enable verbose mode, print script as it is executed
  -d --debug       Enables debug mode
  -h --help        This page
EOF

# shellcheck disable=SC2015
[[ "${__helptext+x}" ]] || read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
 This is the install script for the wowchemy set of helper scripts
EOF

# shellcheck source=./bin/functions/main.sh
source "${__dir}"/bin/functions/main.sh

### Signal trapping and backtracing
##############################################################################

function __b3bp_cleanup_before_exit() {
    info "Cleaning up. Done"
}
trap __b3bp_cleanup_before_exit EXIT

# requires `set -o errtrace`
__b3bp_err_report() {
    local error_code=${?}
    error "Error in ${__file} in function ${1} on line ${2}"
    exit ${error_code}
}

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
    curl --silent -LJ "${1}" --output ./"${2}"

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

    # Install the Github Workflow
    __download_file "${__git_name}"/workflows/update_netlify.yml .github/workflows/update_netlify.yml

    info "Scripts are installed!"
    notice "Please run the install script ${PWD}/bin/setup.sh"
}

### Command-line argument switches (like -d for debugmode, -h for showing helppage)
##############################################################################
# debug mode
if [[ "${arg_d:?}" = "1" ]]; then
    set -o xtrace
    PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    LOG_LEVEL="7"
    # Enable error backtracing
    trap '__b3bp_err_report "${FUNCNAME:-.}" ${LINENO}' ERR
fi

# verbose mode
if [[ "${arg_v:?}" = "1" ]]; then
    set -o verbose
fi

# help mode
if [[ "${arg_h:?}" = "1" ]]; then
    # Help exists with code 1
    help "Help using ${0}"
fi

if [[ "${arg_i:?}" = "1" ]]; then
    notice Installing the scripts to "${PWD}"/
    __run_script

fi
if [[ "${arg_u:?}" = "1" ]]; then
    notice updating
    info "${__dir}"
fi
