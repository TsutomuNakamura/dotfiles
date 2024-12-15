#!/usr/bin/env bats
load helpers

function setup() {
    stub install_package_from_aur
}

@test '#prepare_vscode_arch should return 0 if all instructions have succeeded' {
    run prepare_vscode_arch

    [ "$status" -eq 0 ]
    [ "$(stub_called_times install_package_from_aur)"   -eq 1 ]
    stub_called_with_exactly_times install_package_from_aur 1 "https://aur.archlinux.org/visual-studio-code-bin.git"
}

@test '#prepare_vscode_arch should return 1 if install_package_from_aur has failed' {
    stub_and_eval install_package_from_aur '{ return 1; }'
    run prepare_vscode_arch

    [ "$status" -ne 0 ]
    [ "$(stub_called_times install_package_from_aur)"   -eq 1 ]
    stub_called_with_exactly_times install_package_from_aur 1 "https://aur.archlinux.org/visual-studio-code-bin.git"
}
