#!/usr/bin/env bats
load helpers

function setup() {
    stub _install_tmux_plugin_manager
    stub _install_and_update_tmux_plugins
    stub logger_err
}

function teardown() {
    true
}

@test '#deploy_tmux_environment should return 0 if all instructions were succeeded' {
    run deploy_tmux_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_tmux_plugin_manager)"      -eq 1 ]]
    [[ "$(stub_called_times _install_and_update_tmux_plugins)"  -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 0 ]]

    stub_called_with_exactly_times _install_tmux_plugin_manager 1 "${HOME}/.tmux/plugins/tpm"
}

@test '#deploy_tmux_environment should return 1 if _install_tmux_plugin_manager was failed' {
    stub_and_eval _install_tmux_plugin_manager '{ return 1; }'

    run deploy_tmux_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_tmux_plugin_manager)"      -eq 1 ]]
    [[ "$(stub_called_times _install_and_update_tmux_plugins)"  -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 1 ]]

    stub_called_with_exactly_times _install_tmux_plugin_manager 1 "${HOME}/.tmux/plugins/tpm"
    stub_called_with_exactly_times logger_err 1 "Failed to install tmux_plugin_manager"
}

@test '#deploy_tmux_environment should return 1 if _install_and_update_tmux_plugins was failed' {
    stub_and_eval _install_tmux_plugin_manager '{ return 1; }'

    run deploy_tmux_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_tmux_plugin_manager)"      -eq 1 ]]
    [[ "$(stub_called_times _install_and_update_tmux_plugins)"  -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                        -eq 1 ]]

    stub_called_with_exactly_times _install_tmux_plugin_manager 1 "${HOME}/.tmux/plugins/tpm"
    stub_called_with_exactly_times logger_err 1 "Failed to install tmux_plugin_manager"
}

