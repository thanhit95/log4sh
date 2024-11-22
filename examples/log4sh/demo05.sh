#!/bin/bash


# This demo shows logging in the context of sourced scripts.


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


echo -e "BEGIN DEMO 05\n"
do_sth
echo -e "\nDONE DEMO 05"


# Expected output:
#
# BEGIN DEMO 05
#
# 2024-11-22 00:54:25.198 [TRACE] demo_sub.sh:21: do_bar: msg with trace level
# 2024-11-22 00:54:25.201 [DEBUG] demo_sub.sh:22: do_bar: msg with debug level
# 2024-11-22 00:54:25.203 [INFO ] demo_sub.sh:23: do_bar: msg with info level
# 2024-11-22 00:54:25.206 [WARN ] demo_sub.sh:24: do_bar: msg with warn level, plus array: 9 8 7
# 2024-11-22 00:54:25.209 [ERROR] demo_sub.sh:25: do_bar: msg with err level
# 2024-11-22 00:54:25.211 [FATAL] demo_sub.sh:26: do_bar: msg with fatal level, plus special chars: [] %d %l %F %f %L %m
# 2024-11-22 00:54:25.214 [WARN ] demo_sub.sh:27: do_bar: illegal string format [] %d %l
#     at do_bar (/home/thanh/linux_shell_kit/examples/log4sh/demo_sub.sh:27)
#     at do_foo (/home/thanh/linux_shell_kit/examples/log4sh/demo_sub.sh:32)
#     at do_sth (./examples/log4sh/demo05.sh:24)
#     at main (./examples/log4sh/demo05.sh:29)
#
# DONE DEMO 05

