#!/usr/bin/env bats
load helpers

function setup() {
    cd ${HOME}

    function uuidgen() { echo "00000000-0000-0000-0000-000000000000"; }
    __BACKUP_DIR__="/var/tmp/backup"
    __BACKUP_FILE__="/var/tmp/backup/$(uuidgen).backup_anchor"
    mkdir -p "$__BACKUP_DIR__"
}

function teardown() {
    true
    rm -rf "$__BACKUP_DIR__"
}

@test '#create_backup_anchor_file should return STAT_SUCCEEDED_IN_CREATING_BACKUP_ANCHOR_FILE' {
    run create_backup_anchor_file "$__BACKUP_DIR__"

    [[ $status -eq $STAT_SUCCEEDED_IN_CREATING_BACKUP_ANCHOR_FILE ]]
    [[ "$(cat $__BACKUP_FILE__)" == "$STAT_BACKUP_IN_PROGRESS" ]]
}

@test '#create_backup_anchor_file should return STAT_ALREADY_CREATED_BACKUP_ANCHOR_FILE' {
    touch $__BACKUP_FILE__
    run create_backup_anchor_file "$__BACKUP_DIR__"

    [[ $status -eq $STAT_ALREADY_CREATED_BACKUP_ANCHOR_FILE ]]
}

@test '#create_backup_anchor_file should return STAT_FAILED_TO_CREATE_BACKUP_ANCHOR_FILE' {
    skip
    # TODO: How to validate this situation?
    run create_backup_anchor_file "$__BACKUP_DIR__"
    # Do stuff
}

