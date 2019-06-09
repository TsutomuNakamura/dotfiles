#!/usr/bin/env bats

load helpers "install.sh"

function setup() {
    command rm -f /tmp/.*BrewfileOfDotfiles

    stub curl
    stub brew
    stub rm
    stub logger_info
    stub logger_err
    export __USERID__="$(id -u)"
}

function teardown() {
    command rm -f /tmp/.*BrewfileOfDotfiles
    unset rm
}

@test '#install_packages_with_homebrew should return 0 and get Brewfile from master branch' {

    run install_packages_with_homebrew

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/BrewfileOfDotfiles"
    stub_called_with_exactly_times brew 1 bundle "--file=/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times rm 1 -f "/tmp/.${__USERID__}_BrewfileOfDotfiles"
    logger_info "brew bundle has succeeded. Your packages have been already up to date."
}

@test '#install_packages_with_homebrew should return 0 and get Brewfile from branch that specified in the parameter' {

    run install_packages_with_homebrew "develop"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/develop/BrewfileOfDotfiles"
    # stub_called_with_exactly_times brew 1 bundle "--file=/tmp/.${__USERID__}_BrewfileOfDotfiles"
    # stub_called_with_exactly_times rm 1 -f "/tmp/.${__USERID__}_BrewfileOfDotfiles"
    # logger_info "brew bundle has succeeded. Your packages have been already up to date."
}

@test '#install_packages_with_homebrew should return 1 if curl was failed' {
    stub_and_eval curl '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]
    # [[ -f /tmp/.${__USERID__}_BrewfileOfDotfiles      ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to download Brewfile from \"${RAW_GIT_REPOSITORY_HTTPS}/master/BrewfileOfDotfiles\""
}

@test '#install_packages_with_homebrew should return 1 brew was failed' {
    stub_and_eval brew '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]
    # [[ -f /tmp/.${__USERID__}_BrewfileOfDotfiles      ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to install packages with brew bundle"
}

@test '#install_packages_with_homebrew should return 1 rm was failed' {
    stub_and_eval rm '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]
    # [[ -f /tmp/.${__USERID__}_BrewfileOfDotfiles      ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to remove \"/tmp/.${__USERID__}_BrewfileOfDotfiles\" after brew bundle has succeeded"
}

