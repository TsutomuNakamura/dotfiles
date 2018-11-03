#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    rm -rf /var/tmp/.vim
    declare -g FULL_DOTDIR_PATH="/var/tmp/.dotfiles"
    declare -a -g VIM_CONF_LINK_LIST=(
        "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim,/var/tmp/.dotfiles/.vim/after/syntax"
        "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim,/var/tmp/.dotfiles/.vim/ftdetect"
    )
    stub mmkdir
    stub lln
    stub _install_vim_plug
    stub _validate_plug_install
    stub _install_you_complete_me
    stub logger_err
}

function teardown() {
    rm -rf /var/tmp/.vim
}

@test '#deploy_vim_environment should return 0 if all instructions were succeeded' {
    run deploy_vim_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 2 ]]
    [[ "$(stub_called_times lln)"                       -eq 2 ]]
    [[ "$(stub_called_times _install_vim_plug)"         -eq 1 ]]
    [[ "$(stub_called_times _install_you_complete_me)"  -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" "/var/tmp/.dotfiles/.vim/ftdetect"
}

@test '#deploy_vim_environment should return 1 if path of link_src is not start at dotfiles directory' {
    declare -a -g VIM_CONF_LINK_LIST=(
        "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim,/tmp/.dotfiles/.vim/after/syntax"
    )
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 0 ]]
    [[ "$(stub_called_times lln)"                       -eq 0 ]]
    [[ "$(stub_called_times _install_vim_plug)"         -eq 0 ]]
    [[ "$(stub_called_times _install_you_complete_me)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Link of source \"/tmp/.dotfiles/.vim/after/syntax\" must in your dotfiles root directory \"/var/tmp/.dotfiles\". Aborted."
}

@test '#deploy_vim_environment should return 1 if lln was failed' {
    stub_and_eval lln '{ return 1; }'
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 1 ]]
    [[ "$(stub_called_times lln)"                       -eq 1 ]]
    [[ "$(stub_called_times _install_vim_plug)"         -eq 0 ]]
    [[ "$(stub_called_times _install_you_complete_me)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
}

@test '#deploy_vim_environment should return 0 if _install_vim_plug returns non 0' {
    stub_and_eval _install_vim_plug '{ return 1; }'
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 2 ]]
    [[ "$(stub_called_times lln)"                       -eq 2 ]]
    [[ "$(stub_called_times _install_vim_plug)"         -eq 1 ]]
    [[ "$(stub_called_times _install_you_complete_me)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times _install_vim_plug 1
}

@test '#deploy_vim_environment should return 0 if _install_you_complete_me returns non 0' {
    stub_and_eval _install_you_complete_me '{ return 1; }'
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 2 ]]
    [[ "$(stub_called_times lln)"                       -eq 2 ]]
    [[ "$(stub_called_times _install_vim_plug)"         -eq 1 ]]
    [[ "$(stub_called_times _install_you_complete_me)"  -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times _install_vim_plug 1
    stub_called_with_exactly_times _install_you_complete_me 1
}
