#!/usr/bin/env bash
<<EOF

    LinkExtractor \ Shared Functions \ Kubernetes

    A collection of shared functions used in various places.

EOF
[ -n "${SHARED_FUNCTIONS_KUBERNETES_EXT}" ] && return
SHARED_FUNCTIONS_KUBERNETES_EXT=0
CURRENT_SCRIPT_DIRECTORY_FUNCTIONS_KUBERNETES=$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))
export SHARED_EXT_SCRIPTS_PATH=$(realpath ${SHARED_EXT_SCRIPTS_PATH:-$CURRENT_SCRIPT_DIRECTORY_FUNCTIONS_KUBERNETES})
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"

type -f check_docker_installed >/dev/null 2>&1 && unset -f check_docker_installed
type -f check_docker_running >/dev/null 2>&1 && unset -f check_docker_running
type -f check_kubernetes_enabled >/dev/null 2>&1 && unset -f check_kubernetes_enabled
type -f check_kubernetes_status >/dev/null 2>&1 && unset -f check_kubernetes_status

# Function to check if Docker is installed
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed. Please install Docker Desktop for macOS."
        exit 1
    fi
}

# Function to check if Docker Desktop is running
check_docker_running() {
    if ! docker info &> /dev/null; then
        echo "Docker Desktop is not running. Please start Docker Desktop."
        exit 1
    fi
}

# Function to check if Kubernetes is enabled in Docker Desktop
check_kubernetes_enabled() {
    if ! docker system info | grep -q "Kubernetes"; then
        echo "Kubernetes is not enabled in Docker Desktop. Please enable it in Docker Desktop settings."
        exit 1
    fi
}

# Function to check Kubernetes cluster status
check_kubernetes_status() {
    if ! kubectl version --client &> /dev/null; then
        echo "kubectl is not installed. Please install kubectl for macOS."
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        echo "Kubernetes is not running. Please ensure Kubernetes is enabled and running in Docker Desktop."
        exit 1
    fi
}