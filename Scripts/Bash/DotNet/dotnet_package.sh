#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ DotNet \ Package

   Publish the .NET application as a NuGet package.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

function usage() {
    write_info "package" "./package.sh [-p <project filepath>] [-c <configuration>]"
    exit 1
}

VALID_CONFIGURATIONS=("Release" "Debug")

while getopts ':p:c:o:h?' opt; do
    case $opt in
        c)
            CONFIGURATION=$OPTARG
            if [[ ! " ${VALID_CONFIGURATIONS[@]} " =~ " ${CONFIGURATION} " ]]; then
                write_error "package" "\"$CONFIGURATION\" is not a valid configuration."
                exit 1
            else
            fi
            
            write_warning "package" "Build Configuration: \"$CONFIGURATION\""
        ;;
        p)
            PROJECT_PATH=$OPTARG
            write_warning "package" "Project Path: \"$PROJECT_PATH\""
        ;;
        o)
            OUTPUT_DIR=$OPTARG
            write_warning "package" "Output Path: \"$OUTPUT_DIR\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "package" "\"-${OPTARG}\" requires an argument"
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

write_info "package" "Packaging: \"$PROJECT_PATH\""
dotnet package "$PROJECT_PATH" -c "$CONFIGURATION" -o "$OUTPUT_DIR" || write_error "package" "Packaging failed."
if ! write_response "package" "Package: $PROJECT_PATH"; then
    write_error "package" "Failed: Unable to package the project \"$PROJECT_PATH\""
    exit 1
fi

write_success "package" "Done"
exit 0