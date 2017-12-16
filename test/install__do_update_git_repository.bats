#!/usr/bin/env bats
load helpers

function setup() {
    cd ~
    mkdir "/var/tmp/.dotfiles"
    stub git
    stub rm
    stub logger_info
    stub logger_warn
}
function teardown() {
    cd ~
    command rm -rf "/var/tmp/.dotfiles"
}

@test '#_do_update_git_repository should call "git clone -b master <url> <dir>" if the update_type is GIT_UPDATE_TYPE_JUST_CLONE' {
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_JUST_CLONE

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_JUST_CLONE and git-clone has failed' {
    stub_and_eval git '{ return 1; }'
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_JUST_CLONE

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to clone the repository(git -C \"/var/tmp/.dotfiles\" clone -b \"master\" \"https://github.com/TsutomuNakamura/dotfiles.git\" \".dotfiles\")"
}

@test '#_do_update_git_repository should call rm then "git clone -b master <url> <dir>" if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY' {
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY and git-clone has failed' {
    stub_and_eval git '{ return 1; }'
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to clone the repository(git -C \"/var/tmp/.dotfiles\" clone -b \"master\" \"https://github.com/TsutomuNakamura/dotfiles.git\" \".dotfiles\")"
}

@test '#_do_update_git_repository should call rm then "git clone -b master <url> <dir> if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE"' {
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE and git-clone has failed"' {
    stub_and_eval git '{ return 1; }'
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to clone the repository(git -C \"/var/tmp/.dotfiles\" clone -b \"master\" \"https://github.com/TsutomuNakamura/dotfiles.git\" \".dotfiles\")"
}

@test '#_do_update_git_repository should call rm then "git clone -b master <url> <dir> if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET"' {
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET"' {
    stub_and_eval git '{ return 1; }'
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to clone the repository(git -C \"/var/tmp/.dotfiles\" clone -b \"master\" \"https://github.com/TsutomuNakamura/dotfiles.git\" \".dotfiles\")"
}

@test '#_do_update_git_repository should call rm then "git clone -b master <url> <dir> if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT"' {
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT"' {
    stub_and_eval git '{ return 1; }'
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times rm) -eq 1 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf "/var/tmp/.dotfiles"
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" clone -b "master" "https://github.com/TsutomuNakamura/dotfiles.git" ".dotfiles"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to clone the repository(git -C \"/var/tmp/.dotfiles\" clone -b \"master\" \"https://github.com/TsutomuNakamura/dotfiles.git\" \".dotfiles\")"
}


@test '#_do_update_git_repository should return GIT_UPDATE_TYPE_ABOARTED if the update_type is GIT_UPDATE_TYPE_ABOARTED"' {
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_ABOARTED

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times rm) -eq 0 ]]
    [[ $(stub_called_times logger_info) -eq 1 ]]
    [[ $(stub_called_times git) -eq 0 ]]
    stub_called_with_exactly_times logger_info 1 "Updating or cloning repository \"https://github.com/TsutomuNakamura/dotfiles.git\" has been aborted."
}

@test '#_do_update_git_repository should call git-reset then remove-untracked-tiles then git-pull if the update_type is GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL"' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo "master"
        return 0
    }'
    stub remove_all_untracked_files

    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times remove_all_untracked_files) -eq 1 ]]
    [[ $(stub_called_times git) -eq 3 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" reset --hard
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" pull origin master
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL and remote is different from "origin"' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo "master"
        return 0
    }'
    stub remove_all_untracked_files

    #run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origine" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times remove_all_untracked_files) -eq 0 ]]
    [[ $(stub_called_times git) -eq 0 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times logger_warn 1 "ERROR: Sorry, this script only supports remote as \"origin\". The repository had been going to clone remote as \"origine\""
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL and git-rev-parse has failed' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo ""        # Failed to get branch name
        return 0
    }'
    stub remove_all_untracked_files

    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times remove_all_untracked_files) -eq 0 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to get git branch name from \"/var/tmp/.dotfiles\""
}

@test '#_do_update_git_repository should return 1 if the update_type is unknown' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo "master"
        return 0
    }'
    stub remove_all_untracked_files

    #run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL
    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" 97

    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times remove_all_untracked_files) -eq 0 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times logger_warn 1 "ERROR: Invalid git update type (97). Some error occured when determining git update type of \"/var/tmp/.dotfiles\"."
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL and git-reset has failed' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo "master"
        [[ "$3" == "reset" ]] && return 1
        return 0
    }'
    stub remove_all_untracked_files

    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL

    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times remove_all_untracked_files) -eq 0 ]]
    [[ $(stub_called_times git) -eq 2 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" reset --hard
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to reset git repository at \"/var/tmp/.dotfiles\" for some readson."
}

@test '#_do_update_git_repository should return 1 if the update_type is GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL and git-pull has failed' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo "master"
        [[ "$3" == "pull" ]] && return 1
        return 0
    }'
    stub remove_all_untracked_files

    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL

    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times remove_all_untracked_files) -eq 1 ]]
    [[ $(stub_called_times git) -eq 3 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" reset --hard
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" pull "origin" "master"
    stub_called_with_exactly_times remove_all_untracked_files 1 "$PWD"
    stub_called_with_exactly_times logger_warn 1 "ERROR: Failed to pull \"origin\" \"master\"."
}

@test '#_do_update_git_repository should just call git pull if the update_type is GIT_UPDATE_TYPE_JUST_PULL"' {
    stub_and_eval git '{
        [[ "$3" == "rev-parse" ]] && echo "master"
        return 0
    }'

    run _do_update_git_repository "/var/tmp/.dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "origin" "master" $GIT_UPDATE_TYPE_JUST_PULL

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times git) -eq 2 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 -C "/var/tmp/.dotfiles" pull origin master
}

