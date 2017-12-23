#!/usr/bin/env bats
load helpers

function setup() {
    stub print_boarder
}
#function teardown() {}

@test '#print_post_message_list should NOT call if POST_MESSAGES is empty' {
    run print_post_message_list

    [[ "$status" -eq 0 ]]
    [[ -z "$outputs" ]]
    [[ "$(stub_called_times print_boarder)" -eq 0 ]]
}

@test '#print_post_message_list should call if POST_MESSAGES is not empty' {
    push_post_message_list "foo"
    run print_post_message_list

    echo "$status"
    [[ "$status" -eq 0 ]]
    [[ -z "$outputs" ]]
    [[ "$(stub_called_times print_boarder)" -eq 2 ]]

    stub_called_with_exactly_times print_boarder 1 " Summary of the instruction "
    stub_called_with_exactly_times print_boarder 1
}

