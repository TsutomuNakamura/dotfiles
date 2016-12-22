#!/usr/bin/env bash
set -eu

trap 'echo "SIG INT was received. This program will be terminated." && exit 1' INT

# URI of dotfiles repository
REPO_URI="https://github.com/TsutomuNakamura/dotfiles"
# The directory whom dotfiles resources will be installed
DOTDIR=".dotfiles"
## # Base directory for running this script
## BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Distribution of this environment
DISTRIBUTION=

## cd $BASE_DIR

function main() {
    opts=$(
        getopt -o "idonb:c" --long "init,deploy,only-install-packages,no-install-packages,branch:,cleanup" -- "$@"
    )

    [ $? != 0 ] && {
        echo "Unknown options have been detected."
        usage
        return 1
    }

    eval set -- "$opts"

    local flag_init=0
    local flag_deploy=0
    local flag_only_install_packages=0
    local flag_no_install_packages=0
    local branch=
    local flag_cleanup=0

    while true; do
        case "$1" in
            -i | --init )
                flag_init=1;    shift ;;
            -d | --deploy )
                flag_deploy=1;  shift ;;
            -o | --only-install-packages )
                flag_only_install_packages=1; shift ;;
            -n | --no-install-packages )
                flag_no_install_packages=1; shift ;;
            -b | --branch )
                branch=$2; shift 2 ;;
            -c | --cleanup )
                flag_cleanup=1; shift ;;
            -h | --help )
                usage && return 0 ;;
            -- )
                shift; break ;;
            * )
                break ;;
        esac
    done

    branch=${branch:-master}

    if [ "$flag_only_install_packages" == "1" ] && [ "$flag_no_install_packages" == "1" ]; then
        echo "Some contradictional options were found. (-o|--only-install-packages and -n|--no-install-packages)"
        return 1
    fi

    if [ "$flag_only_install_packages" == "1" ]; then
        if do_i_have_admin_privileges; then
            install_packages
        else
            echo "Sorry, you don't have privileges to install packages."
            return 1
        fi
    elif [ "$flag_cleanup" == "1" ]; then
        backup_current_dotfiles
    elif [ "$flag_init" == "1" ]; then
        init "$branch" "$flag_no_install_packages"
    elif [ "$flag_deploy" == "1" ]; then
        deploy
    elif [ "$flag_init" != "1" ] && [ "$flag_deploy" != "1" ]; then
        init "$branch" && deploy
    fi

    return 0
}

function usage() {
    echo "usage"
}

# Initialize dotfiles repo
function init() {

    local branch=${1:-master}
    local flag_no_install_packages=${2:-0}

    if [ "$flag_no_install_packages" == 0 ]; then
        if do_i_have_admin_privileges; then
            # Am I root? Or, am I in the sudoers?
            install_packages
        else
            echo "= NOTICE ========================================================"
            echo "You don't have privileges to install packages."
            echo "Process of installing packages will be skipped."
            echo "================================================================="
        fi
    fi

    ## backup_current_dotfiles
    # Install patched fonts in your home environment
    install_patched_fonts
    # Cloe the repository if it's not existed
    init_repo "$branch"
    init_vim_environment
}

# Install packages
function install_packages() {
    if [ "$(get_distribution_name)" == "debian" ]; then
        install_packages_with_apt git vim vim-gtk ctags tmux
    elif [ "$(get_distribution_name)" == "fedora" ]; then
        install_packages_with_dnf git vim vim-gtk ctags tmux
    elif [ "$(get_distribution_name)" == "arch" ]; then
        install_packages_with_pacman git gvim ctags tmux
    elif [ "$(get_distribution_name)" == "mac" ]; then
        install_packages_with_homebrew vim ctags tmux
    fi
}

# Installe patched powerline fonts
function install_patched_fonts() {
    local font_tmp_dir="${HOME}/${DOTDIR}/resources/dependencies/fonts"
    pushd ${font_tmp_dir}
    bash ./install.sh                                 # TODO: error handling
    popd
}

function install_packages_with_apt() {
    declare -a packages=($@)
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )

    ${prefix} apt-get update
    for (( i = 0; i < ${#packages[@]}; i++ )) {
        ${prefix} apt-get install -y ${packages[i]}
    }
}

function install_packages_with_dnf() {
    declare -a packages=($@)
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        ${prefix} dnf install -y ${packages[i]}
    }
}

function install_packages_with_pacman() {
    declare -a packages=($@)

    local installed_list="$(pacman -Qe)"
    local prefix=$( (command -v apt-get > /dev/null 2>&1) && echo "sudo" )

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        if (grep "^${packages[i]} " <<< "$installed_list" > /dev/null); then
            echo "The package ${packages[i]} is already installed."
        else
            echo "${prefix} pacman -Sy --noconfirm ${packages[i]}"
            ${prefix} pacman -Sy --noconfirm ${packages[i]}
        fi
    }
}

