#!/bin/bash


# This demo demonstrates how to log to syslog channel.


CUR_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    CUR_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    CUR_FILE_PATH="${0:a}"
else
    CUR_FILE_PATH="$(readlink -f "$0")"
fi
CUR_BASE_DIR="${CUR_FILE_PATH%/*}"


# . "$CUR_BASE_DIR/../../t_log4sh.sh"
. "$CUR_BASE_DIR/demo_sub.sh"


function do_sth() {
    # do_foo is from file demo_sub.sh
    do_foo
}


echo -e "BEGIN DEMO 08\n"

t_log4sh_init_from_cfg_file "$CUR_BASE_DIR/demo08.config.ini"
do_sth

echo -e "\nDONE DEMO 08"


# Expected output:
#
