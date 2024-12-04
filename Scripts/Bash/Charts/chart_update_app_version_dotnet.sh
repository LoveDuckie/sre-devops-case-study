#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Helm Charts \ Update App Version

   Update the application version for the Chart specified.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/scripts)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

# Exit on errors
set -e

function usage() {
    write_info "chart_update_app_version" "./chart_update_app_version.sh [-c <helm chart path>] [-p <csproj filepath>]"
    exit 1
}

while getopts ':p:c:h?' opt; do
    case $opt in
        c)
            HELM_CHART_PATH=$OPTARG
            write_warning "chart_update_app_version" "Using Chart: \"$HELM_CHART_PATH\""
        ;;
        
        p)
            CSPROJ_FILEPATH=$OPTARG
            write_warning "chart_update_app_version" "Using Project: \"$CSPROJ_FILEPATH\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "chart_update_app_version" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done


if [ "$#" -ne 2 ]; then
    write_error "Usage: $0 <path-to-csproj-file> <path-to-helm-chart>"
    exit 1
fi

CSPROJ_FILEPATH="$1"
HELM_CHART_PATH="$2"

if [ ! -d "$HELM_CHART_PATH" ]; then
    write_error "chart_update_app_version" "The Helm Chart specified is not a directory."
    exit 1
fi

CHART_YAML="${HELM_CHART_PATH}/Chart.yaml"

# Check if the .csproj file exists
if [ ! -f "$CSPROJ_FILEPATH" ]; then
    write_error "chart_update_app_version" "Error: .csproj file not found at '$CSPROJ_FILEPATH'"
    exit 1
fi

# Check if the Helm chart's Chart.yaml exists
if [ ! -f "$CHART_YAML" ]; then
    write_error "chart_update_app_version" "Error: Chart.yaml not found at '$CHART_YAML'"
    exit 1
fi

# Extract the application version from the .csproj file
APP_VERSION=$(xmllint --xpath "string(//Project/PropertyGroup/Version)" "$CSPROJ_FILEPATH" 2>/dev/null || echo "")

# Validate that the application version was found
if [ -z "$APP_VERSION" ]; then
    write_error "chart_update_app_version" "Error: Application version not found in '$CSPROJ_FILEPATH'"
    exit 1
fi

write_warning "chart_update_app_version" "Application version extracted: $APP_VERSION"

# Update the appVersion in the Chart.yaml file
if grep -q "^appVersion:" "$CHART_YAML"; then
    sed -i.bak "s/^appVersion: .*/appVersion: \"$APP_VERSION\"/" "$CHART_YAML"
else
    echo "appVersion: \"$APP_VERSION\"" >> "$CHART_YAML"
fi

write_warning "Updated \"appVersion\" in \"$CHART_YAML\" to \"$APP_VERSION\""

# Cleanup backup file (if created by sed on macOS)
if [ -f "${CHART_YAML}.bak" ]; then
    write_warning "chart_update_app_version" "Deleting backup file \"${CHART_YAML}.bak\""
    rm -f "${CHART_YAML}.bak"
fi

write_success "chart_update_app_version" "Done"
exit 0