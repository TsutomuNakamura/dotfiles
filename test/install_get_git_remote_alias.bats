#!/usr/bin/env bats
load helpers

# function setup() {}

# function teardown() {}

@test '#get_git_remote_alias should output "origin" the repository refers origin.' {
    stub_and_eval git '{ echo "origin"; }'
    run get_git_remote_alias "~/testdir"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "origin" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output "origin" the repository refers the remote that refers other than origin and origin.' {
    stub_and_eval git '{ echo "aaaa"; echo "origin"; }'
    run get_git_remote_alias "~/testdir"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "origin" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output "origin" the repository refers origin and the remote that refers other than origin.' {
    stub_and_eval git '{ echo "origin"; echo "aaaa"; }'
    run get_git_remote_alias "~/testdir"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "origin" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output empty string if the repository refers remotes only other than origin.' {
    stub_and_eval git '{ echo "develop"; echo "foo"; }'
    run get_git_remote_alias "~/testdir"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "$outputs" = "" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output empty string if the function has occured some error.' {
    stub_and_eval git '{ echo "Some error was occured." >&2 ; }'
    run get_git_remote_alias "~/testdir"

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "$outputs" = "" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}


