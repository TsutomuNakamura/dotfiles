#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    cd "${HOME}"
    function get_distribution_name  { echo "debian"; }
    function get_xdg_data_home      { echo "${HOME}/.local/share"; }
    stub mkdir
    stub pushd
    stub popd
    stub fc-cache
    stub install_the_font
    stub logger_info
}

function teardown() {
    cd "${HOME}"
}

function assert_install_the_nerd_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} \
            "_install_font_inconsolata_nerd" \
            "Inconsolata for Powerline Nerd Font" \
            "" \
            "For more information about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."
}
function assert_install_the_migu1m_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} \
            "_install_font_migu1m" \
            "Migu 1M Font" \
            "" \
            "For more information about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"." \
            "The program will install IPA font alternatively." \
            "The program will install IPA font alternatively."
}
function assert_install_the_noto_emoji_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} \
            "_install_font_noto_emoji" \
            "NotoEmojiFont" \
            "" \
            "For more information about the font, please see \"https://github.com/googlei18n/noto-emoji\"." \
            "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary." \
            "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary."
}
function assert_install_the_ipa_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} "_install_font_ipafont" "IPA Font" "" "" "" ""
}

@test '#install_fonts should call install_the_font() for Nerd Font, Migu1M Font, Noto Emoji Font (but not IPA Font) on linux(debian).' {
    run install_fonts

    [[ "$status" -eq 0 ]]
    declare -a outputs
    IFS=$'\n' outputs=($output)
    # [[ ${outputs[0]} = "Building font information cache files with \"fc-cache -f ${HOME}/.local/share/fonts\"" ]]
    stub_called_with_exactly_times mkdir 1 -p "${HOME}/.local/share/fonts"
    stub_called_with_exactly_times pushd 1 "${HOME}/.local/share/fonts"
    [[ "$(stub_called_times popd)"                -eq 1 ]]
    [[ "$(stub_called_times fc-cache)"            -eq 0 ]]

    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
}

@test '#install_fonts should call install_the_font() for Nerd Font, Migu1M Font (but not Emoji font and IPA Font) on mac.' {
    function get_distribution_name()                { echo "mac"; }
    function get_xdg_data_home()                    { echo "${HOME}/Library"; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    declare -a outputs; IFS=$'\n' outputs=($output)
    # [[ ${outputs[0]} = "Building font information cache files with \"fc-cache -f ${HOME}/Library/Fonts\"" ]]
    stub_called_with_exactly_times mkdir 1 -p "${HOME}/Library/Fonts"
    stub_called_with_exactly_times pushd 1 "${HOME}/Library/Fonts"
    [[ "$(stub_called_times popd)"                -eq 1 ]]
    [[ "$(stub_called_times fc-cache)"            -eq 0 ]]

    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  0
    assert_install_the_ipa_font         0
}

@test '#install_fonts should return 0 if _install_font_inconsolata_nerd() returns 1 (installing the font has succeeded).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_inconsolata_nerd" ]] && return 1 || return 0; }'
    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0

    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

@test '#install_fonts should return 1 if _install_font_inconsolata_nerd() returns 2 (installing the font has failed).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_inconsolata_nerd" ]] && return 2 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0

    # stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    # stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

@test '#install_fonts should return 1 if _install_font_inconsolata_nerd() returns 3 (installing the font has failed by unknown error).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_inconsolata_nerd" ]] && return 3 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0

    # stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    # stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

@test '#install_fonts should return 0 if _install_font_noto_emoji() returns 1 (installing the font has succeeded).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_noto_emoji" ]] && return 1 || return 0; }'
    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

@test '#install_fonts should return 1 if _install_font_noto_emoji() returns 2 (installing the font has failed).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_noto_emoji" ]] && return 2 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
    # stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    # stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

@test '#install_fonts should return 1 if _install_font_noto_emoji() returns 2 (installing the font has failed by unknown error).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_noto_emoji" ]] && return 3 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 0 ]]
    [[ "$(stub_called_times logger_info)" -eq 0 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
    # stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    # stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

@test '#install_fonts should return 0 if _install_font_migu1m() returns 1 (installing the font has succeeded).' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_migu1m" ]] && return 1 || return 0; }'
    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times fc-cache)"               -eq 1 ]]
    [[ "$(stub_called_times logger_info)" -eq 1 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
    stub_called_with_exactly_times logger_info 1 "Font cache was recreated."
}

