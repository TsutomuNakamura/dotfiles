#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    function id() { true; }
    stub contains_element
}

function teardown() {
    true
}

@test '#has_permission_to_rw return 0 if all instructions were succeeded' {
    stub_and_eval stat '{
        if [[ "$2" == "%Su" ]]; then
            whoami
            return 0
        elif [[ "$2" == "%Sg" ]]; then
            # same as username
            whoami
            return 0
        fi
        return 1
    }'

    run has_permission_to_rw "/usr/local/sbin"

    [[ $status -eq 0 ]]
    [[ $(stub_called_times contains_element)    -eq 1 ]]
    [[ $(stub_called_times stat)                -eq 2 ]]
    stub_called_with_exactly_times stat 1 -f "%Su" "/usr/local/sbin"
    stub_called_with_exactly_times stat 1 -f "%Sg" "/usr/local/sbin"
}

@test '#has_permission_to_rw return 0 if owner of a target was unknown but group was known' {
    stub_and_eval stat '{
        if [[ "$2" == "%Su" ]]; then
            # whoami
            echo "unknown_user"
            return 0
        elif [[ "$2" == "%Sg" ]]; then
            # same as username
            whoami
            return 0
        fi
        return 1
    }'

    run has_permission_to_rw "/usr/local/sbin"

    [[ $status -eq 0 ]]
    [[ $(stub_called_times contains_element)    -eq 1 ]]
    [[ $(stub_called_times stat)                -eq 2 ]]
    stub_called_with_exactly_times stat 1 -f "%Su" "/usr/local/sbin"
    stub_called_with_exactly_times stat 1 -f "%Sg" "/usr/local/sbin"
}

@test '#has_permission_to_rw return 0 if group of a target was unknown but owner was known' {
    stub_and_eval stat '{
        if [[ "$2" == "%Su" ]]; then
            whoami
            return 0
        elif [[ "$2" == "%Sg" ]]; then
            # same as username
            #whoami
            echo "unknown_group"
            return 0
        fi
        return 1
    }'

    run has_permission_to_rw "/usr/local/sbin"

    [[ $status -eq 0 ]]
    [[ $(stub_called_times contains_element)    -eq 1 ]]
    [[ $(stub_called_times stat)                -eq 2 ]]
    stub_called_with_exactly_times stat 1 -f "%Su" "/usr/local/sbin"
    stub_called_with_exactly_times stat 1 -f "%Sg" "/usr/local/sbin"
}

@test '#has_permission_to_rw return 1 if group of a target was unknown and owner was unknown' {
    stub_and_eval contains_element '{ return 1; }'
    stub_and_eval stat '{
        if [[ "$2" == "%Su" ]]; then
            #whoami
            echo "unknown_user"
            return 0
        elif [[ "$2" == "%Sg" ]]; then
            # same as username
            #whoami
            echo "unknown_group"
            return 0
        fi
        return 1
    }'

    run has_permission_to_rw "/usr/local/sbin"

    [[ $status -eq 1 ]]
    [[ $(stub_called_times contains_element)    -eq 1 ]]
    [[ $(stub_called_times stat)                -eq 2 ]]
    stub_called_with_exactly_times stat 1 -f "%Su" "/usr/local/sbin"
    stub_called_with_exactly_times stat 1 -f "%Sg" "/usr/local/sbin"
}
