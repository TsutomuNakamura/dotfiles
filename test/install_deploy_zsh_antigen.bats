#!/usr/bin/env bats
load helpers

function setup() {
    stub_and_eval mkdir '{
        command mkdir "$@"
    }'
    stub curl
    stub zsh
    stub logger_err
}

function teardown() {
    command rm -rf "${ZSH_DIR}/antigen"
}

@test '#deploy_zsh_antigen should return 0 if all instructions werer succeeded' {
    run deploy_zsh_antigen

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)"         -eq 1 ]]
    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times zsh)"           -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]
    stub_called_with_exactly_times mkdir 1 -p "${ZSH_DIR}/antigen"
    stub_called_with_exactly_times curl 1 -L git.io/antigen
    stub_called_with_exactly_times zsh 1 -c "source \"${HOME}/.zshrc\""
}

@test '#deploy_zsh_antigen should return 1 if mkdir has failed' {
    stub_and_eval mkdir '{ return 1; }'
    run deploy_zsh_antigen

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)"         -eq 1 ]]
    [[ "$(stub_called_times curl)"          -eq 0 ]]
    [[ "$(stub_called_times zsh)"           -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times mkdir 1 -p "${ZSH_DIR}/antigen"
    stub_called_with_exactly_times logger_err 1 "Failed to create \"${ZSH_DIR}\""
}

@test '#deploy_zsh_antigen should return 1 if curl has failed' {
    stub_and_eval curl '{ return 1; }'
    run deploy_zsh_antigen

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)"         -eq 1 ]]
    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times zsh)"           -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times mkdir 1 -p "${ZSH_DIR}/antigen"
    stub_called_with_exactly_times curl 1 -L git.io/antigen
    stub_called_with_exactly_times logger_err 1 "Failed to create \"${ZSH_DIR}/antigen/antigen.zsh\" by downloading from git.io/antigen"
}

@test '#deploy_zsh_antigen should return 1 if zsh to install packages has failed' {
    stub_and_eval zsh '{ return 1; }'
    run deploy_zsh_antigen

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)"         -eq 1 ]]
    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times zsh)"           -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times mkdir 1 -p "${ZSH_DIR}/antigen"
    stub_called_with_exactly_times curl 1 -L git.io/antigen
    stub_called_with_exactly_times zsh 1 -c "source \"${HOME}/.zshrc\""
    stub_called_with_exactly_times logger_err 1 "Failed to load .zshrc to install packages with antigen"
}
