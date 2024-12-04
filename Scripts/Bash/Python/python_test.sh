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

if [ ! -d "$PYTHON_PROJECT_PATH" ]; then
    write_error "python_test" "Failed: Unable to find the path \"$PYTHON_PROJECT_PATH\""
    exit 1
fi

pushd "$PYTHON_PROJECT_PATH" >/dev/null 2>&1

write_info "run_tests" "Install Dependencies: \"$PYTHON_PROJECT_PATH\""
poetry -C "$PYTHON_PROJECT_PATH" install
if ! write_response "run_tests" "Install Dependencies: $PYTHON_PROJECT_PATH"; then
    write_error "run_tests" "Failed: Unable to install the dependencies \$$PYTHON_PROJECT_PATH\""
    exit 1
fi

write_info "run_tests" "Running unit tests with \"coverage\"."
poetry -C "$PYTHON_PROJECT_PATH" run coverage run -m unittest discover -s link_extractor_tests -p "*.py" || { echo "Tests failed"; exit 1; }
if ! write_response "run_lint" "Run Coverage: Unit tests"; then
    write_error "run_lint" "Failed: Unable to run unit tests."
    exit 2
fi

write_info "run_tests" "Generating coverage report..."
poetry -C "$PYTHON_PROJECT_PATH" run coverage report -m
if ! write_response "run_tests" "Run Unit Tests: $PYTHON_PROJECT_PATH"; then
    write_error "run_tests" "Failed: Unable to run the unit tests \$$PYTHON_PROJECT_PATH\""
    exit 3
fi

write_info "run_tests" "Generating HTML report..."
poetry -C "$PYTHON_PROJECT_PATH" run coverage html
if ! write_response "run_tests" "Generate Coverage Report: $PYTHON_PROJECT_PATH"; then
    write_error "run_tests" "Failed: Unable to run the unit tests \"$PYTHON_PROJECT_PATH\""
    exit 4
fi

popd >/dev/null 2>&1

write_success "run_tests" "Done"
exit 0