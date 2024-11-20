#!/bin/bash


_T_TEST_LOG4SH_THIS_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    _T_TEST_LOG4SH_THIS_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    _T_TEST_LOG4SH_THIS_FILE_PATH="${0:a}"
fi
_T_TEST_LOG4SH_THIS_BASE_DIR="${_T_TEST_LOG4SH_THIS_FILE_PATH%/*}"
_T_TEST_LOG4SH_THIS_FILE_NAME="${_T_TEST_LOG4SH_THIS_FILE_PATH##*/}"
# echo "_T_TEST_LOG4SH_THIS_FILE_PATH: $_T_TEST_LOG4SH_THIS_FILE_PATH"
# echo "_T_TEST_LOG4SH_THIS_BASE_DIR: $_T_TEST_LOG4SH_THIS_BASE_DIR"
# echo "_T_TEST_LOG4SH_THIS_FILE_NAME: $_T_TEST_LOG4SH_THIS_FILE_NAME"


. "$_T_TEST_LOG4SH_THIS_BASE_DIR/t_log4sh_test_sub.sh"


function do_foo() {
    do_bar
}


function do_sth() {
    do_foo
}


do_sth

