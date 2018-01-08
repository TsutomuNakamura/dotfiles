#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    command mkdir -p "${HOME}/.local/share/fonts"
    command cd "${HOME}/.local/share/fonts"
    stub logger_err
    stub_and_eval rm '{ command rm "$@"; }'
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            command echo foo > "NotoColorEmoji.ttf"
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            command echo foo > "NotoEmoji-Regular.ttf"
        else
            return 1
        fi
    }'
}

function teardown() {
    command cd "${HOME}"
    command rm -rf .local
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
    [[ "$(stub_called_times curl)"  -eq 2 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    [[ -e "NotoEmoji-Regular.ttf" ]]
    [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
}

@test '#_install_font_noto_emoji should return 1 if the font NotoEmoji-Regular.ttf was existed but NotoColorEmoji.ttf was not existed' {
    # command echo foo > "NotoColorEmoji.ttf"
    command echo foo > "NotoEmoji-Regular.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"  -eq 2 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    [[ -e "NotoEmoji-Regular.ttf" ]]
    [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
}

@test '#_install_font_noto_emoji should return 1 if the font NotoColorEmoji.ttf was existed but NotoEmoji-Regular.ttf was not existed' {
    command echo foo > "NotoColorEmoji.ttf"
    # command echo foo > "NotoEmoji-Regular.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"  -eq 2 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    [[ -e "NotoEmoji-Regular.ttf" ]]
    [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
}

@test '#_install_font_noto_emoji should return 1 if the font NotoEmoji-Regular.ttf and NotoColorEmoji.ttf were existed but NotoColorEmoji.ttf was empty' {
    command touch "NotoColorEmoji.ttf"
    command echo foo > "NotoEmoji-Regular.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"  -eq 2 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    [[ -e "NotoEmoji-Regular.ttf" ]]
    [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
}

@test '#_install_font_noto_emoji should return 1 if the font NotoEmoji-Regular.ttf and NotoColorEmoji.ttf were existed but NotoEmoji-Regular.ttf was empty' {
    command echo foo > "NotoColorEmoji.ttf"
    command touch "NotoEmoji-Regular.ttf"
    run _install_font_noto_emoji

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"  -eq 2 ]]
    [[ "$(stub_called_times rm)"    -eq 1 ]]
    [[ -e "NotoColorEmoji.ttf" ]]
    [[ $(wc -c < "NotoColorEmoji.ttf") -ne 0 ]]
    [[ -e "NotoEmoji-Regular.ttf" ]]
    [[ $(wc -c < "NotoEmoji-Regular.ttf") -ne 0 ]]
    stub_called_with_exactly_times rm 1 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoColorEmoji.ttf has failed.' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            return 1        # Failed
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            command echo foo > "NotoEmoji-Regular.ttf"
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 2 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    [[ "$(stub_called_times logger_err)"                -eq 1 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
    stub_called_with_exactly_times logger_err 1 "Failed to install NotoColorEmoji.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf)"
    [[ ! -e "NotoColorEmoji.ttf" ]]
    [[ ! -e "NotoEmoji-Regular.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoEmoji-Regular.ttf has failed.' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            command echo foo > "NotoColorEmoji.ttf"
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            return 1        # Failed
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 2 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
    stub_called_with_exactly_times logger_err 1 "Failed to install NotoEmoji-Regular.ttf (from https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf)"
    [[ ! -e "NotoColorEmoji.ttf" ]]
    [[ ! -e "NotoEmoji-Regular.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoColorEmoji.ttf has succeeded but file not existed' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            #command echo foo > "NotoColorEmoji.ttf"
            true        # Succeeded but empty
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            command echo foo > "NotoEmoji-Regular.ttf"
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 2 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
    [[ ! -e "NotoColorEmoji.ttf" ]]
    [[ ! -e "NotoEmoji-Regular.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoEmoji-Regular.ttf has succeeded but file not existed' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            command echo foo > "NotoColorEmoji.ttf"
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            # command echo foo > "NotoEmoji-Regular.ttf"
            true        # Succeeded but empty
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 2 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
    [[ ! -e "NotoColorEmoji.ttf" ]]
    [[ ! -e "NotoEmoji-Regular.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoColorEmoji.ttf has succeeded but file is empty' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            # command echo foo > "NotoColorEmoji.ttf"
            touch "NotoColorEmoji.ttf"
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            command echo foo > "NotoEmoji-Regular.ttf"
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 2 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
    [[ ! -e "NotoColorEmoji.ttf" ]]
    [[ ! -e "NotoEmoji-Regular.ttf" ]]
}

@test '#_install_font_noto_emoji should return 2 if the curl installing NotoEmoji-Regular.ttf has succeeded but file is empty' {
    stub_and_eval curl '{
        if [[ "$2" == "NotoColorEmoji.ttf" ]]; then
            command echo foo > "NotoColorEmoji.ttf"
        elif [[ "$2" == "NotoEmoji-Regular.ttf" ]]; then
            # command echo foo > "NotoEmoji-Regular.ttf"
            touch "NotoEmoji-Regular.ttf"
        else
            return 1
        fi
    }'
    run _install_font_noto_emoji

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)"                      -eq 2 ]]
    [[ "$(stub_called_times rm)"                        -eq 2 ]]
    stub_called_with_exactly_times rm 2 -f "NotoColorEmoji.ttf" "NotoEmoji-Regular.ttf"
    stub_called_with_exactly_times curl 1 -fLo "NotoColorEmoji.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoColorEmoji.ttf
    stub_called_with_exactly_times curl 1 -fLo "NotoEmoji-Regular.ttf" https://raw.githubusercontent.com/googlei18n/noto-emoji/master/fonts/NotoEmoji-Regular.ttf
    [[ ! -e "NotoColorEmoji.ttf" ]]
    [[ ! -e "NotoEmoji-Regular.ttf" ]]
}

