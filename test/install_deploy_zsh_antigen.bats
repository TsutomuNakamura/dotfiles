
#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub_and_eval mkdir '{
        command mkdir "$@"
    }'
    stub curl
    stub source
}

function teardown() {
    command rm -rf "${ZSH_DIR}/antigen"
}

@test '#deploy_zsh_antigen should return 0 if all instructions werer succeeded' {
    run deploy_zsh_antigen

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times mkdir)"     -eq 1 ]]
    [[ "$(stub_called_times curl)"      -eq 1 ]]
    [[ "$(stub_called_times source)"    -eq 1 ]]
    stub_called_with_exactly_times mkdir 1 -p "${ZSH_DIR}/antigen"
    stub_called_with_exactly_times curl 1 -L git.io/antigen
    stub_called_with_exactly_times source 1 "${HOME}/.zshrc"

}


