#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub pushd
    stub popd
    stub mmkdir
    stub lln
    stub _validate_plug_install
    stub vim
    stub logger_err
}

#function teardown() {}

#@test '#deploy_vim_environment should return 0 if all instructions were succeeded' {
#    run deploy_vim_environment
#
#    [[ "$status" -eq 0 ]]
#    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                      -eq 1 ]]
#    [[ "$(stub_called_times mmkdir)"                    -eq 3 ]]
#    [[ "$(stub_called_times lln)"                       -eq 4 ]]
#    [[ "$(stub_called_times _validate_plug_install)"    -eq 1 ]]
#    [[ "$(stub_called_times vim)"                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
#    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
#    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
#    stub_called_with_exactly_times mmkdir 1 ".vim/ftdetect"
#    stub_called_with_exactly_times mmkdir 1 ".vim/snippets"
#    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ".vim/after/syntax"
#    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim" ".vim/ftdetect"
#    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/snipmate-snippets.git/snippets/bats.snippets" ".vim/snippets"
#    stub_called_with_exactly_times lln 1 "../../resources/etc/config/vim/snipmate-snippets.git/snippets/chef.snippets" ".vim/snippets"
#    stub_called_with_exactly_times vim 1 "+PlugInstall" "+sleep 1000m" "+qall"
#}

#@test '#deploy_vim_environment should return 1 if pushd was failed' {
#    stub_and_eval pushd '{ return 1; }'
#    run deploy_vim_environment
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                      -eq 0 ]]
#    [[ "$(stub_called_times mmkdir)"                    -eq 0 ]]
#    [[ "$(stub_called_times lln)"                       -eq 0 ]]
#    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
#    [[ "$(stub_called_times vim)"                       -eq 0 ]]
#    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
#    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
#}

#@test '#deploy_vim_environment should return 1 if 1st mmkdir was failed' {
#    stub_and_eval mmkdir '{ return 1; }'
#    run deploy_vim_environment
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                      -eq 1 ]]
#    [[ "$(stub_called_times mmkdir)"                    -eq 1 ]]
#    [[ "$(stub_called_times lln)"                       -eq 0 ]]
#    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
#    [[ "$(stub_called_times vim)"                       -eq 0 ]]
#    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
#    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
#    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
#}

#@test '#deploy_vim_environment should return 1 if 2nd mmkdir was failed' {
#    stub_and_eval mmkdir '{
#        [[ "$1" == ".vim/after/syntax" ]] && return 0
#        return 1
#    }'
#    run deploy_vim_environment
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                      -eq 1 ]]
#    [[ "$(stub_called_times mmkdir)"                    -eq 2 ]]
#    [[ "$(stub_called_times lln)"                       -eq 0 ]]
#    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
#    [[ "$(stub_called_times vim)"                       -eq 0 ]]
#    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
#    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
#    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
#    stub_called_with_exactly_times mmkdir 1 ".vim/ftdetect"
#}

#@test '#deploy_vim_environment should return 1 if 3rd mmkdir was failed' {
#    stub_and_eval mmkdir '{
#        if [[ "$1" == ".vim/after/syntax" ]] || [[ "$1" == ".vim/ftdetect" ]]; then
#            return 0
#        fi
#        return 1
#    }'
#    run deploy_vim_environment
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                      -eq 1 ]]
#    [[ "$(stub_called_times mmkdir)"                    -eq 3 ]]
#    [[ "$(stub_called_times lln)"                       -eq 0 ]]
#    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
#    [[ "$(stub_called_times vim)"                       -eq 0 ]]
#    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
#    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
#    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
#    stub_called_with_exactly_times mmkdir 1 ".vim/ftdetect"
#    stub_called_with_exactly_times mmkdir 1 ".vim/snippets"
#}

#@test '#deploy_vim_environment should return 1 if 1st lln was failed' {
#    stub_and_eval lln '{ return 1; }'
#    run deploy_vim_environment
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                      -eq 1 ]]
#    [[ "$(stub_called_times mmkdir)"                    -eq 3 ]]
#    [[ "$(stub_called_times lln)"                       -eq 1 ]]
#    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
#    [[ "$(stub_called_times vim)"                       -eq 0 ]]
#    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
#    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
#    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
#    stub_called_with_exactly_times mmkdir 1 ".vim/ftdetect"
#    stub_called_with_exactly_times mmkdir 1 ".vim/snippets"
#    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ".vim/after/syntax"
#}

@test '#deploy_vim_environment should return 1 if 2nd lln was failed' {
    stub_and_eval lln '{
        if [[ "$1" == "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ]]; then
            return 0
        fi
        return 1
    }'
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
    [[ "$(stub_called_times popd)"                      -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 3 ]]
    [[ "$(stub_called_times lln)"                       -eq 2 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
    [[ "$(stub_called_times vim)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 ".vim/ftdetect"
    stub_called_with_exactly_times mmkdir 1 ".vim/snippets"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ".vim/after/syntax"
}

@test '#deploy_vim_environment should return 1 if 2nd lln was failed' {
    stub_and_eval lln '{
        if [[ "$1" == "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ]]; then
            return 0
        fi
        return 1
    }'
    run deploy_vim_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times pushd)"                     -eq 1 ]]
    [[ "$(stub_called_times popd)"                      -eq 1 ]]
    [[ "$(stub_called_times mmkdir)"                    -eq 3 ]]
    [[ "$(stub_called_times lln)"                       -eq 2 ]]
    [[ "$(stub_called_times _validate_plug_install)"    -eq 0 ]]
    [[ "$(stub_called_times vim)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    stub_called_with_exactly_times pushd 1 "${HOME}/${DOTDIR}"
    stub_called_with_exactly_times mmkdir 1 ".vim/after/syntax"
    stub_called_with_exactly_times mmkdir 1 ".vim/ftdetect"
    stub_called_with_exactly_times mmkdir 1 ".vim/snippets"
    stub_called_with_exactly_times lln 1 "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim" ".vim/after/syntax"
}






