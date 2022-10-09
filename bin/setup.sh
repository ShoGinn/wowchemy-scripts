#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./functions/core.sh
source "${__dir}"/functions/core.sh

function _add_packages() {
    __dev_packages=(
        rimraf
        npm-run-all
        cross-env
    )
    info "Adding the required dev packages: ${__dev_packages[*]}"

    for __item in "${__dev_packages[@]}"; do
        debug "Adding ${__item}"
        npm install "$__item" --save-dev >>/dev/null
    done
}
function add_package_scripts() {
    _add_packages
    info "Setting up the npm scripts!"
    npm pkg set scripts.clean:hugo="rimraf hugo{.log,_stats.json} resources public assets/jsconfig.json .hugo_build.lock _vendor"
    npm pkg set scripts.serve="run-p serve:hugo"
    npm pkg set scripts.start:hugo="./bin/build/hugo.sh"
    npm pkg set scripts.serve:hugo="cross-env SHOGINN_SCRIPTS_SERVE_HUGO=1 run-p start:hugo"
    npm pkg set scripts.build:hugo="cross-env SHOGINN_SCRIPTS_BUILD_HUGO=1 run-s clean:hugo start:hugo"
}

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export REQUIRED_TOOLS=(
        npm
    )
    info "Loading NPM Package Setup functions."
    required_tools "NPM Functions"
else
    add_package_scripts
    exit ${?}
fi
