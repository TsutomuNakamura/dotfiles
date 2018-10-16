#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    rm -f /var/tmp/lang
    stub curl
    stub_and_eval vim '{ echo "$LANG" > /var/tmp/lang; }'
    stub _validate_plug_install
    stub logger_err
    export LANG="ja_JP.UTF-8"
}

function teardown() {
    rm -f /var/tmp/lang
}

@test '#_install_vim_plug should return 0 if all instructions are succeeded' {
    run _install_vim_plug

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing vim plugins..." ]]
    [[ "$(cat /var/tmp/lang)" = "ja_JP.UTF-8" ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times vim)"                       -eq 1 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times curl 1 -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    stub_called_with_exactly_times vim 1 +PlugInstall "+sleep 1000m" +qall
    stub_called_with_exactly_times _validate_plug_install 1
}

@test '#_install_vim_plug should return 1 if installing vim-plug with curl was failed' {
    stub_and_eval curl '{ return 1; }'
    run _install_vim_plug

    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times vim)"                       -eq 0 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times curl 1 -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    stub_called_with_exactly_times logger_err 1 "Failed to install plug-vim from https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
}

@test '#_install_vim_plug should call vim command with LANG=en_US.UTF-8 if environment variable LANG is undefined' {
    export LANG=
    stub_and_eval vim '{
        echo "$LANG" > /var/tmp/lang
    }'
    run _install_vim_plug

    cat /var/tmp/lang
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing vim plugins..." ]]
    [[ "$(cat /var/tmp/lang)" = "en_US.UTF-8" ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times vim)"                       -eq 1 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times curl 1 -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    stub_called_with_exactly_times vim 1 +PlugInstall "+sleep 1000m" +qall
    stub_called_with_exactly_times _validate_plug_install 1
}

@test '#_install_vim_plug should call vim command with LANG=en_US.UTF-8 if environment variable LANG is C' {
    export LANG=C
    stub_and_eval vim '{
        echo "$LANG" > /var/tmp/lang
    }'
    run _install_vim_plug

    cat /var/tmp/lang
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing vim plugins..." ]]
    [[ "$(cat /var/tmp/lang)" = "en_US.UTF-8" ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times vim)"                       -eq 1 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times curl 1 -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    stub_called_with_exactly_times vim 1 +PlugInstall "+sleep 1000m" +qall
    stub_called_with_exactly_times _validate_plug_install 1
}

@test '#_install_vim_plug should call logger_err behaind _validate_plug_install if _validate_plug_install returns non 0' {
    stub_and_eval _validate_plug_install '{ return 1; }'
    run _install_vim_plug

    cat /var/tmp/lang
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing vim plugins..." ]]
    [[ "$(cat /var/tmp/lang)" = "ja_JP.UTF-8" ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times vim)"                       -eq 1 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times curl 1 -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    stub_called_with_exactly_times vim 1 +PlugInstall "+sleep 1000m" +qall
    stub_called_with_exactly_times _validate_plug_install 1
    stub_called_with_exactly_times logger_err 1 "Failed to install some plugins of vim. After this installer has finished, run a command manually like \`vim +PlugInstall +\"sleep 1000m\" +qall\` or rerun this installer to fix it."
}