function install_packages_with_homebrew() {
    declare -a packages=($@)

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        brew install ${packages[i]}
    }
}

function should_the_dotfile_be_skipped() {
    local target="$1"
    [[ "$target" == ".git" ]] ||                        \
            [[ "$target" == ".DS_Store" ]] ||           \
            [[ "$target" == ".gitignore" ]] ||          \
            [[ "$target" == ".gitmodules" ]] ||         \
            [[ "$target" == "*.swp" ]] ||               \
            [[ "$target" == ".dotfiles" ]] ||           \
            [[ "$target" == ".backup_of_dotfiles" ]]
}

function get_target_dotfiles() {
    local dir="$1"
    declare -a dotfiles=()
    pushd ${dir}

    for f in .??*
    do
        (should_the_dotfile_be_skipped "$f") || {
            dotfiles+=($f)
        }
    done

    popd
    echo ${dotfiles[@]}
}

# BAckup current backup files
function backup_current_dotfiles() {

    [ ! -d "${HOME}/${DOTDIR}" ] && {
        echo "There are no dotfiles to backup."
        return
    }

    local backup_dir="${HOME}/.backup_of_dotfiles/$(date "+%Y%m%d%H%M%S")"
    declare -a dotfiles=($(get_target_dotfiles "${HOME}/${DOTDIR}"))

    mkdir -p ${backup_dir}
    pushd ${HOME}
    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        [ -e ${dotfiles[i]} ] || continue

        echo "Backup dotfiles...: cp -Lpr ${dotfiles[i]} ${backup_dir}"
        cp -Lpr ${dotfiles[i]} ${backup_dir}

        echo "Removing ${dotfiles[i]} ..."
        if [ -L ${dotfiles[i]} ]; then
            unlink ${dotfiles[i]}
        elif [ -d ${dotfiles[i]} ]; then
            rm -rf ${dotfiles[i]}
        else
            rm -f ${dotfiles[i]}
        fi
    }
    popd
}

# Deploy dotfiles on user's home directory
function deploy() {

    backup_current_dotfiles

    declare -a dotfiles=($(get_target_dotfiles "${HOME}/${DOTDIR}"))

    pushd ${HOME}
    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        echo "Creating a symbolic link -> ${DOTDIR}/${dotfiles[i]}"
        ln -s ${DOTDIR}/${dotfiles[i]}
    }
    popd
}

# Check whether I have admin privileges or not
function do_i_have_admin_privileges() {
    [ "$(whoami)" == "root" ] ||  ((command -v apt-get > /dev/null 2>&1) && (sudo -v 2> /dev/null))
}

# Initialize dotfiles repo
function init_repo() {

    local branch="$1"

    mkdir -p "${HOME}/${DOTDIR}"
    [ -d "${HOME}/${DOTDIR}" ] || {
        echo "Failed to create the directory ${HOME}/${DOTDIR}."
        return 1
    }

    # Is here the git repo?
    pushd ${HOME}/${DOTDIR}
    if is_here_git_repo; then
        echo "The repository ${REPO_URI} is already existed. Pulling from \"origin $branch\""
        git pull origin $branch    # TODO: testing
        # TODO: error handling
    else

        local files=$(shopt -s nullglob dotglob; echo ${HOME}/${DOTDIR}/*)
        if (( ${#files} )); then
            # Contains some files
            echo "Couldn't clone the dotfiles repository because of the directory ${HOME}/${DOTDIR}/ is not empty"
            return 1
        fi

        echo "The repository is not existed. Cloning branch from ${REPO_URI} then checkout branch ${branch}"
        git clone -b $branch $REPO_URI .
    fi

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
    # TODO
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    # Is Mac OS?
    if [ "$(uname)" == "Darwin" ] || (command -v brew > /dev/null 2>&1); then
        DISTRIBUTION="mac"
    fi
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    local release_info="$(cat /etc/*-release 2> /dev/null)"

    # Check the distribution from release-infos
    if (grep -i fedora <<< "$release_info" > /dev/null 2>&1); then
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
    [ ! -z ${DISTRIBUTION} ] && echo "${DISTRIBUTION}" && return

    echo "unknown"
}

# Check current directory is whether git repo or not.
function is_here_git_repo() {
    [ -d .git ] || (git rev-parse --git-dir > /dev/null 2>&1)
}

function pushd() {
    command pushd "$@" > /dev/null
}

function popd() {
    command popd "$@" > /dev/null
}

main "$@"

