#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

__helptext=false
__usage=false

# shellcheck source=main.sh
source "${__dir}"/main.sh

function refresh_hugo() {
    # cleanup hugo logging
    npm run clean:hugo

    # update modules
    hugo mod get -u ./...

    # tidy up modules
    hugo mod tidy

}

function __module_replacements() {
    # create replacements via environment
    __not_first_line=false
    __hugo_module_replacements=""
    __replacements="${__dir}"/../etc/.replacements
    debug ${__replacements}
    info "Checking for Module replacements."
    if test -f "${__replacements}"; then
        debug "Found some replacements"
        while read -ra __; do
            if $__not_first_line; then
                __hugo_module_replacements="${__hugo_module_replacements},${__[0]} -> ${__[1]}"
            else
                __hugo_module_replacements="${__[0]} -> ${__[1]}"
                __not_first_line=true
            fi
        done <"${__replacements}"
        [[ -n "${__hugo_module_replacements}" ]] && export HUGO_MODULE_REPLACEMENTS="${__hugo_module_replacements}" || info "No replacements found"
    fi
    debug "$(env | grep ^HUGO_MODULE)"
}
function __hugo_env() {
    info "Settings up the Hugo Environment"
    __hugo_base_url=""
    if [[ "${SHOGINN_SCRIPTS_HUGO_BASE_URL:-}" ]]; then
        info "Base URL Set to ${SHOGINN_SCRIPTS_HUGO_BASE_URL}"
        export __hugo_base_url="--baseURL=${SHOGINN_SCRIPTS_HUGO_BASE_URL}"
    fi
    __hugo_debug=""
    if [[ "${SHOGINN_SCRIPTS_HUGO_DEBUG:-}" ]]; then
        info "Debugging ON"
        export __hugo_debug="--debug"
    else
        info "Debugging OFF"
    fi
    __hugo_verbose=""
    if [[ "${SHOGINN_SCRIPTS_HUGO_VERBOSE:-true}" || "${SHOGINN_SCRIPTS_HUGO_DEBUG:-}" ]]; then
        info "Verbose ON"
        __hugo_verbose="--templateMetrics --templateMetricsHints"
        __hugo_verbose="${__hugo_verbose} --printI18nWarnings --printMemoryUsage --printPathWarnings --printUnusedTemplates"
        export __hugo_verbose="${__hugo_verbose} --verbose --verboseLog"
    else
        info "Verbose OFF"
    fi

    __server_future=""
    if [[ "${SHOGINN_SCRIPTS_SERVER_FUTURE:-}" ]]; then
        info "Future Posts ON"
        export __server_future="--buildFuture "
    else
        info "Future Posts OFF"
    fi
    __server_expired=""
    if [[ "${SHOGINN_SCRIPTS_SERVER_EXPIRED:-}" ]]; then
        info "Expired Posts ON"
        export __server_expired="--buildExpired "
    else
        info "Expired Posts OFF"
    fi
    __server_drafts=""
    if [[ "${SHOGINN_SCRIPTS_SERVER_DRAFTS:-}" ]]; then
        info "Draft Posts ON"
        export __server_drafts="--buildDrafts "
    else
        info "Draft Posts OFF"
    fi
    __scripts_test=""
    if [[ "${SHOGINN_SCRIPTS_TEST:-}" ]]; then
        notice "Test Mode is on; Hugo commands will echo."
        export __scripts_hugo_cmd="info"
    else
        export __scripts_hugo_cmd="hugo"
    fi
    __module_replacements
}

function build_hugo() {
    # starting hugo server
    "${__scripts_hugo_cmd}" \
        --minify \
        --cleanDestinationDir \
        --enableGitInfo \
        --log=true \
        --logFile hugo.log \
        "${__hugo_debug}" \
        "${__hugo_verbose}" \
        "${__hugo_base_url}"

}

function serve_hugo() {
    trap "{ echo 'Terminated with Ctrl+C'; }" SIGINT

    # starting hugo server
    "${__scripts_hugo_cmd}" server \
        --environment development \
        --disableFastRender \
        --navigateToChanged \
        --renderToDisk \
        "${__server_drafts}" \
        "${__server_future}" \
        "${__server_expired}" \
        "${__hugo_debug}" \
        "${__hugo_verbose}" \
        --watch \
        --enableGitInfo \
        --forceSyncStatic \
        --port "${PORT:-1313}" \
        --baseURL http://"${IP:-127.0.0.1}"/ \
        --bind "${IP:-127.0.0.1}" 2>&1 | tee -a hugo.log

}
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export REQUIRED_TOOLS=(
        hugo
        npm
        export
        trap
    )
    required_tools "Hugo Functions"
    info "Loading Hugo functions."
    __hugo_env
else

    exit ${?}
fi
