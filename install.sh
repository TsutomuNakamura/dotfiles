#!/usr/bin/env bash
trap 'echo "SIG INT was received. This program will be terminated." && exit 1' INT

# The directory that dotfiles resources will be installed
DOTDIR=".dotfiles"
# Full path of the dotdir
FULL_DOTDIR_PATH="${HOME}/${DOTDIR}"
# The directory that dotfiles resources will be backuped
BACKUPDIR=".backup_of_dotfiles"
# The full directory that dotfiles resources will be backuped
FULL_BACKUPDIR_PATH="${HOME}/${BACKUPDIR}"
# Anchor for backup
BACKUP_ANCHOR_FILE=
# Status of create backup anchor file. Already created backup anchor file
STAT_ALREADY_CREATED_BACKUP_ANCHOR_FILE=255
# Status of create backup anchor file. Succeeded in creating backup anchor file
STAT_SUCCEEDED_IN_CREATING_BACKUP_ANCHOR_FILE=0
# Status of create backup anchor file. Failed to create backup anchor file
STAT_FAILED_TO_CREATE_BACKUP_ANCHOR_FILE=1

# Status of backup. Not started.
STAT_BACKUP_NOT_STARTED=255
# Status of backup. Finished.
STAT_BACKUP_FINISHED=0
# Status of backup. In progress.
STAT_BACKUP_IN_PROGRESS=1

# Git repository location over https
GIT_REPOSITORY_HTTPS="https://github.com/TsutomuNakamura/dotfiles.git"
# Git repository location over ssh
GIT_REPOSITORY_SSH="git@github.com:TsutomuNakamura/dotfiles.git"
# Raw git repository location over https
RAW_GIT_REPOSITORY_HTTPS="https://raw.github.com/TsutomuNakamura/dotfiles"

# Default XDG_CONFIG_HOME for Linux
DEFAULT_XDG_CONFIG_HOME_FOR_LINUX="${HOME}/.config"
# Default XDG_CONFIG_HOME for Mac
DEFAULT_XDG_CONFIG_HOME_FOR_MAC="${HOME}/Library/Preferences"
# Default XDG_DATA_HOME for Linux
DEFAULT_XDG_DATA_HOME_FOR_LINUX="${HOME}/.local/share"
# Default XDG_DATA_HOME for Mac
DEFAULT_XDG_DATA_HOME_FOR_MAC="${HOME}/Library"

# zsh dir
ZSH_DIR="${HOME}/.zsh"

# Temporary git user email from previous .gitconfig
GIT_USER_EMAIL_STORE_FILE="git_tmp_user_email"
# Full file path of temporary git user email from previous .gitconfig
GIT_USER_EMAIL_STORE_FILE_FULL_PATH="${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"

# Temporary git user name from previous .gitconfig
GIT_USER_NAME_STORE_FILE="git_tmp_user_name"
# Full file path of temporary git user name from previous .gitconfig
GIT_USER_NAME_STORE_FILE_FULL_PATH="${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"

# Temporary git user signingkey from previous .gitconfig
GIT_USER_SIGNINGKEY_STORE_FILE="git_tmp_user_signingkey"
# Full file path of temporary git user signingkey from previous .gitconfig
GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH="${FULL_BACKUPDIR_PATH}/${GIT_USER_SIGNINGKEY_STORE_FILE}"

# Temporary git commit gpgsign from previous .gitconfig
GIT_COMMIT_GPGSIGN_STORE_FILE="git_tmp_commit_gpgsign"
# Full file path of temporary git commit gpgsign from previous .gitconfig
GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH="${FULL_BACKUPDIR_PATH}/${GIT_COMMIT_GPGSIGN_STORE_FILE}"

# Temporary git gpg program from previous .gitconfig
GIT_GPG_PROGRAM_STORE_FILE="git_tmp_gpg_program"
# Full file path of temporary git gpg program from previous .gitconfig
GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH="${FULL_BACKUPDIR_PATH}/${GIT_GPG_PROGRAM_STORE_FILE}"

GLOBAL_DELIMITOR=','
declare -g -A GIT_PROPERTIES_TO_KEEP=(
    # ['label']="${tmp_file_path},${name_of_variable},${command_to_restore}"
    ['email']="${GIT_USER_EMAIL_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__user__email${GLOBAL_DELIMITOR}git config --global user.email \"\${__arg__}\""
    ['name']="${GIT_USER_NAME_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__user__name${GLOBAL_DELIMITOR}git config --global user.name \"\${__arg__}\""
    ['signingkey_id']="${GIT_USER_SIGNINGKEY_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__user__signingkey${GLOBAL_DELIMITOR}git config --global user.signingkey \"\${__arg__}\""
    ['gpgsign_flag']="${GIT_COMMIT_GPGSIGN_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__commit__gpgsign${GLOBAL_DELIMITOR}git config --global commit.gpgsign \"\${__arg__}\""
    ['gpg_program']="${GIT_GPG_PROGRAM_STORE_FILE_FULL_PATH}${GLOBAL_DELIMITOR}INI__gpg__program${GLOBAL_DELIMITOR}git config --global gpg.program \"\${__arg__}\""
)

# Directories which may be required by brew of Mac
# These element will be added a prefix in front of them with $(brew --prefix)
declare -g -a DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC=(
    "/sbin"
)

# Git user name to store .gitconfig
GIT_USER_NAME=
# Git user email to store .gitconfig
GIT_USER_EMAIL=

# Cache of absolute backup dir
CASH_ABSOLUTE_BACKUPDIR=
# Distribution of this environment
DISTRIBUTION=

# Post message list
declare -g -a POST_MESSAGES=()

PACKAGES_TO_INSTALL_ON_DEBIAN="git vim vim-gtk ctags tmux zsh unzip ranger ffmpeg cmake python3-dev libclang-dev xclip build-essential xbindkeys"
PACKAGES_TO_INSTALL_ON_DEBIAN_THAT_HAS_GUI="fonts-noto fonts-noto-mono fonts-noto-cjk"

PACKAGES_TO_INSTALL_ON_UBUNTU="git vim vim-gtk ctags tmux zsh unzip ranger ffmpeg cmake python3-dev libclang-dev build-essential xclip xbindkeys"
PACKAGES_TO_INSTALL_ON_UBUNTU+=" neovim python-dev python3-dev python3-pip"
PACKAGES_TO_INSTALL_ON_UBUNTU_THAT_HAS_GUI="fonts-noto fonts-noto-mono fonts-noto-cjk fonts-noto-cjk-extra"

PACKAGES_TO_INSTALL_ON_CENTOS="git vim-enhanced gvim ctags tmux zsh unzip gnome-terminal ffmpeg cmake gcc-c++ make python3-devel xclip"
PACKAGES_TO_INSTALL_ON_CENTOS_THAT_HAS_GUI="google-noto-sans-cjk-fonts.noarch google-noto-serif-fonts.noarch google-noto-sans-fonts.noarch"

PACKAGES_TO_INSTALL_ON_FEDORA="git vim-enhanced ctags tmux zsh unzip gnome-terminal ranger ffmpeg cmake gcc-c++ make python3-devel clang clang-devel xclip xbindkeys"
PACKAGES_TO_INSTALL_ON_FEDORA+=" neovim python2-neovim python3-neovim"
PACKAGES_TO_INSTALL_ON_FEDORA_THAT_HAS_GUI="google-noto-sans-fonts.noarch google-noto-serif-fonts.noarch google-noto-mono-fonts.noarch google-noto-cjk-fonts.noarch"

PACKAGES_TO_INSTALL_ON_ARCH="gvim git ctags tmux zsh unzip gnome-terminal ranger ffmpeg cmake gcc make python3 clang xclip xbindkeys npm"
PACKAGES_TO_INSTALL_ON_ARCH+=" neovim python-neovim"
PACKAGES_TO_INSTALL_ON_ARCH_THAT_HAS_GUI="noto-fonts noto-fonts-cjk"

# Packages will be installed on Mac
##PACKAGES_TO_INSTALL_ON_MAC="vim ctags tmux zsh unzip cmake python3 llvm"
##PACKAGES_TO_INSTALL_ON_MAC+=" neovim"

# URL of tmux-plugin
URL_OF_TMUX_PLUGIN="https://github.com/tmux-plugins/tpm.git"

# Symbolic link list of configuration of vim.
declare -g -a VIM_CONF_LINK_LIST=(
    # "<link_dest>,<link_src>"
    "../../../resources/etc/config/vim/bats.vim/after/syntax/sh.vim,${FULL_DOTDIR_PATH}/.vim/after/syntax"
    "../../resources/etc/config/vim/bats.vim/ftdetect/bats.vim,${FULL_DOTDIR_PATH}/.vim/ftdetect"
    "../../resources/etc/config/vim/snipmate-snippets.git/snippets/bats.snippets,${FULL_DOTDIR_PATH}/.vim/snippets"
    "../../resources/etc/config/vim/snipmate-snippets.git/snippets/chef.snippets,${FULL_DOTDIR_PATH}/.vim/snippets"
)

