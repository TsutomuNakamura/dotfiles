#!/usr/bin/env bats
load helpers

function setup() {
    stub rm
}
#function teardown() {}

@test '#install_remove_all_untracked_files should remove only untracked files' {
    stub_and_eval git '{
        echo "?? foo.txt"
        echo " M bar.txt"
        echo "?? hoge.txt"
    }'
    run remove_all_untracked_files /var/tmp

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times rm) -eq 2 ]]
    stub_called_with_exactly_times rm 1 -rf /var/tmp/foo.txt
    stub_called_with_exactly_times rm 1 -rf /var/tmp/hoge.txt
}

@test '#install_remove_all_untracked_files should remove no files if untracked were not existed' {
    stub_and_eval git '{
        echo " M bar.txt"
        echo "AA foo.txt"
    }'
    run remove_all_untracked_files /var/tmp

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times rm) -eq 0 ]]
}

