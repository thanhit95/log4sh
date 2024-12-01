#!/bin/bash


# This demo instructs how to log to multiple channels.
# There are multiple supported channels: stdout,stderr,file,cmd,syslog
# Checkout file template.config.ini for more details


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


echo "BEGIN DEMO 04"

# We will log to both stderr and a file
t_log4sh_set_config "channels" "stderr,file"
t_log4sh_set_config "channel.file.path" "./demo04.log"

# t_log4sh_print_configs

echo -e "\n---- BEGIN TESTING ----"
send_request

echo -e "\nDONE DEMO 04"


# Expected output in both stderr and file demo04.log:
#
# 2024-11-30 15:26:23.413 [INFO ] demo04.sh:27: check_data: msg with info level
# 2024-11-30 15:26:23.418 [WARN ] demo04.sh:28: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-30 15:26:23.421 [ERROR] demo04.sh:29: check_data: msg with err level
# 2024-11-30 15:26:23.424 [WARN ] demo04.sh:31: check_data: illegal string format [] %d %l
#     at check_data (./demo04.sh:31)
#     at send_request (./demo04.sh:36)
#     at main (./demo04.sh:49)

