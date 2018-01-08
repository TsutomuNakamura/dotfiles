#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub apt-get
    stub sudo
    stub logger_info
    stub logger_err
    function command() { return 0; }
}

# function teardown() {}

@test '#install_packages_with_apt should call apt-get with parameter "vim" when it was not installed' {
    stub_and_eval apt '{
        if [[ "$1" = "list" ]] && [[ "$2" = "--installed" ]]; then
            # echo "vim/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "vim-common/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed,automatic]"
            echo "vim-gtk/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "git/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 amd64 [installed]"
            echo "git-man/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 all [installed,automatic]"
        fi
    }'
    run install_packages_with_apt vim

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing vim..." ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times sudo 1 apt-get install -y vim
    stub_called_with_exactly_times logger_info 1 "Packages vim have been installed."
}

@test '#install_packages_with_apt should NOT call apt-get if all packages going to be installed have already been installed' {
    stub_and_eval apt '{
        if [[ "$1" = "list" ]] && [[ "$2" = "--installed" ]]; then
            echo "vim/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "vim-common/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed,automatic]"
            echo "vim-gtk/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "git/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 amd64 [installed]"
            echo "git-man/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 all [installed,automatic]"
        fi
    }'
    run install_packages_with_apt vim

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "vim has already installed. Skipped." ]]
    [[ "${outputs[1]}" = "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times apt-get)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times sudo 1 apt-get update
}

@test '#install_packages_with_apt should call apt-get with parameter "vim" "tmux" when it was not installed' {
    stub_and_eval apt '{
        if [[ "$1" = "list" ]] && [[ "$2" = "--installed" ]]; then
            # echo "vim/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "vim-common/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed,automatic]"
            echo "vim-gtk/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "git/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 amd64 [installed]"
            echo "git-man/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 all [installed,automatic]"
        fi
    }'
    run install_packages_with_apt vim tmux
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing vim tmux..." ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    stub_called_with_exactly_times sudo 1 apt-get install -y vim tmux
    stub_called_with_exactly_times logger_info 1 "Packages vim tmux have been installed."
}

@test '#install_packages_with_apt should call apt-get with parameter "vim" when the git is specified but it was already installed' {
    stub_and_eval apt '{
        if [[ "$1" = "list" ]] && [[ "$2" = "--installed" ]]; then
            # echo "vim/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "vim-common/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed,automatic]"
            echo "vim-gtk/xenial-updates,xenial-security,now 2:7.4.1689-3ubuntu1.2 amd64 [installed]"
            echo "git/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 amd64 [installed]"
            echo "git-man/xenial-updates,xenial-security,now 1:2.7.4-0ubuntu1.1 all [installed,automatic]"
        fi
    }'
    run install_packages_with_apt vim git

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "git has already installed. Skipped." ]]
    [[ "${outputs[1]}" = "Installing vim..." ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    stub_called_with_exactly_times sudo 1 apt-get install -y vim
    stub_called_with_exactly_times logger_info 1 "Packages vim have been installed."
}

@test '#install_packages_with_apt should return 1 when apt-get update has failed' {
    stub_and_eval sudo '{
        if [[ "$1" = "apt-get" ]]; then
            if [[ "$2" = "update" ]]; then
                return 1
            fi
        fi
    }'
    stub apt
    run install_packages_with_apt vim

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times apt-get)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Some error has occured when updating packages with apt-get update."
}

@test '#install_packages_with_apt should return 1 when apt list outputs empty string with some error' {
    stub_and_eval apt '{
        if [[ "$1" = "list" ]]; then
            echo -n ""
        fi
    }'
    stub apt
    run install_packages_with_apt vim

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times apt-get)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to get installed packages with apt list --installed."
}

