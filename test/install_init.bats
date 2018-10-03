#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub do_i_have_admin_privileges
    stub install_packages
    stub init_repo
    stub install_fonts
    stub init_vim_environment
    stub install_bin_utils
    stub_and_eval question '{ return $ANSWER_OF_QUESTION_YES; }'
    # stub_and_eval git '{
    #     [[ "$1" == "--version" ]] && {
    #         echo "git version 2.19.0"
    #     }
    #     return 0
    # }'

    stub logger_err
}

@test '#init should return 0 if no errors have occured' {
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    echo "$output"
    [[ "$status" -eq 0 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 1 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    stub_called_with_exactly_times init_repo 1 "git@github.com:TsutomuNakamura/dotfiles.git" "develop"
}

@test '#init should use default parameters if no parameters were specified' {
    run init

    [[ "$status" -eq 0 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 1 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    stub_called_with_exactly_times init_repo 1 "https://github.com/TsutomuNakamura/dotfiles.git" "master"
}

@test '#init should return 1 if install_packages return 1' {
    stub_and_eval  install_packages '{ return 1; }'
    run init

    [[ "$status" -eq 1 ]]
    # [[ "$(stub_called_times git)"                           -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 0 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    local m="Failed to install dependency packages."
    m+="\n  If you want to continue following processes that after installing packages, you can specify the option \"-n (no-install-packages)\"."
    m+="\n  ex) "
    m+="\n    bash -- <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh) -n"
    stub_called_with_exactly_times logger_err 1 "$m"
}

@test '#init should not call install_packages() if flag_no_install_packages was specified as 1(not 0).' {
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 1

    [[ "$status" -eq 0 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 0 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 1 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    stub_called_with_exactly_times init_repo 1 "git@github.com:TsutomuNakamura/dotfiles.git" "develop"
}

@test '#init should should call following instructions except call install_packages() if the do_i_have_admin_privileges() returns false and the user accept to be not able to install dependency packages.' {
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 0 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]        # should not call
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 1 ]]
    [[ "$(stub_called_times question)"                      -eq 1 ]]

    stub_called_with_exactly_times init_repo 1 "git@github.com:TsutomuNakamura/dotfiles.git" "develop"
    stub_called_with_exactly_times question 1 "Do you continue to install the dotfiles without dependency packages? [Y/n]: "
}

@test '#init should should return 255 if the do_i_have_admin_privileges() returns false and the user inputs to question with invalid answer over 3 times.' {
    stub_and_eval question '{ return $ANSWER_OF_QUESTION_ABORTED; }'
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 255 ]]
    # [[ "$(stub_called_times git)"                           -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]        # should not call
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 0 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
    [[ "$(stub_called_times question)"                      -eq 1 ]]

    stub_called_with_exactly_times question 1 "Do you continue to install the dotfiles without dependency packages? [Y/n]: "
}

@test '#init should return 255 if the user answers no to the question.' {
    stub_and_eval question '{ return $ANSWER_OF_QUESTION_NO; }'
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 255 ]]
    # [[ "$(stub_called_times git)"                           -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 0 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
    [[ "$(stub_called_times question)"                      -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 0 ]]

    stub_called_with_exactly_times question 1 "Do you continue to install the dotfiles without dependency packages? [Y/n]: "
}

#@test '#init should return 1 if the version of git is lower then 1.9.0.' {
#    stub_and_eval git '{
#        [[ "$1" == "--version" ]] && {
#            echo "git version 1.8.99"
#        }
#        return 0
#    }'
#
#    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0
#
#    [[ "$status" -eq 1 ]]
#    [[ "$(stub_called_times git)"                           -eq 1 ]]
#    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
#    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
#    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
#    [[ "$(stub_called_times init_repo)"                     -eq 0 ]]
#    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
#    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
#    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
#    [[ "$(stub_called_times question)"                      -eq 0 ]]
#    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
#
#    stub_called_with_exactly_times logger_err 1 "Your version of git is 1.8.99. Remaining processes of this script requires version of git greater than or equals 1.9. Re-run this script after you upgrade it by yourself, please."
#}

@test '#init should return 1 if the init_repo() returns 1.' {
    stub_and_eval init_repo '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 1 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]
}

@test '#init should return 1 if the install_fonts returns 1.' {
    stub_and_eval install_fonts '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 1 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to installing fonts. Remaining install process will be aborted."
}

@test '#init should return 1 if the init_vim_environment() returns 1.' {
    stub_and_eval init_vim_environment '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 1 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 0 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to initializing vim environment. Remaining install process will be aborted."
}

@test '#init should return 1 if the install_bin_utils() returns 1.' {
    stub_and_eval install_bin_utils '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    [[ "$status" -eq 1 ]]
    # [[ "$(stub_called_times git)"                           -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times logger_err)"                    -eq 1 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times install_bin_utils)"             -eq 1 ]]
    [[ "$(stub_called_times question)"                      -eq 0 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to installing bin utils that will be installed in ~/bin. Remaining install process will be aborted."
}