# Directories should be deep linked
declare -g -a DEEP_LINK_DIRECTORIES=(".config" "bin" ".local")

# Files should be copied on only Mac
declare -g -a FILES_SHOULD_BE_COPIED_ON_ONLY_MAC=("Inconsolata for Powerline.otf")

# Answer status for question() yes
ANSWER_OF_QUESTION_YES=0
# Answer status for question() no
ANSWER_OF_QUESTION_NO=1
# Answer status for question() aborted
ANSWER_OF_QUESTION_ABORTED=255

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

# Color of font red
FONT_COLOR_GREEN='\033[0;32m'
# Color of font yello
FONT_COLOR_YELLOW='\033[0;33m'
# Color of font red
FONT_COLOR_RED='\033[0;31m'
# Color of font end
FONT_COLOR_END='\033[0m'

# Emojis
EMOJI_START_EYES="🤩"

function main() {

    cd "${HOME}" || {
        echo "ERROR: Your home directory \"${HOME}\" isn't exist or you don't have permission to access it." >&2
        return 1
    }

    check_environment || return 1

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
            install_packages "$branch" || (( error_count++ ))
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

    do_post_instructions || (( error_count++ ))

    return $error_count
}

function check_environment() {
    is_customized_xdg_base_directories || {
        logger_err "Sorry, this dotfiles requires XDG Base Directory as default or unset XDG_CONFIG_HOME and XDG_DATA_HOME environments."
        logger_err "Current environment variables XDG_CONFIG_HOME and XDG_DATA_HOME is set like below."
        if [[ -z "${XDG_CONFIG_HOME}" ]]; then
            logger_err "  XDG_CONFIG_HOME=(unset)"
        else
            logger_err "  XDG_CONFIG_HOME=\"${XDG_CONFIG_HOME}\""
        fi
        logger_err     "    -> This must be set \"${HOME}/.config\" in Linux or \"${HOME}/Library/Preferences\" in Mac or unset."
        if [[ -z "${XDG_DATA_HOME}" ]]; then
            logger_err "  XDG_DATA_HOME=(unset)"
        else
            logger_err "  XDG_DATA_HOME=\"${XDG_DATA_HOME}\""
        fi
        logger_err     "    -> This must be set \"${HOME}/.local/share\" in Linux or \"${HOME}/Library\" in Mac or unset."

        return 1
    }

    [[ -z "$BASH" ]] && {
        logger_err "This script must run as bash script"
        return 1
    }
    [[ -z "$BASH_VERSION" ]] && {
        logger_err "This session does not have BASH_VERSION environment variable. Is this a proper bash session?"
        return 1
    }

    local current_bash_version=$(grep -o -E '^[0-9](\.[0-9])+' <<< "$BASH_VERSION")
    vercomp "4.0.0" "$current_bash_version"

    local result="$?"
    [[ "$result" -eq 1 ]] && {
        logger_err "Version of bash have to greater than 4.0.0."
        logger_err "Please update your bash greater than 4.0.0 then run this script again."
        logger_err "If you use mac, you can change new version of bash by running commands like below..."
        logger_err "  $ brew install bash"
        logger_err "  $ grep -q '/usr/local/bin/bash' /etc/shells || echo /usr/local/bin/bash | sudo tee -a /etc/shells"
        logger_err "...then relogin or restart your Mac"

        return 1
    }

    if [[ "$(get_distribution_name)" == "mac" ]]; then
        check_environment_of_mac || {
            logger_err "Failed to pass checking the environment of Mac"
            return 1
        }
    fi

    return 0
}

# Check environment of Mac
function check_environment_of_mac() {
    local dir
    local prefix="$(brew --prefix)"

    for dir in "${DIRECTORIES_MAY_REQUIRED_BY_BREW_ON_MAC[@]}"; do
        dir="${prefix}${dir}"

        if [[ ! -d "${dir}" ]]; then
            local msg="Directory \"${dir}\" that may be required by brew does not exist.\n"
            msg+="    Rerun this script after you created a directory \"${dir}\"\n"
            msg+="    example)\n"
            msg+="        sudo mkdir \"${dir}\"\n"
            msg+="        sudo chown $(whoami) \"${dir}\""
            logger_err "$msg"

            return 1
        fi

        if ! has_permission_to_rw "$dir"; then
            local msg="Directory \"${dir}\" not permitted to write and read by user $(whoami)."
            msg+="    Please check your permission whether you have a permission to read/write to the directory \"${dir}\""
            logger_err "$msg"

            return 1
        fi
    done

    return 0
}

function has_permission_to_rw() {
    local dir="$1"
    local user_name="$(whoami)"
    local is_owner=0
    local is_group=0

    declare -a groups=($(id -G -n $user_name))

    if [[ "$(stat -f '%Su' "$dir")" != "$user_name" ]]; then
        is_owner=1
    fi

    local own_group="$(stat -f '%Sg' "$dir")"

    if ! contains_element "$own_group" "${groups[@]}"; then
        is_group=1
    fi

    if [[ "$is_owner" -eq 1 ]] && [[ "$is_group" -eq 1 ]]; then
        # You don't have permission to read/writer to "$dir"
        return 1
    fi

    return 0
}

# Run post instructions
function do_post_instructions() {
    local result=0

    clear_backup_anchor_file || {
        logger_warn "Failed to delete backup anchor file \"${BACKUP_ANCHOR_FILE}\". You would delete it by your own, please."
        # TODO: Need not detect as an error.
        # (( ++result ))
    }

    print_post_message_list

    return $result
}

# Create backup anchor file
# @return 0: Creating anchor file has succeeded
# @return 1: Anchor file is already existed
function create_backup_anchor_file() {
    local backup_dir="$1"

    local uuid="$(uuidgen)"
    BACKUP_ANCHOR_FILE="${backup_dir}/${uuid}.backup_anchor"

    [[ -f "$BACKUP_ANCHOR_FILE" ]] && return $STAT_ALREADY_CREATED_BACKUP_ANCHOR_FILE
    echo -n "$STAT_BACKUP_IN_PROGRESS" > "$BACKUP_ANCHOR_FILE"
    [[ ! -f "$BACKUP_ANCHOR_FILE" ]] && return $STAT_FAILED_TO_CREATE_BACKUP_ANCHOR_FILE

    return $STAT_SUCCEEDED_IN_CREATING_BACKUP_ANCHOR_FILE
}

# Update status of anchor file
function update_backup_anchor_file() {
    local status="$1"
    echo -n "$status" > "$BACKUP_ANCHOR_FILE"

    # TODO: testing
}

# Get status of backup
function get_backup_anchor_file_status() {
    [[ ! -f "$BACKUP_ANCHOR_FILE" ]] && return $STAT_BACKUP_NOT_STARTED

    local status=$(cat "$BACKUP_ANCHOR_FILE")

    if [[ $status -eq $STAT_BACKUP_FINISHED ]]; then
        return $STAT_BACKUP_FINISHED
    elif [[ $status -eq $STAT_BACKUP_IN_PROGRESS ]]; then
        return $STAT_BACKUP_IN_PROGRESS
    fi

    return $STAT_BACKUP_NOT_STARTED
}

# Clear backup anchor file
function clear_backup_anchor_file() {
    [[ -z "${BACKUP_ANCHOR_FILE}" ]] && return 0
    [[ ! -f "${BACKUP_ANCHOR_FILE}" ]] && return 0
    rm -f "${BACKUP_ANCHOR_FILE}"

    # Return the status of deleting the file was succeeded or not
    [[ ! -f "${BACKUP_ANCHOR_FILE}" ]]
}

