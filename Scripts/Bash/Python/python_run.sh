#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Python \ Run

   Run the Project

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

usage() {
    write_info "python_run" "./python_run.sh -p <project_path> [app_args...]"
    exit 1
}

TARGET_PROJECT_PATH=""
APP_ARGS=()

while getopts ':p:h?' opt; do
    case $opt in
        p)
            TARGET_PROJECT_PATH=$OPTARG
            write_info "python_run" "Python Project Path: \"$TARGET_PROJECT_PATH\""
        ;;
        h|?)
            usage
            exit 0
        ;;
        :)
            write_error "python_run" "\"-${OPTARG}\" requires an argument"
            usage
            exit 1
        ;;
        *)
            usage
            exit 1
        ;;
    esac
done

# Shift positional parameters to get trailing arguments
shift $((OPTIND - 1))

# Capture additional arguments after -p <project_path>
APP_ARGS=("$@")

# Debugging: Print captured arguments
write_info "python_run" "Captured APP_ARGS: ${APP_ARGS[@]}"

if [ -z "$TARGET_PROJECT_PATH" ]; then
    write_error "python_run" "Project path (-p) is required."
    usage
    exit 1
fi

pushd "$TARGET_PROJECT_PATH" || exit 1

python -m venv "$CURRENT_SCRIPT_DIRECTORY/venv"

write_info "python_run" "Virtual Environment: Activating"
. "$CURRENT_SCRIPT_DIRECTORY/venv/bin/activate"

write_info "python_run" "Installing Package"
pip install .
if ! write_response "python_run" "Install Package Dependencies: \"$(basename $TARGET_PROJECT_PATH)\""; then
    write_error "python_run" "Failed: Unable to install package dependencies"
    exit 1
fi

# Debugging the arguments being passed
write_info "python_run" "Running link-extractor with arguments: ${APP_ARGS[@]}"

link-extractor "${APP_ARGS[@]}"
if ! write_response "python_run" "Run \"link-extractor\": \"$TARGET_PROJECT_PATH\""; then
    write_error "python_run" "Failed: Unable to run link-extractor"
    exit 2
fi

write_info "python_run" "Virtual Environment: Deactivating"
deactivate

write_info "python_run" "Virtual Environment: Deleting"
rm -rf "$CURRENT_SCRIPT_DIRECTORY/venv"

popd || exit 1

write_success "python_run" "Done"
exit 0
