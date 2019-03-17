#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    pushd ${HOME}
    mkdir -p .dotfiles
    rm -f ~/.vimrc_do_not_use_ambiwidth

    function get_distribution_name() { echo "ubuntu"; }
    stub_and_eval backup_current_dotfiles '{ return 0; }'
    stub_and_eval should_it_make_deep_link_directory '{
        [[ "$1" = ".config" ]]  && return 0
        [[ "$1" = ".config2" ]] && return 0
        [[ "$1" = ".local" ]]   && return 0
        [[ "$1" = "bin" ]]      && return 0
        return 1
    }'
    stub_and_eval files_that_should_not_be_linked '{
        local target="$1"
        [[ "$target" = "LICENSE.txt" ]]
    }'
    stub_and_eval files_that_should_be_copied_on_only_mac '{
        local target="$1"
        [[ "$(get_distribution_name)" == "mac" ]] && \
            [[ "$target" == "Inconsolata for Powerline.otf" ]]
    }'
    stub deploy_xdg_base_directory
    stub deploy_vim_environment
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR} ${HOME}/.config ${HOME}/.config2 ${HOME}/.local ${HOME}/bin ${HOME}/.vim ${HOME}/.vimrc_do_not_use_ambiwidth
    [[ -L ${HOME}/.dir0 ]] && unlink ${HOME}/.dir0
    [[ -L ${HOME}/.dir1 ]] && unlink ${HOME}/.dir1
    popd
}

