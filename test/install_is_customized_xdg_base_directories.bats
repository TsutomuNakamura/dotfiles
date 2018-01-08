#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    unset XDG_CONFIG_HOME
    unset XDG_DATA_HOME
    unset -f get_distribution_name
}

# function teardown() {}

@test '#install_fonts should return 0 if XDG_CONFIG_HOME and XDG_DATA_HOME are not defined' {
    function get_distribution_name() { echo "arch"; }
    run is_customized_xdg_base_directories
    [[ "$status" -eq 0 ]]

    function get_distribution_name() { echo "mac"; }
    run is_customized_xdg_base_directories
    [[ "$status" -eq 0 ]]
}

@test '#install_fonts should return 0 if XDG_CONFIG_HOME is defined and same with default' {
    function get_distribution_name() { echo "arch"; }
    export XDG_CONFIG_HOME="${HOME}/.config"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 0 ]]

    function get_distribution_name() { echo "mac"; }
    export XDG_CONFIG_HOME="${HOME}/Library/Preferences/"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 0 ]]
}

@test '#install_fonts should return 0 if XDG_DATA_HOME is defined and same with default' {
    function get_distribution_name() { echo "arch"; }
    export XDG_DATA_HOME="${HOME}/.local/share"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 0 ]]

    function get_distribution_name() { echo "mac"; }
    export XDG_DATA_HOME="${HOME}/Library/"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 0 ]]
}

@test '#install_fonts should return not 1 if XDG_CONFIG_HOME is defined and differ from default' {
    function get_distribution_name() { echo "arch"; }
    export XDG_CONFIG_HOME="${HOME}/.foo"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 1 ]]

    function get_distribution_name() { echo "mac"; }
    export XDG_CONFIG_HOME="${HOME}/Library/foo/"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 1 ]]
}

@test '#install_fonts should return not 1 if XDG_DATA_HOME is defined and differ from default' {
    function get_distribution_name() { echo "arch"; }
    export XDG_CONFIG_HOME="${HOME}/.local/foo"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 1 ]]

    function get_distribution_name() { echo "mac"; }
    export XDG_CONFIG_HOME="${HOME}/foo/"
    run is_customized_xdg_base_directories
    [[ "$status" -eq 1 ]]
}

