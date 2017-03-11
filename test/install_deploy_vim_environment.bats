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
    ln -sf ${DOTDIR}/.vim
}

function teardown() {
    cd ${HOME}
    rm -rf ${DOTDIR}
    rm -rf .vim
}

@test '#deploy_vim_environment should deploy bats.vim' {

    run deploy_vim_environment

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L ".vim/after/syntax/sh.vim" ]]
    [[ "$(readlink .vim/after/syntax/sh.vim)" = "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ]]
    [[ "$(readlink .vim/ftdetect/bats.vim)" = "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" ]]

    [[ -L ".vim/snippets/bats.snippets" ]]
    [[ "$(readlink ".vim/snippets/bats.snippets")" = "../../resources/etc/config/vim/snipmate-snippets.git/snippets/bats.snippets" ]]
    [[ -L ".vim/snippets/chef.snippets" ]]
    [[ "$(readlink ".vim/snippets/chef.snippets")" = "../../resources/etc/config/vim/snipmate-snippets.git/snippets/chef.snippets" ]]
}

