#!/bin/bash


# The difference of this demo vs. previous demo01 are:
# - It prints all configs of log4sh
# - It detects the current script path at runtime,
#   so you can run this demo from any working directory


CUR_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    CUR_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    CUR_FILE_PATH="${0:a}"
else
    CUR_FILE_PATH="$(readlink -f "$0")"
fi
CUR_BASE_DIR="${CUR_FILE_PATH%/*}"


. "$CUR_BASE_DIR/../../t_log4sh.sh"


function check_data() {
    local a=(9 8 7)
    # t_logtrace "msg with trace level"
    # t_logdbg "msg with debug level"
    t_loginfo "msg with info level"
    t_logwarn "msg with warn level, plus array: ${a[*]}"
    t_logerr "msg with err level"
    # t_logfatal "msg with fatal level, plus special chars: [] %d %l %F %f %L %m"
    t_logwarn_st "illegal string format [] %d %l"
}


function send_request() {
    check_data
}


echo "BEGIN DEMO02"

echo -e "\n---- CURRENT LOG4SH CONFIGS ----"
# Note: Empty config means using default value
t_log4sh_print_configs

echo -e "\n---- BEGIN TESTING ----"
send_request

echo -e "\nDONE DEMO02"


# Expected output:
#
# BEGIN DEMO02
#
# ---- CURRENT LOG4SH CONFIGS ----
# log_format:
# date_format:
# date_time_zone:
# trace_dump_resolve_abs_path:
# threshold_min_level: 0
# threshold_max_level: 7
# channels: stdout
# channel.file.path:
# channel.cmd.cmdline:
#
# ---- BEGIN TESTING ----
# 2024-11-22 00:51:05.290 [INFO ] demo02.sh:28: check_data: msg with info level
# 2024-11-22 00:51:05.293 [WARN ] demo02.sh:29: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 00:51:05.295 [ERROR] demo02.sh:30: check_data: msg with err level
# 2024-11-22 00:51:05.297 [WARN ] demo02.sh:32: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo02.sh:32)
#     at send_request (./examples/log4sh/demo02.sh:37)
#     at main (./examples/log4sh/demo02.sh:47)
#
# DONE DEMO02

