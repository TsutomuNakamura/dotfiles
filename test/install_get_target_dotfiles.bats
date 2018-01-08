#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    mkdir -p ${HOME}/${DOTDIR}
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR}
}

@test '#get_target_dotfiles should get the file with the name that starts with dot' {
    touch ${HOME}/${DOTDIR}/.vim

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 1 ]]
    contains ".vim" "${result[@]}"
}

@test '#get_target_dotfiles should get some files with the name that starts with dot' {
    touch ${HOME}/${DOTDIR}/.vim
    touch ${HOME}/${DOTDIR}/.tmux.conf

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 2 ]]
    contains ".vim" "${result[@]}"
    contains ".tmux.conf" "${result[@]}"
}

@test '#get_target_dotfiles should get the directory with the name that starts with dot' {
    mkdir ${HOME}/${DOTDIR}/.vim

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 1 ]]
    contains ".vim" "${result[@]}"
}

@test '#get_target_dotfiles should get some directories with the name that starts with dot' {
    mkdir ${HOME}/${DOTDIR}/.vim
    mkdir ${HOME}/${DOTDIR}/.dir0

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 2 ]]
    contains ".dir0" "${result[@]}"
    contains ".vim" "${result[@]}"
}

@test '#get_target_dotfiles should get a directory and a file with the name that starts with dot' {
    touch ${HOME}/${DOTDIR}/.file0
    mkdir ${HOME}/${DOTDIR}/.dir0


    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 2 ]]
    contains ".dir0" "${result[@]}"
    contains ".file0" "${result[@]}"
}

@test '#get_target_dotfiles should get some directories and some files with the name that starts with dot' {
    touch ${HOME}/${DOTDIR}/.file0
    touch ${HOME}/${DOTDIR}/.file1
    mkdir ${HOME}/${DOTDIR}/.dir0
    mkdir ${HOME}/${DOTDIR}/.dir1


    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 4 ]]
    contains ".dir0" "${result[@]}"
    contains ".dir1" "${result[@]}"
    contains ".file0" "${result[@]}"
    contains ".file1" "${result[@]}"
}

@test '#get_target_dotfiles should get no elements if target was not existed' {
    mkdir ${HOME}/${DOTDIR}/lib
    touch ${HOME}/${DOTDIR}/foo

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 0 ]]
}

@test '#get_target_dotfiles should get bin directory if it was existed' {
    mkdir ${HOME}/${DOTDIR}/bin

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 1 ]]
    contains "bin" "${result[@]}"
}

@test '#get_target_dotfiles should get Library directory if it was existed' {
    mkdir ${HOME}/${DOTDIR}/Library

    run get_target_dotfiles "${HOME}/${DOTDIR}"
    declare -a result=($output)

    [[ "$status" -eq 0 ]]
    [[ "${#result[@]}" -eq 1 ]]
    contains "Library" "${result[@]}"
}

