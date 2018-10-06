#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub push_post_message_list
}

@test '#logger_err should call push_post_message_list' {
    run logger_err "foo\n\"bar\""

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*ERROR.*:\ line\ [0-9]+:\ run\(\):\ foo.*\"bar\"$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    # `sed -e ':a' -e 'N' -e '$!ba'` is replace newline(\n) using sed.
    local line_no=$(echo "$output" | sed -e ':a' -e 'N' -e '$!ba' -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: line ${line_no}: run(): foo\n\"bar\""
}


