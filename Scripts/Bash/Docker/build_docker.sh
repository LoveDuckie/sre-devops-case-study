#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Build \ Docker



EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

function usage() {
    write_info "build_docker" "build_docker.sh [-p <dockerfile path>]"
    exit 1
}

while getopts ':p:h?' opt; do
    case $opt in
        p)
            DOCKER_FILEPATH=$OPTARG
            write_warning "build_docker" "Dockerfile Path: \"$DOCKER_FILEPATH\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "build_docker" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ -z "$DOCKER_FILEPATH" ]; then
    write_error "build_docker" "The Dockerfile was not defined."
    exit 1
fi

if [ ! -e "$DOCKER_FILEPATH"  ]; then
    write_error "build_docker" "The Dockerfile was not found. (\"$DOCKER_FILEPATH\")"
    exit 1
fi


if ! is_valid_docker_builder "$BUILDER_NAME"; then
    write_info "build_docker" "Creating Builder: \"$BUILDER_NAME\""
    create_docker_builder "$BUILDER_NAME"
fi

DOCKER_PROJECT_PATH=$(dirname $DOCKER_FILEPATH)

BUILD_ARCHITECTURES=("linux/amd64" "linux/arm64")
BUILD_TYPES=("development" "production")
BUILDER_NAME=link-extractor-builder


for build_type in ${BUILD_TYPES[@]}; do
    write_info "build_docker" "Building type: \"$build_type\""
    TAG="${TAG_PREFIX}:${build_type}"
    TAG_VERSION="${TAG_PREFIX}:${VERSION}-${build_type}"
    
    for build_architecture in "${BUILD_ARCHITECTURES[@]}"; do
        TAG_ARCH="${TAG}-${build_architecture//\//-}"
        write_info "build_docker" "↪ Architecture: \"$build_architecture\""
        write_info "build_docker" "↪ Tag (Architecture): \"$TAG_ARCH\""
        
        docker buildx build --builder "$BUILDER_NAME" \
        --platform "$build_architecture" \
        --load \
        --tag "$TAG_ARCH" \
        --build-arg BUILD_TYPE="$build_type" \
        --build-arg VERSION="$BUILD_VERSION" \
        -f "$SERVICE_DOCKERFILE_PATH_ABS" "$DOCKER_PROJECT_PATH"
    done
done


write_success "build_docker" "Done"
exit 0