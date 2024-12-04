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

if ! is_command_available poetry; then
    write_error "python_build" "Poetry is not installed on this system. Unable to continue."
    exit 1
fi

if [ -d "$PYTHON_PROJECT_PATH/dist" ]; then
   write_warning "python_build" "Cleaning: \"$PYTHON_PROJECT_PATH/dist\""
   rm -rf "$PYTHON_PROJECT_PATH/dist"
fi

write_info "python_build" "Installing Dependencies: \"$PYTHON_PROJECT_PATH\""
poetry -C "$PYTHON_PROJECT_PATH" install
if ! write_response "python_build" "Install Dependencies: $PYTHON_PROJECT_PATH"; then
   write_error "python_build" "Failed: Unable to build \"$PYTHON_PROJECT_PATH\""
   exit 1
fi


write_info "python_build" "Building: \"$PYTHON_PROJECT_PATH\""
poetry -C "$PYTHON_PROJECT_PATH" build 
if ! write_response "python_build" "Build: $PYTHON_PROJECT_PATH"; then
   write_error "python_build" "Failed: Unable to build \"$PYTHON_PROJECT_PATH\""
   exit 1
fi

write_success "python_build" "Done"
exit 0