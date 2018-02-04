#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub install_packages_with_apt
    stub install_packages_with_yum
    stub install_packages_with_dnf
    stub install_packages_with_pacman
    stub install_packages_with_homebrew
    stub logger_info
    stub logger_err
}
# function teardown() {}

@test '#install_packages return 0 if install packages has succeeded on debian' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 git vim vim-gtk ctags tmux zsh unzip ranger
}

@test '#install_packages return 1 if install packages has failed on debian' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    stub_and_eval install_packages_with_apt '{ return 1; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 git vim vim-gtk ctags tmux zsh unzip ranger
}

@test '#install_packages return 0 if install packages has succeeded on centos' {
    stub_and_eval get_distribution_name '{ echo "centos"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_yum 1 git vim gvim ctags tmux zsh unzip gnome-terminal
    stub_called_with_exactly_times logger_info 1 "INFO: Package \"ranger\" will not be installed on Cent OS. So please instlal it manually."
}

@test '#install_packages return 1 if install packages has failed on centos' {
    stub_and_eval get_distribution_name '{ echo "centos"; }'
    stub_and_eval install_packages_with_yum '{ return 1; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_yum 1 git vim gvim ctags tmux zsh unzip gnome-terminal
}

@test '#install_packages return 0 if install packages has succeeded on fedora' {
    stub_and_eval get_distribution_name '{ echo "fedora"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 3 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_dnf 1 git vim ctags tmux zsh unzip gnome-terminal ranger
}

@test '#install_packages return 1 if install packages has failed on fedora' {
    stub_and_eval get_distribution_name '{ echo "fedora"; }'
    stub_and_eval install_packages_with_dnf '{ return 1; }'

    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 3 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_dnf 1 git vim ctags tmux zsh unzip gnome-terminal ranger
}

@test '#install_packages return 1 if install packages has succeeded on arch' {
    stub_and_eval get_distribution_name '{ echo "arch"; }'

    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 4 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_pacman 1 git ctags tmux zsh unzip gnome-terminal ranger
}

@test '#install_packages return 1 if install packages has failed on arch' {
    stub_and_eval get_distribution_name '{ echo "arch"; }'
    stub_and_eval install_packages_with_pacman '{ return 1; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 4 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_pacman 1 git ctags tmux zsh unzip gnome-terminal ranger
}

@test '#install_packages return 1 if install packages has succeeded on mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'

    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 5 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_homebrew 1 vim ctags tmux zsh unzip
}

@test '#install_packages return 1 if the distribution of the OS has detected as unknown' {
    stub_and_eval get_distribution_name '{ echo "unknown"; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 5 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to get OS distribution to install packages."
}

