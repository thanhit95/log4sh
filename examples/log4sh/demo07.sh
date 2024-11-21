#!/bin/bash


# This demo shows that you can use the log4sh library for remote logging purposes.
# Please view the file demo07.config.ini
#
# >>>>>>>>> Before running this script, you must run listener server
#           in file demo07.listener.sh (in another terminal).


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


echo -e "BEGIN DEMO07\n"

t_log4sh_init_from_cfg_file "$CUR_BASE_DIR/demo07.config.ini"

send_request

echo -e "\nDONE DEMO07"


# Expected output in stdout:
#
# BEGIN DEMO07
#
# 2024-11-22 00:59:16.280 [INFO ] demo07.sh:29: check_data: msg with info level
# 2024-11-22 00:59:16.287 [WARN ] demo07.sh:30: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 00:59:16.297 [ERROR] demo07.sh:31: check_data: msg with err level
# 2024-11-22 00:59:16.305 [WARN ] demo07.sh:33: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo07.sh:33)
#     at send_request (./examples/log4sh/demo07.sh:38)
#     at main (./examples/log4sh/demo07.sh:46)
#
# DONE DEMO07


# Expected output in listener server:
#
# Echo Server is listening on 0.0.0.0:8081
#
# Received data: 2024-11-22 00:59:16.280 [INFO ] demo07.sh:29: check_data: msg with info level
#
# 127.0.0.1 - - [22/Nov/2024 00:59:16] "POST / HTTP/1.1" 200 -
#
# Received data: 2024-11-22 00:59:16.287 [WARN ] demo07.sh:30: check_data: msg with warn level, plus array: 9 8 7
#
# 127.0.0.1 - - [22/Nov/2024 00:59:16] "POST / HTTP/1.1" 200 -
#
# Received data: 2024-11-22 00:59:16.297 [ERROR] demo07.sh:31: check_data: msg with err level
#
# 127.0.0.1 - - [22/Nov/2024 00:59:16] "POST / HTTP/1.1" 200 -
#
# Received data: 2024-11-22 00:59:16.305 [WARN ] demo07.sh:33: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo07.sh:33)
#     at send_request (./examples/log4sh/demo07.sh:38)
#     at main (./examples/log4sh/demo07.sh:46)
#
# 127.0.0.1 - - [22/Nov/2024 00:59:16] "POST / HTTP/1.1" 200 -

