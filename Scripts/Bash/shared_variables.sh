#!/usr/bin/env bash
<<EOF

    LinkExtractor \ Shared Functions

    A collection of shared functions used in various places.

EOF
[ -n "${SHARED_VARIABLES_EXT}" ] && return
SHARED_VARIABLES_EXT=0
CURRENT_SCRIPT_DIRECTORY_VARIABLES=$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))
export SHARED_EXT_SCRIPTS_PATH=$(realpath ${SHARED_EXT_SCRIPTS_PATH:-$CURRENT_SCRIPT_DIRECTORY_VARIABLES})
export REPO_ROOT_PATH=${REPO_ROOT_PATH:-$(realpath $SHARED_EXT_SCRIPTS_PATH/../../)}

export HELM_CHARTS_PATH="$REPO_ROOT_PATH/Helm/Charts"
export SERVICES_PATH="$REPO_ROOT_PATH/Services"
export SOLUTIONS_PATH="$REPO_ROOT_PATH/Solutions"

export PYTHON_PROJECT_PATH=$REPO_ROOT_PATH/Solutions/Python/link-extractor
