#!/usr/bin/env bats
load helpers

#function setup() {}
# function teardown() {}

@test "#pushd should return 0 if success" {
    stub logger_err
    run pushd /tmp

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times logger_err) -eq 0 ]]
}

@test "#pushd should return 1 if the parameter is never existed directory" {
    stub logger_err
    # Change to nerver existed directory
    run pushd /a/b/c/d/e/f/g

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times logger_err) -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Failed to change (pushd) the directory to \"/a/b/c/d/e/f/g\""
}

