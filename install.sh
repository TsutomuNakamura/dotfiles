#!/usr/bin/env bash
trap 'echo "SIG INT was received. This program will be terminated." && exit 1' INT

# The directory that dotfiles resources will be installed
DOTDIR=".dotfiles"
# The directory that dotfiles resources will be backuped
BACKUPDIR=".backup_of_dotfiles"
# Git repository location over https
GIT_REPOSITORY_HTTPS="https://github.com/TsutomuNakamura/dotfiles.git"
# Git repository location over ssh
GIT_REPOSITORY_SSH="git@github.com:TsutomuNakamura/dotfiles.git"
# Cache of absolute backup dir
CASH_ABSOLUTE_BACKUPDIR=
# Distribution of this environment
DISTRIBUTION=
# Messages of info
declare -a INFO_MESSAGES=()
# Messages of warn or error
declare -a WARN_MESSAGES=()

function main() {

    is_customized_xdg_base_directories || {
        echo "ERROR: Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments."
        echo "       Current environment variables XDG_CONFIG_HOME and XDG_DATA_HOME is set like below."
        if [[ -z "${XDG_CONFIG_HOME}" ]]; then
            echo "       XDG_CONFIG_HOME=(unset)"
        else
            echo "       XDG_CONFIG_HOME=\"${XDG_CONFIG_HOME}\""
        fi
        echo "           -> This must be set \"\${HOME}/.config\" in Linux or \"\${HOME}/Library/Preferences\" in Mac or unset."
        if [[ -z "${XDG_DATA_HOME}" ]]; then
            echo "       XDG_DATA_HOME=(unset)"
        else
            echo "       XDG_DATA_HOME=\"${XDG_DATA_HOME}\""
        fi
        echo "           -> This must be set \"${HOME}/.local/share\" in Linux or \"${HOME}/Library\" in Mac or unset."
        return 1
    }

    local flag_init=0
    local flag_deploy=0
    local flag_only_install_packages=0
    local flag_no_install_packages=0
    local branch="master"
    local flag_cleanup=0
    local repo="$GIT_REPOSITORY_HTTPS"

    local error_count=0

    while getopts "idonb:cgh" opts; do
        case $opts in
            i)
                flag_init=1;;
            d)
                flag_deploy=1;;
            o)
                flag_only_install_packages=1;;
            n)
                flag_no_install_packages=1;;
            b)
                branch="$OPTARG";;
            c)
                flag_cleanup=1;;
            g)
                repo="$GIT_REPOSITORY_SSH";;
            h | \?)
                usage && return 0 ;;
        esac
    done

    if [ "$flag_only_install_packages" == "1" ] && [ "$flag_no_install_packages" == "1" ]; then
        echo "Some contradictional options were found. (-o|--only-install-packages and -n|--no-install-packages)"
        return 1
    fi

    if [ "$flag_only_install_packages" == "1" ]; then
        if do_i_have_admin_privileges; then
            install_packages || (( error_count++ ))
        else
            echo "Sorry, you don't have privileges to install packages." >&2
            (( error_count++ ))
        fi
    elif [ "$flag_cleanup" == "1" ]; then
        backup_current_dotfiles || {
            echo "ERROR: Cleaning up and backup current dotfiles are failed." >&2
            (( error_count++ ))
        }
    elif [ "$flag_init" == "1" ]; then
        init "$branch" "$flag_no_install_packages" "$repo" || {
            echo "ERROR: init() has failed." >&2
            (( error_count++ ))
        }
    elif [ "$flag_deploy" == "1" ]; then
        deploy
    elif [ "$flag_init" != "1" ] && [ "$flag_deploy" != "1" ]; then
        # It's a default behavior.
        init "$branch" "$flag_no_install_packages" "$repo" || {
            echo "ERROR: init() has failed." >&2
            (( error_count++ ))
        }
        if [[ "$error_count" -eq 0 ]]; then
            deploy || {
                echo "ERROR: deploy() has failed." >&2
                (( error_count++ ))
            }
        fi
    fi

    if [[ "$error_count" -eq 0 ]]; then
        print_a_success_message
    else
        echo "Some error or warning are occured."
        if ! is_warn_messages_empty; then
            print_warn_messages
        fi
    fi
    return $error_count
}

# Push a message into info message list
function push_info_message_list() {
    INFO_MESSAGES+=("$1")
}
# Push a message into warn message list
function push_warn_message_list() {
    WARN_MESSAGES+=("$1")
}

# Print info messages
function print_info_message_list() {
    print_boarder
    _print_message_list 'INFO_MESSAGES[@]'
}

# Print warn messages
function print_warn_message_list() {
    print_boarder
    _print_message_list 'WARN_MESSAGES[@]'
}
# Print boarder on console
function print_boarder() {
    local width=$(( $(tput cols) - 2 ))
    printf '=%.0s' $(seq 1 ${width})
}

# Print messages
function _print_message_list() {
    local msg_list="$1"
    if [[ ! -z "${msg_list}" ]]; then
        for m in "${!msg_list}"; do
            echo -e "* ${m}"
        done
    fi
}

function usage() {
    echo "usage"
}

