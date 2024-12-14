#!/usr/bin/env bats
load helpers

function setup() {
    stub install_packages_on_redhat
}
function teardown() {
    true
}

@test '#install_packages_with_yum should call install_packages_on_redhat() with parameters yum, vim' {
    run install_packages_with_yum vim

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times install_packages_on_redhat)" -eq 1 ]]
    stub_called_with_exactly_times install_packages_on_redhat 1 "yum" "vim"
}

@test '#install_packages_with_yum should call install_packages_on_redhat() with parameters yum, vim, tmux' {
    run install_packages_with_yum vim tmux

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times install_packages_on_redhat)" -eq 1 ]]
    stub_called_with_exactly_times install_packages_on_redhat 1 "yum" "vim" "tmux"
}

@test '#install_packages_with_yum should output error if the function is called with no parameters' {
    run install_packages_with_yum

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" == "ERROR: Failed to find packages to install at install_packages_with_yum()" ]]
    [[ "$(stub_called_times install_packages_on_redhat)" -eq 0 ]]
}

