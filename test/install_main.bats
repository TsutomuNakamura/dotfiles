#!/usr/bin/env bats
load helpers

function setup() {
    mkdir -p ${HOME}/${DOTDIR}
    stub_and_eval is_customized_xdg_base_directories '{ true; }'
    stub_and_eval usage '{ true; }'
    stub_and_eval do_i_have_admin_privileges '{ true; }'
    stub_and_eval install_packages '{ true; }'
    stub_and_eval backup_current_dotfiles '{ true; }'
    stub_and_eval init '{ true; }'
    stub_and_eval deploy '{ true; }'
    stub_and_eval print_a_success_message '{ true; }'
    stub_and_eval is_warn_messages_empty '{ true; }'
    stub_and_eval print_warn_messages '{ true; }'
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR}
}

@test "#main should call print_a_success_message() when default execution is finished" {
    run main
    echo "$output"

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 1 ]]
}

@test "#main should return 1 when unexpected XDG_CONFIG_HOME was set" {
    stub_and_eval is_customized_xdg_base_directories '{ false; }'
    export XDG_CONFIG_HOME="/foo"

    run main
    echo "$output"
    IFS=$'\n' outputs=($output)

    local i=0
    [[ "${outputs[ $((i++)) ]}" == "ERROR: Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments." ]]
    [[ "${outputs[ $((i++)) ]}" == "       Current environment variables XDG_CONFIG_HOME and XDG_DATA_HOME is set like below." ]]
    [[ "${outputs[ $((i++)) ]}" =~ ^\ +XDG_CONFIG_HOME=\"/foo\"$ ]]
    [[ "${outputs[ $((i++)) ]}" == "           -> This must be set \"\${HOME}/.config\" in Linux or \"\${HOME}/Library/Preferences\" in Mac or unset." ]]
    [[ "${outputs[ $((i++)) ]}" =~ ^\ +XDG_DATA_HOME=\(unset\)$ ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when unexpected XDG_DATA_HOME was set" {
    stub_and_eval is_customized_xdg_base_directories '{ false; }'
    export XDG_DATA_HOME="/bar"

    run main
    echo "$output"
    IFS=$'\n' outputs=($output)

    local i=0
    [[ "${outputs[ $((i++)) ]}" == "ERROR: Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments." ]]
    [[ "${outputs[ $((i++)) ]}" == "       Current environment variables XDG_CONFIG_HOME and XDG_DATA_HOME is set like below." ]]
    [[ "${outputs[ $((i++)) ]}" =~ ^\ +XDG_CONFIG_HOME=\(unset\)$ ]]
    [[ "${outputs[ $((i++)) ]}" == "           -> This must be set \"\${HOME}/.config\" in Linux or \"\${HOME}/Library/Preferences\" in Mac or unset." ]]
    [[ "${outputs[ $((i++)) ]}" =~ ^\ +XDG_DATA_HOME=\"/bar\"$ ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
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
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call install_packages() when opsions -o(only_install_packages) is set" {
    run main -o
    echo "$output"
    # IFS=$'\n' outputs=($output)

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 1 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 1 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when opsions -o(only_install_packages) is set and install_packages is failed" {
    stub_and_eval install_packages '{ false; }'

    run main -o
    echo "$output"
    # IFS=$'\n' outputs=($output)

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 1 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 1 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should not call install_packages() and return 1 when opsions -o(only_install_packages) is set and do_i_have_admin_privileges returns false" {
    stub_and_eval do_i_have_admin_privileges '{ false; }'

    run main -o
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "Sorry, you don't have privileges to install packages." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 1 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call backup_current_dotfiles() when the option -c(clean_up) is set" {
    run main -c
    echo "$output"
    # IFS=$'\n' outputs=($output)
    # [[ "${outputs[0]}" == "Sorry, you don't have privileges to install packages." ]]

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
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
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: Cleaning up and backup current dotfiles are failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 1 ]]
    [[ "$(stub_called_times init)"                                  -eq 0 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call init() when the option -i(init) is set" {
    run main -i
    echo "$output"
    # IFS=$'\n' outputs=($output)
    # [[ "${outputs[0]}" == "ERROR: Cleaning up and backup current dotfiles are failed." ]]

    [[ "$status"                                                    -eq 0 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should return 1 when the option -i(init) is set and it is failed" {
    stub_and_eval init '{ false; }'

    run main -i
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: init() has failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

# Pattern of init() and deploy() are called is already tested
@test "#main should call init() and deploy() and returns 1 when no option has passed and init() is succeeded but deploy is failed" {
    stub_and_eval deploy '{ false; }'

    run main
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: deploy() has failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 1 ]]
}

@test "#main should call init() (but not deploy()) and returns 1 when no option has passed and init() is is failed" {
    stub_and_eval init '{ false; }'

    run main
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: init() has failed." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
}

@test "#main should call print_warn_messages() when some error has occured and is_warn_messages_empty() returns false" {
    stub_and_eval init '{ false; }'
    stub_and_eval is_warn_messages_empty '{ false; }'

    run main -i
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: init() has failed." ]]
    [[ "${outputs[1]}" == "Some error or warning are occured." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
    [[ "$(stub_called_times is_warn_messages_empty)"                -eq 1 ]]
    [[ "$(stub_called_times print_warn_messages)"                   -eq 1 ]]
}

@test "#main should NOT call print_warn_messages() when some error has occured and is_warn-messages_empty() returns true" {
    stub_and_eval init '{ false; }'

    run main -i
    echo "$output"
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "ERROR: init() has failed." ]]
    [[ "${outputs[1]}" == "Some error or warning are occured." ]]

    [[ "$status"                                                    -eq 1 ]]
    [[ "$(stub_called_times is_customized_xdg_base_directories)"    -eq 1 ]]
    [[ "$(stub_called_times usage)"                                 -eq 0 ]]
    [[ "$(stub_called_times do_i_have_admin_privileges)"            -eq 0 ]]
    [[ "$(stub_called_times install_packages)"                      -eq 0 ]]
    [[ "$(stub_called_times backup_current_dotfiles)"               -eq 0 ]]
    [[ "$(stub_called_times init)"                                  -eq 1 ]]
    [[ "$(stub_called_times deploy)"                                -eq 0 ]]
    [[ "$(stub_called_times is_warn_messages_empty)"                -eq 1 ]]
    [[ "$(stub_called_times print_warn_messages)"                   -eq 0 ]]
}

