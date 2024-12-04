#!/usr/bin/env bash
<<EOF

    LinkExtractor \ Shell Scripts \ Build \ Docker \ DotNet

    Build the Dockerfile container image.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

# set -euo pipefail

function usage() {
    write_info "build_docker" "build_docker.sh [-p <dockerfile path>] [-c <docker build context path>]"
    exit 1
}

while getopts ':c:p:t:h?' opt; do
    case $opt in
        c)
            DOCKER_BUILD_CONTEXT_PATH=$OPTARG
            write_warning "build_docker" "Docker Build Context Path: \"$DOCKER_BUILD_CONTEXT_PATH\""
        ;;
        p)
            DOCKERFILE_FILEPATH=$OPTARG
            write_warning "build_docker" "Dockerfile Path: \"$DOCKERFILE_FILEPATH\""
        ;;
        t)
            TAG_SUFFIX=$OPTARG
            write_warning "build_docker" "Tag Suffix: \"$TAG_SUFFIX\""
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

TAG_SUFFIXES=( "dotnet" "python" )
if [[ ! " ${TAG_SUFFIXES[@]} " =~ " ${TAG_SUFFIX} " ]]; then
    write_error "build_docker" "Value \"${TAG_SUFFIX}\" is not a valid suffix."
fi

if [ -z "$TAG_SUFFIX" ]; then
    write_error "build_docker" "The tag suffix for the image was not defined. Unable to determine the purpose of the container image (\"python\" or \"dotnet\"?)."
    exit 1
fi

if [ -z "$DOCKER_BUILD_CONTEXT_PATH" ]; then
    write_error "build_docker" "The Docker build context was not defined."
    exit 1
fi

if [ ! -d "$DOCKER_BUILD_CONTEXT_PATH"  ]; then
    write_error "build_docker" "The Docker build context path was not found. (\"$DOCKERFILE_FILEPATH\")"
    exit 2
fi

if [ -z "$DOCKERFILE_FILEPATH" ]; then
    write_error "build_docker" "The Dockerfile was not defined."
    exit 1
fi

if [ ! -e "$DOCKERFILE_FILEPATH"  ]; then
    write_error "build_docker" "The Dockerfile was not found at the path specified. (\"$DOCKERFILE_FILEPATH\")"
    exit 2
fi

write_info "build_docker" "Docker Build Context Path: $DOCKER_BUILD_CONTEXT_PATH"

BUILD_ARCHITECTURES=("linux/amd64" "linux/arm64")

BUILD_ARCHITECTURES_COMBINED=$(IFS=,; echo "${BUILD_ARCHITECTURES[*]}")
BUILD_TYPES=("development" "production")

TAG_PREFIX=lucshelton/link-extractor
BUILDER_NAME=link-extractor-builder

BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
BUILD_UID="$(uuidgen)"

if ! is_valid_docker_builder "$BUILDER_NAME"; then
    write_info "build_docker" "Creating Builder: \"$BUILDER_NAME\""
    if ! create_docker_builder "$BUILDER_NAME"; then
        write_error "build_docker" "Unable to create Docker BuildKit builder instance. Terminating."
        exit 1
    fi
fi

write_info "build_docker" "Build Date: \"$BUILD_DATE\""
write_info "build_docker" "Build UID: \"$BUILD_UID\""

for build_type in ${BUILD_TYPES[@]}; do
    for build_architecture in "${BUILD_ARCHITECTURES[@]}"; do
        TAG_ARCH="${TAG_PREFIX}:${TAG_SUFFIX}-latest-${build_architecture//\//-}"
        write_info "build_docker" "↪ Architecture: \"$build_architecture\""
        write_info "build_docker" "↪ Tag (Architecture): \"$TAG_ARCH\""
        
        docker buildx build --builder "$BUILDER_NAME" \
        --platform "$build_architecture" \
        --load \
        --push \
        --tag "$TAG_ARCH" \
        --build-arg BUILD_TYPE="$build_type" \
        --build-arg BUILD_DATE="$BUILD_DATE" \
        --build-arg BUILD_UID="$BUILD_UID" \
        --file "$DOCKERFILE_FILEPATH" \
        "$DOCKER_BUILD_CONTEXT_PATH"
        if ! write_response "build_docker" "Build: \"$DOCKERFILE_FILEPATH\""; then
            write_error "build_docker" "Failed: Unable to build \"$DOCKERFILE_FILEPATH\""
            exit 1
        fi
    done
done

write_success "build_docker" "Done"
exit 0