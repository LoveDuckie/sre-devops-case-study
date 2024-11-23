#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Docker \ Build

   Build the Docker image

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

if ! is_docker_installed; then
    write_error "build_all_arch_buildx" "Failed: Docker is not installed on this system"
    exit 1
fi

if ! is_command_available yq; then
    write_error "build_all_arch_buildx" "Failed: Unable to find the command \"yq\""
    exit 1
fi

export DOCKER_BUILDKIT=1
export DOCKER_PROJECT_PATH="$CURRENT_SCRIPT_DIRECTORY/projects/website"
export DOCKER_PROJECT_COMPOSE_FILEPATH="$DOCKER_PROJECT_PATH/docker-compose.yaml"
export DOCKER_PROJECT_CONTAINERS_PATH="$DOCKER_PROJECT_PATH/containers"
export CONTAINERS_ROOT=$DOCKER_PROJECT_CONTAINERS_PATH

BUILD_SERVICES=$(yq '.services | to_entries | map(select(.value.build? != null)) | .[].key' "$DOCKER_PROJECT_COMPOSE_FILEPATH")

if [ ! ${#BUILD_SERVICES[@]} -gt 0 ]; then
    write_error "build_all_arch_buildx" "No container images to build."
    exit 3
fi

BUILD_ARCHITECTURES=("linux/amd64" "linux/arm64")
BUILD_TYPES=("development" "production")
BUILDER_NAME=portfolio-builder

if ! is_valid_docker_builder "$BUILDER_NAME"; then
    write_info "build_all_arch_buildx" "Creating Builder: \"$BUILDER_NAME\""
    create_docker_builder "$BUILDER_NAME"
fi

pushd "$DOCKER_PROJECT_PATH" 2>&1 >/dev/null

# Combine architectures for manifest
IFS=","
ARCHS_COMBINED="${BUILD_ARCHITECTURES[*]}"
unset IFS

IMAGE_PREFIX=portfolio

for build_service in ${BUILD_SERVICES[@]}; do
    write_info "build_all_arch_buildx" "*********************************"
    write_info "build_all_arch_buildx" "Building Service: \"$build_service\""
    write_info "build_all_arch_buildx" "*********************************"
    write_info "build_all_arch_buildx" "↪ Service: $build_service"
    SERVICE_DOCKERFILE_PATH=$(yq ".services[\"$build_service\"][\"build\"][\"dockerfile\"]" $DOCKER_PROJECT_COMPOSE_FILEPATH)
    SERVICE_DOCKERFILE_PATH_ABS=$(echo $SERVICE_DOCKERFILE_PATH | envsubst)
    write_info "build_all_arch_buildx" "$SERVICE_DOCKERFILE_PATH_ABS"

    SERVICE_BUMPVERSION_FILE_PATH=$DOCKER_PROJECT_CONTAINERS_PATH/$build_service/build/.bumpversion.toml
    BUILD_VERSION=$(yq e '.tool."bumpversion".current_version' $SERVICE_BUMPVERSION_FILE_PATH)
    write_info "build_all_arch_buildx" "↪ Build Version: $BUILD_VERSION"
    SERVICE_DOCKERFILE_PATH=$(yq ".services[\"$build_service\"][\"build\"][\"dockerfile\"]" $DOCKER_PROJECT_COMPOSE_FILEPATH)
    if [ -z "$SERVICE_DOCKERFILE_PATH" ]; then
        write_error "build_all_arch_buildx" "The Dockerfile for \"$build_service\" could not be resolved."
        continue
    fi

    TAG_PREFIX="$IMAGE_PREFIX/$build_service"

    for build_type in ${BUILD_TYPES[@]}; do
        write_info "build_all_arch_buildx" "Building type: \"$build_type\""
        TAG="${TAG_PREFIX}:${build_type}"
        TAG_VERSION="${TAG_PREFIX}:${VERSION}-${build_type}"

        for build_architecture in "${BUILD_ARCHITECTURES[@]}"; do
            TAG_ARCH="${TAG}-${build_architecture//\//-}"
            write_info "build_all_arch_buildx" "↪ Architecture: \"$build_architecture\""
            write_info "build_all_arch_buildx" "↪ Tag (Architecture): \"$TAG_ARCH\""

            docker buildx build --builder "$BUILDER_NAME" \
                --platform "$build_architecture" \
                --load \
                --tag "$TAG_ARCH" \
                --build-arg BUILD_TYPE="$build_type" \
                --build-arg VERSION="$BUILD_VERSION" \
                -f "$SERVICE_DOCKERFILE_PATH_ABS" "$DOCKER_PROJECT_PATH"
        done
    done
done

write_success "build_docker" "Done"