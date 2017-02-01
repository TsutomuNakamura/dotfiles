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


BATS_TEST_SKIPPED=
SCRIPT_DIR="$(dirname "$(readlink -f "$BASH_SOURCE")")"
. ${SCRIPT_DIR}/../install.sh --load-functions

