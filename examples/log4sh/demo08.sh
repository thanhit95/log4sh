#!/bin/bash


# This demo instructs how to log to syslog.


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


echo "BEGIN DEMO 08"

# We will log to both stderr and a file
t_log4sh_set_config "channels" "stdout,syslog"
#t_log4sh_set_config "channel.syslog.facility" "local2"
#t_log4sh_set_config "channel.syslog.tag" "myapp"

# echo -e "\n---- CURRENT LOG4SH CONFIGS ----"
# t_log4sh_print_configs

echo -e "\n---- BEGIN TESTING ----"
send_request

echo -e "\nDONE DEMO 08"


# Expected output in stderr:
#
