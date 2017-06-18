#!/bin/bash

# Count file, directory or link in the target directory.
function count() {
    find $1 -maxdepth 1 -mindepth 1 \( -type f -or -type d -or -type l \) | wc -l;
}

# Check the array where the element is exist or not.
function contains() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

_call_count_dir="/var/tmp/_callcount_"
function increment_call_count() {
    local function_name="$1"

    if [[ ! -d "$_call_count_dir"  ]]; then
        mkdir -p "$_call_count_dir"
    fi

    if [[ ! -f "${_call_count_dir}/${function_name}" ]]; then
        echo 1 > ${_call_count_dir}/${function_name}
    else
        echo $(( $(cat ${_call_count_dir}/${function_name}) + 1 )) > ${_call_count_dir}/${function_name}
    fi
}

function clear_call_count() {
    rm -rf ${_call_count_dir}
}

function call_count() {
    local function_name="$1"
    if [[ ! -f "${_call_count_dir}/${function_name}" ]]; then
        echo 0
    else
        cat ${_call_count_dir}/${function_name}
    fi
}

BATS_TEST_SKIPPED=
SCRIPT_DIR="$(dirname "$(readlink -f "$BASH_SOURCE")")"
. ${SCRIPT_DIR}/../stub4bats.sh/stub.sh
. ${SCRIPT_DIR}/../install.sh --load-functions

