#!/bin/bash


# This demo shows how to log to syslog channel.


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


echo -e "BEGIN DEMO 08\n"

t_log4sh_init_from_cfg_file "$CUR_BASE_DIR/demo08.config.ini"
do_sth

echo -e "\nDONE DEMO 08"


# Expected output in stdout:
#
# BEGIN DEMO 08
#
# 2024-11-30 15:35:17.154 [WARN ] demo_sub.sh:24: do_bar: msg with warn level, plus array: 9 8 7
# 2024-11-30 15:35:17.160 [ERROR] demo_sub.sh:25: do_bar: msg with err level
# 2024-11-30 15:35:17.165 [FATAL] demo_sub.sh:26: do_bar: msg with fatal level, plus special chars: [] %d %l %F %f %L %m
# 2024-11-30 15:35:17.171 [WARN ] demo_sub.sh:27: do_bar: illegal string format [] %d %l
#     at do_bar (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:27)
#     at do_foo (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:32)
#     at do_sth (./demo08.sh:23)
#     at main (./demo08.sh:30)
#
# DONE DEMO 08


# Expected output in the syslog output file:
# Nov 30 15:35:17 fedora myapp[51459]: 51453 demo_sub.sh:24: do_bar: msg with warn level, plus array: 9 8 7
# Nov 30 15:35:17 fedora myapp[51461]: 51453 demo_sub.sh:25: do_bar: msg with err level
# Nov 30 15:35:17 fedora myapp[51463]: 51453 demo_sub.sh:26: do_bar: msg with fatal level, plus special chars: [] %d %l %F %f %L %m
# Nov 30 15:35:17 fedora myapp[51466]: 51453 demo_sub.sh:27: do_bar: illegal string format [] %d %l#012    at do_bar (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:27)#012    at do_foo (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:32)#012    at do_sth (./demo08.sh:23)#012    at main (./demo08.sh:30)
