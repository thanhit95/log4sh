#!/bin/bash


# This demo shows how to use t_log4sh_set_config to set configs.


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


echo "BEGIN DEMO 03"

# echo -e "\n---- CURRENT LOG4SH CONFIGS ----"
# t_log4sh_print_configs
echo -e "\n---- BEGIN TESTING WITH CURRENT LOG4SH CONFIGS ----"
send_request

t_log4sh_set_config "msg_item.format" "%d {{ %l }} %f at line %L: %m"
t_log4sh_set_config "msg_item.date.format" "%A %H:%M:%S"
t_log4sh_set_config "threshold.min_level" "4"
t_log4sh_set_config "trace_dump.abs_path" "true"

# echo -e "\n---- UPDATED LOG4SH CONFIGS ----"
# t_log4sh_print_configs
echo -e "\n---- BEGIN TESTING WITH UPDATED LOG4SH CONFIGS ----"
send_request

echo -e "\nDONE DEMO 03"


# Expected output:
#
# BEGIN DEMO 03
#
# ---- BEGIN TESTING WITH CURRENT LOG4SH CONFIGS ----
# 2024-11-30 15:25:06.365 [INFO ] demo03.sh:25: check_data: msg with info level
# 2024-11-30 15:25:06.368 [WARN ] demo03.sh:26: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-30 15:25:06.370 [ERROR] demo03.sh:27: check_data: msg with err level
# 2024-11-30 15:25:06.373 [WARN ] demo03.sh:29: check_data: illegal string format [] %d %l
#     at check_data (./demo03.sh:29)
#     at send_request (./demo03.sh:34)
#     at main (./demo03.sh:43)
#
# ---- BEGIN TESTING WITH UPDATED LOG4SH CONFIGS ----
# Saturday 15:25:06 {{ WARN  }} demo03.sh at line 26: msg with warn level, plus array: 9 8 7
# Saturday 15:25:06 {{ ERROR }} demo03.sh at line 27: msg with err level
# Saturday 15:25:06 {{ WARN  }} demo03.sh at line 29: illegal string format [] %d %l
#     at check_data (/home/thanh/linux_shell_kit/log4sh/examples/demo03.sh:29)
#     at send_request (/home/thanh/linux_shell_kit/log4sh/examples/demo03.sh:34)
#     at main (/home/thanh/linux_shell_kit/log4sh/examples/demo03.sh:53)
#
# DONE DEMO 03

