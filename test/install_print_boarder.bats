#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub_and_eval tput '{ echo "100"; }'
}
#function teardown() {}

@test '#print_boarder should outputs subject and boader' {
    run print_boarder " Some subject "

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times tput)" -eq 1 ]]
    [[ "$output" == "== Some subject ====================================================================================" ]]
}

@test '#print_boader should outputs boarder only if any argument are not specified' {
    run print_boarder

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times tput)" -eq 1 ]]
    [[ "$output" == "====================================================================================================" ]]

}

