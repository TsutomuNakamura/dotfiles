#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    true
}
function teardown() {
    true
}

@test '#install_or_update_one_package_with_homebrew return 0 if the package was already installed then upgrade it' {
    stub brew
    run install_or_update_one_package_with_homebrew "gnupg"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times brew)" -eq 2 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 upgrade "gnupg"
}

@test '#install_or_update_one_package_with_homebrew return 0 if the package was already installed then upgrade it' {
    stub_and_eval brew '{
        [[ "$1" == "ls" ]] && return 1
        return 0
    }'

    run install_or_update_one_package_with_homebrew "gnupg"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times brew)" -eq 2 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 install "gnupg"
}

@test '#install_or_update_one_package_with_homebrew return 1 if brew upgrade was failed' {
    stub_and_eval brew '{
        [[ "$1" == "upgrade" ]] && return 1
        return 0
    }'

    run install_or_update_one_package_with_homebrew "gnupg"

    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times brew)" -eq 2 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 upgrade "gnupg"
}

@test '#install_or_update_one_package_with_homebrew return 1 if brew install was failed' {
    stub_and_eval brew '{
        [[ "$1" == "ls" ]] && return 1
        [[ "$1" == "install" ]] && return 1
        return 0
    }'

    run install_or_update_one_package_with_homebrew "gnupg"

    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times brew)" -eq 2 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 install "gnupg"
}

