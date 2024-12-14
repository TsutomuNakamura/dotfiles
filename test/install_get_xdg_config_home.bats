#!/usr/bin/env bats
load helpers

function setup() {
    unset XDG_CONFIG_HOME

}
function teardown() {
    unset XDG_CONFIG_HOME
}

@test '#get_xdg_config_home should echo "${HOME}/Library/Preferences" when XDG_CONFIG_HOME was not defined and type of OS was Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 1 ]]
    [[ "$output" == "${HOME}/Library/Preferences" ]]
}

@test '#get_xdg_config_home should echo "${HOME}/foo/bar" when XDG_CONFIG_HOME was defined as "${HOME}/foo/bar" and type of OS was Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    export XDG_CONFIG_HOME="${HOME}/foo/bar"

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 0 ]]
    [[ "$output" == "${HOME}/foo/bar" ]]
}

@test '#get_xdg_config_home should echo "${HOME}/.config" when XDG_CONFIG_HOME was not defined and type of OS like Linux' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 1 ]]
    [[ "$output" = "${HOME}/.config" ]]
}

@test '#get_xdg_config_home should echo "${HOME}/foo/bar" when XDG_CONFIG_HOME was defined as "${HOME}/foo/bar" and type of OS like Linux' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    export XDG_CONFIG_HOME="${HOME}/foo/bar"

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

@test '#get_xdg_config_home should expand special variable like "~/foo/bar" to /home/foo/foo/bar' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    export XDG_CONFIG_HOME="~/foo/bar"

    run get_xdg_config_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

