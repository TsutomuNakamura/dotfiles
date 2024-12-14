#!/usr/bin/env bats
load helpers

function setup() {
    cd ${HOME}
    function get_distribution_name() { echo "arch"; }
    stub_and_eval files_that_should_be_copied_on_only_mac '{
        local target="$1"
        [[ "$(get_distribution_name)" == "mac" ]] && [[ "$target" == "Inconsolata for Powerline.otf" ]]
    }'
    stub_and_eval files_that_should_not_be_linked '{
        local target="$1"
        [[ "$target" = "LICENSE.txt" ]]
    }'
}

function teardown() {
    command rm -rf ./.dotfiles ./.config ./.local ./Library
}

function count() {
    find $1 -maxdepth 1 -mindepth 1 \( -type f -or -type d -or -type l \) | wc -l;
}

@test 'link_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_CONFIG_HOME" to "~/.config" on Linux' {
    mkdir -p .dotfiles/XDG_CONFIG_HOME/foo
    touch .dotfiles/XDG_CONFIG_HOME/bar.txt
    touch .dotfiles/XDG_CONFIG_HOME/foo/baz.sh

    run link_xdg_base_directory 'XDG_CONFIG_HOME' "${HOME}/.config"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./.config/bar.txt" ]]
    [[ -L "./.config/foo/baz.sh" ]]
    [[ "$(count ./.config)"                                             -eq 2 ]]
    [[ "$(readlink ./.config/bar.txt)"                                  = "../.dotfiles/XDG_CONFIG_HOME/bar.txt" ]]
    [[ "$(count ./.config/foo)"                                         -eq 1 ]]
    [[ "$(readlink ./.config/foo/baz.sh)"                               = "../../.dotfiles/XDG_CONFIG_HOME/foo/baz.sh" ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 2 ]]
}

@test 'link_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_DATA_HOME" to "~/.local/share" on Linux' {
    mkdir -p .dotfiles/XDG_DATA_HOME/foo
    touch .dotfiles/XDG_DATA_HOME/bar.txt
    touch .dotfiles/XDG_DATA_HOME/foo/baz.sh

    run link_xdg_base_directory 'XDG_DATA_HOME' "${HOME}/.local/share"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./.local/share/bar.txt" ]]
    [[ -L "./.local/share/foo/baz.sh" ]]
    [[ "$(count ./.local/share)"                                        -eq 2 ]]
    [[ "$(readlink ./.local/share/bar.txt)"                             = "../../.dotfiles/XDG_DATA_HOME/bar.txt" ]]
    [[ "$(count ./.local/share/foo)"                                    -eq 1 ]]
    [[ "$(readlink ./.local/share/foo/baz.sh)"                          = "../../../.dotfiles/XDG_DATA_HOME/foo/baz.sh" ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 2 ]]
}

@test 'link_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_CONFIG_HOME" to "~/Library/Preferences" on Mac' {
    mkdir -p .dotfiles/XDG_CONFIG_HOME/foo
    touch .dotfiles/XDG_CONFIG_HOME/bar.txt
    touch .dotfiles/XDG_CONFIG_HOME/foo/baz.sh

    function get_distribution_name() { echo "mac"; }

    run link_xdg_base_directory 'XDG_CONFIG_HOME' "${HOME}/Library/Preferences"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./Library/Preferences/bar.txt" ]]
    [[ -L "./Library/Preferences/foo/baz.sh" ]]
    [[ "$(count ./Library/Preferences)"                                 -eq 2 ]]
    [[ "$(readlink ./Library/Preferences/bar.txt)"                      = "../../.dotfiles/XDG_CONFIG_HOME/bar.txt" ]]
    [[ "$(count ./Library/Preferences/foo)"                             -eq 1 ]]
    [[ "$(readlink ./Library/Preferences/foo/baz.sh)"                   = "../../../.dotfiles/XDG_CONFIG_HOME/foo/baz.sh" ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 2 ]]
}

@test 'link_xdg_base_directory should deploy resources in "~/.dotfiles/XDG_DATA_HOME" to "~/Library" on Mac' {
    mkdir -p .dotfiles/XDG_DATA_HOME/foo
    touch .dotfiles/XDG_DATA_HOME/bar.txt
    touch .dotfiles/XDG_DATA_HOME/foo/baz.sh

    function get_distribution_name() { echo "mac"; }

    run link_xdg_base_directory 'XDG_DATA_HOME' "${HOME}/Library"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "./Library/bar.txt" ]]
    [[ -L "./Library/foo/baz.sh" ]]
    [[ "$(count ./Library)"                                             -eq 2 ]]
    [[ "$(readlink ./Library/bar.txt)"                                  = "../.dotfiles/XDG_DATA_HOME/bar.txt" ]]
    [[ "$(count ./Library/foo)"                                         -eq 1 ]]
    [[ "$(readlink ./Library/foo/baz.sh)"                               = "../../.dotfiles/XDG_DATA_HOME/foo/baz.sh" ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 2 ]]
}

@test 'link_xdg_base_directory should deploy fonts "Inconsolata for Powerline.otf" in "~/Library/Fonts" on Mac' {
    mkdir -p .dotfiles/XDG_DATA_HOME/fonts
    touch ".dotfiles/XDG_DATA_HOME/fonts/Inconsolata for Powerline.otf"

    function get_distribution_name() { echo "mac"; }

    run link_xdg_base_directory 'XDG_DATA_HOME' "${HOME}/Library"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ./Library/Fonts)"                                       -eq 1 ]]
    [[ ! -L "./Library/Fonts/Inconsolata for Powerline.otf" ]] && [[ -f "./Library/Fonts/Inconsolata for Powerline.otf" ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 1 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 1 ]]
}

@test 'link_xdg_base_directory should NOT deploy files that is included in "files_that_should_not_be_linked"' {
    mkdir -p .dotfiles/XDG_DATA_HOME/fonts
    mkdir -p ./.local/share
    touch ".dotfiles/XDG_DATA_HOME/fonts/LICENSE.txt"

    run link_xdg_base_directory 'XDG_DATA_HOME' "${HOME}/.local/share"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ ! -d "./.local/share/fonts" ]]
    [[ "$(count ./.local/share)"                                        -eq 0 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 1 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 0 ]]
}

