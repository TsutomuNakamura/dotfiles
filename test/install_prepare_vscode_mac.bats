#!/usr/bin/env bats
load helpers

function setup() {
    true
}

# TODO: A function prepare_vscode_mac has not been implemented yet.
@test '#prepare_vscode_mac(not implemented yet) should return 0 if all instructions have succeeded' {
    run prepare_vscode_mac
    [ "$status" -eq 0 ]
}

