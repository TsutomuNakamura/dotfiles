#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    true
}

function teardown() {
    true
}

@test '#clear_git_personal_properties should return 0 if all instructions are succeeded' {

    run clear_git_personal_properties
}

