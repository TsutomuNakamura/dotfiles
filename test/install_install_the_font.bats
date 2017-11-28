#!/usr/bin/env bats
load helpers

function setup() {
    cd "${HOME}"
    stub push_info_message_list
}

function teardown() {
    cd "${HOME}"
}

@test '#install_the_font should return 0 and logged already installed if the font has already installed.' {
    function eval() { return 0; }
    run install_the_font "install_cmd" "font name" "msg1" "msg 2" "msg \"3\"" ""
    unset -f eval

    [[ "$status" -eq 0 ]]
    [[ "$output" = "$(echo -e "INFO: font name has already installed.\n  msg1")" ]]
    [[ "$(stub_called_times push_info_message_list)" = "0" ]]
}

@test '#install_the_font should return 0 and logged installe has successfully if the font has installed successfully.' {
    function eval() { return 1; }
    run install_the_font "install_cmd" "font name" "msg1" "msg 2" "msg \"3\"" ""
    unset -f eval

    echo -e "$output"
    [[ "$status" -eq 0 ]]
    [[ "$output" = "$(echo -e "INFO: font name has installed.\n  msg 2")" ]]
    echo $(stub_called_times push_info_message_list)
    stub_called_with_exactly_times push_info_message_list 1 "INFO: font name has installed.\n  msg 2"
}

