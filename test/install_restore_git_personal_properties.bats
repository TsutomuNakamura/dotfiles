#!/usr/bin/env bats
load helpers

function setup() {
    source ".bash_modules/read_ini.sh"

    cd "${HOME}"
    rm -rf "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}"
    mkdir -p "${FULL_BACKUPDIR_PATH}"
    if [[ -e "${HOME}/.gitconfig" ]] || [[ -L "${HOME}/.gitconfig" ]]; then
        unlink ${HOME}/.gitconfig
    fi

    # Process will be located in dotfiles repository.
    # mkdir -p "${FULL_DOTDIR_PATH}/.bash_modules"
    mkdir -p "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}"
    # cp "$(pwd)/.bash_modules/read_ini.sh" "${FULL_DOTDIR_PATH}/.bash_modules/"

    echo    '[user]'                        >  "${FULL_DOTDIR_PATH}/.gitconfig"
    echo -e '\temail = foo-bar@example.com' >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo -e '\tname ='                      >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo    ''                              >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo    '[include]'                     >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo -e '\tpath = .globalgitconfig'     >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo    ''                              >> "${FULL_DOTDIR_PATH}/.gitconfig"
    ln -s "${FULL_DOTDIR_PATH}/.gitconfig" .gitconfig

    ## Create email and name store
    echo 'foo bar' > "$GIT_USER_NAME_STORE_FILE_FULL_PATH"
    echo 'gpg2' > "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"

    # GIT_PROPERTIES_TO_KEEP contains git.user.email, git.user.name and git.gpg.program but backup file of git.user.email was not exist
    declare -g -A GIT_PROPERTIES_TO_KEEP=(
        # ['label']="${tmp_file_path},${name_of_variable},${command_to_restore}"
        ['email']="${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__user__email${GLOBAL_DELIMITOR}git config --global user.email \"\${__arg__}\""
        ['name']="${GIT_USER_NAME_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__user__name${GLOBAL_DELIMITOR}git config --global user.name \"\${__arg__}\""
        ['gpg_program']="${GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__gpg__program${GLOBAL_DELIMITOR}git config --global gpg.program \"\${__arg__}\""
    )

    stub_and_eval get_backup_dir '{ echo ${HOME}/${BACKUPDIR}/19000101000000; }'
    # stub_and_eval mkdir '{
    #     if [[ "$1" == "-p" ]]; then
    #         command mkdir -p "$2"
    #     fi
    # }'
    stub_and_eval git '{ command git "$@"; }'
    stub logger_err
}

function teardown() {
    command rm -rf "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}"
    if [[ -e "${HOME}/.gitconfig" ]] || [[ -L "${HOME}/.gitconfig" ]]; then
        unlink ${HOME}/.gitconfig
    fi
}

@test '#install_restore_git_personal_properties should return 0 if all instructions were succeeded' {
    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    echo "$output"
    read_ini "${HOME}/.gitconfig"
    # declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"

    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "foo-bar@example.com" ]]
    [[ "${INI__user__name}"                             == "foo bar" ]]
    [[ "${INI__gpg__program}"                           == "gpg2" ]]
    [[ "$(stub_called_times git)"                       -eq 2 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]

    stub_called_with_exactly_times git 1 config --global user.name "foo bar"
    stub_called_with_exactly_times git 1 config --global gpg.program "gpg2"
}

@test '#install_restore_git_personal_properties should return 0 if files GIT_USER_EMAIL_STORE_FILE_FULL_PATH and GIT_USER_NAME_STORE_FILE_FULL_PATH were not existed' {
    rm -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" "$GIT_USER_NAME_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "foo-bar@example.com" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "${INI__gpg__program}"                           == "gpg2" ]]

    [[ "$(stub_called_times git)"                       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]

    stub_called_with_exactly_times git 1 config --global gpg.program "gpg2"
}

@test '#install_restore_git_personal_properties should return 0 if files GIT_USER_EMAIL_STORE_FILE_FULL_PATH and GIT_USER_NAME_STORE_FILE_FULL_PATH were existed but empty' {
    true > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    true > "$GIT_USER_NAME_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "foo-bar@example.com" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "${INI__gpg__program}"                           == "gpg2" ]]

    [[ "$(stub_called_times git)"                       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]

    stub_called_with_exactly_times git 1 config --global gpg.program "gpg2"
}

@test '#install_restore_git_personal_properties should return 0 and call all git command that stored GIT_PROPERTIES_TO_KEEP' {
    echo "hoge-fuga@example.com" > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    echo "hoge fuga" > "$GIT_USER_NAME_STORE_FILE_FULL_PATH"
    echo "gpg3" > "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "hoge-fuga@example.com" ]]
    [[ "${INI__user__name}"                             == "hoge fuga" ]]
    [[ "${INI__gpg__program}"                           == "gpg3" ]]
    [[ "$(stub_called_times git)"                       -eq 3 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]

    stub_called_with_exactly_times git 1 config --global user.email "hoge-fuga@example.com"
    stub_called_with_exactly_times git 1 config --global user.name "hoge fuga"
    stub_called_with_exactly_times git 1 config --global gpg.program "gpg3"
}

@test '#install_restore_git_personal_properties should return 0 and not call any git command that stored GIT_PROPERTIES_TO_KEEP if backup files are not existed' {
    rm -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    rm -f "$GIT_USER_NAME_STORE_FILE_FULL_PATH"
    rm -f "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "foo-bar@example.com" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "${INI__gpg__program}"                           == "" ]]
    [[ "$(stub_called_times git)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
}

@test '#install_restore_git_personal_properties should return 0 and not call any git command that stored GIT_PROPERTIES_TO_KEEP if contents of backup files are all empty' {
    true > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    true > "$GIT_USER_NAME_STORE_FILE_FULL_PATH"
    true > "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "foo-bar@example.com" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "${INI__gpg__program}"                           == "" ]]
    [[ "$(stub_called_times git)"                       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
}


@test '#install_restore_git_personal_properties should return 1 if git command that changing name has failed' {
    echo "hoge-fuga@example.com" > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    echo "hoge fuga" > "$GIT_USER_NAME_STORE_FILE_FULL_PATH"
    echo "gpg3" > "$GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH"

    stub_and_eval git '{
        [[ "$3" == "user.name" ]] && return 1
        command git "$@"
    }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    [[ "$status" -eq 1 ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times git)"                -ge 1 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]

    stub_called_with_exactly_times git 1 config --global user.name "hoge fuga"
}

