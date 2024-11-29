#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Part4 \ Method2



EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

usage() {
    write_info "part4_method2" "./part4_method2.sh [-f <path to the file>]"
    exit 1
}

while getopts ':f:h?' opt; do
    case $opt in
        f)
            PARSE_FILEPATH=$OPTARG
            write_warning "part4_method2" "Input File: \"$PARSE_FILEPATH\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "part4_method2" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ ! -f "$PARSE_FILEPATH" ]; then
    write_error "part4_method2" "Error: File \"$PARSE_FILEPATH\" not found."
    exit 1
fi

# 1. Split by http:// (last trailing slash), if the protocol is specified
# 2. Remove trailing ".", if there is one
# 3. If it's a subdomain or CNAME, capture only the last 2 components
# 4. Case conversion from upper case to lower.

awk -F'/' '{print $NF}' $PARSE_FILEPATH | \
sed 's/\.$//' | \
awk -F'.' '{if (NF > 1) print $(NF-1)"."$NF}' | \
tr '[:upper:]' '[:lower:]' | \
sort -u > output.txt
