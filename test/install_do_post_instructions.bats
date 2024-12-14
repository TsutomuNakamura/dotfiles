#!/usr/bin/env bats
load helpers

function setup() {
    cd ${HOME}
    mkdir -p .dotfiles


    stub clear_backup_anchor_file
    stub print_post_message_list
    stub logger_warn
}

function teardown() {
    true
}

@test '#do_post_instructions should return 0' {
    run do_post_instructions

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times clear_backup_anchor_file)"  -eq 1 ]]
    [[ "$(stub_called_times print_post_message_list)"   -eq 1 ]]
    [[ "$(stub_called_times logger_warn)"               -eq 0 ]]
}

@test '#do_post_instructions should return 0 and call logger_warn if clear_backup_anchor_file has failed' {
    stub_and_eval clear_backup_anchor_file '{ return 1; }'

    run do_post_instructions

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times clear_backup_anchor_file)"  -eq 1 ]]
    [[ "$(stub_called_times print_post_message_list)"   -eq 1 ]]
    [[ "$(stub_called_times logger_warn)"               -eq 1 ]]

    stub_called_with_exactly_times logger_warn 1 "Failed to delete backup anchor file \"${BACKUP_ANCHOR_FILE}\". You would delete it by your own, please."
}
