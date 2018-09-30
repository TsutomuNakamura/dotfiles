#!/usr/bin/env bats

load helpers "install.sh"

function setup() {
    stub_and_eval dnf '{
        [[ "$1" == "list" ]] && {
            echo "Last metadata expiration check: 0:03:54 ago on Sun Sep 30 02:35:45 2018."
            echo "Available Packages"
            echo "ctags.x86_64                             5.8-22.fc28                     fedora"
            echo "tmux.x86_64                              2.7-1.fc28                      updates"
            echo "vim-enhanced.x86_64                      2:8.1.408-1.fc28                updates"
            echo "zsh.x86_64                               5.5.1-2.fc28                    updates"
        }
    }'
    stub_and_eval sudo '{ return 0; }'
    # stub of "rpm -qa --queryformat="%{NAME}\n""
    stub_and_eval rpm '{
        echo "vim-enhanced"
        echo "tmux"
    }'
    stub logger_info
    stub logger_warn
    stub logger_err
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
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    stub_called_with_exactly_times sudo 1 dnf install -y zsh
    stub_called_with_exactly_times logger_info 1 "Packages zsh have been installed."
}

@test '#install_packages_on_redhat should NOT call "sudo dnf" (vim-enhanced is already installed)' {
    run install_packages_on_redhat "dnf" vim-enhanced

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    stub_called_with_exactly_times logger_info 1 "Package vim-enhanced has already installed. Skipping install it."
}

@test '#install_packages_on_redhat should NOT call "sudo dnf" (vim-enhanced and tmux are already installed)' {
    run install_packages_on_redhat "dnf" vim-enhanced tmux

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 2 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times logger_info 1 "Package vim-enhanced has already installed. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Package tmux has already installed. Skipping install it."
}

# - testing already installed packages ----------------------------------------------------------------------------

@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh(because zsh is already installed)' {
    run install_packages_on_redhat "dnf" vim-enhanced zsh

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 2 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times sudo 1 dnf install -y zsh
    stub_called_with_exactly_times logger_info 1 "Package vim-enhanced has already installed. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh have been installed."
}

@test '#install_packages_on_redhat should call "sudo dnf" with parameter vim-enhanced, zsh, ctags(because vim-enhanced is already installeda)' {
    run install_packages_on_redhat "dnf" vim-enhanced zsh ctags

    echo "======================================="
    echo "$output"
    echo "======================================="
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh ctags..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 2 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times sudo 1 dnf install -y zsh ctags
    stub_called_with_exactly_times logger_info 1 "Package vim-enhanced has already installed. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh ctags have been installed."
}

@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh, ctags(because vim-enhanced, tmux are already installeda)' {
    run install_packages_on_redhat "dnf" vim-enhanced zsh tmux ctags

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh ctags..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 3 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times sudo 1 dnf install -y zsh ctags
    stub_called_with_exactly_times logger_info 1 "Package vim-enhanced has already installed. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Package tmux has already installed. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh ctags have been installed."
}

# - testing unavailable packages -----------------------------------------------------------------------------------

@test '#install_packages_on_redhat should NOT call "sudo dnf" with parameter ffmpeg(ffmpeg is unavailable)' {
    run install_packages_on_redhat "dnf" ffmpeg

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    [[ "$(stub_called_times logger_warn)" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times logger_warn 1 "Package ffmpeg is not available. Skipping install it."
}

@test '#install_packages_on_redhat should NOT call "sudo dnf" with parameter ffmpeg and aptitude(ffmpeg and aptitude are unavailable)' {
    run install_packages_on_redhat "dnf" ffmpeg aptitude

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "There are no packages to install" ]]
    [[ "$(stub_called_times sudo)" -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    [[ "$(stub_called_times logger_warn)" -eq 2 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times logger_warn 1 "Package ffmpeg is not available. Skipping install it."
    stub_called_with_exactly_times logger_warn 1 "Package aptitude is not available. Skipping install it."
}

@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh(ffmpeg is unavailable)' {
    run install_packages_on_redhat "dnf" ffmpeg zsh

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_warn)" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times logger_warn 1 "Package ffmpeg is not available. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh have been installed."
}

@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh(ffmpeg and aptitude are unavailable)' {
    run install_packages_on_redhat "dnf" ffmpeg zsh aptitude

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_warn)" -eq 2 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times logger_warn 1 "Package ffmpeg is not available. Skipping install it."
    stub_called_with_exactly_times logger_warn 1 "Package aptitude is not available. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh have been installed."
}

@test '#install_packages_on_redhat should call "sudo dnf" with parameter zsh(ffmpeg and aptitude are unavailable)' {
    run install_packages_on_redhat "dnf" ffmpeg zsh aptitude

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    [[ "$(stub_called_times logger_warn)" -eq 2 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times logger_warn 1 "Package ffmpeg is not available. Skipping install it."
    stub_called_with_exactly_times logger_warn 1 "Package aptitude is not available. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh have been installed."
}

# ------------------------------------------------------------------------------------------------------------------

@test '#install_packages_on_redhat should return 1 if "rpm -qa" has failed' {
    stub_and_eval rpm '{ return 1; }'
    run install_packages_on_redhat "dnf" vim-enhanced zsh tmux ctags

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Failed to get installed packages at install_packages_on_redhat()"
}

@test '#install_packages_on_redhat should return 1 if "dnf list available" has failed' {
    stub_and_eval dnf '{ return 1; }'
    run install_packages_on_redhat "dnf" vim-enhanced zsh tmux ctags

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Failed to get available packages at install_packages_on_redhat()"
}

@test '#install_packages_on_redhat should return 1 if "sudo dnf" has failed' {
    stub_and_eval sudo '{ return 1; }'
    run install_packages_on_redhat "dnf" zsh

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" == "Installing zsh..." ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 1 ]]
    stub_called_with_exactly_times logger_err 1 "Failed to install packages zsh"
}

@test '#install_packages_on_redhat should call "sudo yum" with parameter zsh, ctags(because vim-enhanced is already installed)' {
    run install_packages_on_redhat "yum" vim-enhanced zsh ctags

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" == "Installing zsh ctags..." ]]
    [[ "$(stub_called_times sudo)" -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 2 ]]
    [[ "$(stub_called_times logger_warn)" -eq 0 ]]
    [[ "$(stub_called_times logger_err)" -eq 0 ]]
    stub_called_with_exactly_times sudo 1 yum install -y zsh ctags
    stub_called_with_exactly_times logger_info 1 "Package vim-enhanced has already installed. Skipping install it."
    stub_called_with_exactly_times logger_info 1 "Packages zsh ctags have been installed."
}
