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
    stub _validate_plug_install
    stub vim
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
    [[ "$(stub_called_times vim)"                       -eq 1 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times vim 1 "+PlugInstall" "+sleep 1000m" "+qall"
}

@test '#deploy_vim_environment should return 1 if path of link_src is not start at dotfiles directory' {
    declare -a -g VIM_CONF_LINK_LIST=(
        "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim,/tmp/.dotfiles/.vim/after/syntax"
    )
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 0 ]]
    [[ "$(stub_called_times lln)"                       -eq 0 ]]
    [[ "$(stub_called_times vim)"                       -eq 0 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Link of source \"/tmp/.dotfiles/.vim/after/syntax\" must in your dotfiles root directory \"/var/tmp/.dotfiles\". Aborted."
}

@test '#deploy_vim_environment should return 1 if lln was failed' {
    stub_and_eval lln '{ return 1; }'
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 1 ]]
    [[ "$(stub_called_times lln)"                       -eq 1 ]]
    [[ "$(stub_called_times vim)"                       -eq 0 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
}

@test '#deploy_vim_environment should return 0 if _validate_plug_install returns non 0' {
    stub_and_eval _validate_plug_install '{ return 1; }'
    run deploy_vim_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 2 ]]
    [[ "$(stub_called_times lln)"                       -eq 2 ]]
    [[ "$(stub_called_times vim)"                       -eq 1 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" "/var/tmp/.dotfiles/.vim/after/syntax"
    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" "/var/tmp/.dotfiles/.vim/ftdetect"
    stub_called_with_exactly_times vim 1 "+PlugInstall" "+sleep 1000m" "+qall"
    stub_called_with_exactly_times logger_err 1 "Failed to install some plugins of vim. After this installer has finished, run a command manually like \`vim +PlugInstall +\"sleep 1000m\" +qall\` or rerun this installer to fix it."
}
