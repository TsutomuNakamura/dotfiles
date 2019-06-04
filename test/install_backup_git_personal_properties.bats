#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    rm -rf "$FULL_BACKUPDIR_PATH"

    declare -g -A GIT_PROPERTIES_TO_KEEP=(
        # ['label']="${tmp_file_path},${name_of_variable},${command_to_restore}"
        ['email']="${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__user__email${GLOBAL_DELIMITOR}git config --global user.email \"\${__arg__}\""
        ['gpg_program']="${GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__gpg__program${GLOBAL_DELIMITOR}git config --global gpg.program \"\${__arg__}\""
    )

    # Process will be located in dotfiles repository.
    mkdir -p "${FULL_DOTDIR_PATH}/.bash_modules"
    mkdir -p "${FULL_BACKUPDIR_PATH}"
    cp "$(pwd)/.bash_modules/read_ini.sh" "${FULL_DOTDIR_PATH}/.bash_modules/"

    command echo    '[user]'                            >  "${HOME}/.gitconfig"
    command echo -e '\temail = foo-bar@example.com'     >> "${HOME}/.gitconfig"
    command echo -e '\tname = foo bar'                  >> "${HOME}/.gitconfig"
    command echo -e '\tsigningkey = XXXXXXXXXXXXXXXX'   >> "${HOME}/.gitconfig"
    command echo    ''                                  >> "${HOME}/.gitconfig"
    command echo    '[include]'                         >> "${HOME}/.gitconfig"
    command echo -e '\tpath = .globalgitconfig'         >> "${HOME}/.gitconfig"
    command echo    ''                                  >> "${HOME}/.gitconfig"
    command echo    '[commit]'                          >> "${HOME}/.gitconfig"
    command echo -e '\tgpgsign = true'                  >> "${HOME}/.gitconfig"
    command echo    '[gpg]'                             >> "${HOME}/.gitconfig"
    command echo -e '\tprogram = gpg2'                  >> "${HOME}/.gitconfig"

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
    stub logger_info
}

function teardown() {
    rm -rf "$FULL_BACKUPDIR_PATH/*"
}

@test '#install_backup_git_personal_properties should return 0 if all instructions were succeeded' {
    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    #declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    [[ -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    [[ "$(cat "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH")"      == "foo-bar@example.com" ]]
    [[ "$(cat "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH")"     == "gpg2" ]]
}

@test '#install_backup_git_personal_properties should return 0 if file ${HOME}/.gitconfig was not existed' {
    rm -f ${HOME}/.gitconfig
    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    #declare -a outputs; IFS=$'\n' outputs=($output); echo "$outputs"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]
    [[ "$(stub_called_times logger_info)"   -eq 1 ]]

    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_info 1 "There is no ${HOME}/.gitconfig. Skip getting user.name and user.email for new .gitconfig."
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
    [[ "$(stub_called_times logger_info)"   -eq 0 ]]


    # there are no parameters due to the curl is mock
    # [[ -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    # [[ -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]
    # [[ "$(cat "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH")"      == "foo-bar@example.com" ]]
    # [[ "$(cat "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH")"     == "gpg2" ]]

    stub_called_with_exactly_times curl 1 "https://raw.githubusercontent.com/TsutomuNakamura/bash_ini_parser/master/read_ini.sh"
    stub_called_with_exactly_times read_ini 1 "--booleans" "0" "${HOME}/.gitconfig"
}

