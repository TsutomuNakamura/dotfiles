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

# Answer status for question() yes
ANSWER_OF_QUESTION_YES=0
# Answer status for question() no
ANSWER_OF_QUESTION_NO=1
# Answer status for question() aborted
ANSWER_OF_QUESTION_ABORTED=255

# Types of git re-install(re-clone or update) type.
# These variables will be used determin_update_type_of_repository()

# Git update type: just clone
GIT_UPDATE_TYPE_JUST_CLONE=0
# Git update type: remote then clone due to not git repository
GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY=1
# Git update type: remove then clone due to wrong remote
GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE=2
# Git update type: remove then clone due do un pushed yet
GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET=3
# Git update type: reset then remove untracked files then pull
GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL=4
# Git update type: just pull
GIT_UPDATE_TYPE_JUST_PULL=5
# Git update type: remove then clone due to the branch name that going to be installed is different from current branch name
GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT=6
# Git update type: can not get git-update-type due to some reason
GIT_UPDATE_TYPE_ABOARTED=255

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
    local url_of_repo="$GIT_REPOSITORY_HTTPS"

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
                url_of_repo="$GIT_REPOSITORY_SSH";;
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
        init "$branch" "$url_of_repo" "$flag_no_install_packages" || {
            echo "ERROR: init() has failed." >&2
            (( error_count++ ))
        }
    elif [ "$flag_deploy" == "1" ]; then
        deploy
    elif [ "$flag_init" != "1" ] && [ "$flag_deploy" != "1" ]; then
        # It's a default behavior.
        init "$branch" "$url_of_repo" "$flag_no_install_packages" || {
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

    [[ "${#INFO_MESSAGES[@]}" -ne 0 ]] && print_info_message_list
    [[ "${#WARN_MESSAGES[@]}" -ne 0 ]] && print_warn_message_list

    return $error_count
}

# Output the message to stdout then push it to info message list.
function logger_info() {
    local message="$1"
    echo -e "$message"
    push_info_message_list "$message"
}

# Output the message to errout then push it to warn message list.
function logger_warn() {
    local message="$1"
    echo -e "$message" >&2
    push_warn_message_list "$message"
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
    echo
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
    local url_of_repo=${2:-$GIT_REPOSITORY_HTTPS}
    local flag_no_install_packages=${3:-0}

    local result=0
    local answer_of_question

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

            question "Do you continue to install the dotfiles without dependency packages? [Y/n]: "
            answer_of_question=$?
            if [[ "$answer_of_question" -eq "$ANSWER_OF_QUESTION_NO" ]] || \
                    [[ "$answer_of_question" -eq "$ANSWER_OF_QUESTION_ABORTED" ]]; then
                return 255
            fi
        fi
    fi

    # Install patched fonts in your home environment
    # Cloe the repository if it's not existed
    init_repo "$url_of_repo" "$branch" || {
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
    return $ret
}

# Installe font
function install_fonts() {
    local result=0
    local distribution_name="$(get_distribution_name)"
    local flag_fc_cache=0

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
    [[ $ret_install_font_inconsolata_nerd -eq 1 ]] && (( flag_fc_cache++ ))
    [[ $ret_install_font_inconsolata_nerd -gt 1 ]] && (( result++ ))

    install_the_font "_install_font_migu1m" \
            "Migu 1M Font" \
            "" \
            "For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"." \
            "The program will install IPA font alternatively." \
            "The program will install IPA font alternatively."
    local ret_install_font_migu1m=$?
    [[ $ret_install_font_migu1m -eq 1 ]] && (( flag_fc_cache++ ))
    [[ $ret_install_font_migu1m -gt 1 ]] && (( result++ ))

    if [[ "$distribution_name" != "mac" ]]; then
        # Installing the emoji font only on Linux because Mac has already supported it.
        install_the_font "_install_font_noto_emoji" \
                "NotoEmojiFont" \
                "" \
                "For more infotmation about the font, please see \"https://github.com/googlei18n/noto-emoji\"." \
                "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary." \
                "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary."
        local ret_install_font_noto_emoji=$?
        [[ $ret_install_font_noto_emoji -eq 1 ]] && (( flag_fc_cache++ ))
        [[ $ret_install_font_noto_emoji -gt 1 ]] && (( result++ ))
    fi

    if [[ $ret_install_font_migu1m -gt 1 ]]; then
        install_the_font "_install_font_ipafont" "IPA Font" "" "" "" ""
        local ret_install_font_ipafont=$?
        [[ $ret_install_font_ipafont -eq 1 ]] && (( flag_fc_cache++ ))
        [[ $ret_install_font_ipafont -gt 1 ]] && (( result++ )) || (( result-- ))
    fi

    popd

    if [[ "$flag_fc_cache" -ne 0 ]]; then
        echo "Building font information cache files with \"fc-cache -f ${font_dir}\""
        fc-cache -f $font_dir && push_info_message_list "INFO: Font cache was recreated."
    fi

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
            [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]] && [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]; then
        # Already installed
        return 0
    fi
    rm -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    local ret=0

    curl -fLo "NotoColorEmoji.ttf" \
            https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf || {
        push_warn_message_list "ERROR: Failed to install NotoColorEmoji.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf)"
        (( ret++ ))
    }
    curl -fLo "NotoEmoji-Regular.ttf" \
            https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf || {
        push_warn_message_list "ERROR: Failed to install NotoEmoji-Regular.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf)"
        (( ret++ ))
    }

    if [[ "$ret" -eq 0 ]] && \
            [[ -e "NotoColorEmoji.ttf" ]] && [[ -e "NotoEmoji-Regular.ttf" ]] && \
            [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]] && [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]; then
        # Success
        return 1
    fi

    rm -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    return 2
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

    [[ "$target" = ".git" ]] ||                         \
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

