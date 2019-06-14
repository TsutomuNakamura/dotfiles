#!/usr/bin/env bats
load helpers "install.sh"

function setup() {

    function brew() { echo "/usr/local"; }

    declare -g -a DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC=(
        "/sbin"
        "/bin"
    )

    stub logger_err
    stub has_permission_to_rw
}

function teardown() {
    true
}

@test '#check_environment_of_mac return 0 if all instructions were succeeded and DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC has 2 elements' {
    run check_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times has_permission_to_rw)"          -eq 2 ]]
}

@test '#check_environment_of_mac return 0 if all instructions were succeeded and DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC has 1 elements' {
    declare -g -a DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC=("/sbin")
    run check_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times has_permission_to_rw)"          -eq 1 ]]
}

@test '#check_environment_of_mac return 0 if all instructions were succeeded and DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC has no elements' {
    declare -g -a DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC=()
    run check_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times has_permission_to_rw)"          -eq 0 ]]
}

@test '#check_environment_of_mac return 1 if one of a directory in DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC does not existed' {
    declare -g -a DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC=("/un_existed_directory")
    run check_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times has_permission_to_rw)"          -eq 0 ]]

    local msg="Directory \"/usr/local/un_existed_directory\" that may be required by brew does not exist.\n"
    msg+="    Rerun this script after you create directory \"/usr/local/un_existed_directory\"\n"
    msg+="    example with bash)\n"
    msg+="        sudo mkdir \"/usr/local/un_existed_directory\"\n"
    msg+="        sudo chown $(whoami) \"/usr/local/un_existed_directory\""
    stub_called_with_exactly_times logger_err 1 "$msg"
}

@test '#check_environment_of_mac return 1 if has_permission_to_rw was failed' {
    stub_and_eval has_permission_to_rw '{ return 1; }'
    run check_environment


    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times has_permission_to_rw)"          -eq 1 ]]

    local msg="Directory \"/usr/local/sbin\" not permitted to write and read by user $(whoami)."
    msg+="    Please check your permission whether you have a permission to read/write to the directory \"/usr/local/sbin\""
    stub_called_with_exactly_times logger_err 1 "$msg"
}

