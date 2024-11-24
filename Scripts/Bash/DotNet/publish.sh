#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ DotNet \ Publish

   Publish the .NET application as a NuGet package.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header


dotnet publish "$PROJECT_PATH" -c "$CONFIGURATION" -o "$OUTPUT_DIR" || write_error "publish" "Packaging failed."


write_success "publish" "Done"
exit 0