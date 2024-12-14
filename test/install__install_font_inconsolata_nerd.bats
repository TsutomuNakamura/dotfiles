#!/usr/bin/env bats
load helpers

function setup() {
    command mkdir -p "${HOME}/.local/share/fonts"
    cd "${HOME}/.local/share/fonts"
    stub rm
}

function teardown() {
    cd "${HOME}"
    command rm -rf .local
}

@test '#_install_font_inconsolata_nerd should return 0 if the font has already installed.' {
    command echo foo > "Inconsolata Nerd Font Complete.otf"
    stub curl
    run _install_font_inconsolata_nerd

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)" = "0" ]]
    [[ "$(stub_called_times rm)" = "0" ]]
}

@test '#_install_font_inconsolata_nerd should return 1 if the font is not existed and installing the font has been successfully.' {
    # File "Inconsolata Nerd Font Complete.otf" is not existed
    stub_and_eval curl '{ echo "dummy" > "Inconsolata Nerd Font Complete.otf"; }'
    run _install_font_inconsolata_nerd

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "Inconsolata Nerd Font Complete.otf" "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v2.1.0/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf"
    stub_called_with_exactly_times rm 1 "-f" "Inconsolata Nerd Font Complete.otf"
}

@test '#_install_font_inconsolata_nerd should return 1 if the font is existed (but size is 0) and installing the font has been successfully.' {
    # File "Inconsolata Nerd Font Complete.otf" is existed but size is zero
    touch "Inconsolata Nerd Font Complete.otf"
    stub_and_eval curl '{ echo "dummy" > "Inconsolata Nerd Font Complete.otf"; }'
    run _install_font_inconsolata_nerd

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "Inconsolata Nerd Font Complete.otf" "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v2.1.0/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf"
    stub_called_with_exactly_times rm 1 "-f" "Inconsolata Nerd Font Complete.otf"
}

@test '#_install_font_inconsolata_nerd should return 2 if the installing has failed with return code of curl is not 0.' {
    stub_and_eval curl '{ echo "dummy" > "Inconsolata Nerd Font Complete.otf"; return 1; }'
    run _install_font_inconsolata_nerd

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "2" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "Inconsolata Nerd Font Complete.otf" "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v2.1.0/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf"
    stub_called_with_exactly_times rm 2 "-f" "Inconsolata Nerd Font Complete.otf"
}

@test '#_install_font_inconsolata_nerd should return 2 if the installing has failed with the file that downloaded is empty.' {
    stub_and_eval curl '{ touch "Inconsolata Nerd Font Complete.otf"; }'
    run _install_font_inconsolata_nerd

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "2" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "Inconsolata Nerd Font Complete.otf" "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v2.1.0/patched-fonts/Inconsolata/complete/Inconsolata%20Nerd%20Font%20Complete.otf"
    stub_called_with_exactly_times rm 2 "-f" "Inconsolata Nerd Font Complete.otf"
}

