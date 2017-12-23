#!/usr/bin/env bats
load helpers

function setup() {
    stub do_i_have_admin_privileges
    stub install_packages
    stub push_warn_message_list
    stub init_repo
    stub install_fonts
    stub init_vim_environment
    stub_and_eval read '{ eval "answer=y"; }'
}

@test '#init should return 0 if no errors have occured' {
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)

    echo "$outputs"
    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]

    stub_called_with_exactly_times init_repo 1 "git@github.com:TsutomuNakamura/dotfiles.git" "develop" 
}

@test '#init should use default parameters if no parameters were specified' {
    run init

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]

    stub_called_with_exactly_times init_repo 1 "https://github.com/TsutomuNakamura/dotfiles.git" "master"
}

@test '#init should not call install_packages() if flag_no_install_packages was specified as 1(not 0).' {
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 1

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 0 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]

    stub_called_with_exactly_times init_repo 1 "git@github.com:TsutomuNakamura/dotfiles.git" "develop"
}

@test '#init should should call following instructions except call install_packages() if the do_i_have_admin_privileges() returns false and the user accept to be not able to install dependency packages.' {
    # skip
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]        # should not call
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times read)"                          -eq 1 ]]

    stub_called_with_exactly_times init_repo 1 "git@github.com:TsutomuNakamura/dotfiles.git" "develop"
}

@test '#init should should return 255 if the do_i_have_admin_privileges() returns false and the user inputs to question with invalid answer over 3 times.' {
    # skip
    stub_and_eval read '{ eval "answer=foo"; }'        # Invalid answer
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 255 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]        # should not call
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 0 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times read)"                          -eq 3 ]]
}

@test '#init should return 255 if the user answers no to the question.' {
    stub_and_eval read '{ eval "answer=n"; }'        # Invalid answer
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'
    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 255 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 0 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 0 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times read)"                          -eq 1 ]]
}

@test '#init should return 1 if the init_repo() returns 1.' {
    stub_and_eval init_repo '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 0 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times read)"                          -eq 0 ]]
}

@test '#init should return 1 if the install_fonts returns 1.' {
    stub_and_eval install_fonts '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 0 ]]
    [[ "$(stub_called_times read)"                          -eq 0 ]]
}

@test '#init should return 1 if the init_vim_environment() returns 1.' {
    stub_and_eval init_vim_environment '{ return 1; }'

    run init "develop" "git@github.com:TsutomuNakamura/dotfiles.git" 0

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"    -eq 1 ]]
    [[ "$(stub_called_times install_packages)"              -eq 1 ]]
    [[ "$(stub_called_times push_warn_message_list)"        -eq 0 ]]
    [[ "$(stub_called_times init_repo)"                     -eq 1 ]]
    [[ "$(stub_called_times install_fonts)"                 -eq 1 ]]
    [[ "$(stub_called_times init_vim_environment)"          -eq 1 ]]
    [[ "$(stub_called_times read)"                          -eq 0 ]]
}

