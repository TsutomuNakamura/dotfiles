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
    stub add_yarn_repository_to_debian_like_systems
    stub logger_info
    stub logger_err
}

function teardown() {
    true
}

@test '#add_additional_repositories_for_ubuntu should return 0 if the instructions were all succeeded' {
    stub_and_eval get_linux_os_version '{ builtin echo "18.04"; }'

    run add_additional_repositories_for_ubuntu
    builtin echo "$output"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times sudo)"                                          -eq 2 ]]
    [[ "$(stub_called_times get_linux_os_version)"                          -eq 1 ]]
    #[[ "$(stub_called_times add_yarn_repository_to_debian_like_systems)"    -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                                   -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                                    -eq 0 ]]

    stub_called_with_exactly_times logger_info 1 'No need to add a repository for Neovim to Ubuntu 18.04. Skipped it'
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
    [[ "$(stub_called_times sudo)"                                          -eq 1 ]]
    [[ "$(stub_called_times get_linux_os_version)"                          -eq 0 ]]
    #[[ "$(stub_called_times add_yarn_repository_to_debian_like_systems)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                                   -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                                    -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 'Some error has occured when updating packages with apt-get update.'
}

@test '#add_additional_repositories_for_ubuntu should return 1 if \`apt-get install -y software-properties-common\` was failed' {
    stub_and_eval sudo '{
        [[ "$1" == "DEBIAN_FRONTEND=noninteractive" ]] && [[ "$2" == "apt-get" ]] && [[ "$3" == "install" ]] && [[ "$4" == "-y" ]] && [[ "$5" == "software-properties-common" ]] && {
            return 1
        }
        return 0
    }'
    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)"                                          -eq 2 ]]
    [[ "$(stub_called_times get_linux_os_version)"                          -eq 0 ]]
    #[[ "$(stub_called_times add_yarn_repository_to_debian_like_systems)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                                   -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                                    -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 'Failed to install software-properties-common'
}

@test '#add_additional_repositories_for_ubuntu should return 1 if get_linux_os_version() was failed' {
    stub_and_eval get_linux_os_version '{ false; }'

    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)"                                          -eq 2 ]]
    [[ "$(stub_called_times get_linux_os_version)"                          -eq 1 ]]
    #[[ "$(stub_called_times add_yarn_repository_to_debian_like_systems)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                                   -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                                    -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 'Failed to get os version for ubuntu at add_additional_repositories_for_ubuntu()'
}

@test '#add_additional_repositories_for_ubuntu should return 1 if \`add-apt-repository ppa:neovim-ppa/stable -y\` was failed' {
    stub_and_eval sudo '{
        [[ "$1" == "add-apt-repository" ]] && [[ "$2" == "ppa:neovim-ppa/stable" ]] && [[ "$3" == "-y" ]] && {
            return 1
        }
        return 0
    }'
    stub_and_eval get_linux_os_version '{ builtin echo "17.10"; }'

    run add_additional_repositories_for_ubuntu

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)"                                          -eq 3 ]]
    [[ "$(stub_called_times get_linux_os_version)"                          -eq 1 ]]
    #[[ "$(stub_called_times add_yarn_repository_to_debian_like_systems)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                                   -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                                    -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 'Failed to add repository ppa:neovim-ppa/stable'
}

#@test '#add_additional_repositories_for_ubuntu should return 1 if "add_yarn_repository_to_debian_like_systems" was failed' {
#    stub_and_eval get_linux_os_version '{ builtin echo "20.04"; }'
#    #stub_and_eval add_yarn_repository_to_debian_like_systems '{ return 1; }'
#
#    run add_additional_repositories_for_ubuntu
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times sudo)"                                          -eq 2 ]]
#    [[ "$(stub_called_times get_linux_os_version)"                          -eq 1 ]]
#    #[[ "$(stub_called_times add_yarn_repository_to_debian_like_systems)"    -eq 1 ]]
#    [[ "$(stub_called_times logger_info)"                                   -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                    -eq 0 ]]
#}

