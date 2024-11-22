#!/bin/bash


# This demo shows how to use t_log4sh.sh in the simplest way.
# Make sure that your current working directory is the root of this project,
# then you execute the demo script by using command "./examples/log4sh/demo01.sh"
#
# We use API: t_logtrace,    t_logdbg,    t_loginfo, t_logwarn, t_logerr, t_logfatal
#             t_logtrace_st, t_logdbg_st, ...                           , t_logfatal_st


. "./t_log4sh.sh"


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


echo "BEGIN DEMO 01a"
send_request
echo "DONE DEMO 01a"


# Expected output:
#
# BEGIN DEMO 01a
# 2024-11-22 15:35:31.685 [INFO ] demo01a.sh:19: check_data: msg with info level
# 2024-11-22 15:35:31.687 [WARN ] demo01a.sh:20: check_data: msg with warn level, plus array: 9 8 7
# 2024-11-22 15:35:31.689 [ERROR] demo01a.sh:21: check_data: msg with err level
# 2024-11-22 15:35:31.690 [WARN ] demo01a.sh:23: check_data: illegal string format [] %d %l
#     at check_data (./examples/log4sh/demo01a.sh:23)
#     at send_request (./examples/log4sh/demo01a.sh:28)
#     at main (./examples/log4sh/demo01a.sh:33)
# DONE DEMO 01a

