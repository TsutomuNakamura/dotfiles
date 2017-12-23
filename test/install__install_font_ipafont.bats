#!/usr/bin/env bats
load helpers

function setup() {
    command mkdir -p "${HOME}/.local/share/fonts"
    cd "${HOME}/.local/share/fonts"
    function do_i_have_admin_privileges() { return 0; }
    function get_distribution_name() { echo "debian"; }
    stub logger_err

    stub install_packages_with_apt
    stub install_packages_with_dnf
    stub install_packages_with_pacman
    stub true
}

function teardown() {
    cd "${HOME}"
    command rm -rf .local
}

@test '#_install_font_ipafont should return 1 if the font has been installed successfully on debian.' {
    run _install_font_ipafont

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times true)"                          -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 fonts-ipafont
}

@test '#_install_font_ipafont should return 1 if the font has been installed successfully on fedora.' {
    function get_distribution_name() { echo "fedora"; }
    run _install_font_ipafont

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times true)"                          -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_dnf 1 ipa-gothic-fonts ipa-mincho-fonts
}

@test '#_install_font_ipafont should return 1 if the font has been installed successfully on arch.' {
    function get_distribution_name() { echo "arch"; }
    run _install_font_ipafont

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 1 ]]
    [[ "$(stub_called_times true)"                          -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_pacman 1 otf-ipafont
}

@test '#_install_font_ipafont should return 1 if the font has been installed successfully on mac.' {
    function get_distribution_name() { echo "mac"; }
    run _install_font_ipafont

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times true)"                          -eq 1 ]]
    stub_called_with_exactly_times true 1
}

@test '#_install_font_ipafont should return 2 if the font has been failed to install on debian.' {
    stub_and_eval install_packages_with_apt '{ return 1; }'
    run _install_font_ipafont

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times true)"                          -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_apt 1 fonts-ipafont
}

@test '#_install_font_ipafont should return 2 if the font has been failed to install on fedora.' {
    function get_distribution_name() { echo "fedora"; }
    stub_and_eval install_packages_with_dnf '{ return 1; }'
    run _install_font_ipafont

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times true)"                          -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_dnf 1 ipa-gothic-fonts ipa-mincho-fonts
}

@test '#_install_font_ipafont should return 2 if the font has been failed to install on arch.' {
    function get_distribution_name() { echo "arch"; }
    stub_and_eval install_packages_with_pacman '{ return 1; }'
    run _install_font_ipafont

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 1 ]]
    [[ "$(stub_called_times true)"                          -eq 0 ]]
    stub_called_with_exactly_times install_packages_with_pacman 1 otf-ipafont
}

@test '#_install_font_ipafont should return 2 if the font has been failed to install on mac.' {
    # TODO: Doesn't implemented yet on mac.
    function get_distribution_name() { echo "mac"; }
    stub_and_eval true '{ return 1; }'
    run _install_font_ipafont

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times true)"                          -eq 1 ]]
    stub_called_with_exactly_times true 1
}

@test '#_install_font_ipafont should return 2 if the user does not hav admin priviledge' {
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'

    run _install_font_ipafont

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_apt)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_dnf)"     -eq 0 ]]
    [[ "$(stub_called_times install_packages_with_pacman)"  -eq 0 ]]
    [[ "$(stub_called_times logger_err)"  -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "ERROR: Installing IPA font has failed because the user doesn't have a privilege (nearly root) to install the font."
}

