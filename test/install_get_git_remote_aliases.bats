#!/usr/bin/env bats
load helpers

# function setup() {}

# function teardown() {}

@test '#get_git_remote_aliases should output "origin" the repository refers origin.' {
    # stub_and_eval get_git_remote_aliases '{ echo "declare -a remotes=([0]=\"origin\")"; }'
    stub_and_eval git '{ echo "origin"; }'
    run get_git_remote_alias "~/testdir" remotes

    [[ "$status" -eq 0 ]]
    [[ "$output" == "declare -a remotes=([0]=\"origin\")" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output "aaaa" and "origin" if the git-remote command outputs them.' {
    stub_and_eval git '{ echo "aaaa"; echo "origin"; }'
    run get_git_remote_alias "~/testdir" foo

    [[ "$status" -eq 0 ]]
    [[ "$output" == "declare -a foo=([0]=\"aaaa\" [1]=\"origin\")" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output "origin" and "aaaa" if the git-remote command outputs them.' {
    stub_and_eval git '{ echo "aaaa"; echo "origin"; }'
    run get_git_remote_alias "~/testdir" remotes

    [[ "$status" -eq 0 ]]
    [[ "$output" == "declare -a remotes=([0]=\"origin\" [1]=\"aaaa\")" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}

@test '#get_git_remote_alias should output empty array if the git commands outputs empty string.' {
    stub_and_eval git '{ echo; }'
    run get_git_remote_alias "~/testdir" remotes

    [[ "$output" == "declare -a remotes" ]]
    [[ $(stub_called_times git) -eq 1 ]]
}


