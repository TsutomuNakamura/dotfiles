#!/usr/bin/env bats
load helpers

function setup() {
    command mkdir -p "${HOME}/.local/share/fonts"
    command cd "${HOME}/.local/share/fonts"
    stub logger_err
    stub_and_eval rm '{ command rm "$@"; }'
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            command echo foo > "NotoColorEmoji.ttf"
        else
            return 1
        fi
    }'
}

function teardown() {
    command cd "${HOME}"
    command rm -rf .local
    rm -f ./*.ttf
}

@test '#_install_font_noto_emoji should return 0 if the font has already installed.' {
    command echo foo > "NotoColorEmoji.ttf"
    command echo foo > "NotoEmoji-Regular.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"  -eq 0 ]]
    [[ "$(stub_called_times rm)"    -eq 0 ]]
}

@test '#_install_font_noto_emoji should return 1 if the font was not installed' {
    run _install_font_noto_emoji

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"  -eq 1 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
}

@test '#_install_font_noto_emoji should return 1 if the font NotoColorEmoji.ttf was already existed' {
    command echo foo > "NotoColorEmoji.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"  -eq 0 ]]
    [[ "$(stub_called_times rm)"    -eq 0 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
}

@test '#_install_font_noto_emoji should return 1 (installing has executed) if the font NotoColorEmoji.ttf was existed but NotoColorEmoji.ttf was empty' {
    command touch "NotoColorEmoji.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"  -eq 1 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoColorEmoji.ttf has failed.' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            return 1        # Failed
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times logger_err 1 "Failed to install NotoColorEmoji.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf)"
    [[ ! -e "NotoColorEmoji.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoColorEmoji.ttf has succeeded but file not existed' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            #command echo foo > "NotoColorEmoji.ttf"
            true        # Succeeded but empty
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    [[ ! -e "NotoColorEmoji.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoColorEmoji.ttf has succeeded but file is empty' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            # command echo foo > "NotoColorEmoji.ttf"
            touch "NotoColorEmoji.ttf"
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 1 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    [[ ! -e "NotoColorEmoji.ttf" ]]
}

