#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Helm Charts \ Bump Version

   Bump the version for the chart specified.

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

usage() {
    write_info "chart_bumpversion" "./chart_bumpversion.sh [-t <bump version type>]"
    exit 1
}

while getopts ':t:h?' opt; do
    case $opt in
        t)
          BUMP_TYPE=$OPTARG
          write_warning "chart_bumpversion" "Bump Version Type: \"$BUMP_TYPE\""  
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "chart_bumpversion" "-${OPTARG} requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

bump_version() {
  local version=$1
  local bump_type=$2

  IFS='.' read -r major minor patch <<< "$version"

  case $bump_type in
    patch)
      patch=$((patch + 1))
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    *)
      echo "Invalid bump type: $bump_type. Use 'patch', 'minor', or 'major'."
      exit 1
      ;;
  esac

  echo "$major.$minor.$patch"
}

BUMP_TYPE=${1:-patch} # Default to patch if not provided

# Detect modified charts in the parent directory using git
write_info "chart_bumpversion" "Helm Charts Path: \"$HELM_CHARTS_PATH\""
write_info "chart_bumpversion" "Detecting modified charts in \"$HELM_CHARTS_PATH\"..."

MODIFIED_CHARTS=$(git diff --name-only HEAD~1 HEAD "$HELM_CHARTS_PATH" | grep "Chart.yaml" | xargs -n1 dirname | sort -u)

if [ -z "$MODIFIED_CHARTS" ]; then
  write_warning "chart_bumpversion" "No changes detected in charts."
  exit 0
fi

for chart in $MODIFIED_CHARTS; do
  write_info "chart_bumpversion" "Processing chart in $chart..."

  chart_file="$REPO_ROOT_PATH/$chart/Chart.yaml"

  if [ ! -f "$chart_file" ]; then
    write_error "chart_bumpversion" "Error: $chart_file does not exist."
    continue
  fi

  # Extract current version
  current_version=$(grep -E '^version:' "$chart_file" | awk '{print $2}')
  if [ -z "$current_version" ]; then
    write_error "chart_bumpversion" "Error: No version found in $chart_file."
    continue
  fi

  new_version=$(bump_version "$current_version" "$BUMP_TYPE")

  sed -i.bak "s/^version: .*/version: $new_version/" "$chart_file"
  rm -f "$chart_file.bak"

  write_info "chart_bumpversion" "Updated $chart_file: $current_version -> $new_version"
done

write_info "Version bumping complete."

write_success "chart_bumpversion" "Done"
exit 0