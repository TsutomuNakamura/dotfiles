#!/usr/bin/env bats

load helpers

function setup() {
    true
}

function teardown() {
    true
}

@test '#install_packages_on_redhat should call dnf with parameter "gc" when it was not installed' {
#    run install_packages_on_redhat "dnf" vim
    run install_packages_on_redhat "dnf" gc

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "There are no packages to install" ]]
}

@test '#install_packages_on_redhat should call dnf with parameter "gc", "vim" and "git" when it was not installed' {

    stub_and_eval dnf '{ true; }'
    stub_and_eval sudo '{ true; }'

    run install_packages_on_redhat "dnf" gc vim git

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "Installing vim git..." ]]
}