function print_post_message_list() {
    [[ ${#POST_MESSAGES[@]} -ne 0 ]] && {
        print_boarder " Summary of the instruction "
        for line in "${POST_MESSAGES[@]}"; do
            echo -e "* $line"
        done
        print_boarder
    }

    return 0
}

# Output the message to stdout then push it to info message list.
function logger_info() {
    local message="$@"
    message="${FONT_COLOR_GREEN}INFO${FONT_COLOR_END}: $message"
    echo -e "$message"
    push_post_message_list "$message"
}

# Output the message to errout then push it to warn message list.
function logger_warn() {
    local message="$@"

    local line_no="${BASH_LINENO[0]}"

    message="${FONT_COLOR_YELLOW}WARN${FONT_COLOR_END}: line ${line_no}: ${FUNCNAME[1]}(): $message"
    echo -e "$message" >&2
    push_post_message_list "$message"
}

function logger_err() {
    local message="$@"

    local line_no
    local func_name="${FUNCNAME[1]}"
    if [[ "$func_name" == "pushd" ]] || [[ "$func_name" == "mmkdir" ]] || [[ "$func_name" == "lln" ]]; then
        # If this method called from pushd, print the caller and its line of pushd for traceability.
        func_name="${FUNCNAME[2]}"
        line_no="${BASH_LINENO[1]}"
    else
        line_no="${BASH_LINENO[0]}"
    fi

    message="${FONT_COLOR_RED}ERROR${FONT_COLOR_END}: line ${line_no}: ${func_name}(): $message"
    echo -e "$message" >&2
    push_post_message_list "$message"
}

function push_post_message_list() {
    local message="$1"
    POST_MESSAGES+=("$message")
}

# Print boarder on console
function print_boarder() {
    local subject="$1"

    echo -n "==${subject}"
    local width=$(( $(tput cols) - 2 - ${#subject} ))
    printf '=%.0s' $(seq 1 ${width})
    echo
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
            install_packages "$branch" || {
                local m="Failed to install dependency packages."
                m+="\n  If you want to continue following processes that after installing packages, you can specify the option \"-n (no-install-packages)\"."
                m+="\n  ex) "
                m+="\n    bash -- <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh) -n"

                logger_err "$m"
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

    backup_current_dotfiles || {
        logger_err "Failed to backup .dotfiles data. Stop the instruction init()."
        return 1
    }

    # Install patched fonts in your home environment
    # Cloe the repository if it's not existed
    init_repo "$url_of_repo" "$branch" || {
        logger_err "Failed to initializing repository. Remaining install process will be aborted."
        return 1
    }
    if has_desktop_env; then
        install_fonts || {
            logger_err "Failed to installing fonts. Remaining install process will be aborted."
            return 1
        }
    else
        logger_info "Installing fonts were skipped due to this environment doesn't have desktop components."
    fi

    init_vim_environment || {
        logger_err "Failed to initializing vim environment. Remaining install process will be aborted."
        return 1
    }
    install_bin_utils || {
        logger_err "Failed to installing bin utils that will be installed in ~/bin. Remaining install process will be aborted."
        return 1
    }

    return 0
}

# Install packages.
# Fonts will be installed only when the machine have some desktop environments.
function install_packages() {
    local branch="${1:-master}"

    local result=0
    local packages=

    if [[ "$(get_distribution_name)" == "debian" ]]; then
        packages="${PACKAGES_TO_INSTALL_ON_DEBIAN}"
        has_desktop_env && packages+=" ${PACKAGES_TO_INSTALL_ON_DEBIAN_THAT_HAS_GUI}"
        # TODO: add_yarn_repository_to_debian_like_systems will not be called because 
        #       yarn will be installed to add vim-prettier and this installer for Debian does not support Neovim on Debian
        install_packages_with_apt $packages || (( result++ ))
    elif [[ "$(get_distribution_name)" == "ubuntu" ]]; then
        packages="${PACKAGES_TO_INSTALL_ON_UBUNTU}"
        has_desktop_env && packages+=" ${PACKAGES_TO_INSTALL_ON_UBUNTU_THAT_HAS_GUI}"
        # TODO: add result++
        add_additional_repositories_for_ubuntu
        install_packages_with_apt $packages || (( result++ ))
    elif [[ "$(get_distribution_name)" == "centos" ]]; then
        packages="${PACKAGES_TO_INSTALL_ON_CENTOS}"
        has_desktop_env && packages+=" ${PACKAGES_TO_INSTALL_ON_CENTOS_THAT_HAS_GUI}"

        # TODO: ranger not supported in centos
        # TODO: Are there google-noto-mono-(sans|serif) fonts?
        install_packages_with_yum $packages \
                && logger_warn "Package \"ranger\" will not be installed on Cent OS. So please install it manually." \
                || (( result++ ))
    elif [[ "$(get_distribution_name)" == "fedora" ]]; then
        packages="${PACKAGES_TO_INSTALL_ON_FEDORA}"
        has_desktop_env && packages+=" ${PACKAGES_TO_INSTALL_ON_FEDORA_THAT_HAS_GUI}"

        install_packages_with_dnf $packages || (( result++ ))
    elif [[ "$(get_distribution_name)" == "arch" ]]; then
        packages="${PACKAGES_TO_INSTALL_ON_ARCH}"
        has_desktop_env && packages+=" ${PACKAGES_TO_INSTALL_ON_ARCH_THAT_HAS_GUI}"

        install_packages_with_pacman $packages || (( result++ ))
    elif [[ "$(get_distribution_name)" == "mac" ]]; then
        install_packages_with_homebrew "$branch" || (( result++ ))
    else
        logger_err "Failed to get OS distribution to install packages."
        (( result++ ))
    fi

    return $result
}

# Add additional repositories for ubuntu.
# This function should call after do_i_have_admin_privileges() has passed
function add_additional_repositories_for_ubuntu() {
    sudo apt-get update || {
        logger_err "Some error has occured when updating packages with apt-get update."
        return 1
    }
    command -v add-apt-repository || {
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common || {
            logger_err "Failed to install software-properties-common"
            return 1
        }
    }

    local os_version=
    os_version=$(get_linux_os_version)
    local ret=$?

    if [[ "$ret" -ne 0 ]]; then
        logger_err "Failed to get os version for ubuntu at add_additional_repositories_for_ubuntu()"
        return 1
    fi

    # Ubuntu greater or equal to 18.04 does not need to add ppa repository for neovim
    local result_of_vercomp=0
    vercomp "18.04" "$os_version" || { result_of_vercomp=$?; true; }

    if [[ "$result_of_vercomp" -eq 1 ]]; then
        # Added ppa:neovim-ppa/stable to install neovim
        sudo add-apt-repository ppa:neovim-ppa/stable -y || {
            logger_err "Failed to add repository ppa:neovim-ppa/stable"
            return 1
        }

        logger_info "Added additional apt repositories. (ppa:neovim-ppa/stable)"
    else
        logger_info "No need to add a repository for Neovim to Ubuntu ${os_version}. Skipped it"
    fi

    add_yarn_repository_to_debian_like_systems || return 1

    return 0
}

# Add yarn repository to debian like system
function add_yarn_repository_to_debian_like_systems() {
    wget -qO - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - || {
        logger_err "Failed to add yarn repository's gpg key from https://dl.yarnpkg.com/debian/pubkey.gpg"
        return 1
    }
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list || {
        logger_err "Failed to add yarn repository to /etc/apt/sources.list.d/yarn.list"
        return 1
    }
    # "sudo apt update" will be run from the another section

    return 0
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
            logger_info "${font_name} has installed.${extra_msg_on_installed}"
            ;;
        2 )
            logger_err "Failed to install ${font_name}.${extra_msg_on_failed}"
            ;;
        * )
            logger_err "Unknown error was occured when installing ${font_name}.${extra_msg_on_unknown_err}"
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
    pushd $font_dir || return 1

    install_the_font "_install_font_inconsolata_nerd" \
            "Inconsolata for Powerline Nerd Font" \
            "" \
            "For more information about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."
    local ret_install_font_inconsolata_nerd=$?
    [[ $ret_install_font_inconsolata_nerd -eq 1 ]] && (( flag_fc_cache++ ))
    [[ $ret_install_font_inconsolata_nerd -gt 1 ]] && (( result++ ))

    install_the_font "_install_font_migu1m" \
            "Migu 1M Font" \
            "" \
            "For more information about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"." \
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
                "For more information about the font, please see \"https://github.com/googlei18n/noto-emoji\"." \
                "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary." \
                "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary."
        local ret_install_font_noto_emoji=$?
        [[ $ret_install_font_noto_emoji -eq 1 ]] && (( flag_fc_cache++ ))
        [[ $ret_install_font_noto_emoji -gt 1 ]] && (( result++ ))
    fi

    if [[ "$distribution_name" == "mac" ]]; then
        # "Inconsolata for Powerline.otf" is installed(linked) in deploy() method
        logger_info "This dotfiles recommends you to use font that patched nerd fonts to show some icons on your terminal. If you don't have any fonts, \"Inconsolata for Powerline.otf\" has installed and try it ${EMOJI_START_EYES} ."
    fi

    popd

    if [[ "$flag_fc_cache" -ne 0 ]]; then
        echo "Building font information cache files with \"fc-cache -f ${font_dir}\""
        fc-cache -f $font_dir && logger_info "Font cache was recreated."
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
        pushd migu-1m-20150712 || return 1
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
        logger_err "Failed to install NotoColorEmoji.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf)"
        (( ret++ ))
    }
    curl -fLo "NotoEmoji-Regular.ttf" \
            https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf || {
        logger_err "Failed to install NotoEmoji-Regular.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf)"
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

# Installing packages with apt.
# Please call this function only after call do_i_have_admin_privileges() which the return-code is 0(true).
function install_packages_with_apt() {
    declare -a packages=($@)
    declare -a packages_will_be_installed
    local output

    sudo apt-get update || {
        logger_err "Some error has occured when updating packages with apt-get update."
        return 1
    }

    local pkg_cache=$(apt list --installed 2> /dev/null | grep -v -E 'Listing...' | cut -d '/' -f 1)
    if [[ -z "$pkg_cache" ]]; then
        logger_err "Failed to get installed packages with apt list --installed."
        return 1
    fi

    local available_packages=
    available_packages="$(sudo apt-cache pkgnames)"
    if [[ -z "$available_packages" ]]; then
        logger_err "Failed to get available package list with 'apt-cache pkgnames'"
        return 1
    fi

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        local p="${packages[i]}"

        if (grep -E "^${p}$" &> /dev/null <<< "$pkg_cache"); then
            # Remove already installed packages
            echo "${p} has already installed. Skipped."
            continue
        fi
        if ! (grep -E "^${p}$" &> /dev/null <<< "$available_packages"); then
            logger_warn "Package ${p} is not available. Installing ${p} was skipped."
            continue
        fi

        packages_will_be_installed+=("${packages[i]}")
    }

    if [[ "${#packages_will_be_installed[@]}" -eq 0 ]]; then
        echo "There are no packages to install"
        return 0
    fi

    echo "Installing ${packages_will_be_installed[@]}..."

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ${packages_will_be_installed[@]} || {
        logger_err "Some error occured when installing ${packages_will_be_installed[@]} with apt-get install."
        return 1
    }

    local installed_packages="${packages_will_be_installed[@]}"
    logger_info "Packages ${installed_packages} have been installed."

    return 0
}

function install_packages_with_yum() {
    [[ "${#@}" -eq 0 ]] && {
        echo "ERROR: Failed to find packages to install at install_packages_with_yum()" >&2
        return 1
    }
    install_packages_on_redhat "yum" $@
}

function install_packages_with_dnf() {
    [[ "${#@}" -eq 0 ]] && {
        echo "ERROR: Failed to find packages to install at install_packages_with_dnf()" >&2
        return 1
    }
    install_packages_on_redhat "dnf" $@
}

# Installing packages with yum or dnf on Red Hat like environments.
# Please call this function only after call do_i_have_admin_privileges() which the return-code is 0(true).
function install_packages_on_redhat() {
    local command_name="$1" ; shift
    declare -a packages=($@)
    declare -a packages_will_be_installed
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local output
    local ret=0

    local pkg_cache
    pkg_cache="$(rpm -qa --queryformat="%{NAME}\n")"
    ret=$?
    [[ "$ret" -ne 0 ]] && {
        logger_err "Failed to get installed packages at install_packages_on_redhat()"
        return 1
    }

    echo "Getting the list of available packages..."
    local available_packages="$(${command_name} list available 2> /dev/null | tail -n +3 | cut -f1 -d' ' | sed -e 's/\(.*\)\.\(noarch\|x86_64\|i.86\)/\1/')"
    [[ -z "$available_packages" ]] && {
        logger_err "Failed to get available packages at install_packages_on_redhat()"
        return 1
    }

    for p in "${packages[@]}"; do
        grep -Fx "$p" <<< "$pkg_cache" > /dev/null
        ret=$?
        [[ $ret -eq 0 ]] && {
            logger_info "Package $p has already installed. Skipping install it."
            continue
        }

        grep -Fx "$p" <<< "$available_packages" > /dev/null
        ret=$?
        [[ $ret -ne 0 ]] && {
            logger_warn "Package $p is not available. Skipping install it."
            continue
        }

        packages_will_be_installed+=("$p")
    done

    #for ((i = 0; i < ${#packages[@]}; i++)) {
    #    while read n; do
    #        if [[ "${packages[i]}" == "$n" ]]; then
    #            echo "$n is already installed"
    #            continue 2
    #        fi
    #    done <<< "$pkg_cache"
    #    packages_will_be_installed+=("${packages[i]}")
    #}

    [[ "${#packages_will_be_installed[@]}" -eq 0 ]] && {
        echo "There are no packages to install"
        return 0
    }

    echo "Installing ${packages_will_be_installed[@]}..."

    local packages_installed="${packages_will_be_installed[@]}"
    ${prefix} ${command_name} install -y ${packages_will_be_installed[@]}
    ret=$?
    [[ "$ret" -ne 0 ]] && {
        logger_err "Failed to install packages $packages_installed"
        return 1
    }
    logger_info "Packages $packages_installed have been installed."

    return 0
}

# Installing packages with pacman.
# Please call this function only after call do_i_have_admin_privileges() which the return-code is 0(true).
function install_packages_with_pacman() {
    declare -a packages=("$@")
    declare -a packages_will_be_installed=()
    declare -a packages_may_conflict=()
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local i
    local result=0
    local installed_packages=

    local failed_to_install_packages=
    local unavailable_packages=
    local already_installed_packages=

    local all_available_packages="$(${prefix} pacman -Ss | grep -P '^[a-zA-z].*' | sed -e 's|^.*/\([^ ]\+\) .*|\1|g')"
    if [[ -z "$all_available_packages" ]]; then
        logger_err "Failed to get available packages with \"pacman -Ss\""
        return 1
    fi

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        if ! grep -Fx "${packages[i]}" <<< "$all_available_packages" > /dev/null ; then
            #logger_warn "Package ${packages[i]} is not available. Installing ${packages[i]} was skipped."
            unavailable_packages+="${packages[i]} "
            continue
        fi

        if ${prefix} pacman -Q "${packages[i]}" > /dev/null 2>&1; then
            already_installed_packages+="${packages[i]} "
        else
            # Packages vim and gvim may conflict each other. Install them individual not to avoid faile to install other packages.
            if [[ "${packages[i]}" = "vim" ]] || [[ "${packages[i]}" = "gvim" ]]; then
                packages_may_conflict+=("${packages[i]}")
            else
                packages_will_be_installed+=("${packages[i]}")
            fi
        fi
    }

    [[ -z "$unavailable_packages" ]] || \
            logger_warn "Packages ${unavailable_packages% } were unavailable. Skipped installing them."
    [[ -z "$already_installed_packages" ]] || \
            logger_info "Packages ${already_installed_packages% } were already installed. Skipped installing them."

    if [[ "${#packages_will_be_installed[@]}" -eq 0 ]] && [[ "${#packages_may_conflict[@]}" -eq 0 ]]; then
        echo "There are no packages to install."
    else
        if [[ "${#packages_will_be_installed[@]}" -ne 0 ]]; then
            echo "Installing ${packages_will_be_installed[@]}..."
            ${prefix} pacman -Sy --noconfirm ${packages_will_be_installed[@]} && {
                installed_packages+="${packages_will_be_installed[@]} "
            }  || {
                failed_to_install_packages+="${packages_will_be_installed[@]} "
                ((result++))
            }
        fi
        for (( i = 0; i < ${#packages_may_conflict[@]}; i++ )) {
            echo "Installing ${packages_may_conflict[i]}..."
            ${prefix} pacman -Sy --noconfirm "${packages_may_conflict[i]}" && {
                installed_packages+="${packages_may_conflict[i]} "
            } || {
                failed_to_install_packages+="${packages_may_conflict[i]} "
                if [[ "${packages_may_conflict[i]}" == "gvim" ]]; then
                    logger_warn "Failed to install ${packages_may_conflict[i]}. It might has been conflict with vim. I recommend to use gvim rather than vim, because of some useful options. Remaining processes will be continued."
                else
                    ((result++))
                fi
            }
        }
    fi

    [[ ! -z "$installed_packages" ]] && \
            logger_info "Package(s) \"${installed_packages% }\" have been installed on your OS."
    [[ ! -z "$failed_to_install_packages" ]] && \
            logger_err "Package(s) \"${failed_to_install_packages% }\" have not been installed on your OS due to some error.\n  Please install these packages manually."

    return $result
}

function install_packages_with_homebrew() {
    local branch=${1:-master}
    local user_id="$(id -u)"
    local local_brewfile="/tmp/.${user_id}_BrewfileOfDotfiles"
    local remote_brewfile="${RAW_GIT_REPOSITORY_HTTPS}/${branch}/.BrewfileOfDotfiles"

    curl -L -o "$local_brewfile" "$remote_brewfile" || {
        logger_err "Failed to download Brewfile from \"${remote_brewfile}\""
        return 1
    }

    # Mac only reached in this function. So options of stat are for Mac's one
    if [[ ! -f "$local_brewfile" ]] || [[ $(stat -f '%z' "$local_brewfile") -eq 0 ]]; then
        logger_err "Failed to download Brewfile. The file \"${local_brewfile}\" is not found or empty"
        return 1
    fi

    # Only Mac can reach this function. So options of command stat are for Macs one
    local amount_of_line="$(cat "$local_brewfile" | wc -l)"

    if [[ "$amount_of_line" -eq 1 ]] && (grep -q -E '^[0-9]+: .*' "$local_brewfile" 2> /dev/null); then
        logger_err "Server returned some status code and downloading Brewfile has failed. (status=$(cat $local_brewfile))"
        return 1
    fi

    brew bundle --file="/tmp/.${user_id}_BrewfileOfDotfiles" || {
        logger_err "Failed to install packages with brew bundle"
        return 1
    }

    rm -f "/tmp/.${user_id}_BrewfileOfDotfiles" || {
        logger_err "Failed to remove \"${local_brewfile}\" after brew bundle has succeeded"
        return 1
    }

    logger_info "brew bundle has succeeded. Your packages have been already up to date."

    return 0
}

function install_or_update_one_package_with_homebrew() {
    local package="$1"
    local output
    local result

    echo "Install or upgrade $package"

    if brew ls --versions "$package" >/dev/null; then
        output=$(HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$package" 2>&1)
        result=$?

        if [[ "$result" -ne 0 ]]; then
            echo "$output" | tail -1 | grep -q -E '.*already installed$' || {
                logger_err "$output"
                return 1
            }
        fi
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$package" || return 1
    fi

    return 0
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

# TODO: This dotfiles unsupported customized XDG directories.
#       XDG_CONFIG_HOME must be "~/.config" in Linux OS and "~/Library/Preferences" in Mac OS.
#       XDG_DATA_HOME must be "~/.local/share" in Linux OS and "~/Library" in Mac OS.
function is_customized_xdg_base_directories() {
    local result=0

    if [[ ! -z "${XDG_CONFIG_HOME}" ]]; then
        if [[ "$(get_distribution_name)" = "mac" ]]; then
            [[ "${XDG_CONFIG_HOME%/}" = "${DEFAULT_XDG_CONFIG_HOME_FOR_MAC}" ]]     || (( result++ ))
        else
            [[ "${XDG_CONFIG_HOME%/}" = "${DEFAULT_XDG_CONFIG_HOME_FOR_LINUX}" ]]   || (( result++ ))
        fi
    fi

    if [[ ! -z "${XDG_DATA_HOME}" ]]; then
        if [[ "$(get_distribution_name)" = "mac" ]]; then
            [[ "${XDG_DATA_HOME%/}" = "${DEFAULT_XDG_DATA_HOME_FOR_MAC}" ]]         || (( result++ ))
        else
            [[ "${XDG_DATA_HOME%/}" = "${DEFAULT_XDG_DATA_HOME_FOR_LINUX}" ]]       || (( result++ ))
        fi
    fi

    return $result
}

# Check the file whether should not be linked.
function files_that_should_not_be_linked() {
    local target="$1"
    [[ "$target" = "LICENSE.txt" ]]
}

function get_target_dotfiles() {
    local dir="$1"
    declare -a dotfiles=()
    pushd ${dir} || return 1

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
    get_backup_anchor_file_status
    local status_of_backup=$?

    [[ $status_of_backup -eq $STAT_BACKUP_FINISHED ]] && return 0

    [[ ! -d "${HOME}/${DOTDIR}" ]] && {
        echo "There are no dotfiles to backup."
        return
    }

    local backup_dir="$(get_backup_dir)"
    declare -a dotfiles=($(get_target_dotfiles "${HOME}/${DOTDIR}"))

    mkdir -p "${backup_dir}"
    pushd ${HOME} || return 1

    create_backup_anchor_file "${backup_dir}"
    local status_of_create_backup=$?

    [[ $status_of_create_backup -eq $STAT_FAILED_TO_CREATE_BACKUP_ANCHOR_FILE ]] && {
        logger_err "Failed to create backup anchor file in backup_current_dotfiles."
        return 1
    }
    # Continue if STAT_ALREADY_CREATED_BACKUP_ANCHOR_FILE or STAT_SUCCEEDED_IN_CREATING_BACKUP_ANCHOR_FILE

    # Backup git personal properties to restore them later
    backup_git_personal_properties "${FULL_DOTDIR_PATH}" || {
        logger_err "Failed to backup git personal properties."
        return 1
    }

    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        [[ -e "${dotfiles[i]}" ]] || continue
        local dir_name=${dotfiles[i]#./}
        dir_name=${dir_name%%/*}
        if (should_it_make_deep_link_directory "$dir_name"); then

            # Backup deeplink
            pushd "${HOME}/${DOTDIR}/${dotfiles[i]}" || { popd; return 1; }
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
    update_backup_anchor_file "$STAT_BACKUP_FINISHED"

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

    pushd "${HOME}/${DOTDIR}" || return 1
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
    backup_current_dotfiles || {
        logger_err "Failed to backup .dotfiles data. Stop the instruction deploy()."
        return 1
    }

    declare -a dotfiles=($(get_target_dotfiles "${FULL_DOTDIR_PATH}"))
    pushd ${HOME} || return 1
    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        if should_it_make_deep_link_directory "${dotfiles[i]}"; then
            # Link only files in dotdirectory
            declare -a link_of_destinations=()
            if [[ ! -e "${dotfiles[i]}" ]]; then
                mkdir "${dotfiles[i]}"
            fi

            [[ ! -d "${dotfiles[i]}" ]] && {
                logger_err "Failed to make directory ${dotfiles[i]} in deploy()."
                return 1
            }
            pushd ${DOTDIR}/${dotfiles[i]} || { popd; return 1; }
            while read f; do
                link_of_destinations+=( "${f#./}" )
            done < <(find . -type f)
            popd
            for (( j = 0; j < ${#link_of_destinations[@]}; j++ )) {

                # Count depth of directory and append "../" in front of the target
                local depth=$(( $(tr -cd / <<< "${dotfiles[i]}/${link_of_destinations[j]}" | wc -c) ))
                local destination="$(printf "../%.0s" $( seq 1 1 ${depth} ))${DOTDIR}/${dotfiles[i]}/${link_of_destinations[j]}"
                mkdir -p "${dotfiles[i]}/$(dirname "${link_of_destinations[j]}")"

                files_that_should_not_be_linked "${link_of_destinations[j]##*/}" && continue

                echo "(cd \"${dotfiles[i]}/$(dirname "${link_of_destinations[j]}")\" && ln -s \"${destination}\")"
                (cd "${dotfiles[i]}/$(dirname "${link_of_destinations[j]}")" && ln -s "${destination}")
            }
        else
            echo "Creating a symbolic link -> ${DOTDIR}/${dotfiles[i]}"
            ln -s "${DOTDIR}/${dotfiles[i]}"
        fi
    }

    # Continue if restore_git_personal_properties() was failed
    # because it is no large effect on later instructions.
    restore_git_personal_properties "${FULL_DOTDIR_PATH}" || {
        local msg="Failed to restore your email of git and(or) name of git."
        msg+="\nYou may nesessary to restore manually with \`git config --global user.name \"Your Name\"\`, \`git config --global user.email your-email@example.com\`"
        logger_warn "$msg"
    }
    clear_git_personal_properties || {
        local msg="Failed to clear your temporary git data \"${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}\" and \"${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}\"."
        msg+="\nYou should clear these data with..."
        msg+="\n\`rm -f ${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}\`"
        msg+="\n\`rm -f ${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}\`"
        logger_warn "$msg"
    }

    # TODO: Should add error handling

    deploy_xdg_base_directory
    deploy_vim_environment
    deploy_tmux_environment
    deploy_zsh_environment || {
        logger_err "Failed to deploy_zsh_environment()"
        return 1
    }

    # FIXME: On Mac, do not ready for fontconfig yet.
    #        For appropriate view, release ambi_width_double settings for vim and 
    #        font "Inconsolata for Powerline Nerd Font Complete.otf" must be set on Mac.
    if [[ "$(get_distribution_name)" == "mac" ]]; then
        touch ~/.vimrc_do_not_use_ambiwidth
    fi

    popd
}

# Set and store git personal properties
function backup_git_personal_properties() {
    local dotfiles_dir="$1"

    local read_ini_sh="${dotfiles_dir}/.bash_modules/read_ini.sh"
    declare -a created_files=()

    # May for the first time.
    [[ ! -f "${HOME}/.gitconfig" ]] && {
        logger_info "There is no ${HOME}/.gitconfig. Skip getting user.name and user.email for new .gitconfig."
        return 0
    }

    # Load ini file parser
    if [[ ! -f "$read_ini_sh" ]]; then
        source <(curl https://raw.githubusercontent.com/TsutomuNakamura/bash_ini_parser/master/read_ini.sh 2> /dev/null)
        local result=$?

        [[ $result -ne 0 ]] && {
            logger_err ".ini file parser \"${read_ini_sh}\" is not found. And failed to try download .ini file parser from https://raw.githubusercontent.com/TsutomuNakamura/bash_ini_parser/master/read_ini.sh"
            return 1
        }
    else
        source "${read_ini_sh}" || {
            logger_err "Failed to load .ini file parser \"${read_ini_sh}\""
            return 1
        }
    fi

    read_ini --booleans 0 "${HOME}/.gitconfig" || {
        logger_err "Failed to parse \"${HOME}/.gitconfig\""
        return 1
    }

    local key

    for key in "${!GIT_PROPERTIES_TO_KEEP[@]}"; do
        local value="${GIT_PROPERTIES_TO_KEEP[$key]}"

        local file_path=$(cut -d"$GLOBAL_DELIMITOR" -f 1 <<< "$value")
        local name_of_val=$(cut -d"$GLOBAL_DELIMITOR" -f 2 <<< "$value")
        local val_to_keep=$(eval "command echo \${${name_of_val}}")

        [[ -f "$file_path" ]] && continue
        [[ -z "$val_to_keep" ]] && continue

        created_files+=("$file_path")
        echo "$val_to_keep" > "$file_path" || {
            logger_err "Failed to store git property \"${key}\" to \"${file_path}\""
            clear_tmp_backup_files "${created_files[@]}"
            return 1
        }
    done

    return 0
}

function clear_tmp_backup_files() {
    local targets=("$@")
    local f
    for f in "${targets[@]}"; do
        rm -f "$f"
    done
}

# Restore git personal properties
function restore_git_personal_properties() {
    declare -a will_be_deleted=()

    # TODO: More efficient way
    for key in "${!GIT_PROPERTIES_TO_KEEP[@]}"; do
        local value="${GIT_PROPERTIES_TO_KEEP[$key]}"

        local file_path=$(cut -d"$GLOBAL_DELIMITOR" -f 1 <<< "$value")
        local cmd=$(cut -d"$GLOBAL_DELIMITOR" -f 3 <<< "$value")

        [[ ! -f "$file_path" ]] && continue
        will_be_deleted+=("$file_path")

        local __arg__="$(cat $file_path)"
        [[ -z "$__arg__" ]] && continue

        # Restore a git parameter by command.
        # __arg__ parameter must be set before run this eval.
        eval "$cmd" || {
            logger_err "Failed to execute \`$cmd\`"
            return 1
        }
    done

    clear_tmp_backup_files "${will_be_deleted[@]}"

    return 0
}

# Clear git personal properties
function clear_git_personal_properties() {
    [[ -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}" ]] && rm -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}"
    [[ -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}" ]] && rm -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}"

    # Return the result of this function
    [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_EMAIL_STORE_FILE}" ]] && [[ ! -f "${FULL_BACKUPDIR_PATH}/${GIT_USER_NAME_STORE_FILE}" ]]
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

    pushd ${HOME}/${DOTDIR} || return 1
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
            pushd "$pushd_target" || { popd; return 1; }
            link_target="$(printf "../%.0s" $( seq 1 1 ${depth} ))${DOTDIR}/${f}"

            echo "-> ${link_target##*/}"
            if files_that_should_be_copied_on_only_mac "${link_target##*/}"; then
                echo "Copy ${xdg_directory}: cp -r \"${link_target}\" ."
                cp -r "${link_target}" .
            else
                echo "Link ${xdg_directory}: ln -s \"${link_target}\" from \"$(pwd)\""
                ln -s "${link_target}"
            fi

            popd
        done < <(find ./${xdg_directory} -type f)
    fi
    popd
}

function deploy_vim_environment() {
    # Directory ${HOME}/.vim is a soft link that linked to ${DOTDIR}/.vim.
    # Since creating files under ${DOTDIR}/.vim are same as creating files under ${HOME}/.vim.

    local record
    local reg_full_dotdir_path="$(sed -e 's/\./\\./g' <<< "${FULL_DOTDIR_PATH}")"

    # FIXME: These commands are dangerous. Instructions in here have to prevent some of dangerous one more strictly.
    for record in "${VIM_CONF_LINK_LIST[@]}"; do
        local link_dest="$(cut -d',' -f 1 <<< "$record")"
        local link_src="$(cut -d',' -f 2 <<< "$record")"

        [[ "$link_src" =~ ^${reg_full_dotdir_path}.*$ ]] || {
            logger_err "Link of source \"${link_src}\" must in your dotfiles root directory \"${FULL_DOTDIR_PATH}\". Aborted."
            return 1
        }

        mmkdir "$link_src"              || return 1
        lln "$link_dest" "$link_src"    || return 1
    done

    _install_vim_plug || return 1

    if [[ "$(get_distribution_name)" == "mac" ]]; then
        # Change options to compile you_complete_me from Linux distributions due to the issue
        # https://github.com/TsutomuNakamura/dotfiles/issues/61
        _install_you_complete_me || return 1

        # Linke to neovim
        mmkdir "${HOME}/.config" || return 1
        pushd "${HOME}/.config" || {
            logger_err "Failed to change directory ${HOME}/.config"
            return 1
        }
        lln "../Library/Preferences/nvim" "." || {
            logger_err "Failed to create symlink with \`ln -sf ../Library/Preferences/nvim .\` from ${HOME}/.config"
            popd
            return 1
        }
        popd
    elif [[ "$(get_distribution_name)" != "centos" ]]; then
        _install_you_complete_me --clang-completer --system-libclang || return 1
    else
        logger_warn "Sorry, this dotfiles installer does not support to install YouCompleteMe on CentOS yet."
    fi

    return 0
}

# Dploy tmux environment
function deploy_tmux_environment() {
    _install_tmux_plugin_manager "${HOME}/.tmux/plugins/tpm" || {
        logger_err "Failed to install tmux_plugin_manager"
        return 1
    }
    _install_and_update_tmux_plugins || {
        logger_err "Failed to install or update tmux plugins"
        return 1
    }

    return 0
}


# Deploy zsh environment
function deploy_zsh_environment() {
    deploy_zsh_antigen || return 1

    return 0
}

# Deploy zsh antigen then install packages managed with antigen
function deploy_zsh_antigen() {
    mkdir -p "${ZSH_DIR}/antigen" || {
        logger_err "Failed to create \"${ZSH_DIR}\""
        return 1
    }
    curl -L git.io/antigen > "${ZSH_DIR}/antigen/antigen.zsh" || {
        logger_err "Failed to create \"${ZSH_DIR}/antigen/antigen.zsh\" by downloading from git.io/antigen"
        return 1
    }
    # Install packages of zsh
    zsh -c "source \"${HOME}/.zshrc\"" || {
        logger_err "Failed to load .zshrc to install packages with antigen"
        return 1
    }

    return 0
}


# Install tmux plugins
function _install_and_update_tmux_plugins() {
    if [[ -z "$TMUX" ]]; then
        # This session does not be attached tmux.
        # Create one tmux session then send keys to install tmux plugins
        # TODO: This should handle errors
        tmux new \; set-buffer "${HOME}/.tmux/plugins/tpm/bin/install_plugins; ${HOME}/.tmux/plugins/tpm/bin/update_plugins all; exit" \; paste-buffer
    else
        ${HOME}/.tmux/plugins/tpm/bin/install_plugins || {
            logger_err "Failed to install tmux plugins with \`${HOME}/.tmux/plugins/tpm/bin/install_plugins\`"
            return 1
        }
        ${HOME}/.tmux/plugins/tpm/bin/update_plugins all || {
            logger_err "Failed to update tmux plugins with \`${HOME}/.tmux/plugins/tpm/bin/update_plugins all\`"
            return 1
        }
        tmux source-file ${HOME}/.tmux.conf || {
            logger_err "Failed to reload .tmux.conf by \`tmux source-file ${HOME}/.tmux.conf\`"
            return 1
        }
    fi

    return 0
}

# Install tmux plugins manager
function _install_tmux_plugin_manager() {
    local install_dir="$1"

    # Install tmux plugin manager
    # https://github.com/tmux-plugins/tpm
    determin_update_type_of_repository "${install_dir}" "origin" "$URL_OF_TMUX_PLUGIN" "master" 1
    local update_type=$?

    case $update_type in
        $GIT_UPDATE_TYPE_JUST_CLONE )
            git clone ${URL_OF_TMUX_PLUGIN} ${install_dir} || {
                logger_err "Just clone https://github.com/tmux-plugins/tpm was failed."
                return 1
            }
            ;;
        $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT )
            rm -rf ${install_dir}
            git clone ${URL_OF_TMUX_PLUGIN} ${install_dir} || {
                logger_err "Remove then clone ${URL_OF_TMUX_PLUGIN} was failed"
                return 1
            }
            ;;
        $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL )
            pushd "$install_dir"
            git reset --hard || {
                logger_err "Failed to git reset --hard ${URL_OF_TMUX_PLUGIN}"
                popd; return 1
            }
            git pull ${URL_OF_TMUX_PLUGIN} || {
                logger_err "Failed to pull repository ${URL_OF_TMUX_PLUGIN}"
                popd; return 1
            }
            popd
            ;;
        $GIT_UPDATE_TYPE_JUST_PULL )
            pushd "$install_dir"
            git pull origin HEAD || {
                logger_err "Fatiled to pull repository ${URL_OF_TMUX_PLUGIN}"
                popd; return 1
            }
            popd
            ;;
        * )
            logger_err "Some error occured when installing ${URL_OF_TMUX_PLUGIN}"
            return 1
            ;;
    esac

    return 0
}

function _install_you_complete_me() {
    declare -a options=("$@")

    # Packages written in .vimrc in vim-plug section are assumed already installed.
    curl -fLo "${HOME}/.ycm_extra_conf.py" "https://raw.githubusercontent.com/Valloric/ycmd/master/.ycm_extra_conf.py" || {
        logger_err "Failed to get vim-plug at ~/.ycm_extra_conf.py"
        return 1
    }

    pushd "${HOME}/.vim/plugged/YouCompleteMe" || {
        logger_err "Failed to change directry \"${HOME}/.vim/plugged/YouCompleteMe\""
        return 1
    }
    python3 install.py ${options[@]} || {
        popd
        logger_err "Failed to install with python3 install.py"
        return 1
    }
    popd

    return 0
}

function _install_vim_plug() {
    # Install dependent modules.
    # FIXME: Is there a compatible way to detect install error.
    curl -fLo ${HOME}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || {
        logger_err "Failed to install plug-vim from https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        return 1
    }

    # An error will be ocurred at ambiwidth=double in .vimrc if LANG environment variable was not set
    echo "Installing vim plugins..."
    if [[ -z "$LANG" ]] || [[ "$LANG" == "C" ]]; then
        #LANG=en_US.UTF-8 vim +PlugInstall +"sleep 1000m" +qall >& /dev/null
        LANG=en_US.UTF-8 vim +PlugInstall +"sleep 1000m" +qall
    else
        # vim +PlugInstall +"sleep 1000m" +qall >& /dev/null
        vim +PlugInstall +"sleep 1000m" +qall
    fi

    _validate_plug_install || {
        logger_err "Failed to install some plugins of vim. After this installer has finished, run a command manually like \`vim +PlugInstall +\"sleep 1000m\" +qall\` or rerun this installer to fix it."
        # It is not necessary to stop remaining process because installing plugins of vim is isolated from this dotfiles-installer and the user can fix this error manually after its installer has finished.
    }

    return 0
}

function _validate_plug_install() {
    declare -a failed_packages=()
    local error_count=0

    pushd "${HOME}"

    local p
    local expected_location
    while read p; do
        p=$(echo "$p" | sed -e "s/^['\"]\(.*\)['\"]\$/\1/" | cut -d',' -f 1 | xargs -I {} basename {})

        if [[ "${p}" == "fzf" ]]; then
            expected_location=".${p}/.git"
        else
            expected_location=".vim/plugged/${p}/.git"
        fi

        if [[ ! -d "$expected_location" ]]; then
            logger_err "Failed to install vim plugin \"${p}\". There is not a directory \"$(dirname ${expected_location})\" or its directory is not a git repository."
            (( error_count++ ))
        fi
    done < <(grep -E '^Plug .*' .vimrc)

    popd
    return $error_count
}

# Check whether the directory should be deep linked or not.
function should_it_make_deep_link_directory() {
    local directory="$1"
    pushd ${HOME}/${DOTDIR} || return 1

    [[ -d $directory ]] && contains_element "$directory" "${DEEP_LINK_DIRECTORIES[@]}"

    local result=$?
    popd

    return $result
}

# Check whether the file should not be copied on only mac.
function files_that_should_be_copied_on_only_mac() {
    local target="$1"
    [[ "$(get_distribution_name)" == "mac" ]] && \
        contains_element "$target" "${FILES_SHOULD_BE_COPIED_ON_ONLY_MAC[@]}"
}

function contains_element() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
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

    local msg=
    local ret=

    if [[ -d "$target" ]]; then

        pushd "$target" || {
            logger_err "Remaining processes will be aborted."
            return $ANSWER_OF_QUESTION_ABORTED
        }

        # Is the directory empty? If so, return GIT_UPDATE_TYPE_JUST_CLONE
        [[ -z "$(ls -A .)" ]] && {
            popd
            return $GIT_UPDATE_TYPE_JUST_CLONE
        }

        if git rev-parse --git-dir > /dev/null 2>&1; then
            local remote_url="$(git remote get-url "$remote" 2> /dev/null)"

            if [[ "$remote_url" == "$url" ]]; then
                local current_branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"

                if [[ "$current_branch" != "$branch" ]]; then
                    if [[ "$need_question" -eq 0 ]]; then
                        msg="The local branch(${current_branch}) in repository that located in \"${target}\" is differ from the branch(${branch}) that going to be updated."
                        msg+="\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
                        question "$msg"
                        ret=$?
                        [[ "$ret" -ne 0 ]] && {
                            echo "Re-cloning \"${target}\" was aborted."
                            popd
                            return $GIT_UPDATE_TYPE_ABOARTED
                        }
                    fi
                    popd
                    return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT
                fi

                # is_there_updates: 0 -> Updates are existed, 1: Updates are not existed
                local is_there_updates="$([[ "$(git status --porcelain 2> /dev/null | wc -l)" -ne 0 ]] && echo 0 || echo 1)"
                # is_there_pushes: 0 -> Files should be pushed are existed, 1: Files should be pushed are not existed
                local is_there_pushes="$([[ "$(git cherry -v 2> /dev/null | wc -l)" -ne 0 ]] && echo 0 || echo 1)"

                if [[ "$is_there_pushes" -eq 0 ]]; then
                    # Question then reinstall
                    if [[ "$need_question" -eq 0 ]]; then
                        msg="The git repository located in \"${target}\" has some unpushed commits."
                        msg+="\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
                        question "$msg"
                        ret=$?
                        [[ "$ret" -ne 0 ]] && {
                            echo "Re-cloning \"${target}\" was aborted."
                            popd
                            return $GIT_UPDATE_TYPE_ABOARTED
                        }
                    fi
                    popd
                    return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET
                else
                    # Question then "git reset --hard" and remove untrackedfiles then update
                    if [[ "$is_there_updates" -eq 0 ]]; then
                        if [[ "$need_question" -eq 0 ]]; then
                            msg="The git repository located in \"${target}\" has some uncommitted files."
                            msg+="\nDo you want to remove them and update the git repository? [y/N]: "
                            question "$msg"
                            ret=$?
                            [[ "$ret" -ne 0 ]] && {
                                echo "Updating git repository \"${target}\" was aborted."
                                popd
                                return $GIT_UPDATE_TYPE_ABOARTED
                            }
                        fi
                        popd
                        return $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL
                    else
                        # Update!!
                        popd
                        return $GIT_UPDATE_TYPE_JUST_PULL
                    fi
                fi
            else
                # Question then reinstall if the remote url is not match.
                if [[ "$need_question" -eq 0 ]]; then
                    msg="The git repository located in \"${target}\" is refering unexpected remote \"${remote_url}\" (expected is \"${url}\")."
                    msg+="\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
                    question "$msg"

                    ret=$?
                    [[ "$ret" -ne 0 ]] && {
                        echo "Re-cloning \"${target}\" was aborted."
                        popd
                        return $GIT_UPDATE_TYPE_ABOARTED
                    }
                fi
                popd
                return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE
            fi
        else
            # Question then reinstall if it is not a git repository.
            if [[ "$need_question" -eq 0 ]]; then
                msg="The directory \"${target}\" is not a git repository."
                msg+="\nDo you want to remove it and clone the repository? [y/N]: "
                question "$msg"
                ret=$?
                [[ "$ret" -ne 0 ]] && {
                    echo "Cloning the repository \"${target}\" was aborted."
                    popd
                    return $GIT_UPDATE_TYPE_ABOARTED
                }
            fi
            popd
            return $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY
        fi
    fi

    return $GIT_UPDATE_TYPE_JUST_CLONE
}

# Get git remote alias.
# For instance, origin.
function get_git_remote_aliases() {
    local directory="$1"

    local counter=0
    local e

    if [[ ! -d "$directory" ]]; then
        return 0
    fi

    pushd "$directory"
    while read e; do
        [[ "$counter" -ne 0 ]] && echo -n ","
        echo -n "$e"
        (( ++counter ))
    done < <(git remote 2> /dev/null)
    popd
    return 0
}

# Initialize dotfiles repo
function init_repo() {
    local url_of_repo="$1"
    local branch="$2"

    local homedir_of_repo="${HOME%/}"
    local dirname_of_repo="${DOTDIR%/}"

    pushd "$homedir_of_repo" || return 1

    update_git_repo "$homedir_of_repo" "$dirname_of_repo" "$url_of_repo" "$branch" || {
        logger_err "Updating repository of dotfiles was aborted due to previous error"
        popd
        return 1
    }
    local path_to_git_repo="${homedir_of_repo}/${dirname_of_repo}"

    # Freeze .gitconfig for not to push username and email
    pushd "$path_to_git_repo" || {
        logger_err "Failed to change the directory \"$path_to_git_repo\"."
        return 1
    }
    [[ -f "${path_to_git_repo}/.gitconfig" ]] \
            && git update-index --assume-unchanged .gitconfig

    git submodule init || {
        logger_err "\"git submodule init\" has failed. Submodules may not be installed correctly on your environment"
        popd; popd
        return 1
    }

    git submodule update || {
        logger_err "\"git submodule update\" has failed. Submodules may not be installed correctly on your environment"
        popd; popd
        return 1
    }

    popd; popd
    return 0
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
            logger_err "Failed to create the directory \"${homedir_of_repo}\""
            return 1
        }
    }

    # Create the directory path string of git
    local path_to_git_repo="${homedir_of_repo}/${dirname_of_repo}"
    # Declare an array named "remotes" that has remote names
    ## ----------------------------------------------------------
    ## TODO: This method is not supported older than bash version 4.4
    #eval "$(get_git_remote_aliases "$path_to_git_repo" remotes)"
    ## ----------------------------------------------------------
    local csv_remotes=$(get_git_remote_aliases "$path_to_git_repo")

    declare -a remotes=(${csv_remotes//,/ })
    ## ----------------------------------------------------------

    if [[ "${#remotes[@]}" -eq 1 ]] && [[ "${remotes[0]}" == "origin" ]]; then
        local remote="${remotes[0]}"
    elif [[ "${#remotes[@]}" -eq 0 ]] || ( [[ "${#remotes[@]}" -eq 1 ]] && [[ "${remotes[0]}" == "" ]] ); then
        # The directory may be not git repository. And it will be cloned as new git repository
        local remote="origin"
    else
        # TODO: Doesn't supported other than origin now
        local msg_remotes="${remotes[@]}"
        logger_err "Sorry, this script only supports single remote \"origin\". This repository has branche(s) \"${msg_remotes}\""
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
            pushd "$homedir_of_repo" || return 1
            git clone -b "$branch" "$url_of_repo" "$dirname_of_repo" || {
                logger_err "Failed to clone the repository(git clone -b \"$branch\" \"$url_of_repo\" \"$dirname_of_repo\")"
                popd
                return 1
            }
            popd
            ;;
        $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET | \
                $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT )
            rm -rf "$path_to_git_repo"

            pushd "$homedir_of_repo" || return 1
            git clone -b "$branch" "$url_of_repo" "$dirname_of_repo" || {
                logger_err "Failed to clone the repository(git clone -b \"$branch\" \"$url_of_repo\" \"$dirname_of_repo\")"
                popd
                return 1
            }
            popd
            ;;
        $GIT_UPDATE_TYPE_ABOARTED )
            logger_info "Updating or cloning repository \"${url_of_repo}\" has been aborted."
            return $GIT_UPDATE_TYPE_ABOARTED
            ;;
        * )
            if [[ "$remote" != "origin" ]]; then
                # TODO: Does not supported remote referencing other than origin yet.
                logger_err "Sorry, this script only supports remote as \"origin\". The repository had been going to clone remote as \"${remote}\""
                return 1
            fi

            pushd "$path_to_git_repo" || { return 1; }

            # Get branch name
            local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
            if [[ -z "$branch" ]]; then
                logger_err "Failed to get git branch name from \"${path_to_git_repo}\""
                popd
                return 1
            fi

            if [[ "$update_type" -eq $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL ]]; then
                # Reset and remove untracked files in git repository
                git reset --hard || {
                    logger_err "Failed to reset git repository at \"${path_to_git_repo}\" for some readson."
                    popd
                    return 1
                }
                remove_all_untracked_files "$path_to_git_repo"
            elif [[ "$update_type" -ne $GIT_UPDATE_TYPE_JUST_PULL ]]; then
                logger_err "Invalid git update type (${update_type}). Some error occured when determining git update type of \"${path_to_git_repo}\"."
                popd
                return 1
            fi
            # Type of GIT_UPDATE_TYPE_JUST_PULL will also reach this section.
            git pull "$remote" "$branch" || {
                logger_err "Failed to pull \"$remote\" \"$branch\"."
                popd
                return 1
            }
            popd
            ;;
    esac

    return 0
}

