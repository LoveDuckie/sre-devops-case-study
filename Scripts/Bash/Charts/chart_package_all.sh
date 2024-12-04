#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Helm Charts \ Package All

   Package all the Helm Charts that are in the repository.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

write_info "chart_package_all" "Helm Charts Path: $HELM_CHARTS_PATH"

for chart_path in $HELM_CHARTS_PATH/*; do
    write_info "chart_package_all" "Chart: $chart_path"
    CHART_NAME=$(basename $chart_path)
    write_info "chart_package_all" "Chart Name: $CHART_NAME"
    $CURRENT_SCRIPT_DIRECTORY/chart_package.sh -c "$CHART_NAME"
done