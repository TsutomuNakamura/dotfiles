#!/usr/bin/env bats
load helpers

function setup() {
    mkdir -p ${HOME}/${DOTDIR}
    function should_it_make_deep_link_directory() { return 1; };
    function date() { echo "19700101000000"; }
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR} ${HOME}/${BACKUPDIR} ${HOME}/.config ${HOME}/.config2 ${HOME}/.local ${HOME}/.vim ${HOME}/bin ${HOME}/foo ${HOME}/bar
}

@test '#backup_current_dotfiles should print a message if dotfiles directory was not existed' {
    rm -rf ${HOME}/${DOTDIR}
    run backup_current_dotfiles

    echo "$output"
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

    echo "$output"
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

    echo "$output"
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

    echo "$output"
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

    echo "$output"
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

    echo "$output"
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

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/.config/fontconfig ]]
    [[ ! -e "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/fonts.conf" ]]
}

@test '#backup_current_dotfiles should backup files deeply if they should be deep copied' {
    mkdir -p ${HOME}/${DOTDIR}/.config/fontconfig
    touch ${HOME}/${DOTDIR}/.config/fontconfig/fonts.conf
    mkdir -p ${HOME}/${DOTDIR}/.config/fontconfig/conf.d
    touch ${HOME}/${DOTDIR}/.config/fontconfig/conf.d/65-something.conf
    touch ${HOME}/${DOTDIR}/.config/fontconfig/conf.d/70-something.conf
    mkdir -p ${HOME}/${DOTDIR}/.config/someconfig
    touch ${HOME}/${DOTDIR}/.config/someconfig/some.conf
    touch ${HOME}/${DOTDIR}/.config/foo.conf

    rm -rf ${HOME}/.config
    mkdir -p ${HOME}/.config/fontconfig
    touch ${HOME}/.config/fontconfig/fonts.conf
    mkdir -p ${HOME}/.config/fontconfig/conf.d
    touch ${HOME}/.config/fontconfig/conf.d/65-something.conf
    ## touch ${HOME}/.config/fontconfig/conf.d/70-something.conf
    mkdir -p ${HOME}/.config/someconfig
    touch ${HOME}/.config/someconfig/some.conf
    touch ${HOME}/.config/foo.conf

    function get_target_dotfiles() { echo ".config"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/.config/fontconfig ]]
    [[ ! -e "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ -d ${HOME}/.config/fontconfig/conf.d ]]
    [[ ! -e "${HOME}/.config/fontconfig/conf.d/65-something.conf" ]]
    [[ ! -e "${HOME}/.config/fontconfig/conf.d/70-something.conf" ]]
    [[ -d ${HOME}/.config/someconfig ]]
    [[ ! -e "${HOME}/.config/someconfig/some.conf" ]]
    [[ ! -e "${HOME}/.config/foo.conf" ]]

    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/fonts.conf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/conf.d" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/conf.d/65-something.conf" ]]
    [[ ! -e "${HOME}/${BACKUPDIR}/19700101000000/.config/fontconfig/conf.d/70-something.conf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.config/someconfig" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/someconfig/some.conf" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.config/foo.conf" ]]
}

@test '#backup_current_dotfiles should backup files deeply if the file name contains some spaces' {
    mkdir -p ${HOME}/${DOTDIR}/.local/share/fonts
    touch "${HOME}/${DOTDIR}/.local/share/fonts/Inconsolata for Powerline.otf"

    mkdir -p ${HOME}/.local/share/fonts
    touch "${HOME}/.local/share/fonts/Inconsolata for Powerline.otf"


    function get_target_dotfiles() { echo ".local"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/.local/share/fonts ]]
    [[ ! -e "${HOME}/.local/share/fonts/Inconsolata for Powerline.otf" ]]
    [[ -d "${HOME}/${BACKUPDIR}/19700101000000/.local/share/fonts" ]]
    [[ -f "${HOME}/${BACKUPDIR}/19700101000000/.local/share/fonts/Inconsolata for Powerline.otf" ]]
}

@test '#backup_current_dotfiles should backup ' {
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
}


@test '#backup_current_dotfiles should backup a file under bin deeply' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    mkdir -p ${HOME}/bin
    touch ${HOME}/bin/foo
    touch ${HOME}/bin/bar

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ -f ${HOME}/bin/bar ]]

    rm -rf ${HOME}/bin
}

@test '#backup_current_dotfiles should backup some files under bin deeply' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    touch ${HOME}/${DOTDIR}/bin/bar
    mkdir -p ${HOME}/bin
    touch ${HOME}/bin/foo
    pushd ${HOME}/bin; ln -s baz bar; popd
    touch ${HOME}/bin/baz

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/bar ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ ! -e ${HOME}/bin/bar ]]
    [[ -f ${HOME}/bin/baz ]]

    rm -rf ${HOME}/bin
}

