#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    sudo mkdir -p /usr/share/xsessions
    function get_distribution_name() { echo "ubuntu"; }
}

function teardown() {
    sudo mkdir -p /usr/share/xsessions
    sudo rm -rf /usr/share/xsessions/*
}

@test '#has_desktop_env return 0 if get_distribution_name returns "mac"' {
    function get_distribution_name() { echo "mac"; }
    sudo touch /usr/share/xsessions/gnome.desktop
    run has_desktop_env

    [[ "$status" -eq 0 ]]
}

@test '#has_desktop_env return 0 if *.desktop files are existed in /usr/share/xsessions' {
    sudo touch /usr/share/xsessions/gnome.desktop
    run has_desktop_env

    [[ "$status" -eq 0 ]]
}

@test '#has_desktop_env return 1 if *.log files are existed in /usr/share/xsessions' {
    run has_desktop_env

    [[ "$status" -eq 1 ]]
}

@test '#has_desktop_env return 1 if /usr/share/xsessions is not existed' {
    run has_desktop_env

    [[ "$status" -eq 1 ]]
}

@test '#has_desktop_env return 1 if no files are existed in /usr/share/xsessions' {
    run has_desktop_env

    [[ "$status" -eq 1 ]]
}

