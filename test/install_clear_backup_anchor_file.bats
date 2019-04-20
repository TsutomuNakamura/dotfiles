#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    cd ${HOME}

    BACKUP_ANCHOR_FILE="/var/tmp/backup_anchor_file"
    touch "$BACKUP_ANCHOR_FILE"
}

function teardown() {
    command rm -f "$BACKUP_ANCHOR_FILE"
}

@test '#clear_backup_anchor_file should return 0 if deleting BACKUP_ANCHOR_FILE has succeeded' {
    run clear_backup_anchor_file

    [[ "$status" -eq 0 ]]
    [[ ! -f "$BACKUP_ANCHOR_FILE" ]]
}

@test '#clear_backup_anchor_file should return 0 if BACKUP_ANCHOR_FILE was not set' {
    BACKUP_ANCHOR_FILE=

    run clear_backup_anchor_file

    [[ "$status" -eq 0 ]]
}

@test '#clear_backup_anchor_file should return 0 if BACKUP_ANCHOR_FILE was not existed' {
    rm -f "$BACKUP_ANCHOR_FILE"
    run clear_backup_anchor_file

    [[ "$status" -eq 0 ]]
}

@test '#clear_backup_anchor_file should return not 0 if deleting BACKUP_ANCHOR_FILE was not succeeded' {
    function rm() { return 0; }
    run clear_backup_anchor_file

    [[ "$status" -ne 0 ]]
}
