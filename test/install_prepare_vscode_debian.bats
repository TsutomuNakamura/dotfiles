#!/usr/bin/env bats
load helpers

function setup() {
    stub logger_err
    stub curl
    stub gpg
    stub sudo
    stub rm
    stub_and_eval get_distribution_name '{ command echo "debian"; }'
}

function teardown() {
    command rm -f /tmp/microsoft.gpg
}

@test '#prepare_vscode_debian should return 0 if all instructions have succeeded' {
    run prepare_vscode_debian

    [ "$status" -eq 0 ]
    [ "$(stub_called_times logger_err)"               -eq 0 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 4 ]
    [ "$(stub_called_times rm)"                       -eq 1 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times sudo 1 "install" "-o" "root" "-g" "root" "-m" "644" "/tmp/microsoft.gpg" "/etc/apt/trusted.gpg.d/microsoft.gpg"
    stub_called_with_exactly_times rm 1 "/tmp/microsoft.gpg"
    stub_called_with_exactly_times sudo 1 "sh" "-c" "echo \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list"
    stub_called_with_exactly_times sudo 1 "apt-get" "update"
    stub_called_with_exactly_times sudo 1 "apt-get" "install" "-y" "code"
    [ -f /tmp/microsoft.gpg ]
}

@test '#prepare_vscode_debian should return 1 if curl to download a key has failed' {
    stub_and_eval curl '{ return 1; }'
    run prepare_vscode_debian

    [ "$status" -eq 1 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 0 ]
    [ "$(stub_called_times rm)"                       -eq 0 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times logger_err 1 "Failed to download microsoft.asc from https://packages.microsoft.com/keys/microsoft.asc on \"debian\""
    [ -f /tmp/microsoft.gpg ]
}

@test '#prepare_vscode_debian should return 1 if gpg to store a key has failed' {
    stub_and_eval gpg '{ return 1; }'
    run prepare_vscode_debian

    [ "$status" -eq 1 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 0 ]
    [ "$(stub_called_times rm)"                       -eq 0 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times logger_err 1 "Failed to download microsoft.asc from https://packages.microsoft.com/keys/microsoft.asc on \"debian\""
    [ -f /tmp/microsoft.gpg ]
}

@test '#prepare_vscode_debian should return 1 if sudo to install a key has failed' {
    stub_and_eval sudo '{
        if [ "$1" = "install" ]; then
            return 1
        fi
        return 0
    }'
    run prepare_vscode_debian

    [ "$status" -eq 1 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 1 ]
    [ "$(stub_called_times rm)"                       -eq 0 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times sudo 1 "install" "-o" "root" "-g" "root" "-m" "644" "/tmp/microsoft.gpg" "/etc/apt/trusted.gpg.d/microsoft.gpg"
    stub_called_with_exactly_times logger_err 1 "Failed to install /tmp/microsoft.gpg to /etc/apt/trusted.gpg.d/microsoft.gpg on \"debian\""
    [ -f /tmp/microsoft.gpg ]
}

@test '#prepare_vscode_debian should return 1 if sudo to run a shell has failed' {
    stub_and_eval sudo '{
        if [ "$1" = "sh" ]; then
            return 1
        fi
        return 0
    }'
    run prepare_vscode_debian

    [ "$status" -eq 1 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 2 ]
    [ "$(stub_called_times rm)"                       -eq 1 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times sudo 1 "install" "-o" "root" "-g" "root" "-m" "644" "/tmp/microsoft.gpg" "/etc/apt/trusted.gpg.d/microsoft.gpg"
    stub_called_with_exactly_times rm 1 "/tmp/microsoft.gpg"
    stub_called_with_exactly_times sudo 1 "sh" "-c" "echo \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list"
    stub_called_with_exactly_times logger_err 1 "Failed to add a repository of Visual Studio Code to /etc/apt/sources.list.d/vscode.list on \"debian\""
    [ -f /tmp/microsoft.gpg ]
}

@test '#prepare_vscode_debian should return 1 if \"sudo apt-get update\" has failed' {
    stub_and_eval sudo '{
        if [ "$1" = "apt-get" ] && [ "$2" = "update" ]; then
            return 1
        fi
        return 0
    }'
    run prepare_vscode_debian

    [ "$status" -eq 1 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 3 ]
    [ "$(stub_called_times rm)"                       -eq 1 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times sudo 1 "install" "-o" "root" "-g" "root" "-m" "644" "/tmp/microsoft.gpg" "/etc/apt/trusted.gpg.d/microsoft.gpg"
    stub_called_with_exactly_times rm 1 "/tmp/microsoft.gpg"
    stub_called_with_exactly_times sudo 1 "sh" "-c" "echo \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list"
    stub_called_with_exactly_times sudo 1 "apt-get" "update"
    stub_called_with_exactly_times logger_err 1 "Failed to update apt-get on \"debian\""
    [ -f /tmp/microsoft.gpg ]
}

@test '#prepare_vscode_debian should return 1 if \"sudo install -y code\" has failed' {
    stub_and_eval sudo '{
        if [ "$1" = "apt-get" ] && [ "$2" = "install" ]; then
            return 1
        fi
        return 0
    }'
    run prepare_vscode_debian

    [ "$status" -eq 1 ]
    [ "$(stub_called_times curl)"                     -eq 1 ]
    [ "$(stub_called_times gpg)"                      -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 4 ]
    [ "$(stub_called_times rm)"                       -eq 1 ]

    stub_called_with_exactly_times curl 1 "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times gpg 1 "--dearmor"
    stub_called_with_exactly_times sudo 1 "install" "-o" "root" "-g" "root" "-m" "644" "/tmp/microsoft.gpg" "/etc/apt/trusted.gpg.d/microsoft.gpg"
    stub_called_with_exactly_times rm 1 "/tmp/microsoft.gpg"
    stub_called_with_exactly_times sudo 1 "sh" "-c" "echo \"deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main\" > /etc/apt/sources.list.d/vscode.list"
    stub_called_with_exactly_times sudo 1 "apt-get" "update"
    stub_called_with_exactly_times sudo 1 "apt-get" "install" "-y" "code"
    stub_called_with_exactly_times logger_err 1 "Failed to install Visual Studio Code with apt-get on \"debian\""
    [ -f /tmp/microsoft.gpg ]
}

