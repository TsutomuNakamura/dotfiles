#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    pushd ${HOME}
    mkdir -p .dotfiles
    rm -rf ${HOME}/${DOTDIR} ${HOME}/.config ${HOME}/.config2 ${HOME}/.local ${HOME}/bin ${HOME}/.vim ${HOME}/.vimrc_do_not_use_ambiwidth

    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
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
    stub deploy_xdg_base_directory
    stub deploy_vim_environment

    stub restore_git_personal_properties
    stub clear_git_personal_properties

    stub logger_err
    stub logger_warn

    function deploy_tmux_environment() { true; }    # TODO: Skip this instruction because this instruction may removed in the future
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
    [[ -L "${HOME}/.vim" ]] && [[ "$(readlink ${HOME}/.vim)" = "${DOTDIR}/.vim" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.vim'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
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

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 4 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.vim'
    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.tmux.conf'
    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.dir0'
    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.dir1'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
}

@test '#deploy should create a link a .config deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    function get_target_dotfiles() { echo ".config"; }

    run deploy

    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/.config" ]]
    [[ -d "${HOME}/.config/fontconfig" ]]
    [[ -L "${HOME}/.config/fontconfig/fonts.conf" ]] && [[ "$(readlink ${HOME}/.config/fontconfig/fonts.conf)" = "../../.dotfiles/.config/fontconfig/fonts.conf" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 1 ]]    # Called if taget may be deep link
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.config'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
}

@test '#deploy should create some links .configs deeply' {
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

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 2 ]]    # Called if taget may be deep link
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.config'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
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

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 2 ]]    # Called if taget may be deep link
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.config'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
}

@test '#deploy should create some links from some source directory deeply' {
    mkdir -p ${DOTDIR}/.config/fontconfig/foo
    touch ${DOTDIR}/.config/fontconfig/fonts.conf
    touch ${DOTDIR}/.config/fontconfig/foo/foo.conf
    mkdir -p ${DOTDIR}/.config2/fontconfig/foo
    touch ${DOTDIR}/.config2/fontconfig/fonts.conf
    touch ${DOTDIR}/.config2/fontconfig/foo/foo.conf

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

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 2 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 4 ]]    # Called if taget may be deep link
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.config'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
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

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 2 ]]    # Called if taget may be deep link
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 '.local'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
}

@test '#deploy should create the symlink to the file under the .dotfiles/bin directory' {
    mkdir -p ${DOTDIR}/bin
    touch ${DOTDIR}/bin/foo

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/bin" ]]
    [[ -L "${HOME}/bin/foo" ]] && [[ "$(readlink ${HOME}/bin/foo)" = "../${DOTDIR}/bin/foo" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 1 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 'bin'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
}

@test '#deploy should create some symlinks to the files under the .dotfiles/bin directory' {
    mkdir -p ${DOTDIR}/bin
    touch ${DOTDIR}/bin/foo
    touch ${DOTDIR}/bin/bar

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ -d "${HOME}/bin" ]]
    [[ -L "${HOME}/bin/foo" ]] && [[ "$(readlink ${HOME}/bin/foo)" = "../${DOTDIR}/bin/foo" ]]
    [[ -L "${HOME}/bin/bar" ]] && [[ "$(readlink ${HOME}/bin/bar)" = "../${DOTDIR}/bin/bar" ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 2 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 'bin'
    stub_called_with_exactly_times restore_git_personal_properties 1 "${FULL_DOTDIR_PATH}"
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

@test '#deploy should return 1 if backup_current_dotfiles() has failed' {
    stub_and_eval backup_current_dotfiles '{ return 1; }'

    run deploy

    echo "$output"
    [[ "$status" -eq 1 ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 0 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 0 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 0 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 0 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to backup .dotfiles data. Stop the instruction deploy()."
}

@test '#deploy should return 1 if pushd ${HOME}' {
    function pushd() { return 1; }

    run deploy

    echo "$output"
    [[ "$status" -eq 1 ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 0 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 0 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 0 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 0 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 0 ]]
}

@test '#deploy should return 1 if mkdir that create directory to make deep-link has failed' {
    function get_target_dotfiles() { echo ".config"; }
    stub_and_eval mkdir '{
        if [[ "$1" == ".config" ]]; then
            return 1
        fi
        command mkdir $@
    }'

    run deploy

    echo "$output"
    stub_called_with_exactly_times should_it_make_deep_link_directory 1 ".config"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 0 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 0 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 0 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 1 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 ".config"
    stub_called_with_exactly_times logger_err 1 "Failed to make directory .config in deploy()."
}

@test '#deploy should return 1 if pushd to make deep link directory has failed' {
    function get_target_dotfiles() { echo ".config .vim"; }
    function pushd() {
        if [[ "$1" == "${DOTDIR}/.config" ]]; then
            return 1
        fi
        command pushd $@
    }

    run deploy

    echo "$output"
    [[ "$status" -eq 1 ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 0 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 0 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 0 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 0 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                            -eq 0 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 ".config"
}

#@test '#deploy should skip command ln if files_that_should_not_be_linked() returns 0' {
#    skip
#    # TODO:
#}
#
#@test '#deploy should exec command ln if files_that_should_not_be_linked() returns 1' {
#    skip
#    # TODO:
#}

@test '#deploy should call logger_warn if restore_git_personal_properties has failed' {
    function get_target_dotfiles() { echo ".vim"; }
    stub_and_eval restore_git_personal_properties '{ return 1; }'

    run deploy

    echo "$output"
    [[ "$status" -eq 0 ]]

    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
    [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
    [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
    [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
    [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
    [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
    [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]
    [[ "$(stub_called_times logger_warn)"                           -eq 1 ]]
    [[ "$(stub_called_times logger_error)"                          -eq 0 ]]

    stub_called_with_exactly_times should_it_make_deep_link_directory 1 ".vim"
    stub_called_with_exactly_times logger_warn 1 "Failed to restore your email of git and(or) name of git.\nYou may nesessary to restore manually with \`git config --global user.name \"Your Name\"\`, \`git config --global user.email your-email@example.com\`"
}

 @test '#deploy should call logger_warn if clear_git_personal_properties has failed' {
     function get_target_dotfiles() { echo ".vim"; }
     stub_and_eval clear_git_personal_properties '{ return 1; }'

     run deploy

     echo "$output"
     [[ "$status" -eq 0 ]]

     [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
     [[ "$(stub_called_times should_it_make_deep_link_directory)"    -eq 1 ]]
     [[ "$(stub_called_times files_that_should_not_be_linked)"       -eq 0 ]]
     [[ "$(stub_called_times restore_git_personal_properties)"       -eq 1 ]]
     [[ "$(stub_called_times clear_git_personal_properties)"         -eq 1 ]]
     [[ "$(stub_called_times deploy_xdg_base_directory)"             -eq 1 ]]
     [[ "$(stub_called_times deploy_vim_environment)"                -eq 1 ]]
     [[ "$(stub_called_times get_distribution_name)"                 -eq 1 ]]
     [[ "$(stub_called_times logger_warn)"                           -eq 1 ]]

     stub_called_with_exactly_times should_it_make_deep_link_directory 1 ".vim"
     stub_called_with_exactly_times logger_warn 1 "Failed to clear your temporary git data \"${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}\" and \"${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}\".\nYou should clear these data with...\n\`rm -f ${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}\`\n\`rm -f ${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}\`"
 }

