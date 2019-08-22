
#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub mkdir
    stub curl
    stub source
}

function teardown() {
    true
}

@test '#deploy_zsh_antigen should return 0 if all instructions werer succeeded' {
    run deploy_zsh_antigen

    [[ "$status" == 0 ]]
}