# Initialize dotfiles repo
function init() {
    local branch=${1:-master}
    local repo=${2:-$GIT_REPOSITORY_HTTPS}
    local flag_no_install_packages=${3:-0}

    local result=0

    if [[ "$flag_no_install_packages" == 0 ]]; then
        if do_i_have_admin_privileges; then
            # Am I root? Or, am I in the sudoers?
            install_packages || {
                echo "ERROR: Failed to install dependency packages."
                local m="ERROR: Failed to install dependency packages."
                m+="\n  If you want to continue following processes that after installing packages, you can specify the option \"-n (no-install-packages)\"."
                m+="\n  ex)"
                m+="\n    curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh | bash -s -- -n"
                push_warn_message_list "$m"
                return 1
            }
        else
            echo "= NOTICE ========================================================"
            echo "You don't have privileges to install packages."
            echo "Process of installing packages will be skipped."
            echo "================================================================="

            local answer
            local read_counter=0
            while true; do
                (( read_counter++ ))
                echo -n "Do you continue to install the dotfiles without dependency packages? [Y/n]: "
                read answer
                if [[ "${answer^^}" =~ ^Y(ES)?$ ]]; then
                    break
                elif [[ "${answer^^}" =~ ^N(O)?$ ]]; then
                    echo "INFO: Installing the dotfiles has been aborted."
                    return 255
                fi
                [[ "$read_counter" -gt 2 ]] && return 255
            done
        fi
    fi

    # Install patched fonts in your home environment
    # Cloe the repository if it's not existed
    init_repo "$branch" "$repo" || {
        echo "ERROR: Failed to initializing repository. Remaining install process will be aborted." >&2
        return 1
    }
    install_fonts || {
        echo "ERROR: Failed to installing fonts. Remaining install process will be aborted." >&2
        return 1
    }
    init_vim_environment || {
        echo "ERROR: Failed to initializing vim environment. Remaining install process will be aborted." >&2
        return 1
    }

    return $result
}

# Install packages
function install_packages() {
    local result=0

    if [[ "$(get_distribution_name)" = "debian" ]]; then
        install_packages_with_apt git vim vim-gtk ctags tmux zsh unzip ranger               || (( result++ ))
    elif [[ "$(get_distribution_name)" = "centos" ]]; then
        # TODO: ranger not supported in centos
        push_info_message_list "INFO: Package \"ranger\" will not be installed, so please instlal it manually."
        install_packages_with_yum git vim gvim ctags tmux zsh unzip gnome-terminal          || (( result++ ))
    elif [[ "$(get_distribution_name)" = "fedora" ]]; then
        install_packages_with_dnf git vim ctags tmux zsh unzip gnome-terminal ranger        || (( result++ ))
    elif [[ "$(get_distribution_name)" = "arch" ]]; then
        install_packages_with_pacman git gvim ctags tmux zsh unzip gnome-terminal ranger    || (( result++ ))
    elif [[ "$(get_distribution_name)" = "mac" ]]; then
        install_packages_with_homebrew vim ctags tmux zsh unzip                             || (( result++ ))
    fi

    return $result
}

# Get the value of XDG_CONFIG_HOME for individual environments appropliately.
function get_xdg_config_home() {
    if [[ -z "${XDG_CONFIG_HOME}" ]]; then
        echo "${HOME}$(get_suffix_xdg_config_home)"
    else
        # Use eval to expand special variable like "~"
        eval echo "${XDG_CONFIG_HOME}"
    fi
}

# Get the value of suffix of XDG_CONFIG_HOME
function get_suffix_xdg_config_home() {
    if [[ "$(get_distribution_name)" = "mac" ]]; then
        echo "/Library/Preferences"
    else
        echo "/.config"
    fi
}

# Get the value of suffix of XDG_DATA_HOME
function get_suffix_xdg_data_home() {
    if [[ "$(get_distribution_name)" = "mac" ]]; then
        echo "/Library"
    else
        echo "/.local/share"
    fi

}

# Get the value of XDG_DATA_HOME for individual environments appropliately.
function get_xdg_data_home() {
    if [[ -z "${XDG_DATA_HOME}" ]]; then
        if [[ "$(get_distribution_name)" = "mac" ]]; then
            echo "${HOME}/Library"
        else
            echo "${HOME}/.local/share"
        fi
    else
        eval echo "${XDG_DATA_HOME}"
    fi
}

function install_the_font() {
    local install_cmd="$1"
    local font_name="$2"
    # Append to front "\n  " if length of variable is greater than 0.
    local extra_msg_on_already_installed="${3:+\n  $3}"
    local extra_msg_on_installed="${4:+\n  $4}"
    local extra_msg_on_failed="${5:+\n  $5}"
    local extra_msg_on_unknown_err="${6:+\n  $6}"

    eval "$install_cmd"
    local ret=$?

    # 0: The font has already installed.
    # 1: Installing the font has successfully.
    # 2: Failed to install the font.
    # *: Unknown error
    case "$ret" in
        0 )
            echo -e "INFO: ${font_name} has already installed.${extra_msg_on_already_installed}"
            ;;
        1 )
            echo -e "INFO: ${font_name} has installed.${extra_msg_on_installed}"
            push_info_message_list "INFO: ${font_name} has installed.${extra_msg_on_installed}"
            ;;
        2 )
            echo -e "ERROR: Failed to install ${font_name}.${extra_msg_on_failed}" >&2
            push_warn_message_list "ERROR: Failed to install ${font_name}.${extra_msg_on_failed}"
            ;;
        * )
            echo -e "ERROR: Unknown error was occured when installing ${font_name}.${extra_msg_on_unknown_err}" >&2
            push_warn_message_list "ERROR: Unknown error was occured when installing ${font_name}.${extra_msg_on_unknown_err}"
            ;;
    esac

    # This function would be finished successfully if return code of install_cmd() is 0(already installed) or 1(install has successfully).
    [[ $ret -le 1 ]]
}

