#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    unset XDG_DATA_HOME
}

function teardown() {
    unset XDG_DATA_HOME
}

@test '#get_xdg_data_home should echo "${HOME}/Library" when XDG_DATA_HOME was not defined and type of OS was Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'

    run get_xdg_data_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 1 ]]
    [[ "$output" = "${HOME}/Library" ]]
}

@test '#get_xdg_data_home should echo "${HOME}/foo/bar" when XDG_DATA_HOME was defined as "${HOME}/foo/bar" and type of OS was Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    export XDG_DATA_HOME="${HOME}/foo/bar"

    run get_xdg_data_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

@test '#get_xdg_data_home should echo "${HOME}/.local/share" when XDG_DATA_HOME was not defined and type of OS like Linux' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'

    run get_xdg_data_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 1 ]]
    [[ "$output" = "${HOME}/.local/share" ]]
}

@test '#get_xdg_data_home should echo "${HOME}/foo/bar" when XDG_DATA_HOME was defined as "${HOME}/foo/bar" and type of OS like Linux' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    export XDG_DATA_HOME="${HOME}/foo/bar"

    run get_xdg_data_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

@test '#get_xdg_data_home should expand special variable like "~/foo/bar" to /home/foo/foo/bar' {
    stub_and_eval get_distribution_name '{ echo "debian"; }'
    export XDG_DATA_HOME="~/foo/bar"

    run get_xdg_data_home

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)" -eq 0 ]]
    [[ "$output" = "${HOME}/foo/bar" ]]
}

