#!/usr/bin/env bats
load helpers

function setup() {
    cd "${HOME}"
    stub git
    stub_and_eval update_git_repo '{
        mkdir -p ${HOME%/}/.dotfiles
        touch ${HOME%/}/.dotfiles/.gitconfig
    }'
    stub logger_err
}

function teardown() {
    cd "${HOME}"
    rm -rf .gitconfig ${HOME%/}/.dotfiles/
}

@test '#init_repo should return 0 if no errors have occured' {
    run init_repo "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times update_git_repo)" -eq 1 ]]
    [[ "$(stub_called_times git)" -eq 3 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times update_git_repo 1 "${HOME%/}" ".dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "master"
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" update-index --assume-unchanged .gitconfig
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule init
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule update
}

@test '#init_repo should return 1 if update_git_repo() has failed' {
    stub_and_eval update_git_repo '{ return 1; }'

    run init_repo "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times update_git_repo)" -eq 1 ]]
    [[ "$(stub_called_times git)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    stub_called_with_exactly_times update_git_repo 1 "${HOME%/}" ".dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "master"
    stub_called_with_exactly_times logger_err 1 "Updating repository of dotfiles was aborted due to previous error"
}

@test '#init_repo should return 0 and doesn not call "git update-index" if .gitconfig file is not existed' {
    stub_and_eval update_git_repo '{
        mkdir -p ${HOME%/}/.dotfiles
        # touch ${HOME%/}/.dotfiles/.gitconfig    # .gitconfig file is not existed
    }'

    run init_repo "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times update_git_repo)" -eq 1 ]]
    [[ "$(stub_called_times git)" -eq 2 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times update_git_repo 1 "${HOME%/}" ".dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "master"
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule init
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule update
}

@test '#init_repo should return 0 no matter what "git update-index" has failed' {
    stub_and_eval git '{
        [[ "$3" == "update-index" ]] && return 1
        return 0
    }'
    run init_repo "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times update_git_repo)" -eq 1 ]]
    [[ "$(stub_called_times git)" -eq 3 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times update_git_repo 1 "${HOME%/}" ".dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "master"
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" update-index --assume-unchanged .gitconfig
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule init
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule update
}

@test '#init_repo should return 1 if "git submodule init has failed"' {
    stub_and_eval git '{
        [[ "$3" == "submodule" ]] && [[ "$4" == "init" ]] && return 1
        return 0
    }'
    run init_repo "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times update_git_repo)" -eq 1 ]]
    [[ "$(stub_called_times git)" -eq 2 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    stub_called_with_exactly_times update_git_repo 1 "${HOME%/}" ".dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "master"
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" update-index --assume-unchanged .gitconfig
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule init
    stub_called_with_exactly_times logger_err 1 "\"git submodule init\" has failed. Submodules may not be installed correctly on your environment"
}

@test '#init_repo should return 1 if "git submodule update has failed"' {
    stub_and_eval git '{
        [[ "$3" == "submodule" ]] && [[ "$4" == "update" ]] && return 1
        return 0
    }'
    run init_repo "https://github.com/TsutomuNakamura/dotfiles.git" "master"

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times update_git_repo)" -eq 1 ]]
    [[ "$(stub_called_times git)" -eq 3 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    stub_called_with_exactly_times update_git_repo 1 "${HOME%/}" ".dotfiles" "https://github.com/TsutomuNakamura/dotfiles.git" "master"
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" update-index --assume-unchanged .gitconfig
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule init
    stub_called_with_exactly_times git 1 -C "${HOME%/}/.dotfiles" submodule update
    stub_called_with_exactly_times logger_err 1 "\"git submodule update\" has failed. Submodules may not be installed correctly on your environment"
}





