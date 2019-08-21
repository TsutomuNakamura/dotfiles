#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub deploy_zsh_antigen
}

function teardown() {
    true
}

@test '#deploy_zsh_environment should return 0 if all instruction has succeeded' {
    run deploy_zsh_environment

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times deploy_zsh_antigen)      -eq 1 ]]
}

@test '#deploy_zsh_environment should return 1 if deploy_zsh_antigen returns 1' {
    stub_and_eval deploy_zsh_antigen '{ return 1; }'
    run deploy_zsh_environment

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times deploy_zsh_antigen)      -eq 1 ]]
}
