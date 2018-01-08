#!/usr/bin/env bash

URL_OF_BATS="https://github.com/sstephenson/bats.git"
URL_OF_STUBSH="https://github.com/TsutomuNakamura/stub4bats.sh"

function main() {
    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Is this container environment
    if [[ ! -e "/.dockerenv" ]] && [[ "${TRAVIS}" != "true" ]]; then
        echo "ERROR: This sciprt can run only on docker environment." >&2
        echo "       If you want to run except the docker environment, specifi --no-docker-environment "
        exit 1
    fi

    local dir_of_test_lib="${script_dir}/test/lib"
    [[ ! -d "${dir_of_test_lib}" ]] && mkdir -p "${dir_of_test_lib}"

    cd "${dir_of_test_lib}" || {
        echo "ERROR: Failed to change directory ${dir_of_test_lib}."
        return 1
    }

    # bats is installed or not?
    export PATH="${dir_of_test_lib}/bats/bin:${PATH}"
    ! (command -v bats > /dev/null 2>&1) && {
        rm -rf bats.git bats
        git clone --depth 1 "${URL_OF_BATS}" bats.git
        mkdir -p bats
        pushd bats.git
        ./install.sh "${dir_of_test_lib}/bats"
        sync
        popd
    }

    # stub.sh is installed or not
    [[ ! -d "./stub4bats.sh" ]] && {
        rm -rf stub4bats.sh
        git clone --depth 1 "${URL_OF_STUBSH}" stub4bats.sh
    }

    cd "$script_dir"

    local optspec=":t-:"
    local opts_for_bats=""

    while getopts "$optspec" optchar; do
        if [[ "$optchar" == "t" ]]; then
            optchar="-" && OPTARG="tap"
        fi

        case "$optchar" in
        - )
            case "$OPTARG" in
            tap )
                opts_for_bats+="--tap "
                ;;
            ? )
                echo "ERROR: Unknown option" >&2
                return 1
            esac
            ;;
        esac
    done

    if [[ "$#" -ne 0 ]]; then
        for f in "$@"; do
            bats $opts_for_bats "$f"
        done
    else
        bats $opts_for_bats ./test/*.bats
    fi
    exit
}

main "$@"

