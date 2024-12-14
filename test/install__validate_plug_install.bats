#!/usr/bin/env bats
load helpers

function setup() {
    stub logger_err
    rm -rf ${HOME}/.vim ${HOME}/.fzf
    cd /var/tmp
    mkdir -p ${HOME}/.vim/plugged/{vim-airline-themes,nerdtree}/.git
}

function teardown() {
    rm -rf ${HOME}/.vim ${HOME}/.fzf
}

@test '#_validate_plug_install should return 0 if a plugin was installed successfully' {
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047vim-airline/vim-airline-themes\047\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
}

@test '#_validate_plug_install should return 0 if some plugins were installed successfully' {
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047vim-airline/vim-airline-themes\047\n"
            printf "Plug \047scrooloose/nerdtree\047\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
}

@test '#_validate_plug_install should return 0 if fzf were installed then check ${HOME}/.fzf but not ${HOME}/.vim/plugged/fzf' {
    mkdir -p ${HOME}/.fzf/.git
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047junegunn/fzf\047, { \047dir\047: \047~/.fzf\047, \047do\047: \047./install --bin\047 }\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
}

@test '#_validate_plug_install should return 1 if fzf were not installed' {
    rm -rf ${HOME}/.fzf
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047junegunn/fzf\047, { \047dir\047: \047~/.fzf\047, \047do\047: \047./install --bin\047 }\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"fzf\". There is not a directory \".fzf\" or its directory is not a git repository."
}

@test '#_validate_plug_install should return 1 if installing a plugin was failed' {
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047vim-airline/vim-airline-themessssss\047\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    echo "$output"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"vim-airline-themessssss\". There is not a directory \".vim/plugged/vim-airline-themessssss\" or its directory is not a git repository."
}

@test '#_validate_plug_install should return 2 if installing 2 plugins were failed' {
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047vim-airline/vim-airline-themess\047\n"
            printf "Plug \047scrooloose/nerdtreee\047\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 2 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"vim-airline-themess\". There is not a directory \".vim/plugged/vim-airline-themess\" or its directory is not a git repository."
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"nerdtreee\". There is not a directory \".vim/plugged/nerdtreee\" or its directory is not a git repository."
}

@test '#_validate_plug_install should return 1 if installing 1 of 2 plugins was failed' {
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047vim-airline/vim-airline-themess\047\n"
            printf "Plug \047scrooloose/nerdtree\047\n"
            return 0
        }
        return 1
    }'
    run _validate_plug_install

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"vim-airline-themess\". There is not a directory \".vim/plugged/vim-airline-themess\" or its directory is not a git repository."
}
