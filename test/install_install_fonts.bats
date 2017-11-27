#!/usr/bin/env bats
load helpers

function setup() {
    cd "${HOME}"
    function get_distribution_name  { echo "debian"; }
    function get_xdg_data_home      { echo "${HOME}/.local/share"; }
    function fc-cache { true; }
    stub_and_eval _install_font_inconsolata_nerd    '{ return 1; }'
    stub_and_eval _install_font_migu1m              '{ return 1; }'
    stub_and_eval _install_font_noto_emoji          '{ return 1; }'
    stub_and_eval _install_font_ipafont             '{ return 1; }'
    stub push_info_message_list
    stub push_warn_message_list
    stub echo
}

function teardown() {
    cd "${HOME}"
    rm -rf .local
}

@test '#install_fonts should _install_font_inconsolata_nerd(), _install_font_migu1m(), _install_font_noto_emoji(), _install_font_ipafont() on linux(debian).' {
    stub fc-cache

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times push_info_message_list 1 \
            "INFO: Inconsolata for Powerline Nerd Font was installed.\n  For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"."
    stub_called_with_exactly_times push_info_message_list 1 \
            "INFO: Migu 1M font was installed.\n  For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"."
    stub_called_with_exactly_times push_info_message_list 1 \
            "INFO: NotoEmojiFont was installed.\n  For more infotmation about the font, please see \"https://github.com/googlei18n/noto-emoji\"."
    stub_called_with_exactly_times push_info_message_list 0 \
            "INFO: IPA font was installed successflly."

    # Error should NOT occured
    stub_called_with_exactly_times push_warn_message_list 0 \
            "ERROR: Failed to install Inconsolata for Powerline Nerd Font.\n  Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."
    stub_called_with_exactly_times push_warn_message_list 0 \
            "ERROR: Failed to install migu-fonts for some reason."
    stub_called_with_exactly_times push_warn_message_list 0 \
            "ERROR: Failed to install NotoEmojiFont.\n  The program will install IPA font alternatively."
    stub_called_with_exactly_times push_warn_message_list 0 \
            "ERROR: Failed to install Inconsolata for Powerline Nerd Font.\n  The program will install IPA font alternatively."

    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/.local/share/fonts
}

@test '#install_fonts should _install_font_inconsolata_nerd(), _install_font_migu1m(), _install_font_noto_emoji(), _install_font_ipafont() on Mac.' {
    stub fc-cache
    function get_distribution_name()                { echo "mac"; }
    function get_xdg_data_home()                    { echo "${HOME}/Library"; }

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times push_info_message_list 1 \
            "INFO: Inconsolata for Powerline Nerd Font has installed.\n  For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"."
    stub_called_with_exactly_times push_info_message_list 1 \
            "INFO: Migu 1M font has installed.\n  For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"."
    stub_called_with_exactly_times push_info_message_list 1 \
            "INFO: NotoEmojiFont has installed.\n  For more infotmation about the font, please see \"https://github.com/googlei18n/noto-emoji\"."
    stub_called_with_exactly_times push_info_message_list 0 \
            "INFO: IPA Font has installed."

    stub_called_with_exactly_times fc-cache 1 -f ${HOME}/Library/Fonts
}


@test '#install_fonts should not call push_info_message_list and push_warn_message_list if _install_font_inconsolata_nerd() return 0 (nerd font has already installed).' {

    stub_and_eval _install_font_inconsolata_nerd '{ return 0; }'

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times echo 1 "INFO: Inconsolata for Powerline Nerd Font has already installed. Skipping."
    stub_called_with_exactly_times push_info_message_list 0 "INFO: Inconsolata for Powerline Nerd Font has installed.\n  For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"."
    stub_called_with_exactly_times push_warn_message_list 0 "ERROR: Failed to install Inconsolata for Powerline Nerd Font.\n  Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."

    stub_called_with_exactly_times echo 0 "ERROR: Unknown error was occured when installing Inconsolata for Powerline Nerd Font."
    stub_called_with_exactly_times push_warn_message_list 0 "ERROR: Unknown error was occured when installing Inconsolata for Powerline Nerd Font."
}