# Remove all files or directories untracked in git repository
function remove_all_untracked_files() {
    local directory="$1"
    local f

    pushd "$directory" || return 1
    while read f; do
        rm -rf "${directory}/${f}"
    done < <(git status --porcelain 2> /dev/null | grep -E '^\?\? .*' | cut -d ' ' -f 2)
    popd
}

# Initialize vim environment
function init_vim_environment() {

    pushd ${HOME}/${DOTDIR} || return 1

    # Install pathogen.vim
    mkdir -p ./.vim/autoload
    echo "curl -LSso ./.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim"
    curl -LSso ./.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

    # update vim's submodules
    # Link color theme
    mkdir -p .vim/colors/
    pushd .vim/colors || { popd; return 1; }
    ln -sf ../../resources/etc/config/vim/colors/molokai.vim

    popd; popd

    # prepare_neovim_environment || return 1

    return 0
}

function prepare_neovim_environment() {

    if [[ "$(get_distribution_name)" == "arch" ]]; then
        # Do nothing
        return 0
    fi

    true
}

# Install command utilities in "${DOTDIR}/bin/emojify"
function install_bin_utils() {
    _install_emojify || return 1
    return 0
}

function _install_emojify() {
    curl https://raw.githubusercontent.com/mrowa44/emojify/master/emojify -o "${HOME}/${DOTDIR}/bin/emojify" || {
        logger_err "Failed to download emojify from https://raw.githubusercontent.com/mrowa44/emojify/master/emojify"
        return 1
    }
    chmod +x "${DOTDIR}/bin/emojify"
}

