#!/usr/bin/env bats

load helpers

# This test case must be run the user that has root privileges or belong to sudoers.
@test 'do_i_have_admin_privileges' {

    run do_i_have_admin_privileges
    [[ "$status" -eq 0 ]]

    function whoami() { echo "root"; }
    function command() { [[ "$1" = "-v" ]] && [[ "$2" = "sudo" ]] && return 1; }
    run do_i_have_admin_privileges
    [[ "$status" -eq 0 ]]

    function whoami() { echo "unexistentuser"; }
    run do_i_have_admin_privileges
    [[ "$status" -ne 0 ]]

    function command() { [[ "$1" = "-v" ]] && [[ "$2" = "sudo" ]] && return 0; }
    function sudo() { return 1; }
    run do_i_have_admin_privileges
    [[ "$status" -ne 0 ]]
}