# @param target:
#      Target of git repository
# @param remote:
#      Target of remote for example origin
# @param need_question:
#      Necessity of question for user if some instructions that is destroying files is needed for update
#
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
# 255: Aboarted to isntall or update repository.
#      Because the user declined to update the repository with some reason.
function determin_update_type_of_repository() {
    local target="$1"
    local remote="$2"
    local url="$3"
    local branch="$4"
    local need_question="$5"

    local msg
    local ret

    if [[ -d "$target" ]]; then

        # Is the directory empty? If so, return GIT_UPDATE_TYPE_JUST_CLONE
        [[ -z "$(ls -A "$target")" ]] && return $GIT_UPDATE_TYPE_JUST_CLONE

        if git -C "$target" rev-parse --git-dir > /dev/null 2>&1; then

            local remote_url="$(git -C "$target" remote get-url "$remote" 2> /dev/null)"

            if [[ "$remote_url" == "$url" ]]; then
                local current_branch="$(git -C "$target" rev-parse --abbrev-ref HEAD 2> /dev/null)"

                if [[ "$current_branch" != "$branch" ]]; then
                    if [[ "$need_question" -eq 0 ]]; then
                        msg="The local branch(${current_branch}) in repository that located in \"${target}\" is differ from the branch(${branch}) that going to be updated."
                        msg+="\nDo you want to remove the git repository and reclone it newly? [y/N]: "
                        question "$msg"
                        ret=$?
                        [[ "$ret" -ne 0 ]] && echo "Recloning \"${target}\" was aborted." && return $GIT_UPDATE_TYPE_ABOARTED
                    fi
                    return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT
                fi

                # is_there_updates: 0 -> Updates are existed, 1: Updates are not existed
                local is_there_updates="$([[ "$(git -C "$target" status --porcelain 2> /dev/null | wc -l)" -ne 0 ]] && echo 0 || echo 1)"
                # is_there_pushes: 0 -> Files should be pushed are existed, 1: Files should be pushed are not existed
                local is_there_pushes="$([[ "$(git -C "$target" cherry -v 2> /dev/null | wc -l)" -ne 0 ]] && echo 0 || echo 1)"

                if [[ "$is_there_pushes" -eq 0 ]]; then
                    # Question then reinstall
                    if [[ "$need_question" -eq 0 ]]; then
                        question "The git repository located in \"${target}\" has some unpushed commits.\nDo you want to remove the git repository and reclone it newly? [y/N]: "
                        ret=$?
                        [[ "$ret" -ne 0 ]] && echo "Recloning \"${target}\" was aborted." && return $GIT_UPDATE_TYPE_ABOARTED
                    fi
                    return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET
                else
                    # Question then "git reset --hard" and remove untrackedfiles then update
                    if [[ "$is_there_updates" -eq 0 ]]; then
                        if [[ "$need_question" -eq 0 ]]; then
                            question "The git repository located in \"${target}\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: "
                            local ret=$?
                            [[ "$ret" -ne 0 ]] && echo "Updating git repository \"${target}\" was aborted." && return $GIT_UPDATE_TYPE_ABOARTED
                        fi
                        return $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL
                    else
                        # Update!!
                        return $GIT_UPDATE_TYPE_JUST_PULL
                    fi
                fi
            else
                # Question then reinstall if the remote url is not match.
                if [[ "$need_question" -eq 0 ]]; then
                    question "The git repository located in \"${target}\" is refering unexpected remote \"${remote_url}\" (expected is \"${url}\").\nDo you want to remove the git repository and reclone it newly? [y/N]: "
                    local ret=$?
                    [[ "$ret" -ne 0 ]] && echo "Recloning \"${target}\" was aborted." && return $GIT_UPDATE_TYPE_ABOARTED
                fi
                return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE
            fi
        else
            # Question then reinstall if it is not a git repository.
            if [[ "$need_question" -eq 0 ]]; then
                question "The directory (or file) \"${target}\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
                local ret=$?
                [[ "$ret" -ne 0 ]] && echo "Cloning the repository \"${target}\" was aborted." && return $GIT_UPDATE_TYPE_ABOARTED
            fi
            return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY
        fi
    fi

    return $GIT_UPDATE_TYPE_JUST_CLONE
}

