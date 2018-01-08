#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    __backup_dir__="${HOME}/${BACKUPDIR}/19700101000000"

    function backup_xdg_base_directory_individually() {
        increment_call_count "backup_xdg_base_directory_individually"
    }
}
function teardown() {
    rm -rf "${HOME}/${BACKUPDIR}"
    unset __backup_dir__
    clear_call_count
}

@test '#backup_xdg_base_directory should create backup_dir if it was not existed' {
    run backup_xdg_base_directory "$__backup_dir__"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "$__backup_dir__" ]]
}

@test '#backup_xdg_base_directory should NOT return non 0 if backup_dir was already existed' {
    run backup_xdg_base_directory "$__backup_dir__"

    mkdir -p "$__backup_dir__"
    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "$__backup_dir__" ]]
}


@test '#backup_xdg_base_directory should call backup_xdg_base_directory_individually 2 times' {
    run backup_xdg_base_directory "$__backup_dir__"

    [[ "$status" -eq 0 ]]
    [[ "$(call_count backup_xdg_base_directory_individually)" -eq 2 ]]
}

