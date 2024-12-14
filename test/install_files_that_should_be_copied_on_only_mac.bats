#!/usr/bin/env bats
load helpers

function setup() {
    stub_and_eval get_distribution_name '{ echo "mac"; }'
    declare -g -a FILES_SHOULD_BE_COPIED_ON_ONLY_MAC=("Inconsolata for Powerline.otf" "foobar")
}
function teardown() { true; }

@test '#files_that_should_be_copied_on_only_mac should return 0 if the file "Inconsolata for Powerline.otf" was specified and on Mac.' {
    run files_that_should_be_copied_on_only_mac "Inconsolata for Powerline.otf"
    [[ "$status" -eq 0 ]]
}

@test '#files_that_should_be_copied_on_only_mac should return 0 if the file "foobar" was specified and on Mac.' {
    run files_that_should_be_copied_on_only_mac "foobar"
    [[ "$status" -eq 0 ]]
}

@test '#files_that_should_be_copied_on_only_mac should return 1 if the file "hogefuga" was specified and on Mac.' {
    run files_that_should_be_copied_on_only_mac "hogefuga"
    [[ "$status" -eq 1 ]]
}

@test '#files_that_should_be_copied_on_only_mac should return 1 if the file "Inconsolata for Powerline.otf" was specified and on Ubuntu.' {
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
    run files_that_should_be_copied_on_only_mac "Inconsolata for Powerline.otf"
    [[ "$status" -eq 1 ]]
}

@test '#files_that_should_be_copied_on_only_mac should return 1 if the file "hogefuga" was specified and on Ubuntu.' {
    stub_and_eval get_distribution_name '{ echo "ubuntu"; }'
    run files_that_should_be_copied_on_only_mac "hogefuga"
    [[ "$status" -eq 1 ]]
}

