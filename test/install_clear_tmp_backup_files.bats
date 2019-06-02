#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub rm
}

function teardown() {
    true
}

@test '#clear_tmp_backup_files should return 0 if no files were passed' {
    run clear_tmp_backup_files

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times rm)"        -eq 0 ]]
}

@test '#clear_tmp_backup_files should return 0 if 1 file was passed' {
    declare -a files=("foo")
    run clear_tmp_backup_files "${files[@]}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times rm)"        -eq 1 ]]

    stub_called_with_exactly_times rm 1 -f "foo"
}

@test '#clear_tmp_backup_files should return 0 if 2 file was passed' {
    declare -a files=("foo" "foo bar")
    run clear_tmp_backup_files "${files[@]}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times rm)"        -eq 2 ]]

    stub_called_with_exactly_times rm 1 -f "foo"
    stub_called_with_exactly_times rm 1 -f "foo bar"
}

