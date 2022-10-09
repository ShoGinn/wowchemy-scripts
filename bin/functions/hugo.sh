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
    "${__scripts_hugo_cmd}" mod get -u ./...

    # tidy up modules
    "${__scripts_hugo_cmd}" mod tidy

}

function __module_replacements() {
    # create replacements via environment
    __not_first_line=false
    __hugo_module_replacements=""
    __replacements="${__dir}"/../etc/.replacements
    debug "${__replacements}"
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
        # shellcheck disable=SC2015
        [[ -n "${__hugo_module_replacements}" ]] && export HUGO_MODULE_REPLACEMENTS="${__hugo_module_replacements}" || info "No replacements found"
    fi
    debug "$(env | grep ^HUGO_MODULE)"
}
function __hugo_env() {
    info "Settings up the Hugo Environment"
    __hugo_args_indiv=()

    if [[ "${SHOGINN_SCRIPTS_HUGO_BASE_URL:-}" ]]; then
        info "Base URL Set to ${SHOGINN_SCRIPTS_HUGO_BASE_URL}"
        __hugo_args_indiv+=("--baseURL=${SHOGINN_SCRIPTS_HUGO_BASE_URL}")
    fi
    if [[ "${SHOGINN_SCRIPTS_HUGO_DEBUG:-}" ]]; then
        info "Debugging ON"
        __hugo_args_indiv+=("--debug")
    else
        info "Debugging OFF"
    fi
    if [[ "${SHOGINN_SCRIPTS_HUGO_VERBOSE:-true}" || "${SHOGINN_SCRIPTS_HUGO_DEBUG:-}" ]]; then
        info "Verbose ON"
        __hugo_verbose=(
            --templateMetrics
            --templateMetricsHints
            --printI18nWarnings
            --printMemoryUsage
            --printPathWarnings
            --printUnusedTemplates
            --verbose
            --verboseLog
        )
        __hugo_args+="${__hugo_verbose[*]}"
    else
        info "Verbose OFF"
    fi

    if [[ "${SHOGINN_SCRIPTS_SERVER_FUTURE:-}" ]]; then
        info "Future Posts ON"
        __hugo_args_indiv+=("--buildFuture")
    else
        info "Future Posts OFF"
    fi
    if [[ "${SHOGINN_SCRIPTS_SERVER_EXPIRED:-}" ]]; then
        info "Expired Posts ON"
        __hugo_args_indiv+=("--buildExpired")
    else
        info "Expired Posts OFF"
    fi
    if [[ "${SHOGINN_SCRIPTS_SERVER_DRAFTS:-}" ]]; then
        info "Draft Posts ON"
        __hugo_args_indiv+=("--buildDrafts")
    else
        info "Draft Posts OFF"
    fi
    if [[ "${SHOGINN_SCRIPTS_TEST:-}" ]]; then
        notice "Test Mode is on; Hugo commands will echo."
        export __scripts_hugo_cmd="info"
    else
        export __scripts_hugo_cmd="hugo"
    fi
    __hugo_args+=("${__hugo_args_indiv[@]}")
    export __hugo_args
    __module_replacements
}

function build_hugo() {
    # starting hugo server
    refresh_hugo
    __hugo_build_args=(
        --minify
        --cleanDestinationDir
        --enableGitInfo
        --log=true
        --logFile hugo.log
    )
    __hugo_args+=("${__hugo_build_args[@]}")
    # shellcheck disable=SC2068
    "${__scripts_hugo_cmd}" ${__hugo_args[@]}
}

function serve_hugo() {
    trap "{ echo 'Terminated with Ctrl+C'; }" SIGINT
    refresh_hugo
    __hugo_serve_args=(
        --environment development
        --disableFastRender
        --navigateToChanged
        --renderToDisk
        --watch
        --enableGitInfo
        --forceSyncStatic
        --port "${PORT:-1313}"
        --baseURL http://"${IP:-127.0.0.1}"
        --bind "${IP:-127.0.0.1}"
    )
    __hugo_args+=("${__hugo_serve_args[@]}")
    # starting hugo server
    # shellcheck disable=SC2068
    "${__scripts_hugo_cmd}" server ${__hugo_args[@]} 2>&1 | tee -a hugo.log

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
