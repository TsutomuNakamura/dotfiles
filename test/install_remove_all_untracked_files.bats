#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub rm
    stub pushd
    stub popd
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
    [[ $(stub_called_times git)     -eq 1 ]]
    [[ $(stub_called_times rm)      -eq 2 ]]
    [[ $(stub_called_times pushd)   -eq 1 ]]
    [[ $(stub_called_times popd)    -eq 1 ]]
    stub_called_with_exactly_times rm 1 -rf /var/tmp/foo.txt
    stub_called_with_exactly_times rm 1 -rf /var/tmp/hoge.txt
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#install_remove_all_untracked_files should remove no files if untracked were not existed' {
    stub_and_eval git '{
        echo " M bar.txt"
        echo "AA foo.txt"
    }'
    run remove_all_untracked_files /var/tmp

    [[ "$status" -eq 0 ]]
    [[ $(stub_called_times git)     -eq 1 ]]
    [[ $(stub_called_times rm)      -eq 0 ]]
    [[ $(stub_called_times pushd)   -eq 1 ]]
    [[ $(stub_called_times popd)    -eq 1 ]]
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#install_remove_all_untracked_files should return 1 if pushd has failed' {
    stub_and_eval pushd '{ return 1; }'
    run remove_all_untracked_files /var/tmp

    [[ "$status" -eq 1 ]]
    [[ $(stub_called_times git)     -eq 0 ]]
    [[ $(stub_called_times rm)      -eq 0 ]]
    [[ $(stub_called_times pushd)   -eq 1 ]]
    [[ $(stub_called_times popd)    -eq 0 ]]
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

