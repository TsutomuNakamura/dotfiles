#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub push_post_message_list
}

@test '#logger_err should call push_post_message_list' {
    run logger_err "foo\n\"bar\""

    [[ "$status" -eq 0 ]]
    [[ "$output" == "$(echo -e "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: foo\n\"bar\"")" ]]
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: foo\n\"bar\""
}


