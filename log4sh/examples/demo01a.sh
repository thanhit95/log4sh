#!/bin/bash


# This demo shows how to use t_log4sh.sh in a simplest way.
# Make sure that your current working directory is the the directory containing this script file,
# then you execute the demo script by using command "./demo01a.sh"
#
# We use API: t_logtrace,    t_logdbg,    t_loginfo, t_logwarn, t_logerr, t_logfatal
#             t_logtrace_st, t_logdbg_st, ...                           , t_logfatal_st


. "../t_log4sh.sh"


function check_data() {
    t_logdbg "msg with debug level"
    t_loginfo "msg with info level"
    t_logwarn "msg with warn level"
    t_logerr "msg with err level"
    t_logwarn_st "a fatal error occurred, including a detailed stack trace"
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
# 2024-11-30 15:38:53.949 [DEBUG] demo01a.sh:16: check_data: msg with debug level
# 2024-11-30 15:38:53.952 [INFO ] demo01a.sh:17: check_data: msg with info level
# 2024-11-30 15:38:53.954 [WARN ] demo01a.sh:18: check_data: msg with warn level
# 2024-11-30 15:38:53.956 [ERROR] demo01a.sh:19: check_data: msg with err level
# 2024-11-30 15:38:53.959 [WARN ] demo01a.sh:20: check_data: a fatal error occurred, including a detailed stack trace
#     at check_data (./demo01a.sh:20)
#     at send_request (./demo01a.sh:25)
#     at main (./demo01a.sh:30)
# DONE DEMO 01a

