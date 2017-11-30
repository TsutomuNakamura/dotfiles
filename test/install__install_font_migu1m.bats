#!/usr/bin/env bats
load helpers

function setup() {
    command mkdir -p "${HOME}/.local/share/fonts"
    cd "${HOME}/.local/share/fonts"
    stub rm
    stub_and_eval curl '{
        if [[ "$2" = "migu-1m-20150712.zip" ]]; then
            command echo "foo" > "migu-1m-20150712.zip"
        fi
    }'
    stub_and_eval unzip '{
        command mkdir migu-1m-20150712
        command echo "foo" > "./migu-1m-20150712/migu-1m-bold.ttf"
        command echo "bar" > "./migu-1m-20150712/migu-1m-regular.ttf"
    }'
}

function teardown() {
    cd "${HOME}"
    command rm -rf .local
}

@test '#_install_font_migu1m should return 0 if the font has already installed.' {
    command echo foo > "migu-1m-bold.ttf"
    command echo bar > "migu-1m-regular.ttf"

    run _install_font_migu1m

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)" = "0" ]]
    [[ "$(stub_called_times rm)" = "0" ]]
}

@test '#_install_font_migu1m should install the font if the migu-1m-bold.ttf was not existed.' {
    # touch "migu-1m-bold.ttf"
    command echo bar > "migu-1m-regular.ttf"

    run _install_font_migu1m
    echo "$output"
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    stub_called_with_exactly_times unzip 1 migu-1m-20150712.zip
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712 migu-1m-20150712.zip
}

@test '#_install_font_migu1m should install the font if the size of migu-1m-bold.ttf is 0.' {
    touch "migu-1m-bold.ttf"
    command echo bar > "migu-1m-regular.ttf"

    run _install_font_migu1m
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
}

@test '#_install_font_migu1m should install the font if the migu-1m-regular.ttf was not existed.' {
    command echo foo > "migu-1m-bold.ttf"
    # command echo bar > "migu-1m-regular.ttf"

    run _install_font_migu1m
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
}

@test '#_install_font_migu1m should install the font if the size of migu-1m-regular.ttf is 0.' {
    command echo foo > "migu-1m-bold.ttf"
    touch "migu-1m-regular.ttf"

    run _install_font_migu1m
    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
}

@test '#_install_font_migu1m should return 2 if the curl returns non 0.' {
    stub_and_eval curl '{ return 1; }'
    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712.zip
}

@test '#_install_font_migu1m should return 2 if the curl is failed to download the font.' {
    stub_and_eval curl '{ command rm -f migu-1m-20150712.zip; return 0; }'
    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712.zip
}

@test '#_install_font_migu1m should return 2 if the curl is download the font but its size of 0.' {
    stub_and_eval curl '{ command rm -f migu-1m-20150712.zip; touch migu-1m-20150712.zip; return 0; }'
    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712.zip
}

@test '#_install_font_migu1m should return 2 if the unzip failed to extracts migu-1m-bold.ttf' {
    stub_and_eval unzip '{
        command mkdir migu-1m-20150712
        command rm -f ./migu-1m-20150712/migu-1m-bold.ttf ./migu-1m-20150712/migu-1m-regular.ttf
        # command echo "foo" > "./migu-1m-20150712/migu-1m-bold.ttf"
        # touch ./migu-1m-20150712/migu-1m-bold.ttf
        command echo "bar" > "./migu-1m-20150712/migu-1m-regular.ttf"
    }'

    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712 migu-1m-20150712.zip migu-1m-bold.ttf migu-1m-regular.ttf
}

@test '#_install_font_migu1m should return 2 if the unzip extracts migu-1m-bold.ttf but its size is 0.' {
    stub_and_eval unzip '{
        command mkdir migu-1m-20150712
        command rm -f ./migu-1m-20150712/migu-1m-bold.ttf ./migu-1m-20150712/migu-1m-regular.ttf
        # command echo "foo" > "./migu-1m-20150712/migu-1m-bold.ttf"
        touch ./migu-1m-20150712/migu-1m-bold.ttf
        command echo "bar" > "./migu-1m-20150712/migu-1m-regular.ttf"
    }'

    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712 migu-1m-20150712.zip migu-1m-bold.ttf migu-1m-regular.ttf
}

@test '#_install_font_migu1m should return 2 if the unzip failed to extracts migu-1m-regular.ttf.' {
    stub_and_eval unzip '{
        command mkdir migu-1m-20150712
        command rm -f ./migu-1m-20150712/migu-1m-bold.ttf ./migu-1m-20150712/migu-1m-regular.ttf
        command echo "foo" > "./migu-1m-20150712/migu-1m-bold.ttf"
        # command echo "bar" > "./migu-1m-20150712/migu-1m-regular.ttf"
        # touch ./migu-1m-20150712/migu-1m-regular.ttf
    }'

    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712 migu-1m-20150712.zip migu-1m-bold.ttf migu-1m-regular.ttf
}

@test '#_install_font_migu1m should return 2 if the unzip extracts migu-1m-bold.ttf but its size is 0.' {
    stub_and_eval unzip '{
        command mkdir migu-1m-20150712
        command rm -f ./migu-1m-20150712/migu-1m-bold.ttf ./migu-1m-20150712/migu-1m-regular.ttf
        command echo "foo" > "./migu-1m-20150712/migu-1m-bold.ttf"
        # command echo "bar" > "./migu-1m-20150712/migu-1m-regular.ttf"
        touch ./migu-1m-20150712/migu-1m-regular.ttf
    }'

    run _install_font_migu1m

    [[ "$status" -eq 2 ]]
    [[ "$(stub_called_times curl)" = "1" ]]
    [[ "$(stub_called_times rm)" = "1" ]]
    stub_called_with_exactly_times curl 1 "-fLo" "migu-1m-20150712.zip" "https://ja.osdn.net/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip"
    stub_called_with_exactly_times rm 1 "-rf" migu-1m-20150712 migu-1m-20150712.zip migu-1m-bold.ttf migu-1m-regular.ttf
}


