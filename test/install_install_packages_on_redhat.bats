#!/usr/bin/env bats

load helpers "install.sh"

function setup() {
    stub dnf
    stub_and_eval sudo '{ return 0; }'
    # stub of "rpm -qa --queryformat="%{NAME}\n""
    stub_and_eval rpm '{
        echo "vim"
        echo "tmux"
    }'
}

function teardown() {
    true
}

@test '#install_packages_on_redhat should call "sudo dnf" zsh with parameter zsh' {
    run install_packages_on_redhat "dnf" zsh

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    stub_called_with_exactly_times sudo 1 dnf install -y zsh
}

@test '#install_packages_on_redhat should NOT call "sudo dnf" (vim is already installed)' {
    run install_packages_on_redhat "dnf" vim

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "vim is already installed" ]]
    [[ "${outputs[1]}" == "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
}

@test '#install_packages_on_redhat should NOT call "sudo dnf" (vim and tmux are already installed)' {
    run install_packages_on_redhat "dnf" vim tmux

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "vim is already installed" ]]
    [[ "${outputs[1]}" == "tmux is already installed" ]]
    [[ "${outputs[2]}" == "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
}



@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh(because zsh is already installed)' {
    run install_packages_on_redhat "dnf" vim zsh

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "vim is already installed" ]]
    [[ "${outputs[1]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    stub_called_with_exactly_times sudo 1 dnf install -y zsh
}

 @test '#install_packages_on_redhat should call "sudo dnf" with parameter vim, zsh, ctags(because vim is already installeda)' {
     run install_packages_on_redhat "dnf" vim zsh ctags
 
     echo "$output"
     declare -a outputs; IFS=$'\n' outputs=($output)
     [[ "$status" -eq 0 ]]
     [[ "${outputs[0]}" == "vim is already installed" ]]
     [[ "${outputs[1]}" == "Installing zsh ctags..." ]]
     [[ "$(stub_called_times sudo)" -eq 1 ]]
     stub_called_with_exactly_times sudo 1 dnf install -y zsh ctags
 }

@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh, ctags(because vim, tmux are already installeda)' {
    run install_packages_on_redhat "dnf" vim zsh tmux ctags

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "vim is already installed" ]]
    [[ "${outputs[1]}" == "tmux is already installed" ]]
    [[ "${outputs[2]}" == "Installing zsh ctags..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    stub_called_with_exactly_times sudo 1 dnf install -y zsh ctags
}

@test '#install_packages_on_redhat should return 1 if "rpm -qa" has failed' {
    stub_and_eval rpm '{ return 1; }'
    run install_packages_on_redhat "dnf" vim zsh tmux ctags

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" == "ERROR: Failed to get installed packages at install_packages_on_redhat()" ]]
}

@test '#install_packages_on_redhat should return 1 if "sudo dnf" has failed' {
    stub_and_eval sudo '{ return 1; }'
    run install_packages_on_redhat "dnf" zsh

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "${outputs[1]}" == "ERROR: Failed to install packages zsh" ]]
}

@test '#install_packages_on_redhat should call "sudo yum" with parameter vim, zsh, ctags(because vim is already installeda)' {
    run install_packages_on_redhat "yum" vim zsh ctags

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "vim is already installed" ]]
    [[ "${outputs[1]}" == "Installing zsh ctags..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    stub_called_with_exactly_times sudo 1 yum install -y zsh ctags
}


