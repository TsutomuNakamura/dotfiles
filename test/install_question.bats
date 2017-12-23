#!/usr/bin/env bats
load helpers

function setup() {
    stub read
}

# function teardown() {}
@test '#question should return 0 if the user answerd "y"' {
    stub_and_eval read '{ echo "y"; command eval "answer=y"; }'

    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: y" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 0 if the user answerd "yes"' {
    stub_and_eval read '{ echo yes; command eval "answer=yes"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: yes" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 0 if the user answerd "Y"' {
    stub_and_eval read '{ echo Y; command eval "answer=Y"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: Y" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 0 if the user answerd "YES"' {
    stub_and_eval read '{ echo YES; command eval "answer=YES"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: YES" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "n"' {
    stub_and_eval read '{ echo n; command eval "answer=n"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: n" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "no"' {
    stub_and_eval read '{ echo no; command eval "answer=no"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: no" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "N"' {
    stub_and_eval read '{ echo N; command eval "answer=N"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: N" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "NO"' {
    stub_and_eval read '{ echo NO; command eval "answer=NO"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: NO" ]]
    [[ "$(stub_called_times read)" -eq 1 ]]
}

@test '#question should return 255 if the user did not answer in 3 times' {
    stub_and_eval read '{ echo; command eval "answer=foo"; }'
    run question "Question: "

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 255 ]]
    [[ "${outputs[0]}" = "Question: foo" ]] && [[ "${outputs[1]}" = "Question: foo" ]] && [[ "${outputs[2]}" = "Question: foo" ]]
    [[ "$(stub_called_times read)" -eq 3 ]]
}

@test '#question should return 255 if the user did not answer in 2 times' {
    stub_and_eval read '{ echo; command eval "answer=foo"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 255 ]]
    [[ "${outputs[0]}" = "Question: foo" ]] && [[ "${outputs[1]}" = "Question: foo" ]]
    [[ "$(stub_called_times read)" -eq 2 ]]
}

@test '#question should return 0 if the user did not answer at 1st but 2nd.' {
    stub_and_eval read '{
        if [[ "$foooooooooo" = "" ]]; then
            foooooooooo=0
            echo foooooooooo
            command eval "answer=foooooooooo"
        else
            # Answer y at secound time
            echo y
            command eval "answer=y"
        fi
    }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: foooooooooo" ]] && [[ "${outputs[1]}" = "Question: y" ]]
    [[ "$(stub_called_times read)" -eq 2 ]]
}



