#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

HOST="$(hostname)"
[[ "${HOST}" = "arch-dot-test" ]] \
        || [[ "${HOST}" = "fedora-dot-test" ]] \
        || {
    echo "ERROR: This test script is not allowed executing on unexpected host because of some instruction make destructive."
    echo "ERROR: It is able to that running this script on the hostname \"arch-dot-test\"."
    exit 1
}

export PATH="${SCRIPT_DIR}/bats/bin:${PATH}"
if ! (command -v bats > /dev/null); then
    rm -rf bats.git bats
    git clone --depth 1 https://github.com/sstephenson/bats.git bats.git
    mkdir -p bats
    cd bats.git
    ./install.sh ${SCRIPT_DIR}/bats
    sync
    cd ../
fi

if [[ "$#" -ne 0 ]]; then
    for f in "$@"; do
        bats $f
    done
else
    bats ./test/*.bats
fi

