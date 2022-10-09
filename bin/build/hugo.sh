#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=../functions/core.sh
source "${__dir}"/../functions/core.sh

# refresh_hugo
# shellcheck source=../functions/hugo.sh
source "${__dir}"/../functions/hugo.sh

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    warning "Don't source this code."
else
    info "Starting Hugo"
    start_hugo

    exit ${?}
fi
