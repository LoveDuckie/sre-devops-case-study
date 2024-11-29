#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Scripts \ Deploy Chart

   Deploy one of the available Helm Charts

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

function usage() {
    write_info "chart_package" "./chart_package.sh [-c <chart name>]"
    exit 1
}

while getopts ':c:h?' opt; do
    case $opt in
        c)
            export HELM_CHART_NAME=$OPTARG
            write_warning "chart_package" "Chart: \"$HELM_CHART_NAME\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "chart_package" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

HELM_CHART_PATH=$HELM_CHARTS_PATH/$HELM_CHART_NAME

if [ ! -d $HELM_CHART_PATH ]; then
    write_error "chart_deploy" "Failed: Unable to find the chart \"$HELM_CHART_NAME\" ($HELM_CHARTS_PATH)"
    exit 1
fi

write_info "chart_package" "(Helm) Packaging: $HELM_CHART_PATH"
helm package $HELM_CHART_PATH

write_success "chart_package" "Done"
exit 0