#!/usr/bin/env bats
load helpers

# These test cases requires _print_message_list() is able to run correctly.

# function setup() {}
# function teardown() {}

@test "#push_info_message_list should be able to push info messages" {
    push_info_message_list "a b c"
    push_info_message_list "d e f"
    run _print_message_list 'INFO_MESSAGES[@]'

    IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "* a b c" ]]
    [[ "${outputs[1]}" == "* d e f" ]]
}

@test "#push_info_message_list should be able to push an info message" {
    push_info_message_list "a b c"
    run _print_message_list 'INFO_MESSAGES[@]'

    IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "* a b c" ]]
    [[ "${outputs[1]}" == "" ]]
}

