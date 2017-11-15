#!/usr/bin/env bats
load helpers

function setup() {
    clear_call_count
    mkdir -p ${HOME}/${DOTDIR}
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR}
    cd ~
    rm -rf .local Library migu-1m* Inconsolata\ for\ Powerline*
    clear_call_count
}

function curl() {
    increment_call_count "curl"
    local option="$1"
    local filename="$2"

    fallocate -l 1 "$2"
}

function unzip() {
    increment_call_count "unzip"
    local filename="$1"

    if [[ ! "$filename" = "migu-1m-20150712.zip" ]]; then
        return 1
    fi

    mkdir ${filename%.*}
    pushd ${filename%.*}
    fallocate -l 1 migu-1m-bold.ttf
    fallocate -l 1 migu-1m-regular.ttf
    fallocate -l 1 migu-README.txt
    mkdir mplus-TESTFLIGHT-060
    popd
}

function fc-cache() { increment_call_count "fc-cache"; }
function install_packages_with_apt() { increment_call_count "install_packages_with_apt"; }
function install_packages_with_dnf() { increment_call_count "install_packages_with_dnf"; }
function install_packages_with_pacman() { increment_call_count "install_packages_with_pacman"; }

@test '#install_fonts should install Inconsolata Powerline, Inconsolata Powerline Nerd, Migu 1M, but not ipa-font on arch' {
    function get_distribution_name() { echo "arch"; }
    function do_i_have_admin_privileges() { return 1; }

    run install_fonts
    ls -l ${HOME}/.local/share/fonts/

    [[ "$status" -eq 0 ]]
    [[ "$(call_count curl)" -eq 2 ]]
    [[ "$(call_count unzip)" -eq 1 ]]
    [[ "$(call_count fc-cache)" -eq 1 ]]
    [[ "$(count ${HOME}/.local/share/fonts/)" -eq 3 ]]
    # [[ -f "${HOME}/.local/share/fonts/Inconsolata for Powerline Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/.local/share/fonts/Inconsolata Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/.local/share/fonts/migu-1m-bold.ttf" ]]
    [[ -f "${HOME}/.local/share/fonts/migu-1m-regular.ttf" ]]
    [[ "$(call_count install_packages_with_pacman)" -eq 0 ]]
}

@test '#install_fonts should install Inconsolata Powerline Nerd, Migu 1M, but not ipa-font on debian' {
    function get_distribution_name() { echo "debian"; }
    function do_i_have_admin_privileges() { return 1; }

    run install_fonts
    ls -l ${HOME}/.local/share/fonts/

    [[ "$status" -eq 0 ]]
    [[ "$(call_count curl)" -eq 2 ]]
    [[ "$(call_count unzip)" -eq 1 ]]
    [[ "$(call_count fc-cache)" -eq 1 ]]
    [[ "$(count ${HOME}/.local/share/fonts/)" -eq 3 ]]
    # [[ -f "${HOME}/.local/share/fonts/Inconsolata for Powerline Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/.local/share/fonts/Inconsolata Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/.local/share/fonts/migu-1m-bold.ttf" ]]
    [[ -f "${HOME}/.local/share/fonts/migu-1m-regular.ttf" ]]
    [[ "$(call_count install_packages_with_apt)" -eq 0 ]]
}

@test '#install_fonts should install Inconsolata Powerline, Inconsolata Powerline Nerd, Migu 1M, but not ipa-font on fedora' {
    function get_distribution_name() { echo "fedora"; }
    function do_i_have_admin_privileges() { return 1; }

    run install_fonts
    ls -l ${HOME}/.local/share/fonts/

    [[ "$status" -eq 0 ]]
    [[ "$(call_count curl)" -eq 2 ]]
    [[ "$(call_count unzip)" -eq 1 ]]
    [[ "$(call_count fc-cache)" -eq 1 ]]
    [[ "$(count ${HOME}/.local/share/fonts/)" -eq 3 ]]
    # [[ -f "${HOME}/.local/share/fonts/Inconsolata for Powerline Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/.local/share/fonts/Inconsolata Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/.local/share/fonts/migu-1m-bold.ttf" ]]
    [[ -f "${HOME}/.local/share/fonts/migu-1m-regular.ttf" ]]
    [[ "$(call_count install_packages_with_dnf)" -eq 0 ]]
}


