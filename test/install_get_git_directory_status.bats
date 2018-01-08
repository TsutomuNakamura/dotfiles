#!/usr/bin/env bats
load helpers "install.sh"

function setup() {
    stub_and_eval git '{
        [[ "$1" = "rev-parse" ]] && [[ "$2" = "--git-dir" ]] && return 0
        [[ "$1" = "rev-parse" ]] && [[ "$2" = "--abbrev-ref" ]] && return 0
        [[ "$1" = "remote" ]] && echo "https://github.com/TsutomuNakamura/dotfiles.git" && return 0
        [[ "$1" = "status" ]] && return 0
        [[ "$1" = "cherry" ]] && return 0
    }'
}
#function teardown() {}
# k1 -> existence_of_directory
# k2 -> existence_of_git_repository
# k3 -> correctness_of_dotfiles_remote
# k4 -> absence_of_files_should_be_committed
# k5 -> absence_of_changes_should_be_pushed
# k6 -> branch_name
@test '$get_git_directory_status should return k1=0, k2=0, k3=0, k4=1, k5=1, k6=master if normally' {
    run get_git_directory_status
    
}

