#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub is_customized_xdg_base_directories
    stub vercomp
    stub_and_eval get_distribution_name '{ command echo "ubuntu"; }'
    stub check_environment_of_mac
    stub logger_err

    export BASH="/usr/bin/bash"
    export BASH_VERSION="4.0.0"
}

function teardown() {
    true
}

@test '#check_environment should return 0 if all instructions are passed' {
    run check_environment

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${#outputs[@]}"                                             -eq 0 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 1 ]]
}

@test '#check_environment should return 0 if all instructions are passed on Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'

    run check_environment

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${#outputs[@]}"                                             -eq 0 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 1 ]]
}

@test '#check_environment should return 1 if is_customized_xdg_base_directories() was failed' {
    stub_and_eval is_customized_xdg_base_directories '{ return 1; }'

    run check_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 6 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 0 ]]

    stub_called_with_exactly_times logger_err 1 "Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments."
    stub_called_with_exactly_times logger_err 1 "  XDG_CONFIG_HOME=(unset)"
    stub_called_with_exactly_times logger_err 1 "    -> This must be set \"${HOME}/.config\" in Linux or \"${HOME}/Library/Preferences\" in Mac or unset."
    stub_called_with_exactly_times logger_err 1 "  XDG_DATA_HOME=(unset)"
    stub_called_with_exactly_times logger_err 1 "    -> This must be set \"${HOME}/.local/share\" in Linux or \"${HOME}/Library\" in Mac or unset."
}

@test '#check_environment should return 1 and output a message for when XDG_CONFIG_HOME was set if is_customized_xdg_base_directories() was failed' {
    stub_and_eval is_customized_xdg_base_directories '{ return 1; }'
    export XDG_CONFIG_HOME="$HOME/.config"

    run check_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 6 ]]

    stub_called_with_exactly_times logger_err 1 "Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments."
    stub_called_with_exactly_times logger_err 1 "Current environment variables XDG_CONFIG_HOME and XDG_DATA_HOME is set like below."
    stub_called_with_exactly_times logger_err 1 "  XDG_CONFIG_HOME=\"${XDG_CONFIG_HOME}\""
    stub_called_with_exactly_times logger_err 1 "    -> This must be set \"${HOME}/.config\" in Linux or \"${HOME}/Library/Preferences\" in Mac or unset."
    stub_called_with_exactly_times logger_err 1 "  XDG_DATA_HOME=(unset)"
    stub_called_with_exactly_times logger_err 1 "    -> This must be set \"${HOME}/.local/share\" in Linux or \"${HOME}/Library\" in Mac or unset."
}

@test '#check_environment should return 1 and output a message for when XDG_DATA_HOME was set if is_customized_xdg_base_directories() was failed' {
    stub_and_eval is_customized_xdg_base_directories '{ return 1; }'
    export XDG_DATA_HOME="$HOME/.local/share"

    run check_environment

    declare -a outputs; IFS=$'\n' outputs=($output); local i=0
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 6 ]]

    stub_called_with_exactly_times logger_err 1 "Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments."
    stub_called_with_exactly_times logger_err 1 "Current environment variables XDG_CONFIG_HOME and XDG_DATA_HOME is set like below."
    stub_called_with_exactly_times logger_err 1 "  XDG_CONFIG_HOME=(unset)"
    stub_called_with_exactly_times logger_err 1 "    -> This must be set \"${HOME}/.config\" in Linux or \"${HOME}/Library/Preferences\" in Mac or unset."
    stub_called_with_exactly_times logger_err 1 "  XDG_DATA_HOME=\"${XDG_DATA_HOME}\""
    stub_called_with_exactly_times logger_err 1 "    -> This must be set \"${HOME}/.local/share\" in Linux or \"${HOME}/Library\" in Mac or unset."
}

@test '#check_environment should return 1 and output a message if BASH was not set' {
    export XDG_DATA_HOME="$HOME/.local/share"
    unset BASH

    run check_environment

    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "This script must run as bash script"
}

@test '#check_environment should return 1 and output a message if BASH_VERSION was not set' {
    export XDG_DATA_HOME="$HOME/.local/share"
    unset BASH_VERSION

    run check_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "This session does not have BASH_VERSION environment variable. Is this a proper bash session?"
}

@test '#check_environment should return 1 and if vercomp() return 1' {
    export XDG_DATA_HOME="$HOME/.local/share"
    stub_and_eval vercomp '{ return 1; }'

    run check_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 6 ]]

    stub_called_with_exactly_times logger_err 1 "Version of bash have to greater than 4.0.0."
    stub_called_with_exactly_times logger_err 1 "Please update your bash greater than 4.0.0 then run this script again."
    stub_called_with_exactly_times logger_err 1 "If you use mac, you can change new version of bash by running commands like below..."
    stub_called_with_exactly_times logger_err 1 "  $ brew install bash"
    stub_called_with_exactly_times logger_err 1 "  $ grep -q '/usr/local/bin/bash' /etc/shells || echo /usr/local/bin/bash | sudo tee -a /etc/shells"
    stub_called_with_exactly_times logger_err 1 "...then relogin or restart your Mac"
}

@test '#check_environment should return 1 if check_environment_of_mac Mac' {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    stub_and_eval check_environment_of_mac '{ return 1; }'

    run check_environment

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times vercomp)"                               -eq 1 ]]
    [[ "$(stub_called_times check_environment_of_mac)"              -eq 1 ]]

    [[ "$(stub_called_times logger_err)"                            -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Failed to pass checking the environment of Mac"
}

