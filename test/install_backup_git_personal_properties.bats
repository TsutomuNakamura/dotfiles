#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    rm -rf "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}" "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" "$GIT_USER_NAME_STORE_FILE_FULL_PATH" "${HOME}/.gitconfig"

    # Process will be located in dotfiles repository.
    mkdir -p "${FULL_DOTDIR_PATH}/.bash_modules"
    mkdir -p "${FULL_BACKUPDIR_PATH}"
    cp "$(pwd)/.bash_modules/read_ini.sh" "${FULL_DOTDIR_PATH}/.bash_modules/"

    echo    '[user]'                            >  "${HOME}/.gitconfig"
    echo -e '\temail = foo-bar@example.com'     >> "${HOME}/.gitconfig"
    echo -e '\tname = foo bar'                  >> "${HOME}/.gitconfig"
    echo -e '\tsigningkey = XXXXXXXXXXXXXXXX'   >> "${HOME}/.gitconfig"
    echo    ''                                  >> "${HOME}/.gitconfig"
    echo    '[include]'                         >> "${HOME}/.gitconfig"
    echo -e '\tpath = .globalgitconfig'         >> "${HOME}/.gitconfig"
    echo    ''                                  >> "${HOME}/.gitconfig"
    echo    '[commit]'                          >> "${HOME}/.gitconfig"
    echo -e '\tgpgsign = true'                  >> "${HOME}/.gitconfig"

    stub_and_eval get_backup_dir '{ echo ${HOME}/${BACKUPDIR}/19000101000000; }'
    stub_and_eval mkdir '{
        if [[ "$1" == "-p" ]]; then
            command mkdir -p "$2"
        fi
    }'
    stub_and_eval clear_tmp_backup_files '{
        local targets=("$@")
        local f
        for f in "${targets[@]}"; do
            rm -f "$f"
        done
    }'
    stub logger_err
}

function teardown() {
    rm -rf "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}" "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" "$GIT_USER_NAME_STORE_FILE_FULL_PATH" "${HOME}/.gitconfig"
}

@test '#install_backup_git_personal_properties should return 0 if all instructions were succeeded' {
    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    [[ -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    [[ "$(cat "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}")"        == "foo-bar@example.com" ]]
    [[ "$(cat "${GIT_USER_NAME_STORE_FILE_FULL_PATH}")"         == "foo bar" ]]
    [[ "$(cat "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}")"   == "XXXXXXXXXXXXXXXX" ]]
    [[ "$(cat "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}")"    == "true" ]]
}

@test '#install_backup_git_personal_properties should return 0 if GIT_USER_EMAIL_STORE_FILE_FULL_PATH, GIT_USER_NAME_STORE_FILE_FULL_PATH, GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH and GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH already existed' {
    touch "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" "$GIT_USER_NAME_STORE_FILE_FULL_PATH" "$GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH" "$GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH"

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 0 ]]

    [[ "$(stub_called_times get_backup_dir)"    -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]
}

@test '#install_backup_git_personal_properties should return 0 if file ${HOME}/.gitconfig was not existed' {
    rm -f ${HOME}/.gitconfig
    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    #declare -a outputs; IFS=$'\n' outputs=($output); echo "$outputs"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]
}

