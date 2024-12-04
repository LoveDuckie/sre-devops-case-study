#!/usr/bin/env bash
<<EOF

   LinkExtractor \ Shell Scripts \ Part 4 \  Method1

EOF
CURRENT_SCRIPT_DIRECTORY=${CURRENT_SCRIPT_DIRECTORY:-$(dirname $(realpath ${BASH_SOURCE[0]:-${(%):-%x}}))}
export SHARED_EXT_SCRIPTS_PATH=${SHARED_EXT_SCRIPTS_PATH:-$(realpath $CURRENT_SCRIPT_DIRECTORY/../)}
export CURRENT_SCRIPT_FILENAME=${CURRENT_SCRIPT_FILENAME:-$(basename ${BASH_SOURCE[0]:-${(%):-%x}})}
export CURRENT_SCRIPT_FILENAME_BASE=${CURRENT_SCRIPT_FILENAME%.*}
. "$SHARED_EXT_SCRIPTS_PATH/shared_functions.sh"
write_header

usage() {
    write_info "part4_method1" "./part4_method1.sh [-f <path to the file>]"
    exit 1
}

while getopts ':f:h?' opt; do
    case $opt in
        f)
            PARSE_FILEPATH=$OPTARG
            write_warning "part4_method1" "Input File: \"$PARSE_FILEPATH\""
        ;;
        h|?)
            usage
        ;;
        :)
            write_error "part4_method1" "\"-${OPTARG}\" requires an argument"
            usage
        ;;
        *)
            usage
        ;;
    esac
done

if [ ! -f "$PARSE_FILEPATH" ]; then
    write_error "part4_method1" "Error: File \"$PARSE_FILEPATH\" not found."
    exit 1
fi


# 1. Make make the file content lower case
# 2. Parse out the host name, leaving https?:// behind.
# 3. Parse out the hostname. The $ regex character ensures that the pattern match is at the end of the string only.
# 4. Sort

tr '[:upper:]' '[:lower:]' < $PARSE_FILEPATH | \
grep -Eo '([a-z0-9-]+\.)+[a-z]{2,}' | \
sed -E 's/^.*\.([a-z0-9-]+\.[a-z]{2,})$/\1/' | \
sort -u > output.txt