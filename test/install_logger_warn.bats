#!/usr/bin/env bats
load helpers

function setup() {
    stub push_warn_message_list
}

# function teardown() {}

@test "#logger_warn should call echo and push_warn_message_list()" {
    run logger_warn "ERROR: foo\n\"bar\""

    [[ "$status" -eq 0 ]]
    [[ "$output" == "$(echo -e "ERROR: foo\n\"bar\"")" ]]
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: foo\n\"bar\""
}

