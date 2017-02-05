#!/usr/bin/env bats

load helpers

function setup() {
    pushd ${HOME}
    mkdir -p .dotfiles

    function backup_current_dotfiles() { return 0; }
    function should_it_make_deep_link_directory() {
        [[ "$1" = ".config" ]] && return 0
        [[ "$1" = ".config2" ]] && return 0
        [[ "$1" = ".local" ]] && return 0
        [[ "$1" = "bin" ]] && return 0
        return 1
    }
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR} ${HOME}/.config ${HOME}/.config2 ${HOME}/.local ${HOME}/bin
    [[ -L ${HOME}/.dir0 ]] && unlink ${HOME}/.dir0
    [[ -L ${HOME}/.dir1 ]] && unlink ${HOME}/.dir1
    popd
}

@test '#deploy should create a link .vim into .dotfiles' {

    touch ${DOTDIR}/.vim
    function get_target_dotfiles() { echo ".vim"; }

    run deploy
    [[ "$status" -eq 0 ]]
    [[ -L "${HOME}/.vim" ]]
    [[ "$(readlink ${HOME}/.vim)" = "${DOTDIR}/.vim" ]]
}

@test '#deploy should create links .vim, .tmux.conf, .dir0 and .dir1 into .dotfiles' {
    touch ${DOTDIR}/.vim
    touch ${DOTDIR}/.tmux.conf
    mkdir ${DOTDIR}/.dir0
    mkdir ${DOTDIR}/.dir1
    function get_target_dotfiles() { echo ".vim .tmux.conf .dir0 .dir1"; }

    run deploy
    [[ "$status" -eq 0 ]]
    [[ -L "${HOME}/.vim" ]]
    [[ -L "${HOME}/.tmux.conf" ]]
    [[ -L "${HOME}/.dir0" ]]
    [[ -L "${HOME}/.dir1" ]]
    [[ "$(readlink ${HOME}/.vim)" = "${DOTDIR}/.vim" ]]
    [[ "$(readlink ${HOME}/.tmux.conf)" = "${DOTDIR}/.tmux.conf" ]]
    [[ "$(readlink ${HOME}/.dir0)" = "${DOTDIR}/.dir0" ]]
    [[ "$(readlink ${HOME}/.dir1)" = "${DOTDIR}/.dir1" ]]
}

@test '#deploy should create a link .config deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    function get_target_dotfiles() { echo ".config"; }

    run deploy
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)" = "../../.dotfiles/.config/fontconfig/fonts.conf" ]]
}

@test '#deploy should create some links .config deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig/foo
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    touch ${DOTDIR}/.config/fontconfig/foo/foo.conf
    function get_target_dotfiles() { echo ".config"; }

    run deploy
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -d "${HOME}/.config/fontconfig/foo" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ -L "${HOME}/.config/fontconfig/foo/foo.conf" ]]
    [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)" = "../../.dotfiles/.config/fontconfig/fonts.conf" ]]
    [[ "$(readlink ${HOME}/.config/fontconfig/foo/foo.conf)" = "../../../.dotfiles/.config/fontconfig/foo/foo.conf" ]]
}

@test '#deploy should create some links from some source directory deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig/foo
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    touch ${DOTDIR}/.config/fontconfig/foo/foo.conf
    mkdir -p ${DOTDIR}/.config2/fontconfig/foo
    touch ${DOTDIR}/.config2/fontconfig/fonts.conf
    touch ${DOTDIR}/.config2/fontconfig/foo/foo.conf

    function get_target_dotfiles() { echo ".config .config2"; }

    run deploy
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -d "${HOME}/.config/fontconfig/foo" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]]
    [[ -L "${HOME}/.config/fontconfig/foo/foo.conf" ]]
    [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)" = "../../${DOTDIR}/.config/fontconfig/fonts.conf" ]]
    [[ "$(readlink ${HOME}/.config/fontconfig/foo/foo.conf)" = "../../../${DOTDIR}/.config/fontconfig/foo/foo.conf" ]]
    [[ -d "${HOME}/.config2" ]]
    [[ -d "${HOME}/.config2/fontconfig" ]]
    [[ -d "${HOME}/.config2/fontconfig/foo" ]]
    [[ -L "${HOME}/.config2/fontconfig/fonts.conf" ]]
    [[ -L "${HOME}/.config2/fontconfig/foo/foo.conf" ]]
    [[ "$(readlink ${HOME}/.config2/fontconfig/fonts.conf)" = "../../${DOTDIR}/.config2/fontconfig/fonts.conf" ]]
    [[ "$(readlink ${HOME}/.config2/fontconfig/foo/foo.conf)" = "../../../${DOTDIR}/.config2/fontconfig/foo/foo.conf" ]]

}

@test '#deploy should create some links .local deeply' {
    mkdir -p ${DOTDIR}/.local/share/fonts
    touch "${DOTDIR}/.local/share/fonts/Inconsolata for Powerline.otf"
    touch "${DOTDIR}/.local/share/fonts/LICENSE.txt"

    function get_target_dotfiles() { echo ".local"; }

    run deploy

    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.local" ]]
    [[ -L "${HOME}/.local/share/fonts/Inconsolata for Powerline.otf" ]]
    [[ ! -e "${HOME}/.local/share/fonts/LICENSE.txt" ]]
    [[ "$(readlink ${HOME}/.local/share/fonts/Inconsolata\ for\ Powerline.otf)" = "../../../${DOTDIR}/.local/share/fonts/Inconsolata for Powerline.otf" ]]
}

@test '#deploy should create the symlink to the file under the .dotfiles/bin directory' {
    rm -rf ${HOME}/bin
    mkdir -p ${DOTDIR}/bin
    touch ${DOTDIR}/bin/foo

    function get_target_dotfiles() { echo "bin"; }

    run deploy
    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/bin" ]]
    [[ -L "${HOME}/bin/foo" ]]
    [[ "$(readlink ${HOME}/bin/foo)" = "../${DOTDIR}/bin/foo" ]]
}

@test '#deploy should create some symlinks to the files under the .dotfiles/bin directory' {
    rm -rf ${HOME}/bin
    mkdir -p ${DOTDIR}/bin
    touch ${DOTDIR}/bin/foo
    touch ${DOTDIR}/bin/bar

    function get_target_dotfiles() { echo "bin"; }

    run deploy
    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/bin" ]]
    [[ -L "${HOME}/bin/foo" ]]
    [[ -L "${HOME}/bin/bar" ]]
    [[ "$(readlink ${HOME}/bin/foo)" = "../${DOTDIR}/bin/foo" ]]
}

