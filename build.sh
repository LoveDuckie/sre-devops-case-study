#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Tools \ Build

   Build The Docker image

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/Scripts/Bash)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

DOCKER_SCRIPTS_PATH=$CURRENT_SCRIPT_DIRECTORY/Scripts/Bash/Docker

$DOCKER_SCRIPTS_PATH/build_docker.sh -p "$CURRENT_SCRIPT_DIRECTORY/Solutions/Python/link-extractor/Dockerfile" -c "$CURRENT_SCRIPT_DIRECTORY/Solutions/Python/link-extractor" -t python



write_success "build" "Done"
exit 0