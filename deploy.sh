#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Deploy \ Image



EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/Scripts/Bash)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

COMMANDS_REQUIRED=(helm helmfile kubectl docker)

for command in ${COMMANDS_REQUIRED[@]}; do
    if ! is_command_available $command; then
        write_error "deploy" "Failed: \"$command\" is not installed or available on this system."
        exit 1
    fi
done

if ! is_valid_docker_image "link-extractor"; then
    write_warning "deploy" "Failed: Unable to find container image \"link-extractor\"."
    write_warning "deploy" "Attempting to build \"link-extractor\"..."
    $CURRENT_SCRIPT_DIRECTORY/build.sh
fi

write_info "deploy" "Deploying Helm Charts"
helmfile sync

write_success "deploy" "Done"
exit 0