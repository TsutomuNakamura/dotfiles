#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub _install_tmux_plugin_manager
}

function teardown() {
    true
}

@test '#deploy_tmux_environment should return 0 if all instructions were succeeded' {
    run deploy_tmux_environment

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_tmux_plugin_manager)"      -eq 1 ]]

    stub_called_with_exactly_times _install_tmux_plugin_manager 1 "${HOME}/.tmux/plugins/tpm"
}

@test '#deploy_tmux_environment should return 1 if _install_tmux_plugin_manager was failed' {
    stub_and_eval _install_tmux_plugin_manager '{ return 1; }'

    run deploy_tmux_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_tmux_plugin_manager)"      -eq 1 ]]

    stub_called_with_exactly_times _install_tmux_plugin_manager 1 "${HOME}/.tmux/plugins/tpm"
}

