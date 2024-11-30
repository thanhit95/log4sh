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
# 2024-11-30 15:27:28.331 [TRACE] demo_sub.sh:21: do_bar: msg with trace level
# 2024-11-30 15:27:28.333 [DEBUG] demo_sub.sh:22: do_bar: msg with debug level
# 2024-11-30 15:27:28.336 [INFO ] demo_sub.sh:23: do_bar: msg with info level
# 2024-11-30 15:27:28.338 [WARN ] demo_sub.sh:24: do_bar: msg with warn level, plus array: 9 8 7
# 2024-11-30 15:27:28.341 [ERROR] demo_sub.sh:25: do_bar: msg with err level
# 2024-11-30 15:27:28.344 [FATAL] demo_sub.sh:26: do_bar: msg with fatal level, plus special chars: [] %d %l %F %f %L %m
# 2024-11-30 15:27:28.346 [WARN ] demo_sub.sh:27: do_bar: illegal string format [] %d %l
#     at do_bar (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:27)
#     at do_foo (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:32)
#     at do_sth (./demo05.sh:23)
#     at main (./demo05.sh:28)
#
# DONE DEMO 05