# Installe font
function install_fonts() {
    local result=0
    local distribution_name="$(get_distribution_name)"

    if [[ "$distribution_name" = "mac" ]]; then
        local font_dir="$(get_xdg_data_home)/Fonts"
    else
        local font_dir="$(get_xdg_data_home)/fonts"
    fi

    mkdir -p $font_dir
    pushd $font_dir

    # _install_font_ipafont
    install_the_font "_install_font_inconsolata_nerd" \
            "Inconsolata for Powerline Nerd Font" \
            "" \
            "For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."
    local ret_install_font_inconsolata_nerd=$?
    (( result += $ret_install_font_inconsolata_nerd ))

    install_the_font "_install_font_migu1m" \
            "Migu 1M Font" \
            "" \
            "For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"." \
            "The program will install IPA font alternatively." \
            "The program will install IPA font alternatively."
    local ret_install_font_migu1m=$?
    (( result += $ret_install_font_migu1m ))

    if [[ "$distribution_name" != "mac" ]]; then
        # Installing the emoji font only on Linux because Mac has already supported it.
        install_the_font "_install_font_noto_emoji" \
                "NotoEmojiFont" \
                "" \
                "For more infotmation about the font, please see \"https://github.com/googlei18n/noto-emoji\"." \
                "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary." \
                "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary."
        local ret_install_font_noto_emoji=$?
        (( result += $ret_install_font_noto_emoji ))
    fi

    if [[ $ret_install_font_migu1m -ne 0 ]]; then
        install_the_font "_install_font_ipafont" "IPA Font" "" "" "" ""
        local ret_install_font_ipafont=$?
        (( result += $ret_install_font_ipafont ))
    fi

    popd

    echo "Building font information cache files with \"fc-cache -f ${font_dir}\""
    fc-cache -f $font_dir && push_info_message_list "INFO: Font cache was recreated."

    return $result
}

# Install font Inconsolata Nerd Font Complete
# Return codes are...
#     0: Already installed
#     1: Installed successfully
#     2: Failed to install
function _install_font_inconsolata_nerd() {
    local result=0

    # Inconsolata for Powerline Nerd Font
    if [[ ! -e "Inconsolata Nerd Font Complete.otf" ]] || [[ "$(wc -c < 'Inconsolata Nerd Font Complete.otf')" == "0" ]]; then
        rm -f "Inconsolata Nerd Font Complete.otf"
        curl -fLo "Inconsolata Nerd Font Complete.otf" \
            https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf
        local ret_of_curl=$?

        if [[ "$ret_of_curl" -eq 0 ]] && [[ -e "Inconsolata Nerd Font Complete.otf" ]] && [[ "$(wc -c < 'Inconsolata Nerd Font Complete.otf')" != "0" ]]; then
            # Installing font has succeeded
            result=1
        else
            # Installing font has failed
            rm -f "Inconsolata Nerd Font Complete.otf"
            result=2
        fi
    fi

    # TODO: If you want to install old Powerline Nerd Font, please download it from old tag
    # curl -fLo "Inconsolata for Powerline Nerd Font Complete.otf" \
    #     https://cdn.rawgit.com/ryanoasis/nerd-fonts/v1.0.0/patched-fonts/Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf

    return $result
}

