#!/usr/bin/env bats
load helpers

function setup() {
    unset XDG_CONFIG_HOME
}
function teardown() {
    unset XDG_CONFIG_HOME
    clear_call_count
}

@test '#get_xdg_config_home should echo "${HOME}/Library/Preferences" when XDG_CONFIG_HOME was not defined and type of OS was Mac' {
    function get_distribution_name() {
        echo "mac"
        increment_call_count "get_distribution_name"
    }

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(call_count get_distribution_name)" -eq 1 ]]
    [[ "$output" = "${HOME}/Library/Preferences" ]]
}

@test '#get_xdg_config_home should echo "${HOME}/foo/bar" when XDG_CONFIG_HOME was defined as "${HOME}/foo/bar" and type of OS was Mac' {
    function get_distribution_name() {
        echo "mac"
        increment_call_count "get_distribution_name"
    }
    export XDG_CONFIG_HOME="${HOME}/foo/bar"

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(call_count get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

@test '#get_xdg_config_home should echo "${HOME}/.config" when XDG_CONFIG_HOME was not defined and type of OS like Linux' {
    function get_distribution_name() {
        echo "debian"
        increment_call_count "get_distribution_name"
    }

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(call_count get_distribution_name)" -eq 1 ]]
    [[ "$output" = "${HOME}/.config" ]]
}

@test '#get_xdg_config_home should echo "${HOME}/foo/bar" when XDG_CONFIG_HOME was defined as "${HOME}/foo/bar" and type of OS like Linux' {
    function get_distribution_name() {
        echo "debian"
        increment_call_count "get_distribution_name"
    }
    export XDG_CONFIG_HOME="${HOME}/foo/bar"

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(call_count get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

@test '#get_xdg_config_home should expand special variable like "~/foo/bar" to /home/foo/foo/bar' {
    function get_distribution_name() {
        echo "debian"
        increment_call_count "get_distribution_name"
    }
    export XDG_CONFIG_HOME="~/foo/bar"

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(call_count get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

