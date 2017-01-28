#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

export PATH="${SCRIPT_DIR}/bats/bin:${PATH}"
if ! (command -v bats > /dev/null); then
    rm -rf bats.git bats
    git clone --depth 1 https://github.com/sstephenson/bats.git bats.git
    mkdir -p bats
    cd bats.git
    ./install.sh ${SCRIPT_DIR}/bats
    sync
    cd ../
fi

#export BATS_TEST_DIRNAME="${SCRIPT_DIR}/test"
#. install.sh --load-functions
#bats ./test/install.sh
bats --tap ./test/install_do_i_have_admin_privileges.bats
bats --tap ./test/install_deploy.bats

