#!/bin/bash


# This demo shows how to use t_log4sh_init_from_cfg_file
# to initialize log4sh from a config file.


CUR_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    CUR_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    CUR_FILE_PATH="${0:a}"
else
    CUR_FILE_PATH="$(readlink -f "$0")"
fi
CUR_BASE_DIR="${CUR_FILE_PATH%/*}"


. "$CUR_BASE_DIR/../t_log4sh.sh"
. "$CUR_BASE_DIR/demo_sub.sh"


function do_sth() {
    # do_foo is from file demo_sub.sh
    do_foo
}


echo -e "BEGIN DEMO 06\n"

# t_log4sh_init_from_cfg_file "/not/existed/file.ini"
t_log4sh_init_from_cfg_file "$CUR_BASE_DIR/demo06.config.ini"

# t_log4sh_print_configs

do_sth

echo -e "\nDONE DEMO 06"


# Expected output in both stderr and file demo06.log:
#
# BEGIN DEMO 06
#
# [ Saturday 15:31:34,29 ][ INFO  ] do_bar() in demo_sub.sh (line 23): msg with info level
# [ Saturday 15:31:34,30 ][ WARN  ] do_bar() in demo_sub.sh (line 24): msg with warn level, plus array: 9 8 7
# [ Saturday 15:31:34,31 ][ WARN  ] do_bar() in demo_sub.sh (line 27): illegal string format [] %d %l
#     at do_bar (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:27)
#     at do_foo (/home/thanh/linux_shell_kit/log4sh/examples/demo_sub.sh:32)
#     at do_sth (/home/thanh/linux_shell_kit/log4sh/examples/demo06.sh:25)
#     at main (/home/thanh/linux_shell_kit/log4sh/examples/demo06.sh:36)
#
# DONE DEMO 06