@test '#install_fonts should install Inconsolata Powerline, Inconsolata Powerline Nerd, Migu 1M on mac' {
    function get_distribution_name() { echo "mac"; }
    function do_i_have_admin_privileges() { return 1; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(call_count curl)" -eq 2 ]]
    [[ "$(call_count unzip)" -eq 1 ]]
    [[ "$(call_count fc-cache)" -eq 1 ]]
    [[ "$(count ${HOME}/Library/Fonts/)" -eq 3 ]]
    # [[ -f "${HOME}/Library/Fonts/Inconsolata for Powerline Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/Library/Fonts/Inconsolata Nerd Font Complete.otf" ]]
    [[ -f "${HOME}/Library/Fonts/migu-1m-bold.ttf" ]]
    [[ -f "${HOME}/Library/Fonts/migu-1m-regular.ttf" ]]
}

@test '#install_fonts should install ipafonts on arch if installing  mplus font has failed' {
    function get_distribution_name() { echo "arch"; }
    function do_i_have_admin_privileges() { return 0; }
    function unzip() { true "do nothing for installing mplus font"; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(call_count install_packages_with_pacman)" -eq 1 ]]
}

@test '#install_fonts should install ipafonts on debian if installing  mplus font has failed' {
    function get_distribution_name() { echo "debian"; }
    function do_i_have_admin_privileges() { return 0; }
    function unzip() { true "do nothing for installing mplus font"; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(call_count install_packages_with_apt)" -eq 1 ]]
}

@test '#install_fonts should install ipafonts on fedora if installing  mplus font has failed' {
    function get_distribution_name() { echo "fedora"; }
    function do_i_have_admin_privileges() { return 0; }
    function unzip() { true "do nothing for installing mplus font"; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(call_count install_packages_with_dnf)" -eq 1 ]]
}

@test '#install_fonts should install ipafonts on arch if migu-1m-bold.ttf is emptry' {
    function get_distribution_name() { echo "arch"; }
    function do_i_have_admin_privileges() { return 0; }
    function unzip() {
        increment_call_count "unzip"
        local filename="$1"

        if [[ ! "$filename" = "migu-1m-20150712.zip" ]]; then
            return 1
        fi

        mkdir ${filename%.*}
        pushd ${filename%.*}
        touch migu-1m-bold.ttf
        fallocate -l 1 migu-1m-regular.ttf
        fallocate -l 1 migu-README.txt
        mkdir mplus-TESTFLIGHT-060
        popd
    }
    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(call_count install_packages_with_pacman)" -eq 1 ]]

    declare -a outputs=
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" = "WARN: Failed to install migu-fonts for some reason." ]]
    [[ "${outputs[1]}" = "WARN: Attempting to install ipa fonts instead." ]]
}

@test '#install_fonts should install ipafonts on arch if migu-1m-regular.ttf is emptry' {
    function get_distribution_name() { echo "arch"; }
    function do_i_have_admin_privileges() { return 0; }
    function unzip() {
        increment_call_count "unzip"
        local filename="$1"

        if [[ ! "$filename" = "migu-1m-20150712.zip" ]]; then
            return 1
        fi

        mkdir ${filename%.*}
        pushd ${filename%.*}
        fallocate -l 1 migu-1m-bold.ttf
        touch migu-1m-regular.ttf
        fallocate -l 1 migu-README.txt
        mkdir mplus-TESTFLIGHT-060
        popd
    }
    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(call_count install_packages_with_pacman)" -eq 1 ]]

    declare -a outputs=
    IFS=$'\n' outputs=($output)
    [[ "${outputs[0]}" = "WARN: Failed to install migu-fonts for some reason." ]]
    [[ "${outputs[1]}" = "WARN: Attempting to install ipa fonts instead." ]]
}