@test '#install_backup_git_personal_properties should return 1 if module read_ini.sh was not found and download(and source) read_init.sh was failed' {
    rm -f "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
    stub curl
    stub_and_eval source '{ return 1; }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 1 ]]

    [[ "$(stub_called_times curl)"          -eq 1 ]]
    [[ "$(stub_called_times source)"        -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 ".ini file parser \"${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh\" is not found. And failed to try download .ini file parser from https://raw.githubusercontent.com/TsutomuNakamura/bash_ini_parser/master/read_ini.sh"
}

@test '#install_backup_git_personal_properties should return 1 if source read_ini.sh locally was failed' {
    stub_and_eval source '{ return 1; }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$outputs"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times source)"     -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]

    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to load .ini file parser \"${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh\""
    stub_called_with_exactly_times source 1 "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
}

@test '#install_backup_git_personal_properties should return 1 if read_ini function was failed' {
    stub source
    stub_and_eval read_ini '{ return 1; }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    [[ "$(stub_called_times source)"     -eq 1 ]]
    [[ "$(stub_called_times read_ini)"   -eq 1 ]]

    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to parse \"${HOME}/.gitconfig\""
    stub_called_with_exactly_times source 1 "${FULL_DOTDIR_PATH}/.bash_modules/read_ini.sh"
}

@test '#install_backup_git_personal_properties should return 0 if GIT_USER_EMAIL_STORE_FILE_FULL_PATH has already existed' {
    command echo 'already-existed@example.com' > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    [[ -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    [[ "$(cat $GIT_USER_EMAIL_STORE_FILE_FULL_PATH)"            == "already-existed@example.com" ]]
    [[ "$(cat $GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH)"           == "gpg2" ]]
}

@test '#install_backup_git_personal_properties should return 0 if GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH has already existed' {
    command echo 'alreadygpg' > "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    [[ -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    [[ "$(cat $GIT_USER_EMAIL_STORE_FILE_FULL_PATH)"            == "foo-bar@example.com" ]]
    [[ "$(cat $GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH)"           == "alreadygpg" ]]
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
    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    [[ "$(stub_called_times clear_tmp_backup_files)" -eq 1 ]]

    # TODO: Assosiated array does not keep order.
    #       So this instruction may operate 2 files or a files.
    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"email\" to \"$GIT_USER_EMAIL_STORE_FILE_FULL_PATH\""
    # stub_called_with_exactly_times clear_tmp_backup_files 1 "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    stub_called_with_exactly_times echo 1 "foo-bar@example.com"
}

@test '#install_backup_git_personal_properties should return 1 if creating GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH was failed' {
    stub_and_eval echo '{
        if [[ "$1" == "gpg2" ]]; then
            return 1
        fi
        command echo "$@"
        return 0
    }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    [[ "$(stub_called_times clear_tmp_backup_files)" -eq 1 ]]

    # TODO: Assosiated array does not keep order.
    #       So this instruction may operate 2 files or a files.
    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"gpg_program\" to \"$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH\""
    # stub_called_with_exactly_times clear_tmp_backup_files 1 "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"
    stub_called_with_exactly_times echo 1 "gpg2"
}

@test '#install_backup_git_personal_properties should return 1 and should exist GIT_USER_EMAIL_STORE_FILE_FULL_PATH if creating GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH was failed and GIT_USER_EMAIL_STORE_FILE_FULL_PATH has already existed' {
    command echo 'already-existed@example.com' > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    stub_and_eval echo '{
        if [[ "$1" == "gpg2" ]]; then
            return 1
        fi
        command echo "$@"
        return 0
    }'

    run backup_git_personal_properties "${FULL_DOTDIR_PATH}"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    [[ "$(stub_called_times clear_tmp_backup_files)" -eq 1 ]]

    [[   -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[ ! -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"gpg_program\" to \"$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH\""
}

@test '#install_backup_git_personal_properties should return 1 and should exist GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH if creating GIT_USER_EMAIL_STORE_FILE_FULL_PATH was failed and GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH has already existed' {
    command echo 'gpg2' > "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"
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
    [[ "$(stub_called_times clear_tmp_backup_files)" -eq 1 ]]

    [[ ! -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" ]]
    [[   -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH" ]]

    stub_called_with_exactly_times logger_err 1 "Failed to store git property \"email\" to \"$GIT_USER_EMAIL_STORE_FILE_FULL_PATH\""
}

