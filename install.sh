#!/usr/bin/env bash

set -eu

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASE_DIR

function init() {

    # Install pathogen.vim
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # update vim's submodules
    git submodule init
    git submodule update

    # Link color theme
    mkdir -p .vim/colors/
    pushd .vim/colors/
    ln -s ../../resources/etc/config/vim/colors/molokai.vim
    popd

    

}

function deploy() {

    

    for f in .??*
    do
        [[ "$f" == ".git" ]] && continue
        [[ "$f" == ".DS_Store" ]] && continue

        echo "$f"
    done
}


