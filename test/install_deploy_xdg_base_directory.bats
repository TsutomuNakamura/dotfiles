#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    cd ${HOME}
    stub link_xdg_base_directory
}

function teardown() {
    command rm -rf ./.dotfiles ./.config ./.local ./Library
}

#function count() {
#    find $1 -maxdepth 1 -mindepth 1 \( -type f -or -type d -or -type l \) | wc -l;
#}

@test '#deploy_xdg_base_directory should call link_xdg_base_directory proper parameters on Linux' {
    # Linux
    stub_and_eval get_xdg_config_home '{ echo "${HOME}/.config"; }'
    stub_and_eval get_xdg_data_home '{ echo "${HOME}/.local/share"; }'

    run deploy_xdg_base_directory

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times link_xdg_base_directory)      -eq 2 ]]

    stub_called_with_exactly_times link_xdg_base_directory 1 "XDG_CONFIG_HOME" "${HOME}/.config"
    stub_called_with_exactly_times link_xdg_base_directory 1 "XDG_DATA_HOME" "${HOME}/.local/share"
}

@test '#deploy_xdg_base_directory should call link_xdg_base_directory proper parameters on Mac' {
    # Linux
    stub_and_eval get_xdg_config_home '{ echo "${HOME}/Library/Preferences"; }'
    stub_and_eval get_xdg_data_home '{ echo "${HOME}/Library"; }'

    run deploy_xdg_base_directory

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times link_xdg_base_directory)      -eq 2 ]]

    stub_called_with_exactly_times link_xdg_base_directory 1 "XDG_CONFIG_HOME" "${HOME}/Library/Preferences"
    stub_called_with_exactly_times link_xdg_base_directory 1 "XDG_DATA_HOME" "${HOME}/Library"
}

