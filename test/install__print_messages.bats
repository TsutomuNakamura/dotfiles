#!/usr/bin/env bats
load helpers

# function setup() {}
# function teardown() {}

@test "#_print_messages should print if message are existed" {
    declare -g -a SOME_MESSAGES
    SOME_MESSAGES[0]="a b c"
    SOME_MESSAGES[1]="d e f"

    run _print_message_list 'SOME_MESSAGES[@]'

    IFS=$'\n' outputs=($output)

    echo "$output"
    [[ "${#outputs[@]}" -eq 2 ]]
    [[ "${outputs[0]}" == "* a b c" ]]
    [[ "${outputs[1]}" == "* d e f" ]]
}

@test "#_print_messages should print nothing if array that passed it is not declared" {
    run _print_message_list 'SOME_MESSAGES[@]'
    [[ -z "$output" ]]
}

@test "#_print_messages should print nothing if array that passed it is empty" {
    declare -g -a SOME_MESSAGES
    run _print_message_list 'SOME_MESSAGES[@]'
    [[ -z "$output" ]]
}

