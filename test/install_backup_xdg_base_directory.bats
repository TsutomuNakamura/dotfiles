#!/usr/bin/env bats
load helpers

# XDG_CONFIG_HOME
#     "~/.config" (Linux)
#     "~/Library/Preferences" (Mac)
# XDG_DATA_HOME
#     "~/.local/share" (Linux)
#     "~/Library" (Mac)

function setup() {
    rm -rf ~/.config ~/.local ~/Library
}

function teardown() {
    rm -rf ~/.config ~/.local ~/Library
}

@test '#backup_xdg_base_directory should backup files in ~/.config(XDG_CONFIG_HOME) directory on Linux' {
    mkdir -p ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/foo
    mkdir -p ${HOME}/.config/foo
    touch ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/hoge.txt
    touch ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/foo/fuga.txt
    touch ${HOME}/.config/hoge.txt
    touch ${HOME}/.config/foo/fuga.txt

    run backup_xdg_base_directory

    echo "$output"
    [[ "$status" -eq 0 ]]
    false
}

