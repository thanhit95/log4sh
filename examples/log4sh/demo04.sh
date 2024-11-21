#!/bin/bash


# This demo instructs how to log to multiple channels.


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


echo "BEGIN DEMO04"

# We will log to both stderr and a file
t_log4sh_set_config "channels" "stderr,file"
t_log4sh_set_config "channel.file.path" "./demo04.log"

# echo -e "\n---- CURRENT LOG4SH CONFIGS ----"
# t_log4sh_print_configs

echo -e "\n---- BEGIN TESTING ----"
send_request

echo -e "\nDONE DEMO04"


# Expected output in stderr:
#
# BEGIN DEMO04
#
# ---- BEGIN TESTING ----
# 2024-11-22 00:52:55.910 [INFO ] demo04.sh:25: check_data: msg with info level
# 2024-11-22 00:52:55.913 [WARN ] demo04.sh:26: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 00:52:55.916 [ERROR] demo04.sh:27: check_data: msg with err level
# 2024-11-22 00:52:55.919 [WARN ] demo04.sh:29: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo04.sh:29)
#     at send_request (./examples/log4sh/demo04.sh:34)
#     at main (./examples/log4sh/demo04.sh:48)
#
# DONE DEMO04


# Expected output in file demo04.log:
# 2024-11-22 00:52:55.910 [INFO ] demo04.sh:25: check_data: msg with info level
# 2024-11-22 00:52:55.913 [WARN ] demo04.sh:26: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 00:52:55.916 [ERROR] demo04.sh:27: check_data: msg with err level
# 2024-11-22 00:52:55.919 [WARN ] demo04.sh:29: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo04.sh:29)
#     at send_request (./examples/log4sh/demo04.sh:34)
#     at main (./examples/log4sh/demo04.sh:48)

