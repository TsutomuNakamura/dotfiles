#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    source ".bash_modules/read_ini.sh"

    cd "${HOME}"
    rm -rf "${FULL_BACKUPDIR_PATH}"
    mkdir -p "${FULL_BACKUPDIR_PATH}"
    if [[ -L "${HOME}/.gitconfig" ]]; then
        unlink ${HOME}/.gitconfig
    fi

    # Process will be located in dotfiles repository.
    # mkdir -p "${FULL_DOTDIR_PATH}/.bash_modules"
    mkdir -p "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}"
    # cp "$(pwd)/.bash_modules/read_ini.sh" "${FULL_DOTDIR_PATH}/.bash_modules/"

    echo    '[user]'                        >  "${FULL_DOTDIR_PATH}/.gitconfig"
    echo -e '\temail ='                     >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo -e '\tname ='                      >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo    ''                              >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo    '[include]'                     >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo -e '\tpath = .globalgitconfig'     >> "${FULL_DOTDIR_PATH}/.gitconfig"
    echo    ''                              >> "${FULL_DOTDIR_PATH}/.gitconfig"
    ln -s "${FULL_DOTDIR_PATH}/.gitconfig" .gitconfig

    ## Create email and name store
    echo 'foo-bar@example.com' > "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}"
    echo 'foo bar' > "${GIT_USER_NAME_STORE_FILE_FULL_PATH}"

    stub_and_eval get_backup_dir '{ echo ${HOME}/${BACKUPDIR}/19000101000000; }'
    # stub_and_eval mkdir '{
    #     if [[ "$1" == "-p" ]]; then
    #         command mkdir -p "$2"
    #     fi
    # }'
    stub logger_err
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
}

function teardown() {
    rm -rf "${FULL_BACKUPDIR_PATH}" "${FULL_DOTDIR_PATH}" "${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}" "${GIT_USER_NAME_STORE_FILE_FULL_PATH}"
    if [[ -L "${HOME}/.gitconfig" ]]; then
        unlink ${HOME}/.gitconfig
    fi
}

@test '#install_restore_git_personal_properties should return 0 if all instructions were succeeded' {
    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    echo "$output"
    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "foo-bar@example.com" ]]
    [[ "${INI__user__name}"                             == "foo bar" ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 2 ]]
}

@test '#install_restore_git_personal_properties should return 0 if files $GIT_USER_EMAIL_STORE_FILE_FULL_PATH and $GIT_USER_NAME_STORE_FILE_FULL_PATH were not existed' {
    rm -f "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH" "$GIT_USER_NAME_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 0 ]]
}

@test '#install_restore_git_personal_properties should return 0 if files $GIT_USER_EMAIL_STORE_FILE_FULL_PATH and $GIT_USER_NAME_STORE_FILE_FULL_PATH were existed but empty' {
    true > "$GIT_USER_EMAIL_STORE_FILE_FULL_PATH"
    true > "$GIT_USER_NAME_STORE_FILE_FULL_PATH"

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 2 ]]
}

@test '#install_restore_git_personal_properties should return 0 and should call sed with options for Linux if it has run on Linux' {
    stub_and_eval sed '{ return 0; }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    echo "$output"
    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 2 ]]
    [[ "$(stub_called_times sed)"                       -eq 2 ]]
    stub_called_with_exactly_times sed 1 -i -e 's|^\([[:space:]]\+\)email[[:space:]]\+=.*|\1email = foo-bar@example.com|g' "${FULL_DOTDIR_PATH}/.gitconfig"
    stub_called_with_exactly_times sed 1 -i -e 's|^\([[:space:]]\+\)name[[:space:]]\+=.*|\1name = foo bar|g' "${FULL_DOTDIR_PATH}/.gitconfig"
}

@test '#install_restore_git_personal_properties should return 0 and should call sed with options for Linux if it has run on Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    stub_and_eval sed '{ return 0; }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 2 ]]
    [[ "$(stub_called_times sed)"                       -eq 2 ]]
    stub_called_with_exactly_times sed 1 -i "" -e 's|^\([[:space:]]\+\)email[[:space:]]\+=.*|\1email = foo-bar@example.com|g' "${FULL_DOTDIR_PATH}/.gitconfig"
    stub_called_with_exactly_times sed 1 -i "" -e 's|^\([[:space:]]\+\)name[[:space:]]\+=.*|\1name = foo bar|g' "${FULL_DOTDIR_PATH}/.gitconfig"
}

@test '#install_restore_git_personal_properties should return 1 if sed that changing email has failed on Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    stub_and_eval sed '{
        if [[ "$1" == "-i" ]] && [[ "$2" == "" ]] && [[ "$3" == "-e" ]] && [[ "$4" =~ .*email.* ]]; then
            return 1
        fi
    }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 1 ]]
    [[ "$(stub_called_times sed)"                       -eq 1 ]]
    stub_called_with_exactly_times sed 1 -i "" -e 's|^\([[:space:]]\+\)email[[:space:]]\+=.*|\1email = foo-bar@example.com|g' "${FULL_DOTDIR_PATH}/.gitconfig"
    stub_called_with_exactly_times logger_err 1 'Failed to restore email of the .gitconfig on your mac'
}

@test '#install_restore_git_personal_properties should return 1 if sed that changing email has failed on Linux' {
    stub_and_eval sed '{
        if [[ "$1" == "-i" ]] && [[ "$2" == "-e" ]] && [[ "$3" =~ .*email.* ]]; then
            return 1
        fi
    }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 1 ]]
    [[ "$(stub_called_times sed)"                       -eq 1 ]]
    stub_called_with_exactly_times sed 1 -i -e 's|^\([[:space:]]\+\)email[[:space:]]\+=.*|\1email = foo-bar@example.com|g' "${FULL_DOTDIR_PATH}/.gitconfig"
    stub_called_with_exactly_times logger_err 1 'Failed to restore email of the .gitconfig'
}

@test '#install_restore_git_personal_properties should return 1 if sed that changing name has failed on Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    stub_and_eval sed '{
        if [[ "$1" == "-i" ]] && [[ "$2" == "" ]] && [[ "$3" == "-e" ]] && [[ "$4" =~ .*name.* ]]; then
            return 1
        fi
    }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 2 ]]
    [[ "$(stub_called_times sed)"                       -eq 2 ]]
    stub_called_with_exactly_times sed 1 -i "" -e 's|^\([[:space:]]\+\)name[[:space:]]\+=.*|\1name = foo bar|g' "${FULL_DOTDIR_PATH}/.gitconfig"
    stub_called_with_exactly_times logger_err 1 'Failed to restore name of the .gitconfig on your mac'
}

@test '#install_restore_git_personal_properties should return 1 if sed that changing name has failed on Linux' {
    stub_and_eval sed '{
        if [[ "$1" == "-i" ]] && [[ "$2" == "-e" ]] && [[ "$3" =~ .*name.* ]]; then
            return 1
        fi
    }'

    run restore_git_personal_properties "${FULL_DOTDIR_PATH}"

    read_ini "${HOME}/.gitconfig"
    declare -a outputs; IFS=$'\n' outputs=($output); command echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "${INI__user__email}"                            == "" ]]
    [[ "${INI__user__name}"                             == "" ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"     -eq 2 ]]
    [[ "$(stub_called_times sed)"                       -eq 2 ]]
    stub_called_with_exactly_times sed 1 -i -e 's|^\([[:space:]]\+\)name[[:space:]]\+=.*|\1name = foo bar|g' "${FULL_DOTDIR_PATH}/.gitconfig"
    stub_called_with_exactly_times logger_err 1 'Failed to restore name of the .gitconfig'
}

