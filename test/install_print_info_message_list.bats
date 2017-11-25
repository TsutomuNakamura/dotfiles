#!/usr/bin/env bats
load helpers

function setup() {
    stub print_boarder
    stub _print_message_list
}

# function teardown() {}

@test "#print_info_message_list should print info messages" {
    run print_info_message_list
    [[ "$(stub_called_times print_boarder)" -eq 1 ]]
    echo $(stub_called_times print_boarder)
    stub_called_with_exactly_times _print_message_list 1 'INFO_MESSAGES[@]'

}

