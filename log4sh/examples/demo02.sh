#!/bin/bash


# The difference of this demo vs. previous demo01 are:
# - It prints all configs of log4sh
# - It detects the current script path at runtime,
#   so you can run this demo from any working directory


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


echo "BEGIN DEMO 02"

echo -e "\n---- CURRENT LOG4SH CONFIGS ----"
# Note: Empty config means using default value
t_log4sh_print_configs

echo -e "\nDONE DEMO 02"


# Expected output:
#
# BEGIN DEMO 02
#
# ---- CURRENT LOG4SH CONFIGS ----
# msg_item.format:
# msg_item.date.format:
# msg_item.date.time_zone:
# channels: stdout
# threshold.min_level: 0
# threshold.max_level: 7
# trace_dump.abs_path:
# channel.file.path:
# channel.syslog.facility: local0
# channel.syslog.tag: demo02.sh
# channel.syslog.server_host:
# channel.syslog.server_port:
#
# DONE DEMO 02

