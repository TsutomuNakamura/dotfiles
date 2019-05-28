#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    # determin_update_type_of_repository returns 0 mean GIT_UPDATE_TYPE_JUST_CLONE
    #stub determin_update_type_of_repository
    #stub git
    stub logger_err
    stub rm
}

function teardown() {
    rm -rf ~/.tmux
}

#@test '#_install_tmux_plugin_manager should return 0 if all instructions are succeeded' {
#    stub determin_update_type_of_repository
#    stub git
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 0 ]]
#
#
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 0 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#}
#
#@test '#_install_tmux_plugin_manager should return 1 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_JUST_CLONE then git clone was failed' {
#    stub determin_update_type_of_repository
#    stub_and_eval git '{ return 1; }'
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 1 ]]
#
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 1 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 0 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times logger_err 1 "Just clone https://github.com/tmux-plugins/tpm was failed."
#}

#@test '#_install_tmux_plugin_manager should return 0 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY then git clone was succeeded' {
#    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY; }'
#    stub git
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 0 ]]
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 1 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times rm 1 -rf "${HOME}/.tmux/plugins/tpm"
#}

#@test '#_install_tmux_plugin_manager should return 0 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE then git clone was succeeded' {
#    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE; }'
#    stub git
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 0 ]]
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 1 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times rm 1 -rf "${HOME}/.tmux/plugins/tpm"
#}

#@test '#_install_tmux_plugin_manager should return 0 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET then git clone was succeeded' {
#    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET; }'
#    stub git
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 0 ]]
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 1 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times rm 1 -rf "${HOME}/.tmux/plugins/tpm"
#}

#@test '#_install_tmux_plugin_manager should return 0 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT then git clone was succeeded' {
#    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT; }'
#    stub git
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 0 ]]
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 1 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times rm 1 -rf "${HOME}/.tmux/plugins/tpm"
#}

#@test '#_install_tmux_plugin_manager should return 0 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY then git clone was failed' {
#    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY; }'
#    stub_and_eval git '{ return 1; }'
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 1 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 1 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 clone "${URL_OF_TMUX_PLUGIN}" "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times rm 1 -rf "${HOME}/.tmux/plugins/tpm"
#    stub_called_with_exactly_times logger_err 1 "Remove then clone ${URL_OF_TMUX_PLUGIN} was failed"
#}

#@test '#_install_tmux_plugin_manager should return 0 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL then git was succeeded' {
#    stub pushd; stub popd
#    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL; }'
#    stub git
#    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"
#
#    [[ "$status"                                                        -eq 0 ]]
#    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
#    [[ "$(stub_called_times git)"                                       -eq 2 ]]
#    [[ "$(stub_called_times logger_err)"                                -eq 0 ]]
#    [[ "$(stub_called_times rm)"                                        -eq 0 ]]
#    [[ "$(stub_called_times pushd)"                                     -eq 1 ]]
#    [[ "$(stub_called_times popd)"                                      -eq 1 ]]
#
#    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
#    stub_called_with_exactly_times git 1 reset --hard
#    stub_called_with_exactly_times git 1 pull "$URL_OF_TMUX_PLUGIN"
#    stub_called_with_exactly_times pushd 1 "${HOME}/.tmux/plugins/tpm"
#}

@test '#_install_tmux_plugin_manager should return 1 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL then git reset was failed' {
    stub pushd; stub popd
    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL; }'
    stub_and_eval git '{
        [[ "$1" == "reset" ]] && return 1
        return 0
    }'
    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"

    [[ "$status"                                                        -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
    [[ "$(stub_called_times git)"                                       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                                -eq 1 ]]
    [[ "$(stub_called_times rm)"                                        -eq 0 ]]
    [[ "$(stub_called_times pushd)"                                     -eq 1 ]]
    [[ "$(stub_called_times popd)"                                      -eq 1 ]]

    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
    stub_called_with_exactly_times git 1 reset --hard
    stub_called_with_exactly_times pushd 1 "${HOME}/.tmux/plugins/tpm"
    stub_called_with_exactly_times logger_err 1 "Failed to git reset --hard ${URL_OF_TMUX_PLUGIN}"
}

@test '#_install_tmux_plugin_manager should return 1 if determin_update_type_of_repository returns GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL then git pull was failed' {
    stub pushd; stub popd
    stub_and_eval determin_update_type_of_repository '{ return $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL; }'
    stub_and_eval git '{
        [[ "$1" == "pull" ]] && return 1
        return 0
    }'
    run _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm"

    [[ "$status"                                                        -eq 1 ]]
    [[ "$(stub_called_times determin_update_type_of_repository)"        -eq 1 ]]
    [[ "$(stub_called_times git)"                                       -eq 2 ]]
    [[ "$(stub_called_times logger_err)"                                -eq 1 ]]
    [[ "$(stub_called_times rm)"                                        -eq 0 ]]
    [[ "$(stub_called_times pushd)"                                     -eq 1 ]]
    [[ "$(stub_called_times popd)"                                      -eq 1 ]]

    stub_called_with_exactly_times determin_update_type_of_repository 1 "${HOME}/.tmux/plugins/tpm" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
    stub_called_with_exactly_times git 1 reset --hard
    stub_called_with_exactly_times git 1 pull "${URL_OF_TMUX_PLUGIN}"
    stub_called_with_exactly_times pushd 1 "${HOME}/.tmux/plugins/tpm"
    stub_called_with_exactly_times logger_err 1 "Failed to pull repository ${URL_OF_TMUX_PLUGIN}"
}