# Install font migu1m (for Japanese)
# Return codes are...
#     0: Already installed
#     1: Installed successfully
#     2: Failed to install
function _install_font_migu1m() {

    # Migu 1M has already been installed?
    if [[ -e "migu-1m-bold.ttf" ]] && [[ "$(wc -c < migu-1m-bold.ttf)" != "0" ]] \
            && [[ -e "migu-1m-regular.ttf" ]] && [[ "$(wc -c < migu-1m-regular.ttf)" != 0 ]]; then
        # Migu M1 has already installed
        return 0
    fi
    # Migu 1M for Japanese font
    curl -fLo "migu-1m-20150712.zip" \
        https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip
    local ret_of_curl=$?

    if [[ "$ret_of_curl" -eq 0 ]] && [[ -e "migu-1m-20150712.zip" ]] && [[ "$(wc -c < migu-1m-20150712.zip)" -ne 0 ]]; then
        unzip migu-1m-20150712.zip
        pushd migu-1m-20150712
        mv ./*.ttf ../
        popd
    else
        # Failed to install
        rm -rf migu-1m-20150712.zip
        return 2
    fi

    if [[ -e "migu-1m-bold.ttf" ]] && [[ "$(wc -c < migu-1m-bold.ttf)" != "0" ]] \
            && [[ -e "migu-1m-regular.ttf" ]] && [[ "$(wc -c < migu-1m-regular.ttf)" != 0 ]]; then
        # Downloading migu1m fonts has been successfully
        rm -rf migu-1m-20150712 migu-1m-20150712.zip
        return 1
    fi

    rm -rf migu-1m-20150712 migu-1m-20150712.zip migu-1m-bold.ttf migu-1m-regular.ttf
    return 2
}

# Install font migu1m (for Japanese)
# Return codes are...
#     0: Already installed (TODO: doesn't implemented now)
#     1: Installed successfully
#     2: Failed to install
function _install_font_ipafont() {
    local result=1

    local ret_of_ipafont=0
    if do_i_have_admin_privileges; then
        if [ "$(get_distribution_name)" == "debian" ]; then
            install_packages_with_apt fonts-ipafont
            ret_of_ipafont=$?
        elif [ "$(get_distribution_name)" == "fedora" ]; then
            install_packages_with_dnf ipa-gothic-fonts ipa-mincho-fonts
            ret_of_ipafont=$?
        elif [ "$(get_distribution_name)" == "arch" ]; then
            install_packages_with_pacman otf-ipafont
            ret_of_ipafont=$?
        elif [ "$(get_distribution_name)" == "mac" ]; then
            true    # TODO:
        fi

        [[ "$ret_of_ipafont" -ne 0 ]] && result=2
    else
        push_warn_message_list "ERROR: Installing IPA font has failed because the user doesn't have a privilege (nearly root) to install the font."
        result=2
    fi

    return $result
}

# Install font noto emoji (for emoji)
# Return codes are...
#     0: Already installed
#     1: Installed successfully
#     2: Failed to install
function _install_font_noto_emoji() {

    if [[ -e "NotoColorEmoji.ttf" ]] && [[ -e "NotoEmoji-Regular.ttf" ]] && \
            [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]] && [[ $(wc -c < "NotoEmoji-Regular.ttf") ]]; then
        # Already installed
        return 0
    fi
    rm -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"

    local ret_of_noto=0
    curl -fLo "NotoColorEmoji.ttf" \
            https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf || (( ret_of_noto++ ))
    curl -fLo "NotoEmoji-Regular.ttf" \
            https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf  || (( ret_of_noto++ ))

    if [[ "$ret_of_noto" -ne 0 ]] || [[ -e "NotoColorEmoji.ttf" ]] || [[ -e "NotoEmoji-Regular.ttf" ]] || \
            [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]] || [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]; then
        rm -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
        return 2
    fi

    return 1
}

# Installing packages with apt
function install_packages_with_apt() {
    declare -a packages=($@)
    declare -a packages_will_be_installed
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local output

    ${prefix} apt-get update || {
        echo "ERROR: Some error has occured when updating packages with apt-get update." >&2
        push_warn_message_list "ERROR: Some error has occured when updating packages with apt-get update."
        return 1
    }

    local pkg_cache=$(apt list --installed 2> /dev/null | grep -v -P 'Listing...' | cut -d '/' -f 1)
    if [[ -z "$pkg_cache" ]]; then
        echo "ERROR: Failed to get installed packages with apt list --installed." >&2
        push_warn_message_list "ERROR: Failed to get installed packages with apt list --installed."
        return 1
    fi

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        local p="${packages[i]}"

        if (grep -P "^${p}$" &> /dev/null <<< "$pkg_cache"); then
            # Remove already installed packages
            echo "INFO: ${p} has already installed. Skipped."
            unset packages[i]
            continue
        fi

        packages_will_be_installed+=("${packages[i]}")
    }

    if [[ "${#packages_will_be_installed[@]}" -eq 0 ]]; then
        echo "INFO: There are no packages to install"
        return 0
    fi

    echo "INFO: Installing ${packages_will_be_installed[@]}..."

    local output="$(${prefix} apt-get install -y ${packages_will_be_installed[@]} 2>&1)" || {
        echo "ERROR: Some error occured when installing ${packages_will_be_installed[i]}" >&2
        echo "${output}" >&2
        push_warn_message_list "ERROR: Some error occured when installing ${packages_will_be_installed[@]}.\n${output}"
        return 1
    }

    # push_info_message_list "INFO: Packages ${packages_will_be_installed[@]} have been installed."

    local installed_packages="${packages_will_be_installed[@]}"
    push_info_message_list "INFO: Packages ${installed_packages} have been installed."

    return 0
}

function install_packages_with_yum() {
    install_packages_on_redhat "yum" $@
}

function install_packages_with_dnf() {
    install_packages_on_redhat "dnf" $@
}

function install_packages_on_redhat() {
    local command="$1" ; shift
    declare -a packages=($@)
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local output
    local flag_deleted=1

    local pkg_cache="$(rpm -qa --queryformat="%{NAME}\n")"

    for ((i = 0; i < ${#packages[@]}; i++)) {
        while read n; do
            if [[ "${packages[i]}" = "$n" ]]; then
                echo "$n is already installed"
                unset packages[i]
                flag_deleted=0
            fi
        done <<< "$pkg_cache"
    }

    packages=("${packages[@]}")

    [[ "${#packages[@]}" -eq 0 ]] && echo "There are no packages to install" && return 0

    echo "Installing ${packages[@]}..."

    ${prefix} ${command} install -y ${packages[@]}
}

function install_packages_with_pacman() {
    declare -a packages=("$@")
    declare -a packages_will_be_installed=()
    declare -a packages_may_conflict=()
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local i
    local result=0
    local installed_packages
    local failed_to_installe_packages

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        if ${prefix} pacman -Q "${packages[i]}"; then
            echo "${packages[i]} is already installed."
        else
            if [[ "${packages[i]}" = "vim" ]] || [[ "${packages[i]}" = "gvim" ]]; then
                packages_may_conflict+=("${packages[i]}")
            else
                packages_will_be_installed+=("${packages[i]}")
            fi
        fi
    }

    if [[ "${#packages_will_be_installed[@]}" -eq 0 ]] && [[ "${#packages_may_conflict[@]}" -eq 0 ]]; then
        echo "There are no packages to install."
    else
        if [[ "${#packages_will_be_installed[@]}" -ne 0 ]]; then
            echo "Installing ${packages_will_be_installed[@]}..."
            ${prefix} pacman -S --noconfirm ${packages_will_be_installed[@]} && {
                installed_packages+="${packages_will_be_installed[@]} "
            }  || {
                failed_to_installe_packages+="${packages_will_be_installed[@]} "
                ((result++))
            }
        fi
        for (( i = 0; i < ${#packages_may_conflict[@]}; i++ )) {
            echo "Installing ${packages_may_conflict[i]}..."
            ${prefix} pacman -S --noconfirm "${packages_may_conflict[i]}" && {
                installed_packages+="${packages_may_conflict[i]} "
            } || {
                failed_to_installe_packages+="${packages_may_conflict[i]} "
                ((result++))
            }
        }
    fi

    [[ ! -z "$installed_packages" ]] && \
            push_info_message_list "NOTICE: Package(s) \"${installed_packages% }\" have been installed on your OS."
    [[ ! -z "$failed_to_installe_packages" ]] && \
            push_warn_message_list "ERROR: Package(s) \"${failed_to_installe_packages% }\" have not been installed on your OS for some error.\n  Please install these packages manually."

    return $result
}

function install_packages_with_homebrew() {
    declare -a packages=($@)
    local output=

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        output="$(sudo brew install ${packages[i]} 2>&1)" || {
            echo "ERROR: Some error occured when installing ${packages[i]}"
            echo "${output}"
        }
    }
}

function should_the_dotfile_be_skipped() {
    local target="$1"

    [[ "$target" = ".git" ]] ||                        \
            [[ "$target" =  ".DS_Store" ]] ||           \
            [[ "$target" =  ".gitignore" ]] ||          \
            [[ "$target" =  ".gitmodules" ]] ||         \
            [[ "$target" =~ \..*.swp ]] ||              \
            [[ "$target" =~ \..*.swo ]] ||              \
            [[ "$target" =  "$DOTDIR" ]] ||             \
            [[ "$target" =  "$BACKUPDIR" ]]
}

# TODO: This dotfiles sunsupported customized XDG directories.
#       XDG_CONFIG_HOME must be "~/.config" in Linux OS and "~/Library/Preferences" in Mac OS.
#       XDG_DATA_HOME must be "~/.local/share" in Linux OS and "~/Library" in Mac OS.
function is_customized_xdg_base_directories() {
    local result=0

    if [[ ! -z "${XDG_CONFIG_HOME}" ]]; then
        if [[ "$(get_distribution_name)" = "mac" ]]; then
            [[ "${XDG_CONFIG_HOME%/}" = "${HOME}/Library/Preferences" ]]    || (( result++ ))
        else
            [[ "${XDG_CONFIG_HOME%/}" = "${HOME}/.config" ]]                || (( result++ ))
        fi
    fi

    if [[ ! -z "${XDG_DATA_HOME}" ]]; then
        if [[ "$(get_distribution_name)" = "mac" ]]; then
            [[ "${XDG_DATA_HOME%/}" = "${HOME}/Library" ]]      || (( result++ ))
        else
            [[ "${XDG_DATA_HOME%/}" = "${HOME}/.local/share" ]] || (( result++ ))
        fi
    fi

    return $result
}

# Check the file whether should not be linked
function files_that_should_not_be_linked() {
    local target="$1"
    [[ "$target" = "LICENSE.txt" ]]
}

function get_target_dotfiles() {
    local dir="$1"
    declare -a dotfiles=()
    pushd ${dir}

    while read f; do
        f=${f#./}
         (should_the_dotfile_be_skipped "$f") || {
             dotfiles+=($f)
         }
    done < <(find . -mindepth 1 -maxdepth 1 -name ".*")

    # Extra target for original command
    [[ -d "./bin" ]] && dotfiles+=("bin")
    [[ -d "./Library" ]] && dotfiles+=("Library")

    popd
    echo ${dotfiles[@]}
}

# Backup current dotfiles
function backup_current_dotfiles() {

    [ ! -d "${HOME}/${DOTDIR}" ] && {
        echo "There are no dotfiles to backup."
        return
    }

    local backup_dir="$(get_backup_dir)"
    declare -a dotfiles=($(get_target_dotfiles "${HOME}/${DOTDIR}"))

    mkdir -p ${backup_dir}
    pushd ${HOME}

    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        [[ -e "${dotfiles[i]}" ]] || continue
        local dir_name=${dotfiles[i]#./}
        dir_name=${dir_name%%/*}
        if (should_it_make_deep_link_directory "$dir_name"); then

            # Backup deeplink
            pushd "${HOME}/${DOTDIR}/${dotfiles[i]}"
            while read target; do
                # Backup only files or symlinks
                target=${target#./}

                local directory=$(dirname "$target")

                echo "mkdir -p \"${backup_dir}/${dir_name}/${directory}\""
                mkdir -p "${backup_dir}/${dir_name}/${directory}"
                [[ -f "${HOME}/${dir_name}/${target}" ]] || [[ -L "${HOME}/${dir_name}/${target}" ]] && {
                    echo "cp -RLp \"${HOME}/${dir_name}/${target}\" \"${backup_dir}/${dir_name}/${directory}\""
                    cp -RLp "${HOME}/${dir_name}/${target}" "${backup_dir}/${dir_name}/${directory}"
                    remove_an_object "${HOME}/${dir_name}/${target}"
                }
            done < <(find . -mindepth 1 \( -type f -or -type l \))
            popd
        else
            echo "cp -RLp \"${dotfiles[i]}\" \"${backup_dir}\""
            cp -RLp "${dotfiles[i]}" "${backup_dir}"
            remove_an_object "${dotfiles[i]}"
        fi
    }

    backup_xdg_base_directory "$backup_dir"

    popd
}

function get_backup_dir() {
    if [[ -z "$CASH_ABSOLUTE_BACKUPDIR" ]]; then
        CASH_ABSOLUTE_BACKUPDIR="${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")"
    fi
    echo "$CASH_ABSOLUTE_BACKUPDIR"
}

function backup_xdg_base_directory() {
    local backup_dir="$1"

    [[ ! -d "$backup_dir" ]] && mkdir -p "$backup_dir"

    backup_xdg_base_directory_individually "XDG_CONFIG_HOME" "$(get_xdg_config_home)" "$(get_backupdir_xdg_config_home)"
    backup_xdg_base_directory_individually "XDG_DATA_HOME" "$(get_xdg_data_home)"     "$(get_backupdir_xdg_data_home)"
}

# Get absolute backup directory path
function get_backupdir_xdg_config_home() {
    echo "$(get_backup_dir)$(get_suffix_xdg_config_home)"
}

function get_backupdir_xdg_data_home() {
    echo "$(get_backup_dir)$(get_suffix_xdg_data_home)"
}

function backup_xdg_base_directory_individually() {
    local xdg_param_name="$1"
    local xdg_dir="$2"
    local backup_dir="$3"
    local target=
    local middle=
    local file=

    pushd "${HOME}/${DOTDIR}"
    while read f; do
        target="${f#./${xdg_param_name}/*}"
        middle=$(dirname "$target")
        file=${target##*/}

        [[ ! -e "$xdg_dir/$middle/$file" ]] && continue
        [[ ! -d "$backup_dir/$middle" ]] && mkdir -p "$backup_dir/$middle"

        echo "cp -RLp $xdg_dir/$middle/$file $backup_dir/$middle/$file"
        cp -RLp "$xdg_dir/$middle/$file" "$backup_dir/$middle/$file"
        remove_an_object "${xdg_dir}/${f#./${xdg_param_name}/*}"
    done < <(find ./${xdg_param_name} -type f)
    popd
}

