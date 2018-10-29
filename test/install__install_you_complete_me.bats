#!/usr/bin/env bats

load helpers "install.sh"

setup() {
    stub curl
    stub python3
    stub logger_err
}

@test '#_install_you_complete_me should return 0 if it was succeeded' {
    run _install_you_complete_me

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times python3)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]
    stub_called_with_exactly_times curl 1 -fLo "${HOME}/.ycm_extra_conf.py" "https://raw.githubusercontent.com/Valloric/ycmd/master/.ycm_extra_conf.py"
    stub_called_with_exactly_times python3 1 install.py --clang-completer --system-libclang
}

@test '#_install_you_complete_me should return 1 if command curl was failed' {
    stub_and_eval curl '{ return 1; }'
    run _install_you_complete_me

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times python3)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times curl 1 -fLo "${HOME}/.ycm_extra_conf.py" "https://raw.githubusercontent.com/Valloric/ycmd/master/.ycm_extra_conf.py"
    stub_called_with_exactly_times logger_err 1 "Failed to get vim-plug at ~/.ycm_extra_conf.py"
}

@test '#_install_you_complete_me should return 1 if command python3 was failed' {
    stub_and_eval python3 '{ return 1; }'
    run _install_you_complete_me

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times python3)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times curl 1 -fLo "${HOME}/.ycm_extra_conf.py" "https://raw.githubusercontent.com/Valloric/ycmd/master/.ycm_extra_conf.py"
    stub_called_with_exactly_times python3 1 install.py --clang-completer --system-libclang
    stub_called_with_exactly_times logger_err 1 "Failed to install with python3 install.py"
}

