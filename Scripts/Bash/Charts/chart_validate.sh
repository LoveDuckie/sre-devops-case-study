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

CHARTS_PATH=$REPO_ROOT_PATH/Charts

function usage() {
    write_info "chart_validate" "./chart_validate.sh"
    exit 1
}

while getopts ':c:h?' opt; do
    case $opt in
        c)
            export CHART_NAME=$OPTARG
            write_warning "chart_validate" "Chart: \"$CHART_NAME\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "chart_validate" "-${OPTARG} requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

CHART_PATH=$CHARTS_PATH/$CHART_NAME

if [ ! -d $CHART_PATH ]; then
    write_error "chart_validate" "Failed: Unable to find the chart \"$CHART_NAME\" ($CHARTS_PATH)"
    exit 1
fi

helm chart validate

write_success "chart_validate" "Done"
exit 0