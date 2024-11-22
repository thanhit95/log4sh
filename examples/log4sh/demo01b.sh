#!/bin/bash


# This demo shows how to use t_log4sh.sh in the simplest way.
# Make sure that your current working directory is the root of this project,
# then you execute the demo script by using command "./examples/log4sh/demo01.sh"
#
# We use API: t_log and t_log_st



. "./t_log4sh.sh"


function check_data() {
    local a=(9 8 7)
    # t_log TRACE "msg with trace level"
    # t_log DEBUG "msg with debug level"
    # t_log INFO "msg with info level"
    t_log WARN "msg with warn level, plus array: ${a[*]}"
    t_log ERR "msg with err level"
    # t_log FATAL "msg with fatal level, plus special chars: [] %d %l %F %f %L %m"
    t_log_st WARN "illegal string format [] %d %l"
}


function send_request() {
    check_data
}


echo "BEGIN DEMO 01b"
send_request
echo "DONE DEMO 01b"


# Expected output:
#
# BEGIN DEMO 01b
# 2024-11-22 15:35:43.087 [WARN ] demo01b.sh:20: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 15:35:43.088 [ERROR] demo01b.sh:21: check_data: msg with err level
# 2024-11-22 15:35:43.090 [WARN ] demo01b.sh:23: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo01b.sh:23)
#     at send_request (./examples/log4sh/demo01b.sh:28)
#     at main (./examples/log4sh/demo01b.sh:33)
# DONE DEMO 01b

