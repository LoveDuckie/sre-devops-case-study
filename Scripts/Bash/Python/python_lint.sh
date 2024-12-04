#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Python \ Lint

   Lint the Python project.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

if [ ! -d "$PYTHON_PROJECT_PATH" ]; then
    write_error "python_lint" "Failed: Unable to find the path \"$PYTHON_PROJECT_PATH\""
    exit 1
fi

pushd $PYTHON_PROJECT_PATH >/dev/null 2>&1

write_info "python_lint" "Installing dependencies..."
poetry -C "$PYTHON_PROJECT_PATH" install
if ! write_response "python_lint" "Install Dependencies: $PYTHON_PROJECT_PATH"; then
   write_error "python_lint" "Failed: Unable to install the dependencies \"$PYTHON_PROJECT_PATH\""
   exit 1
fi

write_info "python_lint" "Linting: \"$PYTHON_PROJECT_PATH\""
poetry -C "$PYTHON_PROJECT_PATH" run pylint --fail-under=8.0 .
if write_response "python_lint" "Lint: \"$PYTHON_PROJECT_PATH\""; then
  write_success "python_lint" "Linting passed with a score >= 8.0!"
else
  write_error "python_lint" "Linting failed with a score below 8.0."
  exit 1
fi

popd >/dev/null 2>&1

write_success "python_lint" "Done"
exit 0