@test '#deploy should create a link .vim into .dotfiles' {

    mkdir -p ${DOTDIR}/.vim
    function get_target_dotfiles() { echo ".vim"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "${HOME}/.vim" ]]
    [[ "$(readlink ${HOME}/.vim)" = "${DOTDIR}/.vim" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 0 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 0 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create links .vim, .tmux.conf, .dir0 and .dir1 into .dotfiles' {
    mkdir -p ${DOTDIR}/.vim
    touch ${DOTDIR}/.tmux.conf
    mkdir ${DOTDIR}/.dir0
    mkdir ${DOTDIR}/.dir1
    function get_target_dotfiles() { echo ".vim .tmux.conf .dir0 .dir1"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -L "${HOME}/.vim" ]]         && [[ "$(readlink ${HOME}/.vim)"        = "${DOTDIR}/.vim" ]]
    [[ -L "${HOME}/.tmux.conf" ]]   && [[ "$(readlink ${HOME}/.tmux.conf)"  = "${DOTDIR}/.tmux.conf" ]]
    [[ -L "${HOME}/.dir0" ]]        && [[ "$(readlink ${HOME}/.dir0)"       = "${DOTDIR}/.dir0" ]]
    [[ -L "${HOME}/.dir1" ]]        && [[ "$(readlink ${HOME}/.dir1)"       = "${DOTDIR}/.dir1" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 4 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 0 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 0 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create a link .config deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    function get_target_dotfiles() { echo ".config"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]] && [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)" = "../../.dotfiles/.config/fontconfig/fonts.conf" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 1 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create some links .config deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig/foo
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    touch ${DOTDIR}/.config/fontconfig/foo/foo.conf
    function get_target_dotfiles() { echo ".config"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -d "${HOME}/.config/fontconfig/foo" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]]    && [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)"   = "../../.dotfiles/.config/fontconfig/fonts.conf" ]]
    [[ -L "${HOME}/.config/fontconfig/foo/foo.conf" ]]  && [[ "$(readlink ${HOME}/.config/fontconfig/foo/foo.conf)" = "../../../.dotfiles/.config/fontconfig/foo/foo.conf" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 2 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
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

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -d "${HOME}/.config/fontconfig/foo" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]]    && [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)"       = "../../${DOTDIR}/.config/fontconfig/fonts.conf" ]]
    [[ -L "${HOME}/.config/fontconfig/foo/foo.conf" ]]  && [[ "$(readlink ${HOME}/.config/fontconfig/foo/foo.conf)"     = "../../../${DOTDIR}/.config/fontconfig/foo/foo.conf" ]]
    [[ -d "${HOME}/.config2" ]]
    [[ -d "${HOME}/.config2/fontconfig" ]]
    [[ -d "${HOME}/.config2/fontconfig/foo" ]]
    [[ -L "${HOME}/.config2/fontconfig/fonts.conf" ]]   && [[ "$(readlink ${HOME}/.config2/fontconfig/fonts.conf)"      = "../../${DOTDIR}/.config2/fontconfig/fonts.conf" ]]
    [[ -L "${HOME}/.config2/fontconfig/foo/foo.conf" ]] && [[ "$(readlink ${HOME}/.config2/fontconfig/foo/foo.conf)"    = "../../../${DOTDIR}/.config2/fontconfig/foo/foo.conf" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 2 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 4 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 4 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create some links .local deeply' {
    mkdir -p ${DOTDIR}/.local/share/fonts
    touch "${DOTDIR}/.local/share/fonts/Inconsolata for Powerline.otf"
    touch "${DOTDIR}/.local/share/fonts/LICENSE.txt"

    function get_target_dotfiles() { echo ".local"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.local" ]]
    [[ -L "${HOME}/.local/share/fonts/Inconsolata for Powerline.otf" ]] && \
        [[ "$(readlink ${HOME}/.local/share/fonts/Inconsolata\ for\ Powerline.otf)" = "../../../${DOTDIR}/.local/share/fonts/Inconsolata for Powerline.otf" ]]
    [[ ! -e "${HOME}/.local/share/fonts/LICENSE.txt" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create the symlink to the file under the .dotfiles/bin directory' {
    mkdir -p ${DOTDIR}/bin
    touch ${DOTDIR}/bin/foo

    function get_target_dotfiles() { echo "bin"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/bin" ]]
    [[ -L "${HOME}/bin/foo" ]] && [[ "$(readlink ${HOME}/bin/foo)" = "../${DOTDIR}/bin/foo" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 1 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create some symlinks to the files under the .dotfiles/bin directory' {
    mkdir -p ${DOTDIR}/bin
    touch ${DOTDIR}/bin/foo
    touch ${DOTDIR}/bin/bar

    function get_target_dotfiles() { echo "bin"; }

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/bin" ]]
    [[ -L "${HOME}/bin/foo" ]] && [[ "$(readlink ${HOME}/bin/foo)" = "../${DOTDIR}/bin/foo" ]]
    [[ -L "${HOME}/bin/bar" ]] && [[ "$(readlink ${HOME}/bin/bar)" = "../${DOTDIR}/bin/bar" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 2 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 2 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should copy "Inconsolata for Powerline.otf" (not symlink) on only Mac' {
    function get_distribution_name() { echo "mac"; }
    mkdir -p ${DOTDIR}/.local/share/fonts
    touch "${DOTDIR}/.local/share/fonts/Inconsolata for Powerline.otf"

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]

    [[ ! -L "${HOME}/.local/share/fonts/Inconsolata for Powerline.otf" ]] && [[ -f "${HOME}/.local/share/fonts/Inconsolata for Powerline.otf" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"                   -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"        -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"           -eq 1 ]]
    [[ "$(stub_called_times files_that_should_be_copied_on_only_mac)"   -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"                 -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                    -eq 1 ]]
}

@test '#deploy should create ~/.vimrc_do_not_use_ambiwidth on Mac' {
    function get_distribution_name() { echo "mac"; }
    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -f ~/.vimrc_do_not_use_ambiwidth ]]
}

@test '#deploy should NOT create ~/.vimrc_do_not_use_ambiwidth on Linux' {
    function get_distribution_name() { echo "arch"; }
    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ ! -f ~/.vimrc_do_not_use_ambiwidth ]]
}

