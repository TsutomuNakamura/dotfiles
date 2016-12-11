#!/usr/bin/env bash
set -eu

trap 'echo "SIG INT was received. This program will be terminated." && exit 1' INT

# URI of dotfiles repository
REPO_URI="https://github.com/TsutomuNakamura/dotfiles"
# The directory whom dotfiles resources will be installed
DOTDIR=".dotfiles"
# Base directory for running this script
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Distribution of this environment
DISTRIBUTION=

cd $BASE_DIR

function main() {
    opts=$(
        getopt -o "idonb:" --long "init,deploy,only-install-packages,no-install-packages,branch:" -- "$@"
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
            -h | --help )
                usage && return 0 ;;
            -- )
                shift; break ;;
            * )
                break ;;
        esac
    done

    branch=${branch:-master}
    echo "Branch name: ${branch}"
    exit        # TODO: test

    if [ "$flag_only_install_packages" == "1" ] && [ "$flag_no_install_packages" == "1" ]; then
        echo "Some contradictional options were found. (-o|--only-install-packages and -n|--no-install-packages)"
        return 1
    fi

    if [ "$flag_only_install_packages" == "0" ]; then
        if [ "$flag_init" == "1" ]; then
            init "$branch" "$flag_no_install_packages"
        elif [ "$flag_deploy" == "1" ]; then
            deploy
        elif [ "$flag_init" != "1" ] && [ "$flag_deploy" != "1" ]; then
            init "$branch" && deploy
        fi
    else
        if do_i_have_admin_privileges; then
            install_packages
        else
            echo "Sorry, you don't have privileges to install packages."
            return 1
        fi
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

    mkdir -p ${HOME}/${DOTDIR}

    if [ "$flag_no_install_packages" == 0 ]; then
        # Am I root? Or, am I in the sudoers?
        if do_i_have_admin_privileges; then
            install_packages
        else
            echo "= NOTICE ========================================================"
            echo "You don't have privileges to install packages."
            echo "Process of installing packages will be skipped."
            echo "================================================================="
        fi
    fi

    cleanup_current_dotfiles
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
    # TODO
    true
}

function install_packages_with_dnf() {
    # TODO
    true
}

function install_packages_with_pacman() {
    declare -a packages=($@)

    local installed_list="$(sudo pacman -Qe)"

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        if (grep "^${packages[i]} " <<< "$installed_list" > /dev/null); then
            echo "The package ${packages[i]} is already installed."
        else
            echo "pacman -Sy --noconfirm ${packages[i]}"
            pacman -Sy --noconfirm ${packages[i]}
        fi
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
function cleanup_current_dotfiles() {
    #local backup_dir="${HOME}/${DOTDIR}/.backup_of_dotfiles/$(date "+%Y%m%d%H%M%S")"
    local backup_dir="${HOME}/.backup_of_dotfiles/$(date "+%Y%m%d%H%M%S")"
    declare -a dotfiles=($(get_target_dotfiles "${HOME}"))

    mkdir -p ${backup_dir}
    pushd ${HOME}
    for (( i = 0; i < ${#dotfiles[@]}; i++ )) {
        echo "Backup dotfiles...: cp -Lpr ${dotfiles[i]} ${backup_dir}"
        cp -Lpr ${dotfiles[i]} ${backup_dir}

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
    [ "$(whoami)" == "root" ] || (sudo -v 2> /dev/null)
}

# Initialize dotfiles repo
function init_repo() {

    local branch="$1"

    [ -d "${HOME}/${DOTDIR}" ] && {
        echo "Creating a directory -> mkdir -p ${HOME}/${DOTDIR}"
        mkdir -p ${HOME}/${DOTDIR}
    }

    # Is here the git repo?
    pushd ${HOME}/${DOTDIR}
    if is_here_git_repo; then
        echo "The repository ${REPO_URI} is already existed. Pulling from \"origin master\""
        git pull origin $branch    # TODO: testing
        # TODO: error handling
    else
        echo "The repository is not existed. Cloning branch from ${REPO_URI} then checkout branch ${branch}"
        git clone -b $branch $REPO_URI .
    fi

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
    if [ ! -z $DISTRIBUTION ]; then
        echo "${DISTRIBUTION}"
        return
    fi

    local release_info="$(cat /etc/*-release)"

    if (grep -i fedora <<< "$release_info" > /dev/null 2>&1); then
        DISTRIBUTION="fedora"
    elif (grep -i ubuntu <<< "$release_info" > /dev/null 2>&1) || \
            (grep -i debian <<< "$release_info" > /dev/null 2>&1); then
        # Like debian
        DISTRIBUTION="debian"
    elif (grep -i "arch linux" <<< "$release_info" > /dev/null 2>&1); then
        DISTRIBUTION="arch"
    else
        DISTRIBUTION="unknown"
    fi

    echo "$DISTRIBUTION"
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

