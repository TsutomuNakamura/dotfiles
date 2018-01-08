#!/usr/bin/env bash
TARGET="$2"
BATS_TEST_SKIPPED=
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ ! -f "${SCRIPT_DIR}/lib/stub4bats.sh/stub.sh" ]] && {
    echo "ERROR: File \"${SCRIPT_DIR}/lib/stub4bats.sh/stub.sh\" was not existed"
    exit 1
}
. "${SCRIPT_DIR}/lib/stub4bats.sh/stub.sh"

[[ ! -f "${SCRIPT_DIR}/lib/stub4bats.sh/stub.sh" ]] && {
    echo "ERROR: File \"${SCRIPT_DIR}/../${TARGET}\" was not existed"
    exit 1
}
. "${SCRIPT_DIR}/../${TARGET}"

