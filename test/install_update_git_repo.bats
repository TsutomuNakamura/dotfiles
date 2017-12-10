#!/usr/bin/env bats
load helpers

function setup() {
    rm -rf /var/tmp/{..?*,.[!.]*,*}
    stub mkdir
    stub logger_warn
    stub logger_info
    stub_and_eval get_git_remote_aliases '{ echo "declare -a remotes=([0]=\"origin\")"; }'
    stub _do_update_git_repository
    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_JUST_CLONE; }'
    stub mkdir
}
function teardown() {
    rm -rf /var/tmp/{..?*,.[!.]*,*}
}

@test '#update_git_repo should call _do_update_git_repository()' {
    run update_git_repo "/var/tmp" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/.dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "master" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}


@test '#update_git_repo should call _do_update_git_repository() with one of a parameter dotfiles if the dir_of_repo of update_git_repo was empty string' {
    run update_git_repo "/var/tmp" "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "master" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" "dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}

@test '#update_git_repo should call determin_update_type_of_repository() with target=/var/tmp/bar/.dotfiles if /var/tmp/bar was specified to install_dir_of_repo' {
    command mkdir /var/tmp/bar
    run update_git_repo "/var/tmp/bar" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    echo "$output"
    [[ "$status" -eq 0 ]]
    # [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/bar/.dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/bar/.dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "master" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}

@test '#update_git_repo should call determin_update_type_of_repository() with url=git@github.com... and _do_update_git_repository() with git_url=git@github.com... if git@github.com... was specified to git_url' {
    run update_git_repo "/var/tmp" "git@github.com:TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/.dotfiles" "origin" "git@github.com:TsutomuNakamura/dotfiles.git" "master" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "git@github.com:TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}

@test '#update_git_repo should call determin_update_type_of_repository() and _do_update_git_repository() with parameter develop as branch if develop was specified to branch' {
    run update_git_repo "/var/tmp" "https://github.com/TsutomuNakamura/dotfiles.git" "develop" ".dotfiles"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/.dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "develop" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "develop" ".dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}

@test '#update_git_repo should create directory if install_dir_of_repo was not existed' {
    stub_and_eval mkdir '{ command mkdir -p "$2"; }'

    run update_git_repo "/var/tmp/foo" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 1 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times mkdir 1 -p "/var/tmp/foo"
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/foo/.dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/foo/.dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "master" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}

@test '#update_git_repo should return 1 if mkdir has failed' {
    stub_and_eval mkdir '{ command mkdir -p "$2"; return 1; }'

    run update_git_repo "/var/tmp/foo" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)" -eq 1 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 0 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 0 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 0 ]]
    stub_called_with_exactly_times mkdir 1 -p "/var/tmp/foo"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to create the directory \"/var/tmp/foo\""
}

@test '#update_git_repo should call determin_update_type_of_repository() with one of a parameter path_to_git_directory is "/var/tmp/.dotfiles (end of slash)"' {
    run update_git_repo "/var/tmp/" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]
    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" "remotes"
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/.dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "master" 0
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" $GIT_UPDATE_TYPE_JUST_CLONE
}

@test '#update_git_repo should return 1 if pushd has failed' {
    stub_and_eval pushd '{ return 1; }'
    run update_git_repo "/var/tmp/" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times pushd)" -eq 1 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 0 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 0 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 0 ]]

    stub_called_with_exactly_times pushd 1 "/var/tmp/"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to change the working directory to \"/var/tmp/\"."
}

@test '#update_git_repo should return 1 if get_git_remote_aliases() returns an array "remotes=([0]="origine")" (not origin)' {
    stub_and_eval get_git_remote_aliases '{ echo "declare -a remotes=([0]=\"origine\")"; }'
    run update_git_repo "/var/tmp/" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 0 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 0 ]]

    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" remotes
    stub_called_with_exactly_times logger_warn 1 "ERROR: Sorry, this script only supports single remote \"origin\". Failed to get remote origin from \"${target}\""
}

@test '#update_git_repo should return 1 if get_git_remote_aliases() returns an array "remotes=([0]="origin" [1]="develop")" (not only origin)' {
    stub_and_eval get_git_remote_aliases '{ echo "declare -a remotes=([0]=\"origin\" [1]=\"develop\")"; }'
    run update_git_repo "/var/tmp/" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 0 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 0 ]]

    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" remotes
    stub_called_with_exactly_times logger_warn 1 "ERROR: Sorry, this script only supports single remote \"origin\". Failed to get remote origin from \"${target}\""
}

@test '#update_git_repo should return 1 if get_git_remote_aliases() returns an empty array.' {
    stub_and_eval get_git_remote_aliases '{ echo "declare -a remotes"; }'
    run update_git_repo "/var/tmp/" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 0 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 0 ]]

    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" remotes
    stub_called_with_exactly_times logger_warn 1 "ERROR: Sorry, this script only supports single remote \"origin\". Failed to get remote origin from \"${target}\""
}

@test '#update_git_repo should call _do_update_git_repository() with update_type=GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY if determin_update_type_of_repository() returns GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY.' {
    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY; }'
    run update_git_repo "/var/tmp/" "https://github.com/TsutomuNakamura/dotfiles.git" "master" ".dotfiles"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)" -eq 0 ]]
    [[ "$(stub_called_times get_git_remote_aliases)" -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)" -eq 1 ]]
    [[ "$(stub_called_times _do_update_git_repository)" -eq 1 ]]

    stub_called_with_exactly_times get_git_remote_aliases 1 "/var/tmp/.dotfiles" remotes
    stub_called_with_exactly_times determin_update_type_of_repository 1 "/var/tmp/.dotfiles" "origin" "https://github.com/TsutomuNakamura/dotfiles.git" "master" 0
    #stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" "$GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY"
    stub_called_with_exactly_times _do_update_git_repository 1 "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" ".dotfiles" "1"

}

