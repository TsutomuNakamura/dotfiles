#!/usr/bin/env bash
set -eu

DOTDIR=".dotfiles"

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASE_DIR

function main() {
    
}

function init() {

    

    # Cloe the repository if it's not existed
    init_repo

    
}

function deploy() {

    # TODO:
    # init_vim_environment

    declare -a dotfiles=()

    pushd ${HOME}/${DOTPATH}
    for f in .??*
    do
        [[ "$f" == ".git" ]] && continue
        [[ "$f" == ".DS_Store" ]] && continue
        dotfiles+=($f)
    done
    popd

    pushd ${HOME}
    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        echo "dotfile: ${dotfiles[i]}"
        ln -s 
    }
    popd
}

function init_repo() {

    [ -d "${HOME}/${DOTDIR}" ] && mkdir -p ${HOME}/${DOTDIR}

    # Is here the git repo?

    pushd $DOTPATH
    if is_here_git_repo; then
        git update
    else
        git clone https://github.com/TsutomuNakamura/dotfiles
        git submodule init
    fi

    git submodule update
}

# Initialize vim environment
function init_vim_environment() {
    # Install pathogen.vim
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # update vim's submodules
    # Link color theme
    mkdir -p .vim/colors/
    pushd .vim/colors/
    ln -s ../../resources/etc/config/vim/colors/molokai.vim
    popd

   
}

# Check current directory is whether git repo or not.
function is_here_git_repo() {
    [ -d .git ] || (git rev-parse --git-dir > /dev/null 2>&1)
}

main "$@"

