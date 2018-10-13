#!/usr/bin/env bats

load helpers "install.sh"

function setup() {
    stub logger_err
    cd /var/tmp
    mkdir -p .vim/plugged/{vim-airline-themes,nerdtree}/.git
}

function teardown() {
    rm -rf /var/tmp/.vim
}

@test '#_validate_plug_install should should return 0 if a plugin was installed successfully' {
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

@test '#_validate_plug_install should should return 0 if some plugins were installed successfully' {
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

@test '#_validate_plug_install should should return 1 if installing a plugin was failed' {
    rm -rf /var/tmp/.vim/plugged/vim-airline-themes
    stub_and_eval grep '{
        [[ "$1" == "-E" ]] && {
            printf "Plug \047vim-airline/vim-airline-themes\047\n"
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
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"vim-airline-themes\". There is not a directory \".vim/plugged/vim-airline-themes\" or its directory is not a git repository."
}

@test '#_validate_plug_install should should return 2 if installing 2 plugins were failed' {
    rm -rf /var/tmp/.vim/plugged/{vim-airline-themes,nerdtree}
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
    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 2 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"vim-airline-themes\". There is not a directory \".vim/plugged/vim-airline-themes\" or its directory is not a git repository."
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"nerdtree\". There is not a directory \".vim/plugged/nerdtree\" or its directory is not a git repository."
}

@test '#_validate_plug_install should should return 1 if installing 1 of 2 plugins was failed' {
    rm -rf /var/tmp/.vim/plugged/vim-airline-themes
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
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times grep)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times grep 1 -E '^Plug .*' .vimrc
    stub_called_with_exactly_times logger_err 1 "Failed to install vim plugin \"vim-airline-themes\". There is not a directory \".vim/plugged/vim-airline-themes\" or its directory is not a git repository."
}
