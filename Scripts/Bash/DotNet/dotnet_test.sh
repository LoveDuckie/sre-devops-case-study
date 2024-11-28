#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ DotNet \ Test

   Test the .NET application for distribution

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

function usage() {
    write_info "test" "./test.sh [-p <project filepath>] [-c <configuration>]"
    exit 1
}

VALID_CONFIGURATIONS=("Release" "Debug")

while getopts ':p:c:h?' opt; do
    case $opt in
        c)
            CONFIGURATION=$OPTARG
            if [[ ! " ${VALID_CONFIGURATIONS[@]} " =~ " ${CONFIGURATION} " ]]; then
                write_error "test" "\"$CONFIGURATION\" is not a valid configuration."
                exit 1
            fi
            
            write_warning "test" "Build Configuration: \"$CONFIGURATION\""
        ;;
        p)
            PROJECT_PATH=$OPTARG
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "test" "\"-${OPTARG}\" requires an argument"
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

write_info "test" "Running Unit Tests: $PROJECT_PATH"
dotnet test "$PROJECT_PATH" -c "$CONFIGURATION" --no-build || write_error "test" "Tests failed."
if ! write_response "test" "Test: $PROJECT_PATH"; then
    write_error "test" "Failed: An error occurred when testing the project \"$PROJECT_PATH\""
    exit 1
fi

write_success "test" "Done"
exit 0