@test '#install_fonts should not call push_warn_message_list if _install_font_inconsolata_nerd() returns 2 (Failed to install nerd font).' {

    stub_and_eval _install_font_inconsolata_nerd    '{ return 2; }'

    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times echo 0 "INFO: Inconsolata for Powerline Nerd Font has already installed. Skipping."
    stub_called_with_exactly_times push_info_message_list 0 "INFO: Inconsolata for Powerline Nerd Font has installed.\n  For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"."
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: Failed to install Inconsolata for Powerline Nerd Font.\n  Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."

    stub_called_with_exactly_times echo 0 "ERROR: Unknown error was occured when installing Inconsolata for Powerline Nerd Font."
    stub_called_with_exactly_times push_warn_message_list 0 "ERROR: Unknown error was occured when installing Inconsolata for Powerline Nerd Font."

}

@test '#install_fonts should not call push_warn_message_list if _install_font_inconsolata_nerd() returns 3 (Unknown error).' {

    stub_and_eval _install_font_inconsolata_nerd    '{ return 2; }'

    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times echo 0 "INFO: Inconsolata for Powerline Nerd Font has already installed. Skipping."
    stub_called_with_exactly_times push_info_message_list 0 "INFO: Inconsolata for Powerline Nerd Font has installed.\n  For more infotmation about the font, please see \"https://github.com/ryanoasis/nerd-fonts\"."
    stub_called_with_exactly_times push_warn_message_list 1 "ERROR: Failed to install Inconsolata for Powerline Nerd Font.\n  Please install it manually from \"https://github.com/ryanoasis/nerd-fonts\" if necessary."

    stub_called_with_exactly_times echo 0 "ERROR: Unknown error was occured when installing Inconsolata for Powerline Nerd Font."
    stub_called_with_exactly_times push_warn_message_list 0 "ERROR: Unknown error was occured when installing Inconsolata for Powerline Nerd Font."

}

@test '#install_fonts should not call push_info_message_list and push_warn_message_list if _install_font_migu1m() returns 2 (Mig1M has already installed).' {

    stub_and_eval _install_font_migu1m '{ return 0; }'

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    # TODO:
    stub_called_with_exactly_times echo 1 "INFO: Migu 1M font has already installed. Skipping."
    stub_called_with_exactly_times push_info_message_list 0 "INFO: Migu 1M font has installed.\n  For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"."
    stub_called_with_exactly_times push_warn_message_list 0 "ERROR: Failed to install migu-fonts for some reason."
}

@test '#install_fonts should not call push_warn_message_list if _install_font_migu1m() returns 2 (failed to install Migu1M). And _install_font_ipafont() should be called.' {

    stub_and_eval _install_font_migu1m '{ return 2; }'

    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 1 ]]

    stub_called_with_exactly_times push_info_message_list 0 \
            "INFO: Migu 1M font has installed.\n  For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"."
    stub_called_with_exactly_times push_warn_message_list 1 \
            "ERROR: Failed to install Migu 1M font.\n  The program will install IPA font alternatively."
}

@test '#install_fonts should not call push_warn_message_list if _install_font_migu1m() returns 3 (unknown error). And _install_font_ipafont() should be called.' {
    # TODO:
    false
}

@test '#install_fonts should not call push_warn_message_list if _install_font_noto_emoji() returns 0 (NotoEmojiFont has already installed).' {

    stub_and_eval _install_font_noto_emoji '{ return 0; }'

    run install_fonts

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times echo 1 \
            "INFO: NotoEmojiFont has already installed. Skipping."
    stub_called_with_exactly_times push_info_message_list 0 \
            "INFO: NotoEmojiFont has installed.\n  For more infotmation about the font, please see \"https://github.com/googlei18n/noto-emoji\"."
    stub_called_with_exactly_times push_warn_message_list 0 \
            "ERROR: Failed to install migu-fonts for some reason."
}

@test '#install_fonts should not call push_warn_message_list if _install_font_noto_emoji() returns 2 (failed to install NotoEmojiFont).' {

    stub_and_eval _install_font_noto_emoji '{ return 2; }'

    run install_fonts

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times _install_font_inconsolata_nerd)"                -eq 1 ]]
    [[ "$(stub_called_times _install_font_migu1m)"                          -eq 1 ]]
    [[ "$(stub_called_times _install_font_noto_emoji)"                      -eq 1 ]]
    [[ "$(stub_called_times _install_font_ipafont)"                         -eq 0 ]]

    stub_called_with_exactly_times push_info_message_list 0 \
            "INFO: Migu 1M font has installed.\n  For more infotmation about the font, please see \"https://ja.osdn.net/projects/mix-mplus-ipa/\"."
    stub_called_with_exactly_times push_warn_message_list 0 \
            "ERROR: Failed to install NotoEmojiFont."
}


@test '#install_fonts should not call push_warn_message_list if _install_font_noto_emoji() returns 3 (unknown error).' {
    # TODO:
    false
}


