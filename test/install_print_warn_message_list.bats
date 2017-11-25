#!/usr/bin/env bats
load helpers

function setup() {
    mkdir -p ${HOME}/${DOTDIR}
    stub print_boarder
    stub _print_message_list
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR}
}

@test "#print_warn_message_list should print info messages" {
    run print_warn_message_list
    [[ "$(stub_called_times print_boarder)" -eq 1 ]]
    stub_called_with_exactly_times _print_message_list 1 'WARN_MESSAGES[@]'
}

