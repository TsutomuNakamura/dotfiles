#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    mkdir "${HOME}/testdir"
}

function teardown() {
    rm -rf "${HOME}/testdir"
}

# TODO: For older than bash version 4.4, get_git_remote_aliases should return remote list as csv

@test '#get_git_remote_aliases should output "origin" the repository refers origin.' {
    # stub_and_eval get_git_remote_aliases '{ echo "declare -a remotes=([0]=\"origin\")"; }'
    stub_and_eval git '{ echo "origin"; }'
    run get_git_remote_aliases "${HOME}/testdir"

    [[ "$status" -eq 0 ]]
    [[ "$output" == "origin" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_aliases should output "aaaa" and "origin" if the git-remote command outputs them.' {
    stub_and_eval git '{ echo "aaaa"; echo "origin"; }'
    run get_git_remote_aliases "${HOME}/testdir"

    [[ "$status" -eq 0 ]]
    [[ "$output" == "aaaa,origin" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_aliases should output "origin" and "aaaa" if the git-remote command outputs them.' {
    stub_and_eval git '{ echo "aaaa"; echo "origin"; }'
    run get_git_remote_aliases "${HOME}/testdir" remotes

    [[ "$status" -eq 0 ]]
    [[ "$output" == "aaaa,origin" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_aliases should output empty array if the git commands outputs empty string.' {
    stub_and_eval git '{ true; }'
    run get_git_remote_aliases "${HOME}/testdir" remotes

    [[ "$status" -eq 0 ]]
    [[ "$output" == "" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output an element empty if the git commands outputs empty line(empty string and break line).' {
    stub_and_eval git '{ echo; }'
    run get_git_remote_aliases "${HOME}/testdir" remotes

    [[ "$status" -eq 0 ]]
    [[ "$output" == "" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

