#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    pushd ${HOME}
    mkdir ${DOTDIR}
    popd

    declare -g -a DEEP_LINK_DIRECTORIES=(".config" "bin" ".local")
}

function teardown() {
    pushd ${HOME}
    command rm -rf ${DOTDIR}
    popd
}

@test '#should_it_make_deep_link_directory should returns 0 if .config directory was existed' {
    mkdir ${HOME}/${DOTDIR}/.config
    pushd ${HOME}
    run should_it_make_deep_link_directory ".config"
    [[ "$status" -eq 0 ]]
    popd

    mkdir ${HOME}/${DOTDIR}/.config2
    run should_it_make_deep_link_directory ".config2"
    [[ "$status" -ne 0 ]]
}

@test '#should_it_make_deep_link_directory should returns 0 if bin directory was existed' {
    mkdir ${HOME}/${DOTDIR}/bin
    pushd ${HOME}
    run should_it_make_deep_link_directory "bin"
    [[ "$status" -eq 0 ]]
    popd
}

@test '#should_it_make_deep_link_directory should returns 0 if .local directory was existed' {
    mkdir ${HOME}/${DOTDIR}/.local
    pushd ${HOME}
    run should_it_make_deep_link_directory ".local"
    [[ "$status" -eq 0 ]]
    popd
}

@test '#should_it_make_deep_link_directory should not returns 0 if .config2 directory was existed' {
    mkdir ${HOME}/${DOTDIR}/.config2
    run should_it_make_deep_link_directory ".config2"
    [[ "$status" -ne 0 ]]
}

@test '#should_it_make_deep_link_directory should not returns 0 if .config file was existed' {
    touch ${HOME}/${DOTDIR}/.config
    run should_it_make_deep_link_directory ".config"
    [[ "$status" -ne 0 ]]
}