@test '#backup_current_dotfiles should backup a symlink as a file' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    mkdir -p ${HOME}/bin
    echo "foo" > ${HOME}/foo
    ln -s ../foo -t ${HOME}/bin

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000/bin)" -eq 1 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/foo)" = "foo" ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]

    rm -rf ${HOME}/bin ${HOME}/foo
}

@test '#backup_current_dotfiles should backup some symlinks as a file' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    touch ${HOME}/${DOTDIR}/bin/bar
    mkdir -p ${HOME}/bin
    echo "foo" > ${HOME}/foo
    echo "bar" > ${HOME}/bar
    ln -s ../foo -t ${HOME}/bin
    ln -s ../bar -t ${HOME}/bin

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000/bin)" -eq 2 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/bar ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/foo)" = "foo" ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/bar)" = "bar" ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ ! -e ${HOME}/bin/bar ]]

    rm -rf ${HOME}/bin ${HOME}/{foo,bar}
}

@test '#backup_current_dotfiles should backup one symlink and one file as a file' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    touch ${HOME}/${DOTDIR}/bin/bar
    mkdir -p ${HOME}/bin
    echo "foo" > ${HOME}/foo
    ln -s ../foo -t ${HOME}/bin
    echo "bar" > ${HOME}/bin/bar

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000/bin)" -eq 2 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/bar ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/foo)" = "foo" ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/bar)" = "bar" ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ ! -e ${HOME}/bin/bar ]]

    rm -rf ${HOME}/bin ${HOME}/{foo,bar}
}

@test '#backup_current_dotfiles should backup some symlinks and some files as a file' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    touch ${HOME}/${DOTDIR}/bin/bar
    touch ${HOME}/${DOTDIR}/bin/baz
    touch ${HOME}/${DOTDIR}/bin/pee
    mkdir -p ${HOME}/bin
    echo "foo" > ${HOME}/foo
    echo "bar" > ${HOME}/bar
    ln -s ../foo -t ${HOME}/bin
    ln -s ../bar -t ${HOME}/bin
    echo "baz" > ${HOME}/bin/baz
    echo "pee" > ${HOME}/bin/pee

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000/bin)" -eq 4 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/bar ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/baz ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/pee ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/foo)" = "foo" ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/bar)" = "bar" ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/baz)" = "baz" ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/pee)" = "pee" ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ ! -e ${HOME}/bin/bar ]]
    [[ ! -e ${HOME}/bin/baz ]]
    [[ ! -e ${HOME}/bin/pee ]]

    rm -rf ${HOME}/bin ${HOME}/{foo,bar}
}





@test '#backup_current_dotfiles should backup some symlinks and some files as a file' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    touch ${HOME}/${DOTDIR}/bin/bar
    mkdir -p ${HOME}/bin
    echo "foo" > ${HOME}/foo
    echo "bar" > ${HOME}/bar
    ln -s ../foo -t ${HOME}/bin
    ln -s ../bar -t ${HOME}/bin

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    find ${HOME}/${BACKUPDIR}/19700101000000/bin -ls

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000/bin)" -eq 2 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/bar ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/foo)" = "foo" ]]
    [[ "$(cat ${HOME}/${BACKUPDIR}/19700101000000/bin/bar)" = "bar" ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ ! -e ${HOME}/bin/bar ]]

    rm -rf ${HOME}/bin ${HOME}/{foo,bar}
}




@test '#backup_current_dotfiles should not remove bin directory after the file backupped' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    mkdir -p ${HOME}/bin
    touch ${HOME}/bin/foo

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ -d ${HOME}/${BACKUPDIR}/19700101000000/bin ]]
    [[ -f ${HOME}/${BACKUPDIR}/19700101000000/bin/foo ]]
    [[ -d ${HOME}/bin ]]
    [[ ! -e ${HOME}/bin/foo ]]
    [[ "$(count ${HOME}/bin)" -eq 0 ]]
}

@test '#backup_current_dotfiles should do nothing when the ${HOME}/bin directory has no target files' {
    rm -rf ${HOME}/${DOTDIR}/bin ${HOME}/bin
    mkdir -p ${HOME}/${DOTDIR}/bin
    touch ${HOME}/${DOTDIR}/bin/foo
    mkdir -p ${HOME}/bin
    touch ${HOME}/bin/bar

    function get_target_dotfiles() { echo "bin"; }
    function should_it_make_deep_link_directory() { return 0; };

    run backup_current_dotfiles

    echo "$output"
    find ${HOME}/${BACKUPDIR}/19700101000000 -ls
    [[ "$status" -eq 0 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000)" -eq 1 ]]
    [[ "$(count ${HOME}/${BACKUPDIR}/19700101000000/bin)" -eq 0 ]]
    [[ -d ${HOME}/bin ]]
    [[ "$(count ${HOME}/bin)" -eq 1 ]]
    [[ -f ${HOME}/bin/bar ]]
    [[ -f ${HOME}/${DOTDIR}/bin/foo ]]
}

