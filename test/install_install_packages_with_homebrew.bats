#!/usr/bin/env bats

load helpers "install.sh"

function setup() {
    command rm -f /tmp/.*BrewfileOfDotfiles

    stub_and_eval curl '{
        if [[ "$2" == "-o" ]]; then
            echo "brew \"llvm\""    >   "$3"
            echo "brew \"neovim\""  >>  "$3"
            echo "brew \"python\""  >>  "$3"
        fi
        return 0
    }'
    stub brew
    stub rm
    stub logger_info
    stub logger_err
    stub grep
    stub_and_eval wc '{ echo "2"; }'

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
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times brew 1 bundle "--file=/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times rm 1 -f "/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_info 1 "brew bundle has succeeded. Your packages have been already up to date."
}

@test '#install_packages_with_homebrew should return 0 and get Brewfile from branch that specified in the parameter' {

    run install_packages_with_homebrew "develop"

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/develop/.BrewfileOfDotfiles"
    stub_called_with_exactly_times brew 1 bundle "--file=/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times rm 1 -f "/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_info 1 "brew bundle has succeeded. Your packages have been already up to date."
}

@test '#install_packages_with_homebrew should return 1 if curl was failed' {
    stub_and_eval curl '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 0 ]]
    [[ "$(stub_called_times wc)"                -eq 0 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to download Brewfile from \"${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles\""
}

@test '#install_packages_with_homebrew should return 1 if curl was succeeded but the file that downloaded was not exist' {
    stub curl

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 0 ]]
    [[ "$(stub_called_times wc)"                -eq 0 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to download Brewfile. The file \"/tmp/.$(id -u)_BrewfileOfDotfiles\" is not found or empty"
}

@test '#install_packages_with_homebrew should return 1 if curl was succeeded but the size of the file that downloaded was 0' {
    stub curl '{ true > "$3"; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 0 ]]
    [[ "$(stub_called_times wc)"                -eq 0 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to download Brewfile. The file \"/tmp/.$(id -u)_BrewfileOfDotfiles\" is not found or empty"
}

@test '#install_packages_with_homebrew should return 0 if amount of line of Brewfile was 2' {
    stub_and_eval curl '{
        echo "403: Not Found" >  "$3";
        echo "403: Not Found" >> "$3";
    }'
    stub_and_eval grep '{ return 0; }'
    stub_and_eval wc '{ echo "2"; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times brew 1 bundle "--file=/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times rm 1 -f "/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_info 1 "brew bundle has succeeded. Your packages have been already up to date."
}

@test '#install_packages_with_homebrew should return 0 if amount of line of Brewfile was 1 but the file does NOT contain error code' {
    stub_and_eval curl '{
        echo "brew \"llvm\"" >  "$3";
    }'
    stub_and_eval wc '{ echo "1"; }'
    stub_and_eval grep '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 1 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 1 ]]
    [[ "$(stub_called_times logger_err)"        -eq 0 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times brew 1 bundle "--file=/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times rm 1 -f "/tmp/.${__USERID__}_BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_info 1 "brew bundle has succeeded. Your packages have been already up to date."
}

@test '#install_packages_with_homebrew should return 1 if amount of line of Brewfile was 1 and Brewfile contains error response code' {
    stub_and_eval curl '{ echo "403: Not Found" > "$3"; }'
    stub_and_eval wc '{ echo "1"; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 0 ]]
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 1 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Server returned some status code and downloading Brewfile has failed. (status=$(cat /tmp/.$(id -u)_BrewfileOfDotfiles))"
}

@test '#install_packages_with_homebrew should return 1 brew was failed' {
    stub_and_eval brew '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 0 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to install packages with brew bundle"
}

@test '#install_packages_with_homebrew should return 1 if rm was failed' {
    stub_and_eval rm '{ return 1; }'

    run install_packages_with_homebrew

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times curl)"              -eq 1 ]]
    [[ "$(stub_called_times brew)"              -eq 1 ]]
    [[ "$(stub_called_times wc)"                -eq 1 ]]
    [[ "$(stub_called_times grep)"              -eq 0 ]]
    [[ "$(stub_called_times rm)"                -eq 1 ]]
    [[ "$(stub_called_times logger_info)"       -eq 0 ]]
    [[ "$(stub_called_times logger_err)"        -eq 1 ]]

    stub_called_with_exactly_times curl 1 -L -o "/tmp/.${__USERID__}_BrewfileOfDotfiles" "${RAW_GIT_REPOSITORY_HTTPS}/master/.BrewfileOfDotfiles"
    stub_called_with_exactly_times logger_err 1 "Failed to remove \"/tmp/.$(id -u)_BrewfileOfDotfiles\" after brew bundle has succeeded"
}

