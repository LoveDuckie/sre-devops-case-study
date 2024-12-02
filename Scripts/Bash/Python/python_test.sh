#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Python \ Test

   Run the tests for the Link Extractor packaged application

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

PYTHON_PROJECT_PATH=$REPO_ROOT_PATH/Solutions/Python/link-extractor

if [ ! -d "$PYTHON_PROJECT_PATH" ]; then
    write_error "python_test" "Failed: Unable to find the path \"$PYTHON_PROJECT_PATH\""
fi

pushd $PYTHON_PROJECT_PATH >/dev/null 2>&1

write_info "python_test" "Running unit tests"
poetry run coverage run --source=. -m unittest discover -s .

# Check if the tests passed
if [ $? -eq 0 ]; then
    write_success "python_test" "Unit tests passed."
else
    write_error "python_test" "Some unit tests failed. Please review the errors."
    exit 1
fi

# Generate coverage report
write_info "python_test" "Generating coverage report..."
coverage report -m

write_info "python_test" "Generating HTML report..."=
coverage html

write_success "python_test" "Coverage report generated. Open 'htmlcov/index.html' to view the detailed report."

write_success "python_test" "Done"
exit 0