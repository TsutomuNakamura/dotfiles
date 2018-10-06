#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub push_post_message_list
}

# function teardown() {}

@test "#logger_warn should call echo and push_post_message_list()" {
    run logger_warn "foo\n\"bar\""

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*WARN.*:\ line\ [0-9]+:\ run\(\):\ foo.*\"bar\"$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    local line_no=$(echo "$output" | sed -e ':a' -e 'N' -e '$!ba' -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_YELLOW}WARN${FONT_COLOR_END}: line ${line_no}: run(): foo\n\"bar\""
}

