#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub push_post_message_list
}

# function teardown() {}

@test "#logger_warn should call echo and push_post_message_list()" {
    function test_logger_warn() {
        logger_warn "foo\n\"bar\""
    }

    run test_logger_warn

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*WARN.*:\ line\ [0-9]+:\ test_logger_warn\(\):\ foo.*\"bar\"$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    local line_no=$(echo "$output" | sed -e ':a' -e 'N' -e '$!ba' -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_YELLOW}WARN${FONT_COLOR_END}: line ${line_no}: test_logger_warn(): foo\n\"bar\""
}

