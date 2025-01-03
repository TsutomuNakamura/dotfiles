#!/usr/bin/env bats
load helpers

function setup() {
    command rm -rf /var/tmp/{foo,bar,baz}
    mkdir -p /var/tmp/foo; touch /var/tmp/foo/bar.txt
    stub_and_eval pushd '{
        command pushd "$@" > /dev/null
    }'
    stub_and_eval popd '{
        command popd "$@" > /dev/null
    }'
}
function teardown() {
    command rm -rf /var/tmp/{foo,bar,baz}
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_JUST_CLONE if target directory was not existed.' {
    run determin_update_type_of_repository /var/tmp/dotfiles origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    [[ "$status"                        -eq $GIT_UPDATE_TYPE_JUST_CLONE ]]
    [[ "$(stub_called_times git)"       -eq 0 ]]
    [[ "$(stub_called_times pushd)"     -eq 0 ]]
    [[ "$(stub_called_times popd)"      -eq 0 ]]
}

@test '#determin_update_type_of_repository should return ANSWER_OF_QUESTION_ABORTED if push target directory has wailed.' {
    stub_and_eval pushd '{
        return 1
    }'
    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    [[ $status                        -eq $ANSWER_OF_QUESTION_ABORTED ]]
    [[ $(stub_called_times git)       -eq 0 ]]
    [[ $(stub_called_times pushd)     -eq 1 ]]
    [[ $(stub_called_times popd)      -eq 0 ]]

}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY if target directory was existed but not git repository.' {
    command rm -rf /var/tmp/foo
    command mkdir -p /var/tmp/foo
    command touch /var/tmp/foo/bar.txt
    stub_and_eval git '{
        [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]] && { return 1; }
        return 0
    }'
    run determin_update_type_of_repository /var/tmp/foo origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    echo "$status"
    [[ "$status"                        -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY ]]
    [[ $(stub_called_times git)         -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times pushd 1 "/var/tmp/foo"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY if target directory was existed but not git repository after the user answerd yes by the question.' {
    stub_and_eval git '{
        [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]] && { return 1; }
        return 0
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ directory.* ]] && return $ANSWER_OF_QUESTION_YES
        return 0
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_NOT_GIT_REPOSITORY ]]
    [[ $(stub_called_times git)         -eq 1 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times question 1 "The directory \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if target directory was existe but not git repository after the user answerd NO by the question.' {
    stub_and_eval git '{
        [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]] && { return 1; }
        return 0
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ directory.* ]] && return $ANSWER_OF_QUESTION_NO
        return 0
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "status: $status"
    [[ "$status"                        -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git)         -eq 1 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times question 1 "The directory \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if target directory was existe but not git repository after the user ABORTED by the question.' {
    stub_and_eval git '{
        [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]] && { return 1; }
        return 0
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ directory.* ]] && { return $ANSWER_OF_QUESTION_ABORTED; }
        return 0
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git)         -eq 1 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times question 1 "The directory \"/var/tmp\" is not a git repository.\nDo you want to remove it and clone the repository? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE if git url was different from the parameter and need_question is 1.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "git@github.com:TsutomuNakamura/dotfiles.git"    # Different from the parameter
        fi
        return 0
    }'
    stub question

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE ]]
    [[ $(stub_called_times git)         -eq 2 ]]
    [[ $(stub_called_times question)    -eq 0 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE if git url was different from the parameter and need_question is 0 and answered Y.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "git@github.com:TsutomuNakamura/dotfiles.git"    # Different from the parameter
        fi
        return 0
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ git\ repository\ located\ in\ .*$ ]] && {
            return 0
        }
        return 2
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE ]]
    [[ $(stub_called_times git)         -eq 2 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" is refering unexpected remote \"git@github.com:TsutomuNakamura/dotfiles.git\" (expected is \"https://github.com/TsutomuNakamura/dotfiles.git\").\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE if git url was different from the parameter and need_question is 0 and answered N.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "git@github.com:TsutomuNakamura/dotfiles.git"    # Different from the parameter
        fi
        return 0
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ git\ repository\ located\ in\ .*$ ]] && {
            return $ANSWER_OF_QUESTION_NO    # Answer NO
        }
        return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git)         -eq 2 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" is refering unexpected remote \"git@github.com:TsutomuNakamura/dotfiles.git\" (expected is \"https://github.com/TsutomuNakamura/dotfiles.git\").\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_WRONG_REMOTE if git url was different from the parameter and need_question is 0 and answere was aborted.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "git@github.com:TsutomuNakamura/dotfiles.git"    # Different from the parameter
        fi
        return 0
    }'
    stub_and_eval question '{
        [[ "$1" =~ ^The\ git\ repository\ located\ in\ .*$ ]] && {
            return $ANSWER_OF_QUESTION_ABORTED    # Aborted
        }
        return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git)         -eq 2 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" is refering unexpected remote \"git@github.com:TsutomuNakamura/dotfiles.git\" (expected is \"https://github.com/TsutomuNakamura/dotfiles.git\").\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT if the current branch is differ from expected branch' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "foo"      # Different from expected branch
        fi
        return 0
    }'
    stub question

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT ]]
    [[ $(stub_called_times git)         -eq 3 ]]
    [[ $(stub_called_times question)    -eq 0 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT if the current branch is differ from expected branch and need_question is 0 and answer YES.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "foo"      # Different from expected branch
        fi
        return 0
    }'
    stub_and_eval question '{
         [[ "$1" =~ ^The\ local\ branch\(.*$ ]] && {
             return $ANSWER_OF_QUESTION_YES
         }
         return $ANSWER_OF_QUESTION_NO
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT ]]
    [[ $(stub_called_times git)         -eq 3 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times question 1 "The local branch(foo) in repository that located in \"/var/tmp\" is differ from the branch(master) that going to be updated.\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT if the current branch is differ from expected branch and need_question is 0 and answer NO.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "foo"      # Different from expected branch
        fi
        return 0
    }'
    stub_and_eval question '{
         [[ "$1" =~ ^The\ local\ branch\(.*$ ]] && {
             return $ANSWER_OF_QUESTION_NO
         }
         return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git)         -eq 3 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times question 1 "The local branch(foo) in repository that located in \"/var/tmp\" is differ from the branch(master) that going to be updated.\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_BRANCH_IS_DIFFERENT if the current branch is differ from expected branch and need_question is 0 and answer is ABORTED.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "foo"      # Different from expected branch
        fi
        return 0
    }'
    stub_and_eval question '{
         [[ "$1" =~ ^The\ local\ branch\(.*$ ]] && {
             return $ANSWER_OF_QUESTION_ABORTED
         }
         return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ "$output" == "Re-cloning \"/var/tmp\" was aborted." ]]
    [[ $(stub_called_times git)         -eq 3 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times question 1 "The local branch(foo) in repository that located in \"/var/tmp\" is differ from the branch(master) that going to be updated.\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET if the files should be pushed are existed.' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            true    # Updates are not existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            echo foo    # Files should be pushed are existed
        fi
    }'
    stub question

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET ]]
    [[ $(stub_called_times git)         -eq 5 ]]
    [[ $(stub_called_times question)    -eq 0 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL if the files should be pushd are existed and answer YES' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            true    # Updates are not existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            echo foo    # Files should be pushed are existed
        fi
    }'
    stub_and_eval question '{
         [[ "$1" == "The git repository located in \"/var/tmp\" has some unpushed commits.\nDo you want to remove the git repository and re-clone it newly? [y/N]: " ]] && {
             return $ANSWER_OF_QUESTION_YES
         }
         return $ANSWER_OF_QUESTION_NO
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_REMOVE_THEN_CLONE_DUE_TO_UN_PUSHED_YET ]]
    [[ $(stub_called_times git)         -eq 5 ]]
    [[ $(stub_called_times question)    -eq 1 ]]
    [[ $(stub_called_times pushd)       -eq 1 ]]
    [[ $(stub_called_times popd)        -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" has some unpushed commits.\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if the files should be pushd are existed and answer NO' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            true    # Updates are not existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            echo foo    # Files should be pushed are existed
        fi
    }'
    stub_and_eval question '{
         [[ "$1" == "The git repository located in \"/var/tmp\" has some unpushed commits.\nDo you want to remove the git repository and re-clone it newly? [y/N]: " ]] && {
             return $ANSWER_OF_QUESTION_NO
         }
         return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    echo "$status"
    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" has some unpushed commits.\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if the files should be pushd are existed and answer ABORTED' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            true    # Updates are not existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            echo foo    # Files should be pushed are existed
        fi
    }'
    stub_and_eval question '{
         [[ "$1" == "The git repository located in \"/var/tmp\" has some unpushed commits.\nDo you want to remove the git repository and re-clone it newly? [y/N]: " ]] && {
             return $ANSWER_OF_QUESTION_ABORTED
         }
         return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" has some unpushed commits.\nDo you want to remove the git repository and re-clone it newly? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL if the updates are existed on local' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            echo bar    # Updates are existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            true    # Files should be pushed are existed
        fi
    }'
    stub question

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 1

    [[ "$status" -eq $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 0 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL if the updates are existed on local and answer YES' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            echo bar    # Updates are existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            true    # Files should be pushed are existed
        fi
    }'
    stub_and_eval question '{
         [[ "$1" == "The git repository located in \"/var/tmp\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: " ]] && {
             return $ANSWER_OF_QUESTION_YES
         }
         return $ANSWER_OF_QUESTION_NO
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_RESET_THEN_REMOVE_UNTRACKED_THEN_PULL ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if the updates are existed on local and answer NO' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            echo bar    # Updates are existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            true    # Files should be pushed are existed
        fi
    }'
    stub_and_eval question '{
         [[ "$1" == "The git repository located in \"/var/tmp\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: " ]] && {
             return $ANSWER_OF_QUESTION_NO
         }
         return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_ABOARTED if the updates are existed on local and answer ABORTED' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            echo bar    # Updates are existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            true    # Files should be pushed are existed
        fi
    }'
    stub_and_eval question '{
         [[ "$1" == "The git repository located in \"/var/tmp\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: " ]] && {
             return $ANSWER_OF_QUESTION_ABORTED
         }
         return $ANSWER_OF_QUESTION_YES
    }'

    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_ABOARTED ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 1 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times question 1 "The git repository located in \"/var/tmp\" has some uncommitted files.\nDo you want to remove them and update the git repository? [y/N]: "
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

