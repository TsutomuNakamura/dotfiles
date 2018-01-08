#!/usr/bin/env bats
load helpers "install.sh"

# function setup() {}
# function teardown() {}

@test '#files_that_should_not_be_linked should return 0 if LICENSE.txt was specified' {
    run files_that_should_not_be_linked "LICENSE.txt"
    [[ "$status" -eq 0 ]]
}

@test '#files_that_should_not_be_linked should return NOT 0 if other than LICENSE.txt were specified' {
    run files_that_should_not_be_linked "hoge.txt"
    [[ "$status" -ne 0 ]]

    run files_that_should_not_be_linked "fuga.txt"
    [[ "$status" -ne 0 ]]
}

