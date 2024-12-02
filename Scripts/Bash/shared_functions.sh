#!/usr/bin/env bash
<<EOF

    LinkExtractor \ Shared Functions

    A collection of shared functions used in various places.

EOF
[ -n "${SHARED_FUNCTIONS_EXT}" ] && return
SHARED_FUNCTIONS_EXT=0
CURRENT_SCRIPT_DIRECTORY_FUNCTIONS=$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))
export SHARED_EXT_SCRIPTS_PATH=$(realpath ${SHARED_EXT_SCRIPTS_PATH:-$CURRENT_SCRIPT_DIRECTORY_FUNCTIONS})
export REPO_ROOT_PATH=${REPO_ROOT_PATH:-$(realpath $SHARED_EXT_SCRIPTS_PATH/../../)}
. "$SHARED_EXT_SCRIPTS_PATH/shared_variables.sh"

type -f write_info >/dev/null 2>&1 && unset -f write_info
type -f write_warning >/dev/null 2>&1 && unset -f write_warning
type -f write_critical >/dev/null 2>&1 && unset -f write_critical
type -f write_error >/dev/null 2>&1 && unset -f write_error
type -f write_success >/dev/null 2>&1 && unset -f write_success
type -f write_response >/dev/null 2>&1 && unset -f write_response
type -f is_command_available >/dev/null 2>&1 && unset -f is_command_available
type -f is_docker_installed >/dev/null 2>&1 && unset -f is_docker_installed
type -f is_running_as_root >/dev/null 2>&1 && unset -f is_running_as_root
type -f is_buildkit_configured >/dev/null 2>&1 && unset -f is_buildkit_configured
type -f is_package_installed >/dev/null 2>&1 && unset -f is_package_installed
type -f is_valid_docker_container >/dev/null 2>&1 && unset -f is_valid_docker_container
type -f is_valid_docker_network >/dev/null 2>&1 && unset -f is_valid_docker_network
type -f is_valid_docker_context >/dev/null 2>&1 && unset -f is_valid_docker_context
type -f is_root >/dev/null 2>&1 && unset -f is_root
type -f is_valid_docker_builder >/dev/null 2>&1 && unset -f is_valid_docker_builder
type -f create_docker_builder >/dev/null 2>&1 && unset -f create_docker_builder
type -f is_valid_docker_image >/dev/null 2>&1 && unset -f is_valid_docker_image

is_root() {
    if [ `whoami` != 'root' ]; then
        return 1
    fi
    
    return 0
}

is_command_available() {
    if [ -z "$(command -v $1)" ]; then
        return 1
    fi
    
    if [ -z "$(type -t $1)" ]; then
        return 2
    fi
    
    return 0
}


is_docker_installed() {
    if ! is_command_available docker; then
        return 1
    fi
    
    return 0
}

is_running_as_root() {
    if [ "$(whoami)" != "root" ]; then
        return 0
    fi
    
    return 1
}

is_buildkit_configured() {
    if [ -z "$COMPOSE_DOCKER_CLI_BUILD" ] && [ -z "$DOCKER_BUILDKIT" ]; then
        return 1
    fi
    
    return 0
}

write_header() {
    if [ -z "$HEADER_OUTPUT" ] && [ -e "$SHARED_EXT_SCRIPTS_PATH/script-header" ]; then
        echo -e "\033[1;37m$(cat $SHARED_EXT_SCRIPTS_PATH/script-header)\033[0m"
    fi
    
    if [ ! -z "$CURRENT_SCRIPT_FILENAME_BASE" ]; then
        echo ""
        write_info "*** SCRIPT: $(echo \"$CURRENT_SCRIPT_FILENAME_BASE\" | awk '{print toupper($0)}')"
        echo ""
    fi
    
    export HEADER_OUTPUT=1
}

write_info() {
    MSG=$2
    echo -e "\033[1;36m$1\033[0m \033[0;37m${MSG}\033[0m" 1>&2
    return 0
}

write_success() {
    MSG=$2
    echo -e "\033[1;32m$1\033[0m \033[0;37m${MSG}\033[0m" 1>&2
    return 0
}

write_error() {
    MSG=$2
    echo -e "\033[1;31m$1\033[0m \033[0;37m${MSG}\033[0m" 1>&2
    return 0
}

write_critical() {
    MSG=$2
    echo -e "\033[1;31;5m$1\033[0m \033[0;37m${MSG}\033[0m" 1>&2
    return 0
}

write_warning() {
    MSG=$2
    echo -e "\033[1;33m$1\033[0m \033[0;37m${MSG}\033[0m" 1>&2
    return 0
}

