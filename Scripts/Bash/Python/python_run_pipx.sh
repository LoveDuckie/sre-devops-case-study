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
}

# Initialize variables
TARGET_PROJECT_PATH=""
APP_ARGS=()

# Parse options
while getopts ':p:h?' opt; do
    case $opt in
        p)
            TARGET_PROJECT_PATH=$OPTARG
            write_info "python_run" "Python Project Path: $TARGET_PROJECT_PATH"
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
APP_ARGS=("$@")

if [ -z "$TARGET_PROJECT_PATH" ]; then
    write_error "python_run" "Project path (-p) is required."
    usage
    exit 1
fi

write_info "python_run" "Ensuring pipx is installed"
if ! is_command_available pipx; then
    write_info "python_run" "pipx not found. Installing pipx."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    export PATH=$PATH:~/.local/bin
fi

write_info "python_run" "Installing package with pipx"
pipx install "$TARGET_PROJECT_PATH"

write_info "python_run" "Running: link-extractor ${APP_ARGS[*]}"
pipx run "$TARGET_PROJECT_PATH" "${APP_ARGS[@]}"

write_info "python_run" "Uninstalling package from pipx"
pipx uninstall "$TARGET_PROJECT_PATH"

write_success "python_run" "Done"
