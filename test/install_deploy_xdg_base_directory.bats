#!/usr/bin/env bats
load helpers

function setup() {
    cd ${HOME}
}

function teardown() {
    rm -rf ./.dotfiles ./.config ./.local ./Library
}

#                      On Linux               On Mac
# XDG_CONFIG_HOME   -> ${HOME}/.config        ${HOME}/Library/Preferences
# XDG_DATA_HOME     -> ${HOME}/.local/share   ${HOME}/Library
## On Mac
# 

@test '#deploy_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_CONFIG_HOME" to "~/.config" on Linux' {
    mkdir -p .dotfiles/XDG_CONFIG_HOME/foo
    touch .dotfiles/XDG_CONFIG_HOME/bar.txt
    touch .dotfiles/XDG_CONFIG_HOME/foo/baz.sh

    function get_distribution_name() { echo "arch"; }

    run deploy_xdg_base_directory

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./.config/bar.txt" ]]
    [[ -L "./.config/foo/baz.sh" ]]
    [[ "$(count ./.config)" -eq 2 ]]
    [[ "$(readlink ./.config/bar.txt)" = "../.dotfiles/XDG_CONFIG_HOME/bar.txt" ]]
    [[ "$(count ./.config/foo)" -eq 1 ]]
    [[ "$(readlink ./.config/foo/baz.sh)" = "../../.dotfiles/XDG_CONFIG_HOME/foo/baz.sh" ]]
}

@test '#deploy_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_DATA_HOME" to "~/.local/share" on Linux' {
    mkdir -p .dotfiles/XDG_DATA_HOME/foo
    touch .dotfiles/XDG_DATA_HOME/bar.txt
    touch .dotfiles/XDG_DATA_HOME/foo/baz.sh

    function get_distribution_name() { echo "arch"; }

    run deploy_xdg_base_directory

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./.local/share/bar.txt" ]]
    [[ -L "./.local/share/foo/baz.sh" ]]
    [[ "$(count ./.local/share)" -eq 2 ]]
    [[ "$(readlink ./.local/share/bar.txt)" = "../../.dotfiles/XDG_DATA_HOME/bar.txt" ]]
    [[ "$(count ./.local/share/foo)" -eq 1 ]]
    [[ "$(readlink ./.local/share/foo/baz.sh)" = "../../../.dotfiles/XDG_DATA_HOME/foo/baz.sh" ]]
}

@test '#deploy_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_CONFIG_HOME" to "~/Library/Preferences" on Mac' {
    mkdir -p .dotfiles/XDG_CONFIG_HOME/foo
    touch .dotfiles/XDG_CONFIG_HOME/bar.txt
    touch .dotfiles/XDG_CONFIG_HOME/foo/baz.sh

    function get_distribution_name() { echo "mac"; }

    run deploy_xdg_base_directory

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./Library/Preferences/bar.txt" ]]
    [[ -L "./Library/Preferences/foo/baz.sh" ]]
    [[ "$(count ./Library/Preferences)" -eq 2 ]]
    [[ "$(readlink ./Library/Preferences/bar.txt)" = "../../.dotfiles/XDG_CONFIG_HOME/bar.txt" ]]
    [[ "$(count ./Library/Preferences/foo)" -eq 1 ]]
    [[ "$(readlink ./Library/Preferences/foo/baz.sh)" = "../../../.dotfiles/XDG_CONFIG_HOME/foo/baz.sh" ]]
}

@test '#deploy_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_DATA_HOME" to "~/Library" on Mac' {
    mkdir -p .dotfiles/XDG_DATA_HOME/foo
    touch .dotfiles/XDG_DATA_HOME/bar.txt
    touch .dotfiles/XDG_DATA_HOME/foo/baz.sh

    function get_distribution_name() { echo "mac"; }

    run deploy_xdg_base_directory

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./Library/bar.txt" ]]
    [[ -L "./Library/foo/baz.sh" ]]
    [[ "$(count ./Library)" -eq 2 ]]
    ls -l ./Library
    [[ "$(readlink ./Library/bar.txt)" = "../.dotfiles/XDG_DATA_HOME/bar.txt" ]]
    [[ "$(count ./Library/foo)" -eq 1 ]]
    [[ "$(readlink ./Library/foo/baz.sh)" = "../../.dotfiles/XDG_DATA_HOME/foo/baz.sh" ]]
}

