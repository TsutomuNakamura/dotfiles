#!/usr/bin/env bash
trap 'echo "SIG INT was received. This program will be terminated." && exit 1' INT

# URI of dotfiles repository
REPO_URI="https://github.com/TsutomuNakamura/dotfiles"
# The directory that dotfiles resources will be installed
DOTDIR=".dotfiles"
# The directory that dotfiles resources will be backuped
BACKUPDIR=".backup_of_dotfiles"
# Distribution of this environment
DISTRIBUTION=

function main() {

    local flag_init=0
    local flag_deploy=0
    local flag_only_install_packages=0
    local flag_no_install_packages=0
    local branch="master"
    local flag_cleanup=0

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
                REPO_URI="git@github.com:TsutomuNakamura/dotfiles.git";;
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
        init "$branch" "$flag_no_install_packages" && deploy
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

    # Install patched fonts in your home environment
    # Cloe the repository if it's not existed
    init_repo "$branch"
    install_fonts
    init_vim_environment
}

# Install packages
function install_packages() {
    if [[ "$(get_distribution_name)" = "debian" ]]; then
        install_packages_with_apt git vim vim-gtk ctags tmux zsh unzip
    elif [[ "$(get_distribution_name)" = "fedora" ]]; then
        install_packages_with_dnf git vim ctags tmux zsh unzip
    elif [[ "$(get_distribution_name)" = "arch" ]]; then
        install_packages_with_pacman git gvim ctags tmux zsh unzip gnome-terminal
    elif [[ "$(get_distribution_name)" = "mac" ]]; then
        install_packages_with_homebrew vim ctags tmux zsh unzip
    fi
}

# Get the value of XDG_CONFIG_HOME for individual environments appropliately.
function get_xdg_config_home() {
    if [[ -z "${XDG_CONFIG_HOME}" ]]; then
        if [[ "$(get_distribution_name)" = "mac" ]]; then
            echo "${HOME}/Library/Preferences"
        else
            echo "${HOME}/.config"
        fi
    else
        echo "${XDG_CONFIG_HOME}"
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
        echo "${XDG_DATA_HOME}"
    fi
}

# Installe font
function install_fonts() {
    if [[ "$(get_distribution_name)" = "mac" ]]; then
        local font_dir="$(get_xdg_data_home)/Fonts"
    else
        local font_dir="$(get_xdg_data_home)/fonts"
    fi

    mkdir -p $font_dir
    pushd $font_dir

    # Inconsolata for Powerlin will be deployed from the repository

    # Inconsolata for Powerline Nerd Font Complete Mono.otf
    curl -fLo "Inconsolata for Powerline Nerd Font Complete.otf" \
            https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/Inconsolata/complete/Inconsolata%20for%20Powerline%20Nerd%20Font%20Complete.otf

    # Migu 1M for Japanese font
    curl -fLo "migu-1m-20150712.zip" \
        https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip

    unzip migu-1m-20150712.zip
    pushd migu-1m-20150712
    mv ./*.ttf ../
    popd
    rm -rf migu-1m-20150712 migu-1m-20150712.zip

    # IPAFonts for express Japanese characters
    if do_i_have_admin_privileges; then
        if [ "$(get_distribution_name)" == "debian" ]; then
            install_packages_with_apt fonts-ipafont
        elif [ "$(get_distribution_name)" == "fedora" ]; then
            install_packages_with_dnf ipa-gothic-fonts ipa-mincho-fonts
        elif [ "$(get_distribution_name)" == "arch" ]; then
            install_packages_with_pacman otf-ipafont
        elif [ "$(get_distribution_name)" == "mac" ]; then
            true    # TODO:
        fi
    fi

    popd
    echo "Building font information cache files with \"fc-cache -f ${font_dir}\""
    fc-cache -f $font_dir
}

function install_packages_with_apt() {
    declare -a packages=($@)
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local output=

    ${prefix} apt-get update
    for (( i = 0; i < ${#packages[@]}; i++ )) {
        echo "Installing ${packages[i]}..."
        output="$(${prefix} apt-get install -y ${packages[i]} 2>&1)" || {
            echo "ERROR: Some error occured when installing ${packages[i]}"
            echo "${output}"
        }
    }
}

function install_packages_with_dnf() {
    declare -a packages=($@)
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )
    local output=

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        echo "Installing ${packages[i]}..."
        output="$(${prefix} dnf install -y ${packages[i]} 2>&1)" || {
            echo "ERROR: Some error occured when installing ${packages[i]}"
            echo "${output}"
        }
    }
}

function install_packages_with_pacman() {
    declare -a packages=($@)
    local prefix=$( (command -v sudo > /dev/null 2>&1) && echo "sudo" )

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        echo "${prefix} pacman -Sy --noconfirm ${packages[i]}"
        ${prefix} pacman -Sy --noconfirm ${packages[i]}
    }
}

function install_packages_with_homebrew() {
    declare -a packages=($@)
    local output=

    for (( i = 0; i < ${#packages[@]}; i++ )) {
        output="$(brew install ${packages[i]} 2>&1)" || {
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

# BAckup current backup files
function backup_current_dotfiles() {

    [ ! -d "${HOME}/${DOTDIR}" ] && {
        echo "There are no dotfiles to backup."
        return
    }

    local backup_dir="${HOME}/${BACKUPDIR}/$(date "+%Y%m%d%H%M%S")"
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
        if should_it_make_deep_link_directory "${dotfiles[i]}" \
                || is_xdg_base_directory "${dotfiles[i]}"; then
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

    popd
}

# Deploy resources about xdg_base directories
function deploy_xdg_base_directory() {
    # XDG_CONFIG_HOME
    # XDG_DATA_HOME

    # Deploy fonts in dotfiles repository
    

    # Deploy fontconfig
    true
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
        git pull origin $branch
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

if [[ "$1" != "--load-functions" ]]; then
    # Call this script as ". ./script --load-functions" if you want to load functions only
    set -eu
    main "$@"
fi

