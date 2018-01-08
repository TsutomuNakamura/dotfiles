#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]]; then
            if [[ "$2" = "-Q" ]]; then
                if [[ "$3" = "sed" ]]; then
                    return 0
                fi
            elif [[ "$2" = "-S" ]] && [[ "$3" = "--noconfirm" ]]; then
                return 0
            fi
        fi
        return 1
    }'
    function command() { return 0; }
    stub logger_info
    stub logger_err
}
# function teardown() {}

@test '#install_packages_with_pacman should NOT call pacman -S with parameter "sed" when it was already installed' {
    run install_packages_with_pacman "sed"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "${outputs[0]}" = "sed is already installed." ]]
    [[ "${outputs[1]}" = "There are no packages to install." ]]
    [[ "$(stub_called_times sudo)" = "1" ]]
    stub_called_with_exactly_times "sudo" 0 pacman -S --noconfirm sed
    stub_called_with_exactly_times sudo 0 pacman -S --noconfirm vim git

    [[ "$(sbut_called_times logger_info)" -eq 0 ]]
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should NOT call pacman -S with parameter "sed" "gvim" when there were already installed' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]]; then
            if [[ "$2" = "-Q" ]]; then
                if [[ "$3" = "sed" ]] || [[ "$3" = "gvim" ]]; then
                    return 0
                fi
            fi
        fi
        return 1
    }'

    run install_packages_with_pacman "sed" "gvim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "${outputs[0]}" = "sed is already installed." ]]
    [[ "${outputs[1]}" = "gvim is already installed." ]]
    [[ "${outputs[2]}" = "There are no packages to install." ]]
    [[ "$(stub_called_times sudo)" = "2" ]]
    stub_called_with_exactly_times "sudo" 0 pacman -S --noconfirm sed gvim
    stub_called_with_exactly_times sudo 0 pacman -S --noconfirm vim git

    [[ "$(sbut_called_times logger_info)" -eq 0 ]]
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman with parameter "git" when it was not installed' {
    run install_packages_with_pacman "git"

    echo "$output"
    [[ "$status" -eq 0 ]]
    [[ "${output##*$'\n'}" = "Installing git..." ]]
    [[ "$(stub_called_times sudo)" = "2" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git

    stub_called_with_exactly_times logger_info 1 'Package(s) "git" have been installed on your OS.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" but "sed" does not' {
    run install_packages_with_pacman "git" "sed"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "sed is already installed." ]]
    [[ "${outputs[1]}" = "Installing git..." ]]
    [[ "$(stub_called_times sudo)" = "3" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git

    stub_called_with_exactly_times logger_info 1 'Package(s) "git" have been installed on your OS.'
    [[ "$(stub_called_times logger_err)" -eq 0 ]]

    # false
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" "curl" but "sed" does not' {
    run install_packages_with_pacman "git" "sed" "curl"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "sed is already installed." ]]
    [[ "${outputs[1]}" = "Installing git curl..." ]]
    [[ "$(stub_called_times sudo)" -eq 4 ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git curl

    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl" have been installed on your OS.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "vim"' {
    run install_packages_with_pacman "git" "vim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "${outputs[1]}" = "Installing vim..." ]]
    [[ "$(stub_called_times sudo)" = "4" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm vim

    stub_called_with_exactly_times logger_info 1 'Package(s) "git vim" have been installed on your OS.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "gvim"' {
    run install_packages_with_pacman "git" "gvim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "${outputs[1]}" = "Installing gvim..." ]]
    [[ "$(stub_called_times sudo)" = "4" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm gvim

    stub_called_with_exactly_times logger_info 1 'Package(s) "git gvim" have been installed on your OS.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" "curl" then pacman -S with "gvim"' {
    run install_packages_with_pacman "git" "gvim" "curl"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git curl..." ]]
    [[ "${outputs[1]}" = "Installing gvim..." ]]
    [[ "$(stub_called_times sudo)" -eq 5 ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git curl
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm gvim

    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl gvim" have been installed on your OS.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" "curl" then do NOT pacman -S with "gvim" that has already installed' {
    stub_and_eval sudo '{
        if [[ "$1" = "pacman" ]]; then
            if [[ "$2" = "-Q" ]]; then
                if [[ "$3" = "gvim" ]]; then
                    return 0
                fi
            fi
            if [[ "$2" = "-S" ]] && [[ "$3" = "--noconfirm" ]]; then
                return 0
            fi
        fi
        return 1
    }'

    run install_packages_with_pacman "git" "gvim" "curl"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "gvim is already installed." ]]
    [[ "${outputs[1]}" = "Installing git curl..." ]]
    [[ "$(stub_called_times sudo)" = "4" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git curl
    stub_called_with_exactly_times sudo 0 pacman -S --noconfirm gvim

    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl" have been installed on your OS.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "gvim" that has already installed' {
    run install_packages_with_pacman "git" "gvim" "sed"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "sed is already installed." ]]
    [[ "${outputs[1]}" = "Installing git..." ]]
    [[ "${outputs[2]}" = "Installing gvim..." ]]
    [[ "$(stub_called_times sudo)" = "5" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm gvim
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "gvim" then pacman -S with "vim"' {
    run install_packages_with_pacman "git" "gvim" "sed" "vim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "sed is already installed." ]]
    [[ "${outputs[1]}" = "Installing git..." ]]
    [[ "${outputs[2]}" = "Installing gvim..." ]]
    [[ "${outputs[3]}" = "Installing vim..." ]]
    [[ "$(stub_called_times sudo)" = "7" ]]
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm gvim
    stub_called_with_exactly_times sudo 1 pacman -S --noconfirm vim
}

@test '#install_packages_with_pacman should call logger_err when pacman command has failed during installing git' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]]; then
            if [[ "$2" = "-S" ]] && [[ "$3" = "--noconfirm" ]]; then
                return 1
            fi
        fi
        return 1
    }'

    run install_packages_with_pacman "git"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]

    stub_called_with_exactly_times logger_err 1 'Package(s) "git" have not been installed on your OS for some error.\n  Please install these packages manually.'
    [[ "$(sbut_called_times logger_err)" -eq 0 ]]
}

@test '#install_packages_with_pacman should call logger_err when pacman command has failed during installing gvim(may conflict)' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]]; then
            if [[ "$2" = "-S" ]] && [[ "$3" = "--noconfirm" ]]; then
                return 1
            fi
        fi
        return 1
    }'

    run install_packages_with_pacman "gvim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 1 ]]

    [[ "$(sbut_called_times logger_info)" -eq 0 ]]
    stub_called_with_exactly_times logger_err 1 'Package(s) "gvim" have not been installed on your OS for some error.\n  Please install these packages manually.'
}

@test '#install_packages_with_pacman should call logger_err when pacman command has failed during installing git curl vim(success) gvim (vim and gvim may conflict)' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]]; then
            if [[ "$2" = "-S" ]] && [[ "$3" = "--noconfirm" ]]; then
                if [[ "$4" = "vim" ]]; then
                    return 0
                else
                    return 1
                fi
            fi
        fi
        return 1
    }'

    run install_packages_with_pacman git curl vim gvim

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 2 ]]
    [[ "$(sbut_called_times logger_info)" -eq 0 ]]

    stub_called_with_exactly_times logger_info 1 'Package(s) "vim" have been installed on your OS.'
    stub_called_with_exactly_times logger_err 1 'Package(s) "git curl gvim" have not been installed on your OS for some error.\n  Please install these packages manually.'
}

