#!/bin/bash

BATS_TEST_SKIPPED=
SCRIPT_DIR="$(dirname "$(readlink -f "$BASH_SOURCE")")"
. ${SCRIPT_DIR}/../install.sh --load-functions

