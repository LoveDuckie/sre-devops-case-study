#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ DotNet \ Restore

   Restore the .NET application package dependencies.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

function usage() {
    write_info "restore" "./restore.sh [-p <project filepath>]"
    exit 1
}

while getopts ':ph?' opt; do
    case $opt in
        p)
            PROJECT_PATH=$OPTARG
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "restore" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ -z "$PROJECT_PATH" ]; then
    write_error "restore" "Failed: The project path was not defined."
    usage
fi

if [ ! -e $PROJECT_PATH ]; then
    write_error "restore" "Failed: The project path was not defined."
    usage
fi

write_info "restore" "Restoring Packages: \"$PROJECT_PATH\" "
dotnet restore "$PROJECT_PATH" || error "Failed to restore dependencies."
if ! write_response "restore" "Restore: \"$PROJECT_PATH\""; then
    write_error "restore" "Failed: Unable to restore packages"
    exit 1
fi

write_success "restore" "Done"
exit 0