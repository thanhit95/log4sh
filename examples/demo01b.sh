#!/bin/bash


# This demo shows how to use t_log4sh.sh in a simplest way.
# Make sure that your current working directory is "examples" (containing this script file),
# then you execute the demo script by using command "./demo01b.sh"
#
# We use API: t_log and t_log_st



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


echo "BEGIN DEMO 01b"
send_request
echo "DONE DEMO 01b"


# Expected output:
#
# BEGIN DEMO 01b
# 2024-11-30 15:39:16.477 [DEBUG] demo01b.sh:16: check_data: msg with debug level
# 2024-11-30 15:39:16.480 [INFO ] demo01b.sh:17: check_data: msg with info level
# 2024-11-30 15:39:16.481 [WARN ] demo01b.sh:18: check_data: msg with warn level
# 2024-11-30 15:39:16.482 [ERROR] demo01b.sh:19: check_data: msg with err level
# 2024-11-30 15:39:16.484 [WARN ] demo01b.sh:20: check_data: a fatal error occurred, including a detailed stack trace
#     at check_data (./demo01b.sh:20)
#     at send_request (./demo01b.sh:25)
#     at main (./demo01b.sh:30)
# DONE DEMO 01b

