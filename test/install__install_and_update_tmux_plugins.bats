#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub tmux
    stub logger_err
    mock_install_plugins
    mock_update_plugins
    export TMUX="/tmp//tmux-1000/default,1111,2"
}

function teardown() {
    rm -rf ${HOME}/.tmux/plugins/tpm/bin/
}

function mock_install_plugins() {
    local code="${1:-0}"

    mkdir -p ${HOME}/.tmux/plugins/tpm/bin/
    cat << EOF > ${HOME}/.tmux/plugins/tpm/bin/install_plugins
#!/usr/bin/env bash
exit $code
EOF
    chmod u+x ${HOME}/.tmux/plugins/tpm/bin/install_plugins

    return 0
}

function mock_update_plugins() {
    local code="${1:-0}"

    mkdir -p ${HOME}/.tmux/plugins/tpm/bin/
    cat << EOF > ${HOME}/.tmux/plugins/tpm/bin/update_plugins
#!/usr/bin/env bash
exit $code
EOF
    chmod u+x ${HOME}/.tmux/plugins/tpm/bin/update_plugins
    return 0
}

@test '#_install_and_update_tmux_plugins should return 0 if all instructions with TMUX env was not set' {
    unset TMUX

    run _install_and_update_tmux_plugins

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times tmux)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]

    # FIXME: How to test that contains carriage return ^M ?
    #stub_called_with_exactly_times tmux 1 new \; set-buffer "${HOME}/.tmux/plugins/tpm/bin/install_plugins; ${HOME}/.tmux/plugins/tpm/bin/update_plugins all" \; paste-buffer
    [[ "paste-buffer" == $(base64 -di /tmp/__stub_sh_$(id -u)__/tmux | tail -1) ]]
}

@test '#_install_and_update_tmux_plugins should return 0 if all instructions with TMUX env was set' {
    run _install_and_update_tmux_plugins

    [[ "$status" -eq 0 ]]
    [[ "$(stub_called_times tmux)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 0 ]]

    stub_called_with_exactly_times tmux 1 source-file ${HOME}/.tmux.conf
}

@test '#_install_and_update_tmux_plugins should return 1 if install_plugins was failed with TMUX env was set' {
    mock_install_plugins 1

    run _install_and_update_tmux_plugins

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times tmux)"          -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to install tmux plugins with \`${HOME}/.tmux/plugins/tpm/bin/install_plugins\`"
}

@test '#_install_and_update_tmux_plugins should return 1 if update_plugins was failed with TMUX env was set' {
    mock_update_plugins 1

    run _install_and_update_tmux_plugins

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times tmux)"          -eq 0 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    stub_called_with_exactly_times logger_err 1 "Failed to update tmux plugins with \`${HOME}/.tmux/plugins/tpm/bin/update_plugins all\`"
}

@test '#_install_and_update_tmux_plugins should return 1 if tmux source-file was failed with TMUX env was set' {
    stub_and_eval tmux '{
        [[ "$1" == "source-file" ]] && return 1
        return 0
    }'

    run _install_and_update_tmux_plugins

    [[ "$status" -eq 1 ]]
    [[ "$(stub_called_times tmux)"          -eq 1 ]]
    [[ "$(stub_called_times logger_err)"    -eq 1 ]]

    stub_called_with_exactly_times tmux 1 source-file ${HOME}/.tmux.conf
    stub_called_with_exactly_times logger_err 1 "Failed to reload .tmux.conf by \`tmux source-file ${HOME}/.tmux.conf\`"
}

