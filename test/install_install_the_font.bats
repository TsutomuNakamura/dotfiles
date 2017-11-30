#!/usr/bin/env bats
load helpers

function setup() {
    cd "${HOME}"
    stub push_info_message_list
    stub push_warn_message_list
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
    [[ "$(stub_called_times push_warn_message_list)" = "0" ]]
}

@test '#install_the_font should return 0 and logged installe has successfully if the font has installed successfully.' {
    function eval() { return 1; }
    run install_the_font "install_cmd" "font name" "msg1" "msg 2" "msg \"3\"" ""
    unset -f eval

    echo -e "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times push_info_message_list)" = "1" ]]
    [[ "$(stub_called_times push_warn_message_list)" = "0" ]]
    [[ "$output" = "$(echo -e "INFO: font name has installed.\n  msg 2")" ]]
    stub_called_with_exactly_times push_info_message_list 1 "INFO: font name has installed.\n  msg 2"
}

@test '#install_the_font should return 0 and logged installe has successfully if the font has installed successfully.' {
    function eval() { return 1; }
    run install_the_font "install_cmd" "font name" "msg1" "msg 2" "msg \"3\"" ""

    echo -e "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times push_info_message_list)" = "1" ]]
    [[ "$output" = "$(echo -e "INFO: font name has installed.\n  msg 2")" ]]
    stub_called_with_exactly_times push_info_message_list 1 "INFO: font name has installed.\n  msg 2"
}

@test '#install_the_font should return 1 and logged an error if the installing the font has been failed.' {
    function eval() { return 2; }
    run install_the_font "install_cmd" "font name" "msg1" "msg 2" "msg \"3\"" ""

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times push_info_message_list)" = "0" ]]
    [[ "$(stub_called_times push_warn_message_list)" = "1" ]]
    [[ "$output" = "$(echo -e "ERROR: Failed to install font name.\n  msg \"3\"")" ]]
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: Failed to install font name.\n  msg \"3\""
}

# TODO:
@test '#install_the_font should return 1 and logged an error if the installing the font has been encounted an unknown error.' {
    function eval() { return 3; }
    run install_the_font "install_cmd" "font name" "msg1" "msg 2" "msg \"3\"" ""

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times push_info_message_list)" = "0" ]]
    [[ "$(stub_called_times push_warn_message_list)" = "1" ]]
    [[ "$output" = "ERROR: Unknown error was occured when installing font name." ]]
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: Unknown error was occured when installing font name."
}



