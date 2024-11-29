#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Scripts \ Chart Deploy

   Deploy one of the available Helm Charts

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

CHARTS_PATH=$REPO_ROOT_PATH/Charts

function usage() {
    write_info "chart_deploy" "./chart_deploy.sh [-c <chart name>]"
    exit 1
}

while getopts ':c:n:h?' opt; do
    case $opt in
        c)
            export CHART_NAME=$OPTARG
            write_warning "chart_deploy" "Helm Chart: \"$CHART_NAME\""
        ;;
        n)
            export CHART_NAMESPACE=$OPTARG
            write_warning "chart_deploy" "Helm Chart Namespace: \"$CHART_NAMESPACE\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "chart_deploy" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ ! -d $CHARTS_PATH/$CHART_NAME ]; then
    write_error "chart_deploy" "Failed: Unable to find the chart \"$CHART_NAME\" ($CHARTS_PATH)"
    exit 1
fi

write_success "chart_deploy" "Done"
exit 0