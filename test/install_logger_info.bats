#!/usr/bin/env bats
load helpers

function setup() {
    stub push_info_message_list
}

# function teardown() {}

@test "#logger_info should call echo and push_info_message_list()" {
    run logger_info "INFO: foo\n\"bar\""

    echo "$output"
    [[ "$status" -eq 0 ]]
    stub_called_with_exactly_times push_info_message_list 1 "INFO: foo\n\"bar\""
}

