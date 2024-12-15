#!/usr/bin/env bats
load helpers

function setup() {
    stub logger_err
    stub sudo
    stub echo
    stub yum
    stub dnf
}

@test '#prepare_vscode_fedora should return 0 if all instructions have succeeded' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'

    run prepare_vscode_fedora

    [ "$status" -eq 0 ]
    [ "$(stub_called_times sudo)"                     -eq 3 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 1 ]
    [ "$(stub_called_times yum)"                      -eq 0 ]
    [ "$(stub_called_times dnf)"                      -eq 1 ]
    [ "$(stub_called_times logger_err)"               -eq 0 ]

    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times echo 1 "-e" "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times dnf 1 "check-update"
    stub_called_with_exactly_times sudo 1 "dnf" "install" "-y" "code"
}

@test '#prepare_vscode_fedora should return 0 if all instructions have succeeded and distribution is Centos' {
    stub_and_eval get_distribution_name '{ command echo "centos"; }'

    run prepare_vscode_fedora

    [ "$status" -eq 0 ]
    [ "$(stub_called_times sudo)"                     -eq 3 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 1 ]
    [ "$(stub_called_times yum)"                      -eq 1 ]
    [ "$(stub_called_times dnf)"                      -eq 0 ]
    [ "$(stub_called_times logger_err)"               -eq 0 ]

    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times echo 1 "-e" "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times yum 1 "check-update"
    stub_called_with_exactly_times sudo 1 "yum" "install" "-y" "code"
}

@test '#prepare_vscode_fedora should return 1 if \"sudo rpm import https://...\" has failed' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'
    stub_and_eval sudo '{
        if [ "$1" = "rpm" ]; then
            return 1
        fi
        return 0
    }'

    run prepare_vscode_fedora

    [ "$status" -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 1 ]
    [ "$(stub_called_times echo)"                     -eq 0 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 0 ]
    [ "$(stub_called_times yum)"                      -eq 0 ]
    [ "$(stub_called_times dnf)"                      -eq 0 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]

    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times logger_err 1 "Failed to import a key with a command \"sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc\""
}

@test '#prepare_vscode_fedora should return 1 if \"sudo tee /etc/yum.repos.d/vscode.repo\" has failed' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'
    stub_and_eval sudo '{
        if [ "$1" = "tee" ]; then
            return 1
        fi
        return 0
    }'

    run prepare_vscode_fedora

    [ "$status" -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 2 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 0 ]
    [ "$(stub_called_times yum)"                      -eq 0 ]
    [ "$(stub_called_times dnf)"                      -eq 0 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times logger_err 1 "Failed to import a repository in a file \"/etc/yum.repos.d/vscode.repo\""
}

@test '#prepare_vscode_fedora should return 1 if \"dnf check-update\" for Fedora has failed' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'
    stub_and_eval dnf '{ return 1; }'

    run prepare_vscode_fedora

    [ "$status" -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 2 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 1 ]
    [ "$(stub_called_times yum)"                      -eq 0 ]
    [ "$(stub_called_times dnf)"                      -eq 1 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times dnf 1 "check-update"
    stub_called_with_exactly_times logger_err 1 "Failed to run \"dnf check-update\""
}

@test '#prepare_vscode_fedora should return 1 if \"dnf install -y code\" for Fedora has failed' {
    stub_and_eval get_distribution_name '{ command echo "fedora"; }'
    stub_and_eval sudo '{
        if [ "$1" = "dnf" ]; then
            return 1
        fi
        return 0
    }'

    run prepare_vscode_fedora

    [ "$status" -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 3 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 1 ]
    [ "$(stub_called_times yum)"                      -eq 0 ]
    [ "$(stub_called_times dnf)"                      -eq 1 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times dnf 1 "check-update"
    stub_called_with_exactly_times sudo 1 "dnf" "install" "-y" "code"
    stub_called_with_exactly_times logger_err 1 "Failed to run \"sudo dnf install -y code\""
}

@test '#prepare_vscode_fedora should return 1 if \"yum check-update\" for Centos has failed' {
    stub_and_eval get_distribution_name '{ command echo "centos"; }'
    stub_and_eval yum '{ return 1; }'

    run prepare_vscode_fedora

    [ "$status" -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 2 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 1 ]
    [ "$(stub_called_times yum)"                      -eq 1 ]
    [ "$(stub_called_times dnf)"                      -eq 0 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times yum 1 "check-update"
    stub_called_with_exactly_times logger_err 1 "Failed to run \"yum check-update\""
}

@test '#prepare_vscode_fedora should return 1 if \"sudo yum install -y code\" for Centos has failed' {
    stub_and_eval get_distribution_name '{ command echo "centos"; }'
    stub_and_eval sudo '{
        if [ "$1" = "yum" ]; then
            return 1
        fi
        return 0
    }'

    run prepare_vscode_fedora

    [ "$status" -eq 1 ]
    [ "$(stub_called_times sudo)"                     -eq 3 ]
    [ "$(stub_called_times echo)"                     -eq 1 ]
    [ "$(stub_called_times get_distribution_name)"    -eq 1 ]
    [ "$(stub_called_times yum)"                      -eq 1 ]
    [ "$(stub_called_times dnf)"                      -eq 0 ]
    [ "$(stub_called_times logger_err)"               -eq 1 ]
    stub_called_with_exactly_times sudo 1 "rpm" "--import" "https://packages.microsoft.com/keys/microsoft.asc"
    stub_called_with_exactly_times sudo 1 "tee" "/etc/yum.repos.d/vscode.repo"
    stub_called_with_exactly_times yum 1 "check-update"
    stub_called_with_exactly_times sudo 1 "yum" "install" "-y" "code"
    stub_called_with_exactly_times logger_err 1 "Failed to run \"sudo yum install -y code\""
}

