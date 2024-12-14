#!/usr/bin/env bats
load helpers

#function setup() {
#    stub read
#}

function teardown() {
    stub readx
}

# function teardown() {}
@test '#question should return 0 if the user answerd "y"' {
    stub_and_eval readx '{ echo "y"; command eval "__ANSWER_OF_READX__=y"; }'

    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: y" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 0 if the user answerd "yes"' {
    stub_and_eval readx '{ echo yes; command eval "__ANSWER_OF_READX__=yes"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: yes" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 0 if the user answerd "Y"' {
    stub_and_eval readx '{ echo Y; command eval "__ANSWER_OF_READX__=Y"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: Y" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 0 if the user answerd "YES"' {
    stub_and_eval readx '{ echo YES; command eval "__ANSWER_OF_READX__=YES"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: YES" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "n"' {
    stub_and_eval readx '{ echo n; command eval "__ANSWER_OF_READX__=n"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: n" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "no"' {
    stub_and_eval readx '{ echo no; command eval "__ANSWER_OF_READX__=no"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: no" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "N"' {
    stub_and_eval readx '{ echo N; command eval "__ANSWER_OF_READX__=N"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: N" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 1 if the user answerd "NO"' {
    stub_and_eval readx '{ echo NO; command eval "__ANSWER_OF_READX__=NO"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 1 ]]
    [[ "${outputs[0]}" = "Question: NO" ]]
    [[ "$(stub_called_times readx)" -eq 1 ]]
}

@test '#question should return 255 if the user did not answer in 3 times' {
    stub_and_eval readx '{ echo; command eval "__ANSWER_OF_READX__=foo"; }'
    run question "Question: "

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 255 ]]
    [[ "${outputs[0]}" = "Question: foo" ]] && [[ "${outputs[1]}" = "Question: foo" ]] && [[ "${outputs[2]}" = "Question: foo" ]]
    [[ "$(stub_called_times readx)" -eq 3 ]]
}

@test '#question should return 255 if the user did not answer in 2 times' {
    stub_and_eval readx '{ echo; command eval "__ANSWER_OF_READX__=foo"; }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 255 ]]
    [[ "${outputs[0]}" = "Question: foo" ]] && [[ "${outputs[1]}" = "Question: foo" ]]
    [[ "$(stub_called_times readx)" -eq 2 ]]
}

@test '#question should return 0 if the user did not answer at 1st but 2nd.' {
    stub_and_eval readx '{
        if [[ "$foooooooooo" = "" ]]; then
            foooooooooo=0
            echo foooooooooo
            command eval "__ANSWER_OF_READX__=foooooooooo"
        else
            # Answer y at secound time
            echo y
            command eval "__ANSWER_OF_READX__=y"
        fi
    }'
    run question "Question: " 2

    declare -a outputs; IFS=$'\n' outputs=($output)
    [[ "$status" -eq 0 ]]
    [[ "${outputs[0]}" = "Question: foooooooooo" ]] && [[ "${outputs[1]}" = "Question: y" ]]
    [[ "$(stub_called_times readx)" -eq 2 ]]
}

