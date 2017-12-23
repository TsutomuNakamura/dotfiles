#!/usr/bin/env bats

load helpers

function setup() {
    stub apt-get
    stub sudo
    stub push_info_message_list
    stub push_warn_message_list
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
    [[ "${outputs[0]}" = "INFO: Installing vim..." ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]
    stub_called_with_exactly_times sudo 1 apt-get install -y vim
    stub_called_with_exactly_times push_info_message_list 1 "INFO: Packages vim have been installed."
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
    [[ "${outputs[0]}" = "INFO: vim has already installed. Skipped." ]]
    [[ "${outputs[1]}" = "INFO: There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times apt-get)" -eq 0 ]]
    [[ "$(stub_called_times push_info_message_list)" -eq 0 ]]
    [[ "$(stub_called_times push_warn_message_list)" -eq 0 ]]
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
    [[ "${outputs[0]}" = "INFO: Installing vim tmux..." ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]
    stub_called_with_exactly_times sudo 1 apt-get install -y vim tmux
    stub_called_with_exactly_times push_info_message_list 1 "INFO: Packages vim tmux have been installed."
    [[ "$(stub_called_times push_warn_message_list)" -eq 0 ]]
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
echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "INFO: git has already installed. Skipped." ]]
    [[ "${outputs[1]}" = "INFO: Installing vim..." ]]
    [[ "$(stub_called_times sudo)" -eq 2 ]]
    stub_called_with_exactly_times sudo 1 apt-get install -y vim
    stub_called_with_exactly_times push_info_message_list 1 "INFO: Packages vim have been installed."
    [[ "$(stub_called_times push_warn_message_list)" -eq 0 ]]
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

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "ERROR: Some error has occured when updating packages with apt-get update." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times apt-get)" -eq 0 ]]
    [[ "$(stub_called_times push_info_message_list)" -eq 0 ]]
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: Some error has occured when updating packages with apt-get update."
}

@test '#install_packages_with_apt should return 1 when apt list outputs empty string with some error' {
    stub_and_eval apt '{
        if [[ "$1" = "list" ]]; then
            echo -n ""
        fi
    }'
    stub apt
    run install_packages_with_apt vim

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "ERROR: Failed to get installed packages with apt list --installed." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times apt-get)" -eq 0 ]]
    [[ "$(stub_called_times push_info_message_list)" -eq 0 ]]
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: Failed to get installed packages with apt list --installed."
}

