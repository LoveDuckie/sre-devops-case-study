#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Setup \ Poetry

   Setup Poetry on the host system.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

set -e
set -o pipefail

write_info "python_setup_poetry" "Starting Poetry installation with pyenv Python..."

# Variables
POETRY_INSTALL_URL="https://install.python-poetry.org"
POETRY_BIN_DIR="$HOME/.local/bin"
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")

# Check if pyenv is installed
if ! is_command_available pyenv; then
    write_error "python_setup_poetry" "Error: pyenv is not installed. Please install pyenv and re-run this script."
    exit 1
fi

# Get the currently active Python version from pyenv
PYENV_PYTHON=$(pyenv which python3 || pyenv which python)

if [[ -z "$PYENV_PYTHON" ]]; then
    write_error "python_setup_poetry" "Error: No Python version is active in pyenv. Activate a Python version and re-run this script."
    exit 1
fi

write_info "python_setup_poetry" "Using Python from pyenv: $PYENV_PYTHON"

# Download and install Poetry
if is_command_available curl; then
    write_info "python_setup_poetry" "Using curl to install Poetry..."
    curl -sSL $POETRY_INSTALL_URL | $PYENV_PYTHON -
    elif is_command_available wget; then
    write_info "python_setup_poetry" "Using wget to install Poetry..."
    wget -qO- $POETRY_INSTALL_URL | $PYENV_PYTHON -
else
    write_info "python_setup_poetry" "Error: Neither curl nor wget is available. Please install one of them and re-run this script."
    exit 1
fi

# Ensure the installation directory is added to PATH
if [[ ":$PATH:" != *":$POETRY_BIN_DIR:"* ]]; then
    write_info "python_setup_poetry" "Adding Poetry's bin directory to PATH..."
    for profile in "${PROFILE_FILES[@]}"; do
        if [[ -f "$profile" ]]; then
            write_info "python_setup_poetry" "export PATH=\"\$PATH:$POETRY_BIN_DIR\"" >> "$profile"
            write_info "python_setup_poetry" "Updated $profile to include Poetry's bin directory."
        fi
    done
    write_info "python_setup_poetry" "Please restart your terminal or run 'source ~/.bashrc' (or equivalent) to use Poetry."
fi

# Verify installation
if is_command_available poetry; then
    write_info "python_setup_poetry" "Poetry installed successfully!"
    poetry --version
else
    write_info "python_setup_poetry" "Poetry installation failed. Please check the output for errors."
    exit 1
fi

write_info "python_setup_poetry" "Installing Extension: \"poetry-bumpversion\""
poetry self add poetry-bumpversion
if ! write_response "python_setup_poetry" "Install Extension: poetry-bumpversion"; then
   write_error "python_setup_poetry" "Failed: Unable to install the extension \"poetry-bumpversion\""
   exit 2
fi


write_success "setup_poetry" "Done"
exit 0