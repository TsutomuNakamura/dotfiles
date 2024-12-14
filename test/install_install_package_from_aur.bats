#!/usr/bin/env bats
load helpers

function setup() {
    stub logger_info
    stub logger_err
    stub git
    stub rm
    stub makepkg
    stub pushd
    stub popd
}

@test '#install_package_from_aur should return 0 if all instructions have succeeded' {
    run install_package_from_aur "https://aur.example.com/foo.git"

    [ "$status" -eq 0 ]
    [ "$(stub_called_times logger_info)"    -eq 1 ]
    [ "$(stub_called_times logger_err)"     -eq 0 ]
    [ "$(stub_called_times git)"            -eq 1 ]
    [ "$(stub_called_times pushd)"          -eq 1 ]
    [ "$(stub_called_times makepkg)"        -eq 1 ]
    [ "$(stub_called_times popd)"           -eq 1 ]
    [ "$(stub_called_times rm)"             -eq 1 ]

    stub_called_with_exactly_times logger_info 1 "Cloning git repository to install AUR package \"https://aur.example.com/foo.git\""
    stub_called_with_exactly_times git 1 "clone" "https://aur.example.com/foo.git"
    stub_called_with_exactly_times pushd 1 "foo"
    stub_called_with_exactly_times makepkg 1 "-sri" "--noconfirm"
    stub_called_with_exactly_times rm 1 "-rf" "foo"
}

@test '#install_package_from_aur should return 1 if a command \"git clone url\" has failed' {
    stub_and_eval git '{ return 1; }'
    run install_package_from_aur "https://aur.example.com/foo.git"

    [ "$status" -eq 1 ]
    [ "$(stub_called_times logger_info)"    -eq 1 ]
    [ "$(stub_called_times logger_err)"     -eq 1 ]
    [ "$(stub_called_times git)"            -eq 1 ]
    [ "$(stub_called_times pushd)"          -eq 0 ]
    [ "$(stub_called_times makepkg)"        -eq 0 ]
    [ "$(stub_called_times popd)"           -eq 0 ]
    [ "$(stub_called_times rm)"             -eq 1 ]

    stub_called_with_exactly_times logger_info 1 "Cloning git repository to install AUR package \"https://aur.example.com/foo.git\""
    stub_called_with_exactly_times git 1 "clone" "https://aur.example.com/foo.git"
    stub_called_with_exactly_times logger_err 1 "Failed to clone git repository \"https://aur.example.com/foo.git\""
    stub_called_with_exactly_times rm 1 "-rf" "foo"
}

@test '#install_package_from_aur should return 1 if a command \"pushd dir\" has failed' {
    stub_and_eval pushd '{ return 1; }'
    run install_package_from_aur "https://aur.example.com/foo.git"

    [ "$status" -eq 1 ]
    [ "$(stub_called_times logger_info)"    -eq 1 ]
    [ "$(stub_called_times logger_err)"     -eq 1 ]
    [ "$(stub_called_times git)"            -eq 1 ]
    [ "$(stub_called_times pushd)"          -eq 1 ]
    [ "$(stub_called_times makepkg)"        -eq 0 ]
    [ "$(stub_called_times popd)"           -eq 0 ]
    [ "$(stub_called_times rm)"             -eq 1 ]

    stub_called_with_exactly_times logger_info 1 "Cloning git repository to install AUR package \"https://aur.example.com/foo.git\""
    stub_called_with_exactly_times git 1 "clone" "https://aur.example.com/foo.git"
    stub_called_with_exactly_times pushd 1 "foo"
    stub_called_with_exactly_times logger_err 1 "Failed to change directory \"foo\""
    stub_called_with_exactly_times rm 1 "-rf" "foo"
}

@test '#install_package_from_aur should return 1 if a command \"makepkg -sri --noconfirm\" has failed' {
    stub_and_eval makepkg '{ return 1; }'
    run install_package_from_aur "https://aur.example.com/foo.git"

    [ "$status" -eq 1 ]
    [ "$(stub_called_times logger_info)"    -eq 1 ]
    [ "$(stub_called_times logger_err)"     -eq 1 ]
    [ "$(stub_called_times git)"            -eq 1 ]
    [ "$(stub_called_times pushd)"          -eq 1 ]
    [ "$(stub_called_times makepkg)"        -eq 1 ]
    [ "$(stub_called_times popd)"           -eq 0 ]
    [ "$(stub_called_times rm)"             -eq 1 ]

    stub_called_with_exactly_times logger_info 1 "Cloning git repository to install AUR package \"https://aur.example.com/foo.git\""
    stub_called_with_exactly_times git 1 "clone" "https://aur.example.com/foo.git"
    stub_called_with_exactly_times pushd 1 "foo"
    stub_called_with_exactly_times makepkg 1 "-sri" "--noconfirm"
    stub_called_with_exactly_times logger_err 1 "Failed to install an AUR package with command \"makepkg -sri --noconfirm\""
    stub_called_with_exactly_times rm 1 "-rf" "foo"
}
