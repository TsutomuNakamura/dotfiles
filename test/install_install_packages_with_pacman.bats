#!/usr/bin/env bats
load helpers

function setup() {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "sed" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "ranger" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Sy" ]] && [[ "$3" = "--noconfirm" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]] ; then
            echo "extra/gvim 8.1.0374-1"
            echo "    Vi Improved, a highly configurable, improved version of the vi text editor (with advanced features, such as a GUI)"
            echo "extra/vim 8.1.0374-1"
            echo "    Vi Improved, a highly configurable, improved version of the vi text editor"
            echo "core/sed 4.5-1 (base base-devel)"
            echo "    GNU stream editor"
            echo "extra/git 2.19.0-1"
            echo "    the fast distributed version control system"
            echo "core/curl 7.61.1-3"
            echo "    An URL retrieval utility and library"
            return 0
        fi
        return 1
    }'

    function command() { return 0; }
    stub logger_info
    stub logger_warn
    stub logger_err
}
# function teardown() {}

@test '#install_packages_with_pacman should be failed if the command to get all available list "pacman -Ss" was failed' {
    stub_and_eval sudo '{
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]] ; then
            return 1
        fi
        return 0
    }'

    run install_packages_with_pacman "sed"

    #declare -a outputs; IFS=$'\n' outputs=($output)
    [[ $status                          -eq 1 ]]
    [[ $(stub_called_times sudo)        -eq 1 ]]
    [[ $(stub_called_times logger_info) -eq 0 ]]
    [[ $(stub_called_times logger_warn) -eq 0 ]]
    [[ $(stub_called_times logger_err)  -eq 1 ]]

    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times logger_err 1 "Failed to get available packages with \"pacman -Ss\""
}

@test '#install_packages_with_pacman should be return 0 if a package is not exist on repo and there are no packages to install' {
    run install_packages_with_pacman "seeeeeeeeeed"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "There are no packages to install." ]]
    [[ $status                          -eq 0 ]]
    [[ $(stub_called_times sudo)        -eq 1 ]]
    [[ $(stub_called_times logger_info) -eq 0 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    [[ $(stub_called_times logger_err)  -eq 0 ]]

    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times logger_warn 1 "Packages seeeeeeeeeed were unavailable. Skipped installing them."
}

@test '#install_packages_with_pacman should be call logger_warn and skip to install some unavailable packages if they were specified' {
    run install_packages_with_pacman "seeeeeeeeeed" "viiiiiiiiiim"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "There are no packages to install." ]]
    [[ $status                          -eq 0 ]]
    [[ $(stub_called_times sudo)        -eq 1 ]]
    [[ $(stub_called_times logger_info) -eq 0 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    [[ $(stub_called_times logger_err)  -eq 0 ]]

    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times logger_warn 1 "Packages seeeeeeeeeed viiiiiiiiiim were unavailable. Skipped installing them."
}

@test '#install_packages_with_pacman should be call logger_info and skip to install one already installed package if it was specified' {
    run install_packages_with_pacman "sed"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "There are no packages to install." ]]
    [[ $status                          -eq 0 ]]
    [[ $(stub_called_times sudo)        -eq 2 ]]
    [[ $(stub_called_times logger_info) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 0 ]]
    [[ $(stub_called_times logger_err)  -eq 0 ]]

    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times logger_info 1 "Packages sed were already installed. Skipped installing them."
}

