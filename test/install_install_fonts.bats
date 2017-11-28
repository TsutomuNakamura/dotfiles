#!/usr/bin/env bats
load helpers

function setup() {
    cd "${HOME}"
    function get_distribution_name  { echo "debian"; }
    function get_xdg_data_home      { echo "${HOME}/.local/share"; }
    function mkdir { true; }
    function pushd { true; }
    function popd { true; }
    function fc-cache { true; }
    stub install_the_font
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
            "For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary." \
            "Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."
}
function assert_install_the_migu1m_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} \
            "_install_font_migu1m" \
            "Migu 1M Font" \
            "" \
            "For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"." \
            "The program will install IPA font alternatively." \
            "The program will install IPA font alternatively."
}
function assert_install_the_noto_emoji_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} \
            "_install_font_noto_emoji" \
            "NotoEmojiFont" \
            "" \
            "For more infotmation about the font, please see \"https://github.com/googlei18n/noto-emoji\"." \
            "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary." \
            "Please install it manually from \"https://github.com/googlei18n/noto-emoji\" if necessary."
}
function assert_install_the_ipa_font() {
    local count=$1
    stub_called_with_exactly_times install_the_font ${count} "_install_font_ipafont" "IPA Font" "" "" "" ""
}

@test '#install_fonts should call install_the_font() for Nerd Font, Migu1M Font, Noto Emoji Font (but not IPA Font) on linux(debian).' {
    stub mkdir; stub pushd; stub popd; stub fc-cache

    run install_fonts

    [[ "$status" -eq 0 ]]
    declare -a outputs
    IFS=$'\n' outputs=($output)
    [[ ${outputs[0]} = "Building font information cache files with \"fc-cache -f ${HOME}/.local/share/fonts\"" ]]
    stub_called_with_exactly_times mkdir 1 -p "${HOME}/.local/share/fonts"
    stub_called_with_exactly_times pushd 1 "${HOME}/.local/share/fonts"
    [[ "$(stub_called_times popd)"                -eq 1 ]]

    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
}

@test '#install_fonts should call install_the_font() for Nerd Font, Migu1M Font, Noto Emoji Font (but not IPA Font) on mac.' {
    stub mkdir; stub pushd; stub popd; stub fc-cache
    function get_distribution_name()                { echo "mac"; }
    function get_xdg_data_home()                    { echo "${HOME}/Library"; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    declare -a outputs
    IFS=$'\n' outputs=($output)
    [[ ${outputs[0]} = "Building font information cache files with \"fc-cache -f ${HOME}/Library/Fonts\"" ]]
    stub_called_with_exactly_times mkdir 1 -p "${HOME}/Library/Fonts"
    stub_called_with_exactly_times pushd 1 "${HOME}/Library/Fonts"
    [[ "$(stub_called_times popd)"                -eq 1 ]]

    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/Library/Fonts
}

@test '#install_fonts should not return 1 if _install_font_inconsolata_nerd() has failed.' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_inconsolata_nerd" ]] && return 1 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
}

@test '#install_fonts should not return 1 if _install_font_noto_emoji() has failed.' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_noto_emoji" ]] && return 1 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         0
}

@test '#install_fonts should not return 1 if _install_font_migu1m() has failed then call _install_font_ipafont()' {
    stub_and_eval install_the_font '{ [[ "$1" = "_install_font_migu1m" ]] && return 1 || return 0; }'
    run install_fonts

    [[ "$status" -eq 1 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         1
}

@test '#install_fonts should not return 2 if _install_font_migu1m() has failed then call _install_font_ipafont() and failed it' {
    stub_and_eval install_the_font '{
        if [[ "$1" = "_install_font_migu1m" ]] || [[ "$1" = "_install_font_ipafont" ]]; then
            return 1
        fi
        return 0
    }'
    run install_fonts

    [[ "$status" -eq 2 ]]
    assert_install_the_nerd_font        1
    assert_install_the_migu1m_font      1
    assert_install_the_noto_emoji_font  1
    assert_install_the_ipa_font         1
}

