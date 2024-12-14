#!/usr/bin/env bats
load helpers

function setup() {
    stub wget
    stub sudo
    stub echo
    stub logger_err
}

function teardown() {
    true
}

@test '#add_yarn_repository_to_debian_like_systems should return 0 if all instruction was succeeded' {
    run add_yarn_repository_to_debian_like_systems; command echo $output

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times wget)"          -eq 1 ]]
    [[ "$(stub_called_times sudo)"          -eq 2 ]]
    [[ "$(stub_called_times echo)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]

    stub_called_with_exactly_times wget 1 '-qO' '-' 'https://dl.yarnpkg.com/debian/pubkey.gpg'
    stub_called_with_exactly_times echo 1 'deb https://dl.yarnpkg.com/debian/ stable main'
    stub_called_with_exactly_times sudo 1 'apt-key' 'add' '-'
    stub_called_with_exactly_times sudo 1 'tee' '/etc/apt/sources.list.d/yarn.list'
}

@test '#add_yarn_repository_to_debian_like_systems should return 1 if adding gpg key was failed' {
    # "apt-key add" will fail if the result of wget was wrong.
    # No need to test wget command sololy.
    stub_and_eval sudo '{
        [[ "$1" == "apt-key" ]] && return 1
        return 0
    }'
    run add_yarn_repository_to_debian_like_systems; command echo $output

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times wget)"          -eq 1 ]]
    [[ "$(stub_called_times sudo)"          -eq 1 ]]
    [[ "$(stub_called_times echo)"          -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    stub_called_with_exactly_times wget 1 '-qO' '-' 'https://dl.yarnpkg.com/debian/pubkey.gpg'
    stub_called_with_exactly_times sudo 1 'apt-key' 'add' '-'
    stub_called_with_exactly_times logger_err 1 "Failed to add yarn repository's gpg key from https://dl.yarnpkg.com/debian/pubkey.gpg"
}

@test '#add_yarn_repository_to_debian_like_systems should return 1 if adding repository was failed' {
    stub_and_eval sudo '{
        [[ "$1" == "tee" ]] && return 1
        return 0
    }'
    run add_yarn_repository_to_debian_like_systems; command echo $output

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times wget)"          -eq 1 ]]
    [[ "$(stub_called_times sudo)"          -eq 2 ]]
    [[ "$(stub_called_times echo)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    stub_called_with_exactly_times wget 1 '-qO' '-' 'https://dl.yarnpkg.com/debian/pubkey.gpg'
    stub_called_with_exactly_times sudo 1 'apt-key' 'add' '-'
    stub_called_with_exactly_times sudo 1 'tee' '/etc/apt/sources.list.d/yarn.list'
    stub_called_with_exactly_times echo 1 'deb https://dl.yarnpkg.com/debian/ stable main'
    stub_called_with_exactly_times logger_err 1 "Failed to add yarn repository to /etc/apt/sources.list.d/yarn.list"
}


