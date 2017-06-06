#!/usr/bin/env bats

load helpers

function setup() {
    true
}

function teardown() {
    restore sudo
    restore apt-get
    restore apt
}

@test '#install_packages_with_apt should call apt-get with parameter "vim" when it was not installed' {

    #stub command
    stub apt-get
    stub sudo
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

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "Installing vim..." ]]
    # [[ "$(stub_called_times sudo)" -eq 2 ]]
}

@test '#install_packages_with_apt should call apt-get with parameter "vim" when it was not installed' {

    #stub command
    stub apt-get
    stub sudo
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

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "There are no packages to install" ]]
    # [[ "$(stub_called_times sudo)" -eq 2 ]]
}

