#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=../functions/core.sh
source "${__dir}"/../functions/core.sh
# shellcheck source=../functions/hugo.sh
source "${__dir}"/../functions/hugo.sh

# refresh_hugo
if [[ ${SHOGINN_SCRIPTS_BUILD_HUGO:-} || ${SHOGINN_SCRIPTS_SERVE_HUGO:-} ]]; then
    if [[ ${SHOGINN_SCRIPTS_BUILD_HUGO:-} ]]; then
        build_hugo
    fi

    if [[ ${SHOGINN_SCRIPTS_SERVE_HUGO:-} ]]; then
        serve_hugo
    fi
else
    error "You never specified what type of hugo to run!"
fi