# Get version of Linux.
# For example, if run this command on Ubuntu 20.04, it will return "20.04"
function get_linux_os_version() {
    source /etc/os-release > /dev/null 2>&1
    local result=$?

    echo "$VERSION_ID"
    return $result
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
    elif (grep -i ubuntu <<< "$release_info" > /dev/null 2>&1); then
        DISTRIBUTION="ubuntu"
    elif (grep -i debian <<< "$release_info" > /dev/null 2>&1); then
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
    command pushd "$@" > /dev/null || {
        logger_err "Failed to change (pushd) the directory to \"$@\""
        return 1
    }
    return 0
}
# Alias of silent popd
function popd() {
    command popd "$@" > /dev/null
}

# Compareing versions
# Return 1 if $1 greater than $2.
# Return 2 if $1 less than $2.
# Return 0 if $1 equals $2.
# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
function vercomp() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Is desktop installed?
function has_desktop_env() {
    if [[ "$(get_distribution_name)" == "mac" ]]; then
        return 0
    fi

    # If your environment is not Mac, check exactly whether the machine has desktop.
    [[ -d "/usr/share/xsessions" ]] && [[ ! -z "$(ls -A /usr/share/xsessions/*.desktop 2> /dev/null)" ]]
}

# Expanded mkdir
function mmkdir() {
    local dir="$1"
    mkdir -p "$dir" || {
        logger_err "Failed to create dir $dir"
        return 1
    }
    return 0
}
# Expanded ln for soft link
function lln() {
    local src="$1"
    local dest="$2"

    ln -sf "$src" "$dest" || {
        logger_err "Failed to create soft link \"${src} -> ${dest}\""
        return 1
    }
    return 0
}

if [[ "${#BASH_SOURCE[@]}" -eq 1 ]]; then
    # Call this script as ". ./script --load-functions" if you want to load functions only
    #set -eu
    main "$@"
    exit $?
fi

