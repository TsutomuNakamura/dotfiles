#!/usr/bin/env bats
load helpers

function setup() {
    stub prepare_vscode_debian
    stub prepare_vscode_fedora
    stub prepare_vscode_arch
    stub prepare_vscode_mac
    stub logger_info
    stub logger_err
}

@test '#prepare_vscode should return 0 if the distribution is "debian" and prepare_vscode_debian has succeeded' {
    stub_and_eval get_distribution_name '{ command echo "debian"; }'
    run prepare_vscode

    [ "$status" -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 1 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]

    stub_called_with_exactly_times logger_info 1 "Visual Studio Code has installed on \"debian\""
}

@test '#prepare_vscode should return 0 if the distribution is "ubuntu" and prepare_vscode_debian has succeeded' {
    stub_and_eval get_distribution_name '{ command echo "ubuntu"; }'
    run prepare_vscode

    [ "$status" -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 1 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]

    stub_called_with_exactly_times logger_info 1 "Visual Studio Code has installed on \"ubuntu\""
}

@test '#prepare_vscode should return 0 if the distribution is "debian" and prepare_vscode_debian has failed' {
    stub_and_eval get_distribution_name '{ command echo "debian"; }'
    stub_and_eval prepare_vscode_debian '{ return 1; }'
    run prepare_vscode

    [ "$status" -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 0 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]
}

@test '#prepare_vscode should return 0 if the distribution is "fedora" and prepare_vscode_fedora has succeeded' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'
    run prepare_vscode

    [ "$status" -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 1 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]

    stub_called_with_exactly_times logger_info 1 "Visual Studio Code has installed on \"fedora\""
}

@test '#prepare_vscode should return 0 if the distribution is "centos" and prepare_vscode_fedora has succeeded' {
    stub_and_eval get_distribution_name '{ command echo "centos"; }'
    run prepare_vscode

    [ "$status" -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 1 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]

    stub_called_with_exactly_times logger_info 1 "Visual Studio Code has installed on \"centos\""
}

@test '#prepare_vscode should return 0 if the distribution is "fedora" and prepare_vscode_fedora has failed' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'
    stub_and_eval prepare_vscode_fedora '{ return 1; }'
    run prepare_vscode

    [ "$status" -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 0 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]
}

@test '#prepare_vscode should return 0 if the distribution is "arch" and prepare_vscode_arch has succeeded' {
    stub_and_eval get_distribution_name '{ command echo "arch"; }'
    run prepare_vscode

    [ "$status" -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 1 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 1 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]
}

@test '#prepare_vscode should return 0 if the distribution is "arch" and prepare_vscode_arch has failed' {
    stub_and_eval get_distribution_name '{ command echo "arch"; }'
    stub_and_eval prepare_vscode_arch '{ return 1; }'
    run prepare_vscode

    [ "$status" -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 1 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 0 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]
}

@test '#prepare_vscode should return 0 if the distribution is "mac" and prepare_vscode_mac has succeeded' {
    stub_and_eval get_distribution_name '{ command echo "mac"; }'
    run prepare_vscode

    [ "$status" -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 1 ]
    [ "$(stub_called_times logger_info)"                        -eq 1 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]
}

@test '#prepare_vscode should return 0 if the distribution is "mac" and prepare_vscode_mac has failed' {
    stub_and_eval get_distribution_name '{ command echo "mac"; }'
    stub_and_eval prepare_vscode_mac '{ return 1; }'
    run prepare_vscode

    [ "$status" -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 1 ]
    [ "$(stub_called_times logger_info)"                        -eq 0 ]
    [ "$(stub_called_times logger_err)"                         -eq 0 ]
}

@test '#prepare_vscode should return 0 and print message if the distribution is unknown' {
    stub_and_eval get_distribution_name '{ command echo "unknown"; }'
    run prepare_vscode

    [ "$status" -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"              -eq 1 ]
    [ "$(stub_called_times prepare_vscode_debian)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_fedora)"              -eq 0 ]
    [ "$(stub_called_times prepare_vscode_arch)"                -eq 0 ]
    [ "$(stub_called_times prepare_vscode_mac)"                 -eq 0 ]
    [ "$(stub_called_times logger_info)"                        -eq 0 ]
    [ "$(stub_called_times logger_err)"                         -eq 1 ]

    stub_called_with_exactly_times logger_err 1 "Sorry, this dotfiles installer only supports to install Visual Studio Code on Debian, Ubuntu, Fedora, CentOS, Arch Linux and Mac OS X. If you want to install Visual Studio Code on other distributions, please install it manually."
}

