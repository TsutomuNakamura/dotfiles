#!/usr/bin/env bats
load helpers

function setup() {
    stub push_post_message_list
}

# function teardown() {}

@test "#logger_warn should call echo and push_warn_message_list()" {
    run logger_warn "foo\n\"bar\""

    [[ "$status" -eq 0 ]]
    [[ "$output" == "$(echo -e "${FONT_COLOR_YELLOW}WARN${FONT_COLOR_END}: foo\n\"bar\"")" ]]
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_YELLOW}WARN${FONT_COLOR_END}: foo\n\"bar\""
}

