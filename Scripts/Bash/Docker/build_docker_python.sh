#!/usr/bin/env bash
<<EOF

    LinkExtractor \ Shell Scripts \ Build \ Docker \ Python

    Build the Dockerfile container image.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

function usage() {
    write_info "build_docker_python" "build_docker_python.sh [-p <dockerfile path>]"
    exit 1
}

while getopts ':p:h?' opt; do
    case $opt in
        p)
            DOCKER_FILEPATH=$OPTARG
            write_warning "build_docker_python" "Dockerfile Path: \"$DOCKER_FILEPATH\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "build_docker_python" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ -z "$DOCKER_FILEPATH" ]; then
    write_error "build_docker_python" "The Dockerfile was not defined."
    exit 1
fi

if [ ! -e "$DOCKER_FILEPATH"  ]; then
    write_error "build_docker_python" "The Dockerfile was not found. (\"$DOCKER_FILEPATH\")"
    exit 2
fi

DOCKER_PROJECT_PATH=$(dirname $(dirname $DOCKER_FILEPATH))
write_info "build_docker_python" "Dockerfile Project Path: $DOCKER_PROJECT_PATH"

BUILD_ARCHITECTURES=("linux/amd64" "linux/arm64")
BUILD_TYPES=("development" "production")
BUILDER_NAME=link-extractor-builder
TAG_PREFIX=link-extractor

if ! is_valid_docker_builder "$BUILDER_NAME"; then
    write_info "build_docker_python" "Creating Builder: \"$BUILDER_NAME\""
    create_docker_builder "$BUILDER_NAME"
fi

# for build_type in ${BUILD_TYPES[@]}; do
#     write_info "build_docker_python" "Building type: \"$build_type\""
#     TAG="${TAG_PREFIX}:${build_type}"
#     TAG_VERSION="${TAG_PREFIX}:${VERSION}-${build_type}"

#     for build_architecture in "${BUILD_ARCHITECTURES[@]}"; do
#         TAG_ARCH="${TAG}-${build_architecture//\//-}"
#         write_info "build_docker_python" "↪ Architecture: \"$build_architecture\""
#         write_info "build_docker_python" "↪ Tag (Architecture): \"$TAG_ARCH\""

#         docker buildx build --builder "$BUILDER_NAME" \
#         --platform "$build_architecture" \
#         --load \
#         --tag "$TAG_ARCH" \
#         --build-arg BUILD_TYPE="$build_type" \
#         --build-arg VERSION="$BUILD_VERSION" \
#         -f "$DOCKERFILE_PATH" "$DOCKER_PROJECT_PATH"
#         # -f "$DOCKERFILE_PATH"
#         if ! write_response "build_docker_python" "Build: \"$DOCKERFILE_PATH\""; then
#             write_error "build_docker_python" "Failed: Unable to build \"$DOCKER_FILEPATH\""
#             exit 1
#         fi
#     done
# done

for build_architecture in "${BUILD_ARCHITECTURES[@]}"; do
    TAG_ARCH="${TAG}-${build_architecture//\//-}"
    write_info "build_docker_python" "↪ Architecture: \"$build_architecture\""
    write_info "build_docker_python" "↪ Tag (Architecture): \"$TAG_ARCH\""
    
    docker buildx build --builder "$BUILDER_NAME" \
    --platform "$build_architecture" \
    --load \
    --tag "$TAG_ARCH" \
    --build-arg BUILD_TYPE="$build_type" \
    --build-arg VERSION="$BUILD_VERSION" \
    -f "$DOCKERFILE_PATH" "$DOCKER_PROJECT_PATH"
    # -f "$DOCKERFILE_PATH"
    if ! write_response "build_docker_python" "Build: \"$DOCKERFILE_PATH\""; then
        write_error "build_docker_python" "Failed: Unable to build \"$DOCKER_FILEPATH\""
        exit 1
    fi
done

write_success "build_docker_python" "Done"
exit 0