@test '#install_backup_git_personal_properties should return 0 if module read_ini.sh was not found but download read_init.sh has succeeded' {
    rm -f "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
    stub curl
    stub source
    stub read_ini

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 0 ]]

    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times source)"        -eq 1 ]]
    [[ "$(stub_called_times read_ini)"      -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]

    [[ -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    # [[ "$(cat "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}")"        == "foo-bar@example.com" ]]
    # [[ "$(cat "${GIT_USER_NAME_STORE_FILE_FULL_PATH}")"         == "foo bar" ]]
    # [[ "$(cat "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}")"   == "XXXXXXXXXXXXXXXX" ]]
    # [[ "$(cat "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}")"    == "true" ]]

    stub_called_with_exactly_times curl 1 "https://raw.githubusercontent.com/TsutomuNakamura/bash_ini_parser/master/read_ini.sh"
    stub_called_with_exactly_times read_ini 1 "--booleans" "0" "${HOME}/.gitconfig"
}

@test '#install_backup_git_personal_properties should return 1 if module read_ini.sh was not found and and download(and source) read_init.sh was failed' {
    rm -f "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
    stub_and_eval source '{ return 1; }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 1 ]]

    [[ "$(stub_called_times source)"        -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 ".ini file parser \"${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh\" is not found. And failed to try download .ini file parser from https://raw.githubusercontent.com/TsutomuNakamura/bash_ini_parser/master/read_ini.sh"
}

@test '#install_backup_git_personal_properties should return 1 if source read_ini.sh locally was failed' {
    stub_and_eval source '{ return 1; }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    [[ "$(stub_called_times source)"     -eq 1 ]]

    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to load .ini file parser \"${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh\""
    stub_called_with_exactly_times source 1 "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
}

@test '#install_backup_git_personal_properties should return 1 if read_ini function was failed' {
    stub_and_eval source '{ return 0; }'
    stub_and_eval read_ini '{ return 1; }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    [[ "$(stub_called_times source)"     -eq 1 ]]
    [[ "$(stub_called_times read_ini)"   -eq 1 ]]

    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to parse \"${HOME}/.gitconfig\""
    stub_called_with_exactly_times source 1 "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
}

@test '#install_backup_git_personal_properties should return 0 if $GIT_USER_EMAIL_STORE_FILE_FULL_PATH has already existed' {
    command echo 'already-existed@example.com' > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    [[ -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    [[ "$(cat $GIT_USER_EMAIL_STORE_FILE_FULL_PATH)"            == "already-existed@example.com" ]]
    [[ "$(cat $GIT_USER_NAME_STORE_FILE_FULL_PATH)"             == "foo bar" ]]
    [[ "$(cat "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}")"   == "XXXXXXXXXXXXXXXX" ]]
    [[ "$(cat "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}")"    == "true" ]]
}

@test '#install_backup_git_personal_properties should return 0 if GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH has already existed' {
    command echo 'false' > "$GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH"

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    [[ -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    [[ "$(cat $GIT_USER_EMAIL_STORE_FILE_FULL_PATH)"            == "foo-bar@example.com" ]]
    [[ "$(cat $GIT_USER_NAME_STORE_FILE_FULL_PATH)"             == "foo bar" ]]
    [[ "$(cat "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}")"   == "XXXXXXXXXXXXXXXX" ]]
    [[ "$(cat "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}")"    == "false" ]]
}

@test '#install_backup_git_personal_properties should return 1 if creating GIT_USER_EMAIL_STORE_FILE_FULL_PATH was failed' {
    stub_and_eval echo '{
        if [[ "$1" == "foo-bar@example.com" ]]; then
            return 1
        fi
        command echo "$@"
        return 0
    }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]

    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"email\" to \"${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}\""
    stub_called_with_exactly_times echo 1 "foo-bar@example.com"
}

@test '#install_backup_git_personal_properties should return 1 if creating GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH was failed' {
    stub_and_eval echo '{
        if [[ "$1" == "true" ]]; then
            return 1
        fi
        command echo "$@"
        return 0
    }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    # [[ "$(stub_called_times echo)"          -eq 4 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"gpgsign_flag\" to \"${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}\""
    stub_called_with_exactly_times echo 1 "foo-bar@example.com"
    stub_called_with_exactly_times echo 1 "foo bar"
    stub_called_with_exactly_times echo 1 "XXXXXXXXXXXXXXXX"
    stub_called_with_exactly_times echo 1 "true"
}

@test '#install_backup_git_personal_properties should return 1 and should exist GIT_USER_EMAIL_STORE_FILE_FULL_PATH if creating GIT_USER_NAME_STORE_FILE_FULL_PATH was failed and GIT_USER_EMAIL_STORE_FILE_FULL_PATH has already existed' {
    command echo 'already-existed@example.com' > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    stub_and_eval echo '{
        if [[ "$1" == "foo bar" ]]; then
            return 1
        fi
        command echo "$@"
        return 0
    }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]

    [[   -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"name\" to \"${GIT_USER_NAME_STORE_FILE_FULL_PATH}\""
    stub_called_with_exactly_times echo 0 "foo-bar@example.com"
    stub_called_with_exactly_times echo 1 "foo bar"
    stub_called_with_exactly_times echo 0 "XXXXXXXXXXXXXXXX"
    stub_called_with_exactly_times echo 0 "true"
}

@test '#install_backup_git_personal_properties should return 1 and should exist GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH if creating GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH was failed and GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH has already existed' {
    command echo 'false' > "$GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH"
    stub_and_eval echo '{
        if [[ "$1" == "XXXXXXXXXXXXXXXX" ]]; then
            return 1
        fi
        command echo "$@"
        return 0
    }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]

    [[ ! -f "${GIT_USER_NAME_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" ]]
    [[ ! -f "${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}" ]]
    [[   -f "${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"signingkey_id\" to \"${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}\""
    stub_called_with_exactly_times echo 1 "foo-bar@example.com"
    stub_called_with_exactly_times echo 1 "foo bar"
    stub_called_with_exactly_times echo 1 "XXXXXXXXXXXXXXXX"
    stub_called_with_exactly_times echo 0 "true"
}

