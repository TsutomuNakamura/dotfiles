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
    function date() { echo "19700101000000"; }
    mkdir -p "${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")"
}

function teardown() {
    rm -rf ~/.config ~/.local ~/Library "${HOME}/${BACKUPDIR}"
}

@test '#backup_xdg_xdg_base_directory_individually should backup files in ~/.config(XDG_CONFIG_HOME) directory on Linux' {
    local abs_backup_dir="${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")/.config"
    local xdg_dir="${HOME}/.config"
    function get_distribution_name() { echo "arch"; }

    mkdir -p ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/foo
    mkdir -p $xdg_dir/foo
    touch ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/hoge.txt
    touch ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/foo/fuga.txt
    touch $xdg_dir/hoge.txt
    touch $xdg_dir/foo/fuga.txt

    run backup_xdg_base_directory_individually "XDG_CONFIG_HOME" "$xdg_dir" "$abs_backup_dir"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -f "$abs_backup_dir/hoge.txt" ]]
    [[ -f "$abs_backup_dir/foo/fuga.txt" ]]
    [[ ! -e "$xdg_dir/hoge.txt" ]]
    [[ ! -e "$xdg_dir/foo/fuga.txt" ]]
}

@test '#backup_xdg_xdg_base_directory_individually should backup files in ~/Library/Preferences(XDG_CONFIG_HOME) directory on Mac' {
    local abs_backup_dir="${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")/Library/Preferences"
    local xdg_dir="${HOME}/Library/Preferences"
    function get_distribution_name() { echo "mac"; }

    mkdir -p ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/foo
    mkdir -p $xdg_dir/foo
    touch ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/hoge.txt
    touch ${HOME}/${DOTDIR}/XDG_CONFIG_HOME/foo/fuga.txt
    touch $xdg_dir/hoge.txt
    touch $xdg_dir/foo/fuga.txt

    run backup_xdg_base_directory_individually "XDG_CONFIG_HOME" "$xdg_dir" "$abs_backup_dir"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -f "$abs_backup_dir/hoge.txt" ]]
    [[ -f "$abs_backup_dir/foo/fuga.txt" ]]
    [[ ! -e "$xdg_dir/hoge.txt" ]]
    [[ ! -e "$xdg_dir/foo/fuga.txt" ]]
}

@test '#backup_xdg_xdg_base_directory_individually should backup files in ~/.local/share(XDG_DATA_HOME) directory on Linux' {
    local abs_backup_dir="${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")/.local/share"
    local xdg_dir="${HOME}/.local/share"
    function get_distribution_name() { echo "arch"; }

    mkdir -p ${HOME}/${DOTDIR}/XDG_DATA_HOME/foo
    mkdir -p $xdg_dir/foo
    touch ${HOME}/${DOTDIR}/XDG_DATA_HOME/hoge.txt
    touch ${HOME}/${DOTDIR}/XDG_DATA_HOME/foo/fuga.txt
    touch $xdg_dir/hoge.txt
    touch $xdg_dir/foo/fuga.txt

    run backup_xdg_base_directory_individually "XDG_DATA_HOME" "$xdg_dir" "$abs_backup_dir"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -f "$abs_backup_dir/hoge.txt" ]]
    [[ -f "$abs_backup_dir/foo/fuga.txt" ]]
    [[ ! -e "$xdg_dir/hoge.txt" ]]
    [[ ! -e "$xdg_dir/foo/fuga.txt" ]]
}

@test '#backup_xdg_xdg_base_directory_individually should backup files in ~/Library(XDG_DATA_HOME) directory on Mac' {
    local abs_backup_dir="${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")/Library"
    local xdg_dir="${HOME}/Library"
    function get_distribution_name() { echo "mac"; }

    mkdir -p ${HOME}/${DOTDIR}/XDG_DATA_HOME/foo
    mkdir -p $xdg_dir/foo
    touch ${HOME}/${DOTDIR}/XDG_DATA_HOME/hoge.txt
    touch ${HOME}/${DOTDIR}/XDG_DATA_HOME/foo/fuga.txt
    touch $xdg_dir/hoge.txt
    touch $xdg_dir/foo/fuga.txt

    run backup_xdg_base_directory "XDG_DATA_HOME" "$xdg_dir" "$abs_backup_dir"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -f "$abs_backup_dir/hoge.txt" ]]
    [[ -f "$abs_backup_dir/foo/fuga.txt" ]]
    [[ ! -e "$xdg_dir/hoge.txt" ]]
    [[ ! -e "$xdg_dir/foo/fuga.txt" ]]
}




#@test '#backup_xdg_xdg_base_directory_individually should backup files in ~/.local/share(XDG_DATA_HOME) directory on Linux' {
#    mkdir -p ${HOME}/${DOTDIR}/XDG_DATA_HOME/foo
#    mkdir -p ${HOME}/.local/share/foo
#    touch ${HOME}/${DOTDIR}/XDG_DATA_HOME/hoge.txt
#    touch ${HOME}/${DOTDIR}/XDG_DATA_HOME/foo/fuga.txt
#    touch ${HOME}/.local/share/hoge.txt
#    touch ${HOME}/.local/share/foo/fuga.txt
#
#    function get_xdg_data_home() { echo "${HOME}/.local/share"; }
#
#    run backup_xdg_base_directory "${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")"
#
#    echo "$output"
#    [[ "$status" -eq 0 ]]
#    [[ -f "${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")/hoge.txt" ]]
#    [[ -f "${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")/foo/fuga.txt" ]]
#    [[ ! -e "${HOME}/.config/hoge.txt" ]]
#    [[ ! -e "${HOME}/.config/foo/fuga.txt" ]]
#}



