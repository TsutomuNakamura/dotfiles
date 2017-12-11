#!/usr/bin/env bats
load helpers

function setup() {
    rm -rf /var/tmp/{..?*,.[!.]*,*}
}
function teardown() {
    rm -rf /var/tmp/{..?*,.[!.]*,*}
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_JUST_CLONE if target directory was not existed.' {
    run determin_update_type_of_repository /var/tmp/dotfiles origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    [[ "$status" -eq $GIT_UPDATE_TYPE_JUST_CLONE ]]
    [[ "$(stub_called_times git)" -eq 0 ]]
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY if target directory was existed but not git repository.' {
    mkdir -p /var/tmp
    stub_and_eval git '{
        [[ "$1" == "-C" ]] && [[ "$3" == "rev-parse" ]] && [[ "$4" == "--git-dir" ]] && {
            return 1        # Failer
        }
    }'
    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY ]]
    [[ $(stub_called_times git) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp" rev-parse --git-dir
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY if target directory was existed but not git repository after the user answerd yes by the question.' {
    stub_and_eval git '{
        [[ "$1" == "-C" ]] && [[ "$3" == "rev-parse" ]] && [[ "$4" == "--git-dir" ]] && {
            return 1        # Failer
        }
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ directory.* ]] && return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp" rev-parse --git-dir
    stub_called_with_exactly_times question 1 "The directory (or file) \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if target directory was existe but not git repository after the user answerd NO by the question.' {
    stub_and_eval git '{
        [[ "$1" == "-C" ]] && [[ "$3" == "rev-parse" ]] && [[ "$4" == "--git-dir" ]] && {
            return 1        # Failer
        }
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ directory.* ]] && return $ANSWER_OF_QUESTION_NO
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp" rev-parse --git-dir
    stub_called_with_exactly_times question 1 "The directory (or file) \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if target directory was existe but not git repository after the user ABORTED by the question.' {
    stub_and_eval git '{
        [[ "$1" == "-C" ]] && [[ "$3" == "rev-parse" ]] && [[ "$4" == "--git-dir" ]] && {
            return 1        # Failer
        }
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ directory.* ]] && return $ANSWER_OF_QUESTION_ABORTED
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git) -eq 1 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 -C "/var/tmp" rev-parse --git-dir
    stub_called_with_exactly_times question 1 "The directory (or file) \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
}

# @test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if target directory was existe but not git repository after the user ABORTED by the question.' {
#     stub_and_eval git '{
#         [[ "$1" == "-C" ]] && [[ "$3" == "rev-parse" ]] && [[ "$4" == "--git-dir" ]] && {
#             return 1        # Failer
#         }
#     }'
#     stub_and_eval question '{
#         [[ "$1" =~ ^The\ directory.* ]] && return $ANSWER_OF_QUESTION_ABORTED
#     }'
# 
#     run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0
# 
#     echo "$status"
#     [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
#     [[ $(stub_called_times git) -eq 1 ]]
#     [[ $(stub_called_times question) -eq 1 ]]
#     stub_called_with_exactly_times git 1 -C "/var/tmp" rev-parse --git-dir
#     stub_called_with_exactly_times question 1 "The directory (or file) \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
# }

