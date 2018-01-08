#!/usr/bin/env bats
load helpers "install.sh"

#function setup() {}
#function teardown() {}

@test '#should_the_dotfile_be_skipped should return 0 when the file that is out of target was specified' {
    run should_the_dotfile_be_skipped ".vim"
    [[ "$status" -ne 0 ]]
    run should_the_dotfile_be_skipped ".tmux.conf"
    [[ "$status" -ne 0 ]]
    run should_the_dotfile_be_skipped "foo"
    [[ "$status" -ne 0 ]]
}

@test '#should_the_dotfile_be_skipped should not return 0 when the file that is in the scope of target was specified' {
    run should_the_dotfile_be_skipped ".git"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped ".DS_Store"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped ".gitignore"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped ".gitmodules"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped ".vim.swp"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped ".foo.swp"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped "${DOTDIR}"
    [[ "$status" -eq 0 ]]
    run should_the_dotfile_be_skipped "${BACKUPDIR}"
    [[ "$status" -eq 0 ]]
}

