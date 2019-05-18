#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    cd ${HOME}
    stub sudo
    function command() {
        [[ "$1" == "-v" ]] && [[ "$2" == "sudo" ]] && {
            return 0
        }
        return 1
    }
    stub logger_info
    stub logger_err
}

function teardown() {
    true
}

@test '#add_additional_repositories_for_ubuntu should return 0 if the instructions were all succeeded' {
    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times sudo)"              -eq 3 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times logger_info 1 'Added additional apt repositories. (ppa:neovim-ppa/stable)'
}

@test '#add_additional_repositories_for_ubuntu should return 1 if apt-get update was failed' {
    stub_and_eval sudo '{
        [[ "$1" == "apt-get" ]] && [[ "$2" == "update" ]] && {
            return 1
        }
        return 0
    }'
    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 'Some error has occured when updating packages with apt-get update.'
}

@test '#add_additional_repositories_for_ubuntu should return 1 if `apt-get install -y software-properties-common` was failed' {
    stub_and_eval sudo '{
        [[ "$1" == "DEBIAN_FRONTEND=noninteractive" ]] && [[ "$2" == "apt-get" ]] && [[ "$3" == "install" ]] && [[ "$4" == "-y" ]] && [[ "$5" == "software-properties-common" ]] && {
            return 1
        }
        return 0
    }'
    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]

    stub_called_with_exactly_times logger_err 1 'Failed to install software-properties-common'
}

@test '#add_additional_repositories_for_ubuntu should return 1 if `add-apt-repository ppa:neovim-ppa/stable -y` was failed' {
    stub_and_eval sudo '{
        [[ "$1" == "add-apt-repository" ]] && [[ "$2" == "ppa:neovim-ppa/stable" ]] && [[ "$3" == "-y" ]] && {
            return 1
        }
        return 0
    }'
    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)" -eq 3 ]]

    stub_called_with_exactly_times logger_err 1 'Failed to add repository ppa:neovim-ppa/stable'
}