@test '#install_packages_with_pacman should be call logger_info and skip to install some already installed packages if they were specified' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "sed" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "ranger" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]] ; then
            echo "core/sed 4.5-1 (base base-devel)"
            echo "    GNU stream editor"
            echo "community/ranger 1.9.1-3"
            echo "    A simple, vim-like file manager"
            return 0
        fi
        return 1
    }'

    run install_packages_with_pacman "sed" "ranger"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "There are no packages to install." ]]
    [[ $status                          -eq 0 ]]
    [[ $(stub_called_times sudo)        -eq 3 ]]
    [[ $(stub_called_times logger_info) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 0 ]]
    [[ $(stub_called_times logger_err)  -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times sudo 1 pacman -Q ranger
    stub_called_with_exactly_times logger_info 1 "Packages sed ranger were already installed. Skipped installing them."
}

@test '#install_packages_with_pacman should be call logger_info and logger_warn if some already installed packages and some unavailable packages were specified' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "sed" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "ranger" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]] ; then
            echo "core/sed 4.5-1 (base base-devel)"
            echo "    GNU stream editor"
            echo "community/ranger 1.9.1-3"
            echo "    A simple, vim-like file manager"
            return 0
        fi
        return 1
    }'

    run install_packages_with_pacman "sed" "ranger" "seeeeed" "rrrrranger"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "There are no packages to install." ]]
    [[ $status                          -eq 0 ]]
    [[ $(stub_called_times sudo)        -eq 3 ]]
    [[ $(stub_called_times logger_info) -eq 1 ]]
    [[ $(stub_called_times logger_warn) -eq 1 ]]
    [[ $(stub_called_times logger_err)  -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times sudo 1 pacman -Q ranger
    stub_called_with_exactly_times logger_info 1 "Packages sed ranger were already installed. Skipped installing them."
    stub_called_with_exactly_times logger_warn 1 "Packages seeeeed rrrrranger were unavailable. Skipped installing them."
}

@test '#install_packages_with_pacman should call pacman with parameter "git" when it was not installed' {
    run install_packages_with_pacman "git"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" == "Installing git..." ]]
    [[ "$status"                            -eq 0 ]]
    [[ $(stub_called_times sudo)            -eq 3 ]]
    [[ $(stub_called_times logger_info)     -eq 1 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git

    stub_called_with_exactly_times logger_info 1 'Package(s) "git" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" but "sed" does not' {
    run install_packages_with_pacman "git" "sed"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times sudo)            -eq 4 ]]
    [[ $(stub_called_times logger_info)     -eq 2 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git
    stub_called_with_exactly_times logger_info 1 'Packages sed were already installed. Skipped installing them.'
    stub_called_with_exactly_times logger_info 1 'Package(s) "git" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" "curl" but "sed" does not' {
    run install_packages_with_pacman "git" "sed" "curl"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git curl..." ]]
    [[ $(stub_called_times sudo)            -eq 5 ]]
    [[ $(stub_called_times logger_info)     -eq 2 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times sudo 1 pacman -Q curl
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git curl

    stub_called_with_exactly_times logger_info 1 'Packages sed were already installed. Skipped installing them.'
    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "vim"' {
    run install_packages_with_pacman "git" "vim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "${outputs[1]}" = "Installing vim..." ]]
    [[ $(stub_called_times sudo) -eq 5 ]]
    [[ $(stub_called_times logger_info)     -eq 1 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q vim
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm vim
    stub_called_with_exactly_times logger_info 1 'Package(s) "git vim" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "gvim"' {
    run install_packages_with_pacman "git" "gvim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "${outputs[1]}" = "Installing gvim..." ]]
    [[ $(stub_called_times sudo) -eq 5 ]]
    [[ $(stub_called_times logger_info)     -eq 1 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim

    stub_called_with_exactly_times logger_info 1 'Package(s) "git gvim" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" "curl" then pacman -S with "gvim"' {
    run install_packages_with_pacman "git" "gvim" "curl"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git curl..." ]]
    [[ "${outputs[1]}" = "Installing gvim..." ]]
    [[ $(stub_called_times sudo)            -eq 6 ]]
    [[ $(stub_called_times logger_info)     -eq 1 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Q curl
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git curl
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim
    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl gvim" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" "curl" then do NOT pacman -S with "gvim" that has already installed' {
    run install_packages_with_pacman "git" "gvim" "curl"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git curl..." ]]
    [[ $(stub_called_times sudo)            -eq 6 ]]
    [[ $(stub_called_times logger_info)     -eq 1 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Q curl
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git curl
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim
    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl gvim" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "gvim" that has already installed' {
    run install_packages_with_pacman "git" "gvim" "sed"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "${outputs[1]}" = "Installing gvim..." ]]
    [[ $(stub_called_times sudo)            -eq 6 ]]
    [[ $(stub_called_times logger_info)     -eq 2 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]

    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim
    stub_called_with_exactly_times logger_info 1 'Packages sed were already installed. Skipped installing them.'
    stub_called_with_exactly_times logger_info 1 'Package(s) "git gvim" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call pacman -S with parameter "git" then pacman -S with "gvim" then pacman -S with "vim"' {
    run install_packages_with_pacman "git" "gvim" "sed" "vim"

    declare -a outputs; IFS=$'\n' outputs=($output)

    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ "${outputs[1]}" = "Installing gvim..." ]]
    [[ "${outputs[2]}" = "Installing vim..." ]]
    [[ $(stub_called_times sudo) -eq 8 ]]
    [[ $(stub_called_times logger_info)     -eq 2 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 0 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Q vim
    stub_called_with_exactly_times sudo 1 pacman -Q sed
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm vim
    stub_called_with_exactly_times logger_info 1 'Packages sed were already installed. Skipped installing them.'
    stub_called_with_exactly_times logger_info 1 'Package(s) "git gvim vim" have been installed on your OS.'
}

@test '#install_packages_with_pacman should call logger_err when pacman command has failed during installing git' {
    stub_and_eval sudo '{
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-Sy" ]] && [[ "$3" = "--noconfirm" ]]; then
            return 1
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Q" ]] && [[ "$3" = "git" ]]; then
            return 1
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]] ; then
            echo "extra/git 2.19.0-1"
            echo "    the fast distributed version control system"
            return 0
        fi
        return 0
    }'

    run install_packages_with_pacman "git"

    echo "$output"
    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Installing git..." ]]
    [[ $(stub_called_times sudo) -eq 3 ]]
    [[ $(stub_called_times logger_info)     -eq 0 ]]
    [[ $(stub_called_times logger_warn)     -eq 0 ]]
    [[ $(stub_called_times logger_err)      -eq 1 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git
    stub_called_with_exactly_times logger_err 1 'Package(s) "git" have not been installed on your OS due to some error.\n  Please install these packages manually.'
}

@test '#install_packages_with_pacman should call logger_err when pacman command has failed during installing gvim(may conflict)' {
    stub_and_eval sudo '{
        # echo "\"$1\", \"$2\", \"$3\""
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-S" ]] && [[ "$3" = "--noconfirm" ]]; then
            return 1
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]]; then
            echo "extra/gvim 8.1.0374-1"
            echo "    Vi Improved, a highly configurable, improved version of the vi text editor (with advanced features, such as a GUI)"
            return 0
        fi
        return 1
    }'

    run install_packages_with_pacman "gvim"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Installing gvim..." ]]
    [[ $(stub_called_times sudo) -eq 3 ]]
    [[ $(stub_called_times logger_info)     -eq 0 ]]
    [[ $(stub_called_times logger_warn)     -eq 1 ]]
    [[ $(stub_called_times logger_err)      -eq 1 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim
    stub_called_with_exactly_times logger_warn 1 'Failed to install gvim. It might has been conflict with vim. I recommend to use gvim rather than vim, because of some useful options. Remaining processes will be continued.'
    stub_called_with_exactly_times logger_err 1 'Package(s) "gvim" have not been installed on your OS due to some error.\n  Please install these packages manually.'
}

@test '#install_packages_with_pacman should call logger_err when pacman command has failed during installing git curl vim(success) gvim (vim and gvim may conflict)' {
    stub_and_eval sudo '{
        if [[ "$1" = "pacman" ]] && [[ "$2" = "-Sy" ]] && [[ "$3" = "--noconfirm" ]] && [[ "$4" = "gvim" ]]; then
            return 1
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Sy" ]] && [[ "$3" = "--noconfirm" ]]; then
            return 0
        elif [[ "$1" = "pacman" ]] && [[ "$2" = "-Ss" ]]; then
            echo "extra/gvim 8.1.0374-1"
            echo "    Vi Improved, a highly configurable, improved version of the vi text editor (with advanced features, such as a GUI)"
            echo "extra/vim 8.1.0374-1"
            echo "    Vi Improved, a highly configurable, improved version of the vi text editor"
            echo "extra/git 2.19.0-1"
            echo "    the fast distributed version control system"
            echo "core/curl 7.61.1-3"
            echo "    An URL retrieval utility and library"
            return 0
        fi
        return 1
    }'
    run install_packages_with_pacman git curl vim gvim

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times sudo) -eq 8 ]]
    [[ $(stub_called_times logger_info)     -eq 1 ]]
    [[ $(stub_called_times logger_warn)     -eq 1 ]]
    [[ $(stub_called_times logger_err)      -eq 1 ]]
    stub_called_with_exactly_times sudo 1 pacman -Ss
    stub_called_with_exactly_times sudo 1 pacman -Q git
    stub_called_with_exactly_times sudo 1 pacman -Q curl
    stub_called_with_exactly_times sudo 1 pacman -Q vim
    stub_called_with_exactly_times sudo 1 pacman -Q gvim
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm git curl
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm vim
    stub_called_with_exactly_times sudo 1 pacman -Sy --noconfirm gvim
    stub_called_with_exactly_times logger_info 1 'Package(s) "git curl vim" have been installed on your OS.'
    stub_called_with_exactly_times logger_warn 1 'Failed to install gvim. It might has been conflict with vim. I recommend to use gvim rather than vim, because of some useful options. Remaining processes will be continued.'
    stub_called_with_exactly_times logger_err 1 'Package(s) "gvim" have not been installed on your OS due to some error.\n  Please install these packages manually.'
}