function remove_an_object() {
    local object=$1

    echo "Removing \"$object\" ..."
    if [ -L "$object" ]; then
        unlink "$object"
    elif [ -d "$object" ]; then
        rm -rf "$object"
    else
        rm -f "$object"
    fi
}

# Deploy dotfiles on user's home directory
function deploy() {

    backup_current_dotfiles

    declare -a dotfiles=($(get_target_dotfiles "${HOME}/${DOTDIR}"))

    pushd ${HOME}
    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        if should_it_make_deep_link_directory "${dotfiles[i]}"; then
            # Link only files in dotdirectory
            declare link_of_destinations=()
            [[ ! -e "${dotfiles[i]}" ]] && mkdir ${dotfiles[i]}
            [[ ! -d "${dotfiles[i]}" ]] && {
                echo "ERROR: ${dotfiles[i]} is already exists and cannot make directory"
                return 1
            }
            pushd ${DOTDIR}/${dotfiles[i]}
            while read f; do
                link_of_destinations+=( "${f#./}" )
            done < <(find . -type f)
            popd

            for (( j = 0; j < ${#link_of_destinations[@]}; j++ )) {
                # Count depth of directory and append "../" in front of the target
                local depth=$(( $(tr -cd / <<< "${dotfiles[i]}/${link_of_destinations[j]}" | wc -c) ))
                local destination="$(printf "../%.0s" $( seq 1 1 ${depth} ))${DOTDIR}/${dotfiles[i]}/${link_of_destinations[j]}"
                mkdir -p "${dotfiles[i]}/$(dirname "${link_of_destinations[j]}")"

                if ! files_that_should_not_be_linked ${link_of_destinations[j]##*/}; then
                    echo "(cd \"${dotfiles[i]}/$(dirname "${link_of_destinations[j]}")\" && ln -s \"${destination}\")"
                    (cd "${dotfiles[i]}/$(dirname "${link_of_destinations[j]}")" && ln -s "${destination}")
                fi
            }
        else
            echo "Creating a symbolic link -> ${DOTDIR}/${dotfiles[i]}"
            ln -s "${DOTDIR}/${dotfiles[i]}"
        fi
    }
    deploy_xdg_base_directory
    deploy_vim_environment

    # FIXME: On Mac, do not ready for fontconfig yet.
    #        For appropriate view, release ambi_width_double settings for vim and 
    #        font "Inconsolata for Powerline Nerd Font Complete.otf" must be set on Mac.
    if [[ "$(get_distribution_name)" == "mac" ]]; then
        touch ~/.vimrc_do_not_use_ambiwidth
    fi

    popd
}

# Deploy resources about xdg_base directories
function deploy_xdg_base_directory() {
    # XDG_CONFIG_HOME must be "~/.config" in Linux OS and "~/Library/Preferences" in Mac OS.
    # XDG_DATA_HOME must be "~/.local/share" in Linux OS and "~/Library" in Mac OS.
    link_xdg_base_directory "XDG_CONFIG_HOME" "$(get_xdg_config_home)"
    link_xdg_base_directory "XDG_DATA_HOME"   "$(get_xdg_data_home)"
}

function link_xdg_base_directory() {
    local xdg_directory="${1#./*}"
    local actual_xdg_directory="${2#./*}"
    local replaced=
    local depth=
    local pushd_target=
    local link_target=


    pushd ${HOME}/${DOTDIR}
    if [[ -d "$xdg_directory" ]]; then
        while read f; do
            f=${f#./*}
            (files_that_should_not_be_linked "${f##*/}") && {
                echo "Creating the link was skipped because of un necessity: $f"
                continue
            }

            replaced="$(sed -e "s|${xdg_directory}|${actual_xdg_directory}|" <<< ${f})"
            replaced="$(sed -e "s|${HOME}|.|" <<< $replaced)"
            # Add -1 since $replaced always starts with "./"
            depth=$(( $(tr -cd / <<< "$replaced" | wc -c) - 1 ))
            pushd_target="$(dirname "${HOME}/${replaced#./*}")"

            # FIXME: Is there a way to change the directory smarter?
            if [[ "$(get_distribution_name)" = "mac" ]]; then
                if [[ "$pushd_target" =~ .*/Library/fonts$ ]]; then
                    pushd_target=$(sed -e "s|/fonts/\?$|/Fonts|" <<< "$pushd_target")
                fi
            fi

            [[ ! -d "$pushd_target" ]] && mkdir -p "$pushd_target"
            pushd "$pushd_target"
            link_target="$(printf "../%.0s" $( seq 1 1 ${depth} ))${DOTDIR}/${f}"
            echo "ln -s \"${link_target}\" from \"$(pwd)\""
            ln -s "${link_target}"
            popd
        done < <(find ./${xdg_directory} -type f)
    fi
    popd
}

function deploy_vim_environment() {
    # Deploy bats.vim
    pushd ${HOME}/${DOTDIR}
    mkdir -p .vim/after/syntax
    mkdir -p .vim/ftdetect
    pushd .vim/after/syntax
    ln -sf ../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim
    popd
    pushd .vim/ftdetect
    ln -sf ../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim
    popd

    # Deploy snipmate-snippets
    mkdir -p .vim/snippets
    pushd .vim/snippets
    ln -sf ../../resources/etc/config/vim/snipmate-snippets.git/snippets/bats.snippets
    ln -sf ../../resources/etc/config/vim/snipmate-snippets.git/snippets/chef.snippets
    popd

    popd
}

function should_it_make_deep_link_directory() {
    local directory="$1"
    pushd ${HOME}/${DOTDIR}

    [[ -d $directory ]] && \
        ( [[ "$directory" = ".config" ]] || [[ "$directory" = "bin" ]] || [[ "$directory" = ".local" ]] )

    local result=$?
    popd

    return $result
}



# Check whether I have admin privileges or not
function do_i_have_admin_privileges() {
    [ "$(whoami)" == "root" ] || ((command -v sudo > /dev/null 2>&1) && (sudo -v 2> /dev/null))
}


# 0:   Just clone as a new repository.
#      Because the directory is not existed.
#
# 1:   Remove the directory then just clone as new repository.
#      Because the directory is existed but it is not git repository.
#
# 2:   Remove the directory then just clone as new repository.
#      Because the directory is existed and it is a git repository but the reference of remote is wrong.
#
# 3:   Remove the directory then just clone as new repository.
#      Because the directory is existed and it is a git repository but commits that should be puhed are remaining.
#
# 4:   Reset the directory hardly then remove untracked files then pull the repository.
#      Because the directory is existed and it is a git repository but files that un committed are existed.
#
# 5:   Just pull as a existing repository.
#      Because the directory is exist and it is a git repository collectly.
#
# 255: Aboarded to isntall or update repository.
#      Because the user declined to update the repository with some reason.
function determin_update_type_of_repository() {
    local directory="$1"
    
}

# Initialize dotfiles repo
function init_repo() {
    local branch="$1"
    local repo="$2"

    mkdir -p "${HOME}/${DOTDIR}"
    [[ -d "${HOME}/${DOTDIR}" ]] || {
        echo "Failed to create the directory ${HOME}/${DOTDIR}."
        return 1
    }

    local target="${HOME}/${DOTDIR}"

    if [[ -d "$target" ]]; then
        if git -C "$target" rev-parse --git-dir > /dev/null 2>&1; then
            
            local remote_url="$(git -C "$target" remote get-url origin)"
            if [[ "$url" = "$GIT_REPOSITORY_SSH" ]] || [[ "$url" = "$GIT_REPOSITORY_HTTPS" ]]; then

                # is_there_updates: 0 -> Updates are existed, 1: Updates are not existed
                local is_there_updates="$([[ "$(git -C "$target" status --porcelain | wc -l)" -ne 0 ]] && echo 0 || echo 1)"
                # is_there_pushes: 0 -> Files should be pushed are existed, 1: Files should be pushed are not existed
                local is_there_pushes="$([[ "$(git -C "$target" cherry -v | wc -l)" -ne 0 ]] && echo 0 || echo 1)"

                if [[ "$is_there_pushes" -eq 0 ]]; then
                    # TODO: Question then reinstall
                else
                    if [[ "$is_there_updates" -eq 0 ]]; then
                        # TODO: Question then "git reset --hard" and remove untrackedfiles then update
                    else
                        # TODO: Update!!
                    fi
                fi
            else
                # Remote url is not match of dotfiles.
                # question then reinstall
                true        # TODO:
            fi
        else
            # It is not a git repository.
            # question then reinstall
            true        # TODO:
        fi
    else
        # reinstall
        true        # TODO:
    fi

    # Is here the git repo?
    declare -A stats_of_dir=$(get_git_directory_status "${HOME}/${DOTDIR}")

    # if is_here_the_git_repo; then
    #     echo "The repository ${repo} is already existed. Pulling from \"origin $branch\""

    #     # TODO:
    #     if [[ "$(git status --porcelain | grep -v -P '^\?\?.*' | wc -l)" -ne 0 ]]; then
    #         
    #     fi


    #     git pull origin $branch
    # else

    #     local files=$(shopt -s nullglob dotglob; echo ${HOME}/${DOTDIR}/*)
    #     if (( ${#files} )); then
    #         # Contains some files
    #         echo "Couldn't clone the dotfiles repository because of the directory ${HOME}/${DOTDIR}/ is not empty"
    #         return 1
    #     fi

    #     echo "The repository is not existed. Cloning branch from ${repo} then checkout branch ${branch}"
    #     git clone -b $branch $repo .
    # fi

    # Freeze .gitconfig for not to push username and email
    [ -f .gitconfig ] && git update-index --assume-unchanged .gitconfig

    echo "Updating submodules..."
    git submodule init
    git submodule update

    popd
}

# Initialize vim environment
function init_vim_environment() {

    pushd ${HOME}/${DOTDIR}

    # Install pathogen.vim
    mkdir -p ./.vim/autoload
    echo "curl -LSso ./.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim"
    curl -LSso ./.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # update vim's submodules
    # Link color theme
    mkdir -p .vim/colors/
    pushd .vim/colors
    ln -sf ../../resources/etc/config/vim/colors/molokai.vim

    popd
    popd
}

# Get your OS distribution name
function get_distribution_name() {
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    # Is Mac OS?
    if [ "$(uname)" == "Darwin" ] || (command -v brew > /dev/null 2>&1); then
        DISTRIBUTION="mac"
    fi
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    local release_info="$(cat /etc/*-release 2> /dev/null)"

    # Check the distribution from release-infos
    if (grep -i centos <<< "$release_info" > /dev/null 2>&1); then
        DISTRIBUTION="centos"
    elif (grep -i fedora <<< "$release_info" > /dev/null 2>&1); then
        DISTRIBUTION="fedora"
    elif (grep -i ubuntu <<< "$release_info" > /dev/null 2>&1) || \
            (grep -i debian <<< "$release_info" > /dev/null 2>&1); then
        # Like debian
        DISTRIBUTION="debian"
    elif (grep -i "arch linux" <<< "$release_info" > /dev/null 2>&1); then
        DISTRIBUTION="arch"
    fi
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    # Check the distribution from command for package management
    if (command -v apt-get > /dev/null 2>&1); then
        DISTRIBUTION="debian"
    elif (command -v dnf > /dev/null 2>&1); then
        DISTRIBUTION="fedora"
    elif (command -v yum > /dev/null 2>&1); then
        DISTRIBUTION="centos"
    elif (command -v pacman > /dev/null 2>&1); then
        DISTRIBUTION="arch"
    fi
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    # Check the distribution from /proc/version file
    local proc_version="$(cat /proc/version)"

    if (grep -i arch <<< "$proc_version" > /dev/null 2>&1); then
        DISTRIBUTION="arch"
        # TODO: Check for fedora, debian, ubuntu etc...
    fi
    [[ ! -z ${DISTRIBUTION} ]] && echo "${DISTRIBUTION}" && return

    echo "unknown"
}

# Check current directory is whether git repo or not.
# The function outputs the string of assosiative array.
# To get outputs, you should write like below
#   declare -A result="$(is_here_git_repo "/path/to/may/be/gitrepo")"
# Result of 0 is true and the others is false.
# List of status are like below.
#   directory <int>:                 0 is true (there is the directory) otherwise false
#   git_directory <int>:             0 is true (it is a git repository) otherwise false
#   dotfiles_remote <int>:           0 is true (the repo refers $GIT_REPOSITORY_HTTPS or $GIT_REPOSITORY_SSH) otherwise false
#   files_should_be_committed <int>: 0 is true (there are files should be committed or handled) otherwise false
#   changes_should_be_pusshed <int>: 0 is true (there are changes should be pushed) otherwise false
#   remote_is_origin <int>:          0 is true (remote is origin). Currentry this script only support remote origin
#   branch_name <string>:            branch name on HEAD
function get_git_directory_status() {
    local target="$1"

    declare -A result=(
        [existence_of_directory]=1
        [existence_of_git_repository]=1
        [correctness_of_dotfiles_remote]=1
        [absence_of_files_should_be_committed]=1
        [absence_of_changes_should_be_pushed]=1
        [branch_name]=""
    )

    if [[ -d "$target" ]]; then
        result[existence_of_directory]=0
        if git rev-parse --git-dir > /dev/null 2>&1; then
            result[existence_of_git_repository]=0

            local url="$(git remote get-url origin)"
            if [[ "$url" = "$GIT_REPOSITORY_SSH" ]] || [[ "$url" = "$GIT_REPOSITORY_HTTPS" ]]; then
                # It is the dotfiles repository
                result[correctness_of_dotfiles_remote]=0

                [[ "$(git status --porcelain | wc -l)" -eq 0 ]] && result[absence_of_files_should_be_committed]=0
                [[ "$(git cherry -v | wc -l)" -eq 0 ]]          && result[absence_of_changes_should_be_pushed]=0
                result[branch_name]="$(git rev-parse --abbrev-ref HEAD)"
            fi
        fi
    fi

    declare -p result
}

# Question to user.
# Return codes are...
#   0:   The user answerd yes
#   1:   The user answerd no
#   255: Failed to get the answers due to the user did not answer within max_times.
function question() {
    local message="$1"
    local max_times="${2:-3}"
    local count=0
    local answer

    while [[ "$count" -lt "$max_times" ]]; do
        ((count++))
        echo -n "$message"
        read answer
        if [[ "${answer^^}" =~ ^Y(ES)?$ ]]; then
            # The user answers yes
            return 0
        elif [[ "${answer^^}" =~ ^N(O)?$ ]]; then
            # The user answers no
            return 1
        fi
    done

    return 255
}

function pushd() {
    command pushd "$@" > /dev/null
}

function popd() {
    command popd "$@" > /dev/null
}

if [[ "$1" != "--load-functions" ]]; then
    # Call this script as ". ./script --load-functions" if you want to load functions only
    #set -eu
    main "$@"
fi

