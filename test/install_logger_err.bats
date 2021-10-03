#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub push_post_message_list
}

@test '#logger_err should call push_post_message_list' {
    function test_logger_err() {
        logger_err "foo\n\"bar\""
    }
    run test_logger_err

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*ERROR.*:\ line\ [0-9]+:\ test_logger_err\(\):\ foo.*\"bar\"$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    local line_no=$(echo "$output" | sed -e ':a' -e 'N' -e '$!ba' -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: line ${line_no}: test_logger_err(): foo\n\"bar\""
}

@test '#logger_err should print message with parent of parent name of method if its called from pushd' {
    function pushd() {
        logger_err "foo bar"
    }
    function test_logger_err() {
        pushd
    }
    run test_logger_err

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*ERROR.*:\ line\ [0-9]+:\ test_logger_err\(\):\ foo\ bar$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    local line_no=$(echo "$output" | sed -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: line ${line_no}: test_logger_err(): foo bar"
}

@test '#logger_err should print message with parent of parent name of method if its called from mmkdir' {
    function mmkdir() {
        logger_err "foo bar"
    }
    function test_logger_err() {
        mmkdir
    }
    run test_logger_err

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*ERROR.*:\ line\ [0-9]+:\ test_logger_err\(\):\ foo\ bar$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    local line_no=$(echo "$output" | sed -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: line ${line_no}: test_logger_err(): foo bar"
}

@test '#logger_err should print message with parent of parent name of method if its called from lln' {
    function lln() {
        logger_err "foo bar"
    }
    function test_logger_err() {
        lln
    }
    run test_logger_err

    [[ "$status" -eq 0 ]]
    [[ "$output" =~ ^.*ERROR.*:\ line\ [0-9]+:\ test_logger_err\(\):\ foo\ bar$ ]]
    [[ $(stub_called_times push_post_message_list) -eq 1 ]]
    local line_no=$(echo "$output" | sed -e 's/.*: line \([0-9]\+\).*/\1/' | cut -d' ' -f1)
    stub_called_with_exactly_times push_post_message_list 1 "${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: line ${line_no}: test_logger_err(): foo bar"
}
