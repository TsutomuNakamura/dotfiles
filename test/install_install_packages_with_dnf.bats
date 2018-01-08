#!/usr/bin/env bats

load helpers

function setup() {
    stub install_packages_on_redhat
    function command() { return 0; }
}
function teardown() {
    true
}

@test '#install_packages_with_dnf should call install_packages_on_redhat() with parameters dnf, vim' {
    run install_packages_with_dnf vim

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times install_packages_on_redhat)" -eq 1 ]]
    stub_called_with_exactly_times install_packages_on_redhat 1 "dnf" "vim"
}

@test '#install_packages_with_dnf should call install_packages_on_redhat() with parameters dnf, vim, tmux' {
    run install_packages_with_dnf vim tmux

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times install_packages_on_redhat)" -eq 1 ]]
    stub_called_with_exactly_times install_packages_on_redhat 1 "dnf" "vim" "tmux"
}

@test '#install_packages_with_dnf should output error if the function is called with no parameters' {
    run install_packages_with_dnf

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" == "ERROR: Failed to find packages to install at install_packages_with_dnf()" ]]
    [[ "$(stub_called_times install_packages_on_redhat)" -eq 0 ]]
}

