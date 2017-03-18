#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if (command -v hostname); then
    HOST="$(hostname)"
elif (command -v uname); then
    HOST="$(uname -n)"
fi

[[ "${HOST}" = "arch-dot-test" ]] \
        || [[ "${HOST}" = "fedora-dot-test" ]] \
        || [[ "${HOST}" = "centos-dot-test" ]] \
        || {
    echo "ERROR: This test script is not allowed executing on unexpected host because of some instruction make destructive."
    echo "ERROR: It is able to that running this script on the hostname \"arch-dot-test\", "centos-dot-test" and \"fedora-dot-test\"."
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

# Only compatible for GNU getopt
opts=$(getopt -o "t" --long "tap" -- "$@")
[[ "$?" -ne 0 ]] && {
    echo "Some error was occured in getopt"
    exit 1
}
eval set -- "$opts"
opts_for_bats=""

while true; do
    case "$1" in
        -t | --tap)
            opts_for_bats+="--tap "
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Some error occured at getopt"
            exit 1
            ;;
    esac
done

if [[ "$#" -ne 0 ]]; then
    for f in "$@"; do
        bats $opts_for_bats $f
    done
else
    bats $opts_for_bats ./test/*.bats
fi

