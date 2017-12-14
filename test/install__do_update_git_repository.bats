#!/usr/bin/env bats
load helpers

function setup() {
    stub git
}
function teardown() {
}

@test '#_do_update_git_repository should ' {
    run _do_update_git_repository
}