write_response() {
    if [ $? -ne 0 ]; then
        if [ ! -z "$3" ]; then
            write_error "error" "$3"
        fi
        return 1
    fi
    
    write_success "success" "$2"
    return 0
}

is_valid_project() {
    if [ -z "$1" ]; then
        write_error "shared_functions" "the name of the project was not defined."
        return 1
    fi
    if [ ! -d "$LOCAL_DOCKER_PATH/projects/$1" ]; then
        write_error "shared_functions" "failed to find \"$1\""
        return 1
    fi
    
    return 0
}

is_ubuntu_package_installed() {
    if [ -z $1 ]; then
        write_error "shared_functions" "the package name was not defined as the first parameter."
        return 1
    fi
    
    if [[ "$(dpkg -s $1 2>&1 | grep "ok installed")" != "" ]]; then
        return 0
    fi
    
    return 1
}

is_valid_docker_container() {
    if [ -z "$1" ]; then
        write_error "is-valid-docker-container" "the docker context was not defined. unable to check."
        return 1
    fi
    
    write_info "is-valid-docker-container" "checking docker container"
    if ! is_docker_installed; then
        write_error "is-valid-docker-container" "docker is not installed on this system"
        return 2
    fi
    docker container inspect $1 >/dev/null 2>&1
    if ! write_response "is-valid-docker-container" "check docker container \"$1\""; then
        write_error "is-valid-docker-container" "docker container \"$1\" does not exist"
        return 3
    fi
    
    return 0
}

is_valid_docker_network() {
    if [ -z "$1" ]; then
        write_error "is-valid-docker-network" "the docker context was not defined. unable to check."
        return 1
    fi
    
    write_info "is-valid-docker-network" "checking docker network"
    docker network inspect $1 >/dev/null 2>&1
    if ! write_response "is-valid-docker-network" "check docker container $1"; then
        write_error "is-valid-docker-network" "docker container \"$1\" does not exist"
        return 2
    fi
    
    return 0
}

is_valid_docker_context() {
    if [ -z "$1" ]; then
        write_error "shared_functions" "the docker context was not defined. unable to check."
        return 1
    fi
    
    local DOCKER_CONTEXT_NAME=${1%%.*}
    
    write_info "shared_functions" "checking docker context \"$DOCKER_CONTEXT_NAME\""
    docker context inspect $DOCKER_CONTEXT_NAME >/dev/null 2>&1
    if ! write_response "check docker context \"$DOCKER_CONTEXT_NAME\""; then
        return 2
    fi
    
    return 0
}


is_valid_docker_builder() {
    export DOCKER_BUILDKIT=1
    
    if [ -z "$1" ]; then
        write_error "shared_functions" "The name of the builder was not defined."
        return 1
    fi
    
    if ! docker buildx inspect "$1" > /dev/null 2>&1; then
        write_error "shared_functions" "The specified builder '$1' does not exist or is not accessible."
        return 1
    fi
    
    return 0
}

create_docker_builder() {
    export DOCKER_BUILDKIT=1
    
    if [ -z "$1" ]; then
        write_error "shared_functions" "The name of the builder was not defined."
        return 1
    fi
    
    # Check if the builder already exists
    if is_valid_docker_builder "$1"; then
        # write_info "shared_functions" "Docker builder '$1' already exists. Skipping creation."
        # return 0
        write_warning "shared_functions" "Removing: \"$1\""
        docker buildx rm "$1"
    fi
    
    # Attempt to create the builder if it doesn't exist
    if ! docker buildx create --name "$1" --use; then
        write_error "shared_functions" "Failed to create Docker builder '$1'."
        return 1
    fi
    
    write_info "shared_functions" "Docker builder '$1' created successfully."
    return 0
}

is_valid_docker_image() {
    local image_name="$1"
    local tag="${2:-latest}"  # Default tag is 'latest' if not provided
    
    # Check if the image exists locally
    if docker image inspect "${image_name}:${tag}" > /dev/null 2>&1; then
        write_info "is_valid_docker_image" "Docker image '${image_name}:${tag}' is available locally."
        return 0
    else
        write_error "is_valid_docker_image" "Docker image '${image_name}:${tag}' is not available locally."
        return 1
    fi
}


export -f is_root
export -f is_valid_docker_image
export -f is_valid_docker_builder
export -f create_docker_builder
export -f write_info
export -f write_warning
export -f write_critical
export -f write_error
export -f write_success
export -f write_response
export -f is_command_available
export -f is_docker_installed
export -f is_running_as_root
export -f is_buildkit_configured
export -f is_valid_docker_container
export -f is_valid_docker_network
export -f is_valid_docker_context