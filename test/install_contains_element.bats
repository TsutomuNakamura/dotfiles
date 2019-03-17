#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    declare -g -a array=(".config" "foo bar")
    true
}

function teardown() {
    true
}

@test '#contains_element should return 0 if ".config" was passed.' {
    run contains_element ".config" "${array[@]}"
    [[ "$status" -eq 0 ]]
}

@test '#contains_element should return 0 if "foo bar" was passed.' {
    run contains_element "foo bar" "${array[@]}"
    [[ "$status" -eq 0 ]]
}

@test '#contains_element should return 1 if "hoge fuga" was passed.' {
    run contains_element "hoge fuga" "${array[@]}"
    [[ "$status" -eq 1 ]]
}

