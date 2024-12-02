#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Scripts \ Run

   Run the tool

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/Scripts/Bash)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

ALLOWED_RUN_TYPES=(default docker)
DEFAULT_RUN_TYPE=default

while getopts ':t:h?' opt; do
   case $opt in
        t)
            RUN_TYPE=$OPTARG
            write_warning "run" "Run Type: \"$RUN_TYPE\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "run" "-${OPTARG} requires an argument"
            usage
        ;;
        *)
            usage
        ;;
   esac
done

case $RUN_TYPE in
    default)
        $CURRENT_SCRIPT_DIRECTORY/run_native.sh
        exit 0
    ;;

    docker)
        $CURRENT_SCRIPT_DIRECTORY/run_docker.sh
        exit 0
    ;;
    *)
        write_error "run" "Run type not recognised."
        exit 1
    ;;
esac

write_success "run" "Done"
exit 0