#!/bin/bash


# This demo shows how to use t_log4sh.sh in the simplest way.
# Make sure that your current working directory is the root of this project,
# then you execute the demo script by using command "./examples/log4sh/demo01.sh"


. "./t_log4sh.sh"


function verify_data() {
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
    verify_data
}


echo "BEGIN DEMO01"
send_request
echo "DONE DEMO01"


# Expected output:
#
# BEGIN DEMO01
# 2024-11-22 00:50:24.535 [INFO ] demo01.sh:16: verify_data: msg with info level
# 2024-11-22 00:50:24.537 [WARN ] demo01.sh:17: verify_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 00:50:24.539 [ERROR] demo01.sh:18: verify_data: msg with err level
# 2024-11-22 00:50:24.540 [WARN ] demo01.sh:20: verify_data: illegal string format [] %d %l
#     at verify_data (./examples/log4sh/demo01.sh:20)
#     at send_request (./examples/log4sh/demo01.sh:25)
#     at main (./examples/log4sh/demo01.sh:30)
# DONE DEMO01

