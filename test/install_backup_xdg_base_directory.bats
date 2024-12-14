#!/usr/bin/env bats
load helpers

function setup() {
    __backup_dir__="${HOME}/${BACKUPDIR}/19700101000000"
    stub backup_xdg_base_directory_individually
}
function teardown() {
    rm -rf "${HOME}/${BACKUPDIR}"
    unset __backup_dir__
}

@test '#backup_xdg_base_directory should create backup_dir if it was not existed' {
    run backup_xdg_base_directory "$__backup_dir__"

    [[ "$status" -eq 0 ]]
    [[ -d "$__backup_dir__" ]]
    [[ "$(stub_called_times backup_xdg_base_directory_individually)" -eq 2 ]]
}

@test '#backup_xdg_base_directory should NOT return non 0 if backup_dir was already existed' {
    mkdir -p "$__backup_dir__"

    run backup_xdg_base_directory "$__backup_dir__"

    [[ "$status" -eq 0 ]]
    [[ -d "$__backup_dir__" ]]
    [[ "$(stub_called_times backup_xdg_base_directory_individually)" -eq 2 ]]
}

