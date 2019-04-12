#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    mkdir -p "${FULL_BACKUPDIR_PATH}"
    touch "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    touch "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"

    stub_and_eval rm '{ command rm $@; }'
}

function teardown() {
    rm -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    rm -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"
}

@test '#clear_git_personal_properties should return 0 if all instructions are succeeded' {
    run clear_git_personal_properties

    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}" ]]
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}" ]]
    stub_called_with_exactly_times rm 1 -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    stub_called_with_exactly_times rm 1 -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"
}

@test '#clear_git_personal_properties should return 0 when email-store file does not exist and skip to remove it' {
    command rm -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    run clear_git_personal_properties

    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}" ]]
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}" ]]
    stub_called_with_exactly_times rm 0 -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    stub_called_with_exactly_times rm 1 -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"
}

@test '#clear_git_personal_properties should return 0 when name-store file does not exist and skip to remove it' {
    command rm -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    run clear_git_personal_properties

    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}" ]]
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}" ]]
    stub_called_with_exactly_times rm 0 -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    stub_called_with_exactly_times rm 1 -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"
}
