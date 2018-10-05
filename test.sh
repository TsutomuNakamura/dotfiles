#!/usr/bin/env bash

URL_OF_BATS="https://github.com/sstephenson/bats.git"
URL_OF_STUBSH="https://github.com/TsutomuNakamura/stub4bats.sh"

function main() {
    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd "$script_dir"

    [[ "$1" == "--suite" ]] && {
        test_all || {
            echo "ERROR: Failed to test due to some errors"
            return 1
        }
        return 0
    }

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

function build_docker_image() {
    local image_name="$1"
    local dockerfile="$2"

    local ret=
    local dir_of_dockerfile="$(dirname "$dockerfile")"
    local dockerfile_name="$(basename "$dockerfile")"

    pushd "$dir_of_dockerfile" || {
        echo "ERROR: Failed to change the directory to $dir_of_dockerfile"
        return 1
    }

    echo "INFO: Building docker image $image_name"
    docker build -t="$image_name" -f "$dockerfile_name" .
    ret=$?
    popd

    return $ret
}

function test_all() {
    local user_name="$(whoami)"
    local ret
    declare -A labels=(
        ["ubuntu1804-dot-test"]="./test/container/ubuntu/Dockerfile1804"
        ["ubuntu1604-dot-test"]="./test/container/ubuntu/Dockerfile1604"
        ["centos-dot-test"]="./test/container/centos/Dockerfile"
        ["fedora-dot-test"]="./test/container/fedora/Dockerfile"
        ["arch-dot-test"]="./test/container/arch/Dockerfile"
    )

    local key
    local current="$(date +%s)"
    local current_date_string="$(date +%Y%m%d%H%M%S)"
    local duration_of_expired=$((1 * 60 * 60 * 24 * 14))
    declare -a images=()

    # Create new docker images
    for key in "${!labels[@]}"; do
        # Create docker image
        local image_name="${user_name}/${key}:latest"
        images+=("${image_name}")
        local hash_of_image="$(docker images -q ${user_name}/${key}:latest)"
        if [[ -z "$hash_of_image" ]]; then
            build_docker_image "$image_name" "${labels[${key}]}" || {
                echo "ERROR: Failed to re-building docker image has failed." >&2
                return 1
            }
            continue
        fi

        created_date=$(docker inspect -f '{{ .Created }}' ${image_name} | grep -P -o '[0-9]{4}\-[0-9]{2}\-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')
        if [[ $duration_of_expired -lt $((current - created_date_string)) ]]; then
            docker rmi
            build_docker_image "$image_name" "${labels[${key}]}" || {
                echo "ERROR: Failed to re-building docker image has failed." >&2
                return 1
            }
            continue
        fi
    done

    for key in "${!labels[@]}"; do
        # Run test cases on each environment
        local image_name="${user_name}/${key}:latest"
        if [[ "$key" == "arch-dot-test" ]]; then
            # Only one test case which has installing font will be tested due to much consumption of the time.
            set -o pipefail
            docker run --rm --volume ${PWD}:/home/foo/dotfiles -ti "$image_name" \
                    /bin/bash -c "mkdir -p /usr/share/xsessions; touch /usr/share/xsessions/gnome.desktop; su - foo bash -c 'bash <(cat ~/dotfiles/install.sh)'" | \
                    tee "./${key}_${current_date_string}_with_font.log"
            ret=$?
            set +o pipefail
            [[ $ret -ne 0 ]] && {
                echo -n "ERROR: Testing has failed on $key with desktop environment." >&2
                echo    "Check log ${key}_${current_date_string}_with_font.log" >&2
                return 1
            }
        fi

        set -o pipefail
        docker run --rm --volume ${PWD}:/home/foo/dotfiles -ti "$image_name" \
                /bin/bash -c "su - foo bash -c 'bash <(cat ~/dotfiles/install.sh)'" | \
                tee "./${key}_${current_date_string}.log"
        ret=$?
        set +o pipefail
        [[ $ret -ne 0 ]] && {
            echo -n "ERROR: Testing has failed on ${key}." >&2
            echo    "Check log ${key}_${current_date_string}.log" >&2
            return 1
        }
    done

    # All test cases have succeeded
    return 0
}

main "$@"

