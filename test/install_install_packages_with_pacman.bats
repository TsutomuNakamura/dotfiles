#!/usr/bin/env bats
load helpers

function setup() {
    true
}
function teardown() {
    true
}

@test '#install_packages_with_pacman should call pacman with parameter "gc" when it was not installed' {
    stub_and_eval sudo '{
        true
    }'
    stub_and_eval pacman '{
        if [[ "$1" -eq "-Qe" ]]; then
            echo "sed 4.4-1"
        fi
    }'

    run install_packages_with_pacman "sed"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "Installing gc..." ]]
}

@test '#install_packages_with_pacman should call pacman with parameter "gc", "vim" when it was not installed' {
    stub_and_eval sudo '{ true; }'
    stub_and_eval pacman '{
        if [[ "$1" -eq "-Qe" ]]; then
            echo "sed 4.4-1"
        fi
    }'

    run install_packages_with_pacman "sed" "vim" "git"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "Installing gc..." ]]
}



