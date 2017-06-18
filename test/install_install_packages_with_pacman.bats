#!/usr/bin/env bats
load helpers

function setup() {
    true
}
function teardown() {
    true
}

@test '#install_packages_with_pacman should not call pacman with parameter "sed" when it was already installed' {
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
    [[ "${output##*$'\n'}" = "There are no packages to install." ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
    [[ "$(stub_called_with_times sudo pacman -Sy --noconfirm vim git)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman with parameter "vim", "git" when they were not installed and sed was already installed' {
    stub_and_eval sudo '{ true; }'
    stub_and_eval pacman '{
        if [[ "$1" -eq "-Qe" ]]; then
            echo "sed 4.4-1"
        fi
    }'

    run install_packages_with_pacman "sed" "vim" "git"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "Installing vim git..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_with_times sudo pacman -Sy --noconfirm vim git)" -eq 1 ]]
}

