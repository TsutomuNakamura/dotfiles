#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub install_packages_with_apt
    stub install_packages_with_yum
    stub install_packages_with_dnf
    stub install_packages_with_pacman
    stub install_packages_with_homebrew
    stub add_additional_repositories_for_ubuntu
    stub logger_info
    stub logger_warn
    stub logger_err
    stub has_desktop_env

    PACKAGES_TO_INSTALL_ON_DEBIAN="debian_cli_a debian_cli_b"
    PACKAGES_TO_INSTALL_ON_DEBIAN_THAT_HAS_GUI="debian_gui_a debian_gui_b"

    PACKAGES_TO_INSTALL_ON_UBUNTU="ubuntu_cli_a ubuntu_cli_b"
    PACKAGES_TO_INSTALL_ON_UBUNTU_THAT_HAS_GUI="ubuntu_gui_a ubuntu_gui_b"

    PACKAGES_TO_INSTALL_ON_CENTOS="centos_cli_a centos_cli_b"
    PACKAGES_TO_INSTALL_ON_CENTOS_THAT_HAS_GUI="centos_gui_a centos_gui_b"

    PACKAGES_TO_INSTALL_ON_FEDORA="fedora_cli_a fedora_cli_b"
    PACKAGES_TO_INSTALL_ON_FEDORA_THAT_HAS_GUI="fedora_gui_a fedora_gui_b"

    PACKAGES_TO_INSTALL_ON_ARCH="arch_cli_a arch_cli_b"
    PACKAGES_TO_INSTALL_ON_ARCH_THAT_HAS_GUI="arch_gui_a arch_gui_b"

    PACKAGES_TO_INSTALL_ON_MAC="mac_a mac_b"
}
#function teardown() {}

@test '#install_packages return 0 if install packages has succeeded on debian with desktop environment' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 debian_cli_a debian_cli_b debian_gui_a debian_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on debian without desktop environment' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    stub_and_eval has_desktop_env '{ return 1; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 debian_cli_a debian_cli_b
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
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 debian_cli_a debian_cli_b debian_gui_a debian_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on ubuntu' {
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"                     -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"                 -eq 1 ]]
    [[ "$(stub_called_times add_additional_repositories_for_ubuntu)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"                 -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"                 -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"              -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"            -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                           -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                               -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 ubuntu_cli_a ubuntu_cli_b ubuntu_gui_a ubuntu_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on ubuntu without desktop environment' {
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
    stub_and_eval has_desktop_env '{ return 1; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 1 ]]
    [[ "$(stub_called_times add_additional_repositories_for_ubuntu)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 ubuntu_cli_a ubuntu_cli_b
}

@test '#install_packages return 0 even if add_additional_repositories_for_ubuntu has failed on ubuntu' {
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
    stub_and_eval add_additional_repositories_for_ubuntu '{ return 1; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"                     -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"                 -eq 1 ]]
    [[ "$(stub_called_times add_additional_repositories_for_ubuntu)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"                 -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"                 -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"              -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"            -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                           -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                               -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
}

@test '#install_packages return 1 if install packages has failed on ubuntu' {
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
    stub_and_eval install_packages_with_apt '{ return 1; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 ubuntu_cli_a ubuntu_cli_b ubuntu_gui_a ubuntu_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on centos' {
    stub_and_eval get_distribution_name '{ echo "centos"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 3 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_warn)"                       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_yum 1 centos_cli_a centos_cli_b centos_gui_a centos_gui_b
    stub_called_with_exactly_times logger_warn 1 "Package \"ranger\" will not be installed on Cent OS. So please install it manually."
}

@test '#install_packages return 0 if install packages has succeeded on centos without desktop environment' {
    stub_and_eval get_distribution_name '{ echo "centos"; }'
    stub_and_eval has_desktop_env '{ return 1; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 3 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_warn)"                       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_yum 1 centos_cli_a centos_cli_b
    stub_called_with_exactly_times logger_warn 1 "Package \"ranger\" will not be installed on Cent OS. So please install it manually."
}

@test '#install_packages return 1 if install packages has failed on centos' {
    stub_and_eval get_distribution_name '{ echo "centos"; }'
    stub_and_eval install_packages_with_yum '{ return 1; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 3 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_warn)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_yum 1 centos_cli_a centos_cli_b centos_gui_a centos_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on fedora' {
    stub_and_eval get_distribution_name '{ echo "fedora"; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 4 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_dnf 1 fedora_cli_a fedora_cli_b fedora_gui_a fedora_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on fedora without desktop environment' {
    stub_and_eval get_distribution_name '{ echo "fedora"; }'
    stub_and_eval has_desktop_env '{ return 1; }'
    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 4 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_dnf 1 fedora_cli_a fedora_cli_b
}

@test '#install_packages return 1 if install packages has failed on fedora' {
    stub_and_eval get_distribution_name '{ echo "fedora"; }'
    stub_and_eval install_packages_with_dnf '{ return 1; }'

    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 4 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_dnf 1 fedora_cli_a fedora_cli_b fedora_gui_a fedora_gui_b
}

@test '#install_packages return 1 if install packages has succeeded on arch' {
    stub_and_eval get_distribution_name '{ echo "arch"; }'

    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 5 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_pacman 1 arch_cli_a arch_cli_b arch_gui_a arch_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on arch without desktop environment' {
    stub_and_eval get_distribution_name '{ echo "arch"; }'
    stub_and_eval has_desktop_env '{ return 1; }'

    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 5 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_pacman 1 arch_cli_a arch_cli_b
}

@test '#install_packages return 1 if install packages has failed on arch' {
    stub_and_eval get_distribution_name '{ echo "arch"; }'
    stub_and_eval install_packages_with_pacman '{ return 1; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 5 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 1 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_pacman 1 arch_cli_a arch_cli_b arch_gui_a arch_gui_b
}

@test '#install_packages return 0 if install packages has succeeded on mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'

    run install_packages

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 6 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 1 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_homebrew 1 mac_a mac_b
}

@test '#install_packages return 1 if install packages has failed on mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    stub_and_eval install_packages_with_homebrew '{ return 1; }'

    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 6 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 1 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times install_packages_with_homebrew 1 mac_a mac_b
}

@test '#install_packages return 1 if the distribution of the OS has detected as unknown' {
    stub_and_eval get_distribution_name '{ echo "unknown"; }'
    run install_packages

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"             -eq 6 ]]
    [[ "$(stub_called_times install_packages_with_apt)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_yum)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"         -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"      -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_homebrew)"    -eq 0 ]]
    [[ "$(stub_called_times has_desktop_env)"                   -eq 0 ]]
    [[ "$(stub_called_times logger_info)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to get OS distribution to install packages."
}

