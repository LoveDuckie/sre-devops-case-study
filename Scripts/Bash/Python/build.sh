#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Python \ Build

   Build and package the Python application

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

write_info "build" "$REPO_ROOT_PATH"

if ! is_command_available poetry; then
    write_error "build" "Poetry is not installed on this system. Unable to continue."
    exit 1
fi

pushd $REPO_ROOT_PATH/Solutions/Python/link-extractor >/dev/null 2>&1



popd >/dev/null 2>&1

write_success "build" "Done"
exit 0