#!/usr/bin/env bats
load helpers

function setup() {
    stub rm
}

function teardown() {
    true
}

@test '#clear_tmp_backup_files should return 0 if 2 files of array were passed' {
    declare -a targets=("foo bar" "hoge-fuga")
    run clear_tmp_backup_files "${targets[@]}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times rm)"        -eq 2 ]]

    stub_called_with_exactly_times rm 1 -f "foo bar"
    stub_called_with_exactly_times rm 1 -f "hoge-fuga"
}

@test '#clear_tmp_backup_files should return 0 if 1 file of array were passed' {
    declare -a targets=("foo bar")
    run clear_tmp_backup_files "${targets[@]}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times rm)"        -eq 1 ]]

    stub_called_with_exactly_times rm 1 -f "foo bar"
}

@test '#clear_tmp_backup_files should return 0 if no files were passed' {
    run clear_tmp_backup_files

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times rm)"        -eq 0 ]]
}

