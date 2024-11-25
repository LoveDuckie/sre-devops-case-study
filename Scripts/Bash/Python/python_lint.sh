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

PYTHON_PROJECT_PATH=$REPO_ROOT_PATH/Solutions/Python/link-extractor

pushd $PYTHON_PROJECT_PATH >/dev/null 2>&1

# Run pylint on the specified directory or file
poetry run pylint .

# Check if pylint completed successfully
if [ $? -eq 0 ]; then
  write_success "python_lint" "Pylint completed without any errors!"
else
  write_warning "python_lint" "Pylint detected issues. Please review the output for details."
  exit 1
fi

popd >/dev/null 2>&1

write_success "python_lint" "Done"
exit 0