# Get git remote alias.
# For instance, origin.
function get_git_remote_aliases() {
    local directory="$1"
    local name_of_result_array="$2"

    eval "declare -a \"${name_of_result_array}\""
    local e
    while read e; do
        eval "${name_of_result_array}+=(\"${e}\")"
    done < <(git -C "$directory" remote 2> /dev/null)
    eval "declare -p \"${name_of_result_array}\""
}

# Initialize dotfiles repo
function init_repo() {
    local url_of_repo="$1"
    local branch="$2"

    local homedir_of_repo="${HOME%/}"
    local dirname_of_repo="${DOTDIR%/}"

    pushd "$homedir_of_repo"

    # mkdir -p "${homedir_of_repo}/${dirname_of_repo}"
    # [[ -d "${homedir_of_repo}/${dirname_of_repo}" ]] || {
    #     echo "ERROR: Failed to create the directory ${homedir_of_repo}/${dirname_of_repo}." >&2
    #     push_warn_message_list "ERROR: Failed to create the directory ${homedir_of_repo}/${dirname_of_repo}."
    #     return 1
    # }

    update_git_repo "$homedir_of_repo" "$dirname_of_repo" "$url_of_repo" "$branch" || {
        echo "init_repo() was aborted" >&2
        return 1
    }
    local path_to_git_repo="${homedir_of_repo}/${dirname_of_repo}"

    # Is here the git repo?
    declare -A stats_of_dir=$(get_git_directory_status "$path_to_git_repo")

    # Freeze .gitconfig for not to push username and email
    [[ -f .gitconfig ]] && git -C "$path_to_git_repo" update-index --assume-unchanged .gitconfig

    echo "Updating submodules..."
    git -C "$path_to_git_repo" submodule init
    git -C "$path_to_git_repo" submodule update

    popd
}

# Update dotfile's git repository
function update_git_repo() {
    local homedir_of_repo="${1%/}"
    local dirname_of_repo="${2%/}"
    local url_of_repo="$3"
    local branch="$4"

    [[ -z "$dirname_of_repo" ]] && {
        # Fetch end of the url and remove its suffix ".git"
        dirname_of_repo="$(basename "$url_of_repo")"
        dirname_of_repo=${dirname_of_repo%.git}
    }

    [[ ! -d "$homedir_of_repo" ]] && {
        mkdir -p "$homedir_of_repo" || {
            logger_warn "ERROR: Failed to create the directory \"${homedir_of_repo}\""
            return 1
        }
    }

    # Create the directory path string of git
    local path_to_git_repo="${homedir_of_repo}/${dirname_of_repo}"
    # Declare an array named "remotes" that has remote names
    eval "$(get_git_remote_aliases "$path_to_git_repo" remotes)"
    if [[ "${#remotes[@]}" -eq 1 ]] && [[ "${remotes[0]}" == "origin" ]]; then
        local remote="${remotes[0]}"
    elif [[ "${#remotes[@]}" -eq 0 ]] || ( [[ "${#remotes[@]}" -eq 1 ]] && [[ "${remotes[0]}" == "" ]] ); then
        # The directory may be not git repository. And it will be cloned as new git repository
        local remote="origin"
    else
        # TODO: Doesn't supported other than origin now
        local msg_remotes="${remotes[@]}"
        logger_warn "ERROR: Sorry, this script only supports single remote \"origin\". This repository has branche(s) \"${msg_remotes}\""
        return 1
    fi

    determin_update_type_of_repository "$path_to_git_repo" "$remote" "$url_of_repo" "$branch" 0
    local update_type=$?

    _do_update_git_repository "$path_to_git_repo" "$url_of_repo" "${remote}" "$branch" "$update_type" || return 1

    return 0
}

# Do update git repository.
# Checking parameters were not implemented because the function is assumed to be called to update_git_repo() that is implementing checking parameters.
# This function called when the current process is in the location that want to clone the repository.
function _do_update_git_repository () {
    local path_to_git_repo="$1"
    local url_of_repo="$2"
    local remote="$3"
    local branch="$4"
    local update_type="$5"

    local homedir_of_repo="$(dirname ${path_to_git_repo})"
    local dirname_of_repo="$(basename ${path_to_git_repo})"

    case $update_type in
        $GIT_UPDATE_TYPE_JUST_CLONE )
            git -C "$homedir_of_repo" clone -b "$branch" "$url_of_repo" "$dirname_of_repo" || {
                logger_warn "ERROR: Failed to clone the repository(git -C \"$homedir_of_repo\" clone -b \"$branch\" \"$url_of_repo\" \"$dirname_of_repo\")"
                return 1
            }
            ;;
        $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT )
            rm -rf "$path_to_git_repo"
            git -C "$homedir_of_repo" clone -b "$branch" "$url_of_repo" "$dirname_of_repo" || {
                logger_warn "ERROR: Failed to clone the repository(git -C \"$homedir_of_repo\" clone -b \"$branch\" \"$url_of_repo\" \"$dirname_of_repo\")"
                return 1
            }
            ;;
        $GIT_UPDATE_TYPE_ABOARTED )
            logger_info "Updating or cloning repository \"${url_of_repo}\" has been aborted."
            return $GIT_UPDATE_TYPE_ABOARTED
            ;;
        * )
            if [[ "$remote" != "origin" ]]; then
                # TODO: Does not supported remote referencing other than origin yet.
                logger_warn "ERROR: Sorry, this script only supports remote as \"origin\". The repository had been going to clone remote as \"${remote}\""
                return 1
            fi

            # Get branch name
            local branch=$(git -C "$path_to_git_repo" rev-parse --abbrev-ref HEAD 2> /dev/null)
            if [[ -z "$branch" ]]; then
                logger_warn "ERROR: Failed to get git branch name from \"${path_to_git_repo}\""
                return 1
            fi

            if [[ "$update_type" -eq $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL ]]; then
                # Reset and remove untracked files in git repository
                git -C "$path_to_git_repo" reset --hard || {
                    logger_warn "ERROR: Failed to reset git repository at \"${path_to_git_repo}\" for some readson."
                    return 1
                }
                remove_all_untracked_files "$path_to_git_repo"
            elif [[ "$update_type" -ne $GIT_UPDATE_TYPE_JUST_PULL ]]; then
                logger_warn "ERROR: Invalid git update type (${update_type}). Some error occured when determining git update type of \"${path_to_git_repo}\"."
                return 1
            fi
            # Type of GIT_UPDATE_TYPE_JUST_PULL will also reach this section.
            git -C "$path_to_git_repo" pull "$remote" "$branch" || {
                logger_warn "ERROR: Failed to pull \"$remote\" \"$branch\"."
                return 1
            }
            ;;
    esac

    return 0
}

# Remove all files or directories untracked in git repository
function remove_all_untracked_files() {
    local directory="$1"
    local f

    while read f; do
        rm -rf "${directory}/${f}"
    done < <(git -C "$directory" status --porcelain 2> /dev/null | grep -P '^\?\? .*' | cut -d ' ' -f 2)
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
        echo -en "$message"
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

# Alias of silent push
function pushd() {
    command pushd "$@" > /dev/null
}
# Alias of silent popd
function popd() {
    command popd "$@" > /dev/null
}

if [[ "$1" != "--load-functions" ]]; then
    # Call this script as ". ./script --load-functions" if you want to load functions only
    #set -eu
    main "$@"
fi

