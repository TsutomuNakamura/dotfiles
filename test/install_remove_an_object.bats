#!/usr/bin/env bats
load helpers

function setup() {
    mkdir -p ${HOME}/${DOTDIR}
}

function teardown() {
    rm -rf ${HOME}/${DOTDIR}
}

@test '#remove_an_object should remove a file' {
    touch ${HOME}/${DOTDIR}/hoge.txt

    run remove_an_object ${HOME}/${DOTDIR}/hoge.txt

    [[ "$status" -eq 0 ]]
    [[ "$output" = "Removing ${HOME}/${DOTDIR}/hoge.txt ..." ]]
    [[ ! -e ${HOME}/${DOTDIR}/hoge.txt ]]
}

@test '#remove_an_object should remove a directory' {
    mkdir -p ${HOME}/${DOTDIR}/foo/bar
    touch ${HOME}/${DOTDIR}/foo/baz.txt

    run remove_an_object "${HOME}/${DOTDIR}/foo"

    [[ "$status" -eq 0 ]]
    [[ "$output" = "Removing ${HOME}/${DOTDIR}/foo ..." ]]
    [[ ! -e "${HOME}/${DOTDIR}/foo" ]]
}

@test '#remove_an_object should remove a symlink linked to a file' {
    mkdir -p ${HOME}/${DOTDIR}/foo
    touch ${HOME}/${DOTDIR}/foo/a
    ln -s -t ${HOME}/${DOTDIR} ./foo/a

    run remove_an_object "${HOME}/${DOTDIR}/a"

    [[ "$status" -eq 0 ]]
    [[ "$output" = "Removing ${HOME}/${DOTDIR}/a ..." ]]
    [[ ! -e "${HOME}/${DOTDIR}/a" ]]
}



