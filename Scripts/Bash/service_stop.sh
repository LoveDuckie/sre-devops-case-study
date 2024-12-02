#!/usr/bin/env bash
<<EOF

    LinkExtractor \ Shell Scripts \ Services \ Start

    Start the service specified.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

usage() {
    write_info "service_stop" "./service_stop.sh [-p <service name>]"
    exit 1
}

while getopts ':s:h?' opt; do
    case $opt in
        s)
            SERVICE_NAME=$OPTARG
            write_warning "service_stop" "Service Name: \"$SERVICE_NAME\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "service_stop" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ -z "$SERVICE_NAME" ]; then
   write_error "service_stop" "The service name was not specified."
   write_error "service_stop" "Avaialble Services:"
   for service_path in $REPO_ROOT_PATH/Services/*; do
    write_info "service_stop" "- $(basename $service_path)"
   done
   exit 1
fi

SERVICE_PROJECT_PATH=$REPO_ROOT_PATH/Services/$SERVICE_NAME

if [ ! -d $SERVICE_PROJECT_PATH ]; then
    write_error "service_stop" "Failed: Unable to find the service project path \"$SERVICE_PROJECT_PATH\""
    exit 2
fi

pushd $SERVICE_PROJECT_PATH >/dev/null 2>&1
docker compose up
popd >/dev/null 2>&1

write_success "service_stop" "Done"
exit 0