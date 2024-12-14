#!/usr/bin/env bats
load helpers

#function setup() {}
#function teardown() {}

@test '#push_post_message_list should return 0' {
    run push_post_message_list "msg"
    [[ "$status" -eq 0 ]]
}

