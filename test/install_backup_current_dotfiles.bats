#!/usr/bin/env bats
load helpers

function setup() {
    mkdir ${HOME}/${DOTDIR}
    function should_it_make_deep_link_directory() { return 1; };

    function date() { echo "19700101000000"; }
    function count() { find $1 -maxdepth 1 -mindepth 1 \( -type f -or -type d \) | wc -l; }
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR}
    rm -rf ${HOME}/${BACKUPDIR}
}

@test '#backup_current_dotfiles should print a message if dotfiles directory was not existed' {
    rm -rf ${HOME}/${DOTDIR}
    run backup_current_dotfiles
    [[ "$status" -eq 0 ]]
    [[ "$output" = "There are no dotfiles to backup." ]]
}

@test '#backup_current_dotfiles should backup if one dotfile was existed' {
    touch ${HOME}/.vimrc

    function get_target_dotfiles() { echo ".vimrc"; }

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ ! -e ${HOME}/.vimrc ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.vimrc" ]]
}

@test '#backup_current_dotfiles should NOT backup if one dotfile was NOT existed' {
    touch ${HOME}/.dummy

    function get_target_dotfiles() { echo ".vimrc"; }

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 0 ]]
    [[ -e ${HOME}/.dummy ]]
    [[ ! -f "${HOME}/${BACKUPDIR}/19700101000000/.vimrc" ]]

    rm -f ${HOME}/.dummy
}

@test '#backup_current_dotfiles should backup if some dotfiles were existed' {
    touch ${HOME}/.vimrc
    touch ${HOME}/.tmux.conf

    function get_target_dotfiles() { echo ".vimrc .tmux.conf"; }

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 2 ]]
    [[ ! -e ${HOME}/.vimrc ]]
    [[ ! -e ${HOME}/.tmux.conf ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.vimrc" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.tmux.conf" ]]

    rm -f ${HOME}/.vimrc ${HOME}/.tmux.conf
}

@test '#backup_current_dotfiles should backup if one directory was existed' {
    rm -rf ${HOME}/.vim
    mkdir -p ${HOME}/.vim/foo
    touch ${HOME}/.vim/foo/bar.vim

    function get_target_dotfiles() { echo ".vim"; }

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ ! -e ${HOME}/.vim/foo ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.vim/foo" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.vim/foo/bar.vim" ]]

    rm -rf ${HOME}/.vim
}

@test '#backup_current_dotfiles should NOT backup if one directory was NOT existed' {
    rm -rf ${HOME}/.dummy
    mkdir ${HOME}/.dummy

    function get_target_dotfiles() { echo ".vim"; }

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 0 ]]
    [[ -e ${HOME}/.dummy ]]
    [[ ! -d "${HOME}/${BACKUPDIR}/19700101000000/.vim" ]]
    [[ ! -f "${HOME}/${BACKUPDIR}/19700101000000/.vim/foo/bar.vim" ]]

    rm -rf ${HOME}/.dummy
}

@test '#backup_current_dotfiles should backup if some directories was existed' {
    rm -rf ${HOME}/.vim
    mkdir -p ${HOME}/.vim/foo
    touch ${HOME}/.vim/foo/bar.vim

    rm -rf ${HOME}/.dir1
    mkdir -p ${HOME}/.dir1
    touch ${HOME}/.dir1/file1.txt

    function get_target_dotfiles() { echo ".vim .dir1"; }

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 2 ]]
    [[ ! -e "${HOME}/.vim" ]]
    [[ ! -e "${HOME}/.vim" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.vim/foo" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.vim/foo/bar.vim" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.dir1" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.dir1/file1.txt" ]]

    rm -rf ${HOME}/.vim ${HOME}/.dir1
}

@test '#backup_current_dotfiles should backup a file deeply if it should be deep copied' {
    mkdir -p ${HOME}/${DOTDIR}/.config/fontconfig
    touch ${HOME}/${DOTDIR}/.config/fontconfig/fonts.conf

    rm -rf ${HOME}/.config
    mkdir -p ${HOME}/.config/fontconfig
    touch ${HOME}/.config/fontconfig/fonts.conf

    function get_target_dotfiles() { echo ".config"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/.config/fontconfig ]]
    [[ ! -e "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/fonts.conf" ]]

    rm -rf ${HOME}/.config
}

@test '#backup_current_dotfiles should backup files deeply if they should be deep copied' {
    mkdir -p ${HOME}/${DOTDIR}/.config/fontconfig
    touch ${HOME}/${DOTDIR}/.config/fontconfig/fonts.conf
    mkdir -p ${HOME}/${DOTDIR}/.config/someconfig
    touch ${HOME}/${DOTDIR}/.config/someconfig/some.conf
    touch ${HOME}/${DOTDIR}/.config/foo.conf

    rm -rf ${HOME}/.config
    mkdir -p ${HOME}/.config/fontconfig
    touch ${HOME}/.config/fontconfig/fonts.conf
    mkdir -p ${HOME}/.config/someconfig
    touch ${HOME}/.config/someconfig/some.conf
    touch ${HOME}/.config/foo.conf

    function get_target_dotfiles() { echo ".config"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/.config/fontconfig ]]
    [[ ! -e "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ -d ${HOME}/.config/someconfig ]]
    [[ ! -e "${HOME}/.config/someconfig/some.conf" ]]
    [[ ! -e "${HOME}/.config/foo.conf" ]]

    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/fonts.conf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/someconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/someconfig/some.conf" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/foo.conf" ]]

    rm -rf ${HOME}/.config
}

@test '#backup_current_dotfiles should backup files deeply if some of source directory were existed' {
    mkdir -p ${HOME}/${DOTDIR}/.config/fontconfig
    touch ${HOME}/${DOTDIR}/.config/fontconfig/fonts.conf
    touch ${HOME}/${DOTDIR}/.config/foo.conf

    rm -rf ${HOME}/.config
    mkdir -p ${HOME}/.config/fontconfig
    touch ${HOME}/.config/fontconfig/fonts.conf
    touch ${HOME}/.config/foo.conf

    mkdir -p ${HOME}/${DOTDIR}/.config2/fontconfig
    touch ${HOME}/${DOTDIR}/.config2/fontconfig/fonts.conf
    touch ${HOME}/${DOTDIR}/.config2/foo.conf

    rm -rf ${HOME}/.config2
    mkdir -p ${HOME}/.config2/fontconfig
    touch ${HOME}/.config2/fontconfig/fonts.conf
    touch ${HOME}/.config2/foo.conf

    function get_target_dotfiles() { echo ".config .config2"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 2 ]]
    [[ -d ${HOME}/.config/fontconfig ]]
    [[ ! -e "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ ! -e "${HOME}/.config/foo.conf" ]]
    [[ -d ${HOME}/.config2/fontconfig ]]
    [[ ! -e "${HOME}/.config2/fontconfig/fonts.conf" ]]
    [[ ! -e "${HOME}/.config2/foo.conf" ]]

    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/fonts.conf" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/foo.conf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config2/fontconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config2/fontconfig/fonts.conf" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config2/foo.conf" ]]

    rm -rf ${HOME}/.config ${HOME}/.config2
}

