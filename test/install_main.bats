#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub check_environment
    stub usage
    stub do_i_have_admin_privileges
    stub install_packages
    stub backup_current_dotfiles
    stub init
    stub deploy
    stub print_post_message_list
 }

# function teardown() {}

@test "#main should call print_a_success_message() when default execution is finished" {
    run main
    echo "$output"

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 1 ]]

    stub_called_with_exactly_times check_environment 1
    stub_called_with_exactly_times init 1 master "https://github.com/TsutomuNakamura/dotfiles.git" "0"
    stub_called_with_exactly_times deploy 1
}

@test "#main should return 1 if check_environment returns 1" {
    stub_and_eval check_environment '{ return 1; }'

    run main

    local i=0

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when opsions -o(only_install_packages), -n(no_install_packages) are set" {
    run main -o -n
    echo "$output"
    IFS=$'\n' outputs=($output)

    [[ "${outputs[ $((i++)) ]}" == 'Some contradictional options were found. (-o|--only-install-packages and -n|--no-install-packages)' ]]
    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call install_packages() when opsions -o(only_install_packages) is set" {
    run main -o

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 1 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 1 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when opsions -o(only_install_packages) is set and install_packages is failed" {
    stub_and_eval install_packages '{ return 1; }'

    run main -o

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 1 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 1 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should not call install_packages() and return 1 when opsions -o(only_install_packages) is set and do_i_have_admin_privileges returns false" {
    stub_and_eval do_i_have_admin_privileges '{ return 1; }'

    run main -o

    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "Sorry, you don't have privileges to install packages." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 1 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call backup_current_dotfiles() when the option -c(clean_up) is set" {
    run main -c
    # IFS=$'\n' outputs=($output)
    # [[ "${outputs[0]}" == "Sorry, you don't have privileges to install packages." ]]

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when the option -c(clean_up) is set and backup_current_dotfiles() is failed" {
    stub_and_eval backup_current_dotfiles '{ false; }'
    run main -c

    local outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: Cleaning up and backup current dotfiles are failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call init() when the option -i(init) is set" {
    run main -i

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when the option -i(init) is set and it is failed" {
    stub_and_eval init '{ return 1; }'

    run main -i

    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: init() has failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]

    stub_called_with_exactly_times init 1 "master" "https://github.com/TsutomuNakamura/dotfiles.git" "0"
}

# Pattern of init() and deploy() are called is already tested
@test "#main should call init() and deploy() and returns 1 when no option has passed and init() is succeeded but deploy is failed" {
    stub_and_eval deploy '{ false; }'

    run main
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: deploy() has failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 1 ]]

    stub_called_with_exactly_times init 1 master "https://github.com/TsutomuNakamura/dotfiles.git" "0"
}

@test "#main should call init() (but not deploy()) and returns 1 when no option has passed and init() is is failed" {
    stub_and_eval init '{ false; }'

    run main
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: init() has failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]

    stub_called_with_exactly_times init 1 master "https://github.com/TsutomuNakamura/dotfiles.git" "0"
}

@test "#main should call init() with parameters 'develop' and 1 and 'git@github.com:TsutomuNakamura/dotfiles.git' when -d and -g and -n flag is specified" {
    run main -b 'develop' -g -n
    echo "$output"

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 1 ]]
    [[ "$(stub_called_times print_post_message_list)"               -eq 1 ]]

    stub_called_with_exactly_times init 1 'develop' 'git@github.com:TsutomuNakamura/dotfiles.git' 1
}

@test "#main should call init() with parameters 'master' and 0 and 'https://github.com/TsutomuNakamura/dotfiles' when no parameters are specified" {
    run main
    echo "$output"

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 1 ]]
    [[ "$(stub_called_times print_post_message_list)"               -eq 1 ]]

    stub_called_with_exactly_times init 1 'master' 'https://github.com/TsutomuNakamura/dotfiles.git' 0
}

@test "#main should call print_post_message_list() when some error has occured and INFO_MESSAGE list is empty" {
    stub_and_eval init '{ true; }'

    run main -i

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times check_environment)"                     -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
    [[ "$(stub_called_times print_post_message_list)"               -eq 1 ]]

    stub_called_with_exactly_times init 1 master "https://github.com/TsutomuNakamura/dotfiles.git" "0"
}
