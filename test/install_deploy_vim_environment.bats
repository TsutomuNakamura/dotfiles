#!/usr/bin/env bats
load helpers

function setup() {
    cd ${HOME}

    # Dummy Resources of bats.vim syntax
    mkdir -p ${DOTDIR}/resources/etc/config/vim/bats.vim/after/syntax
    mkdir -p ${DOTDIR}/resources/etc/config/vim/bats.vim/ftdetect/
    mkdir -p ${DOTDIR}/.vim
    touch ${DOTDIR}/resources/etc/config/vim/bats.vim/after/syntax/sh.vim
    touch ${DOTDIR}/resources/etc/config/vim/bats.vim/ftdetect/bats.vim
}

function teardown() {
    cd ${HOME}
    rm -rf ${DOTDIR}
    unlink .vim
}

@test '#deploy_vim_environment should deploy bats.vim' {

    run deploy_vim_environment

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L ".vim/after/syntax/sh.vim" ]]
    [[ "$(readlink .vim/after/syntax/sh.vim)" = "../../../${DOTDIR}/resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ]]
    [[ "$(readlink .vim/ftdetect/bats.vim)" = "../../${DOTDIR}/resources/etc/config/vim/bats.vim/ftdetect/bats.vim" ]]
}




