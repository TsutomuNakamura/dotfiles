#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub_and_eval echo '{ command echo "$@"; }'
    stub logger_err
}
function teardown() {
    true
    unset echo
}

@test '#install_or_update_one_package_with_homebrew return 0 if the package was already installed then upgrade it' {
    stub brew
    run install_or_update_one_package_with_homebrew "gnupg"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times brew)" -eq 2 ]]
    [[ "$(stub_called_times echo)" -eq 2 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 upgrade "gnupg"
}

@test '#install_or_update_one_package_with_homebrew return 0 if the package was NOT installed then install it' {
    stub_and_eval brew '{
        [[ "$1" == "ls" ]] && return 1
        return 0
    }'

    run install_or_update_one_package_with_homebrew "gnupg"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times brew)" -eq 2 ]]
    [[ "$(stub_called_times echo)" -eq 2 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 install "gnupg"
}

@test '#install_or_update_one_package_with_homebrew return 0 if brew upgrade was succeeded because the package was already installed' {
    stub_and_eval brew '{
        [[ "$1" == "upgrade" ]] && {
            command echo "Error: gnupg 2.2.16 already installed" >&2
            return 1
        }
        return 0
    }'

    run install_or_update_one_package_with_homebrew "gnupg"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times echo)"          -eq 2 ]]
    [[ "$(stub_called_times brew)"          -eq 2 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 upgrade "gnupg"
    stub_called_with_exactly_times echo 1 "Install or upgrade gnupg"
    stub_called_with_exactly_times echo 1 "Error: gnupg 2.2.16 already installed"
}

@test '#install_or_update_one_package_with_homebrew return 1 if brew upgrade was failed' {
    stub_and_eval brew '{
        [[ "$1" == "upgrade" ]] && {
            command echo "Error: some error occured" >&2
            return 1
        }
        return 0
    }'


    run install_or_update_one_package_with_homebrew "gnupg"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times echo)"          -eq 2 ]]
    [[ "$(stub_called_times brew)"          -eq 2 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    stub_called_with_exactly_times brew 1 ls --versions "gnupg"
    stub_called_with_exactly_times brew 1 upgrade "gnupg"
    stub_called_with_exactly_times echo 1 "Install or upgrade gnupg"
    stub_called_with_exactly_times echo 1 "Error: some error occured"
    stub_called_with_exactly_times logger_err 1 "Error: some error occured"

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