@test '#determin_update_type_of_repository should return GIT_UPDATE_TYPE_JUST_PULL if there are no pushes and no updates' {
    stub_and_eval git '{
        if [[ "$1" == "rev-parse" ]] && [[ "$2" == "--git-dir" ]]; then
            return 0
        elif [[ "$1" == "remote" ]] && [[ "$2" == "get-url" ]]; then
            echo "https://github.com/TsutomuNakamura/dotfiles.git"
        elif [[ "$1" == "rev-parse" ]] && [[ "$2" == "--abbrev-ref" ]]; then
            echo "master"
        elif [[ "$1" == "status" ]] && [[ "$2" == "--porcelain" ]]; then
            true    # Updates are not existed
        elif [[ "$1" == "cherry" ]] && [[ "$2" == "-v" ]]; then
            true    # Files should be pushed are existed
        fi
    }'
    stub question
    run determin_update_type_of_repository /var/tmp origin "https://github.com/TsutomuNakamura/dotfiles.git" master 0

    [[ "$status" -eq $GIT_UPDATE_TYPE_JUST_PULL ]]
    [[ $(stub_called_times git) -eq 5 ]]
    [[ $(stub_called_times question) -eq 0 ]]
    stub_called_with_exactly_times git 1 rev-parse --git-dir
    stub_called_with_exactly_times git 1 remote get-url origin
    stub_called_with_exactly_times git 1 rev-parse --abbrev-ref HEAD
    stub_called_with_exactly_times git 1 status --porcelain
    stub_called_with_exactly_times git 1 cherry -v
    stub_called_with_exactly_times pushd 1 "/var/tmp"
}

