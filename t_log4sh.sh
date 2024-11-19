#!/bin/bash


################################################################################
#
# DESCRIPTION
#   This library provides the logging functions with stack trace dumpling.
#   Please view the section "API" for details.
#
#   Supported log levels: DEBUG, INFO, WARN, ERROR
#
#   There are two function types for each log level:
#       t_log{level} and t_log{level}_st
#   The postfix "_st" indicates that the function will dump the call stack.
#
#
#
# USAGE
#   Importing the library:
#       . t_log4sh.sh
#       source t_log4sh.sh
#
#   Using the API:
#       t_log{level} <msg>
#       t_log{level}_st <msg>
#
#       Examples:
#           t_loginfo "Hello, world!"
#           t_loginfo_st "Hello, world!"
#           t_logerr_st "Something happened unexpectedly"
#
#
#
# DEPENDENCIES
#   - Commands: readlink
#
################################################################################




_T_LOG4SH_THIS_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    _T_LOG4SH_THIS_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    _T_LOG4SH_THIS_FILE_PATH="${0:a}"
fi
_T_LOG4SH_THIS_BASE_DIR="${_T_LOG4SH_THIS_FILE_PATH%/*}"
_T_LOG4SH_THIS_FILE_NAME="${_T_LOG4SH_THIS_FILE_PATH##*/}"
# echo "_T_LOG4SH_THIS_FILE_PATH: $_T_LOG4SH_THIS_FILE_PATH"
# echo "_T_LOG4SH_THIS_BASE_DIR: $_T_LOG4SH_THIS_BASE_DIR"
# echo "_T_LOG4SH_THIS_FILE_NAME: $_T_LOG4SH_THIS_FILE_NAME"


################################################################################
#                              PRIVATE CONSTANTS
################################################################################


_T_LOG4SH_SPACE_ARR=(
    ""
    " "
    "  "
    "   "
    "    "
    "     "
    "      "
    "       "
    "        "
)
_T_LOG4SH_SPACE_ARR_SIZE="${#_T_LOG4SH_SPACE_ARR[@]}"


################################################################################
#                          INTERNAL API (may expose later)
################################################################################


# Prints the call stack of the current function invocation.
#
# Arguments:
#   skip_cnt        The number of stack frames to skip. The default is 0.
#   prefix_sp_cnt   The number of spaces to prefix each line with. The default is 4.
#
# Examples:
#   _t_dump_trace
#   _t_dump_trace 1
#   _t_dump_trace 0 8
#
function _t_dump_trace() {
    local skip_cnt="$1"
    local prefix_sp_cnt="$2"
    local n tmp
    local i=0
    local file_name line_no func_name

    [[ -z "$skip_cnt" ]] && skip_cnt=0
    [[ -z "$prefix_sp_cnt" ]] && prefix_sp_cnt=4
    [[ "$prefix_sp_cnt" -gt "$_T_LOG4SH_SPACE_ARR_SIZE" ]] && prefix_sp_cnt=$_T_LOG4SH_SPACE_ARR_SIZE
    [[ "$prefix_sp_cnt" -lt 0 ]] && prefix_sp_cnt=0

    if [[ -n "$BASH_VERSION" ]]; then
        while read -r line_no func_name file_name < <(caller $i); do
            if [[ "$i" -ge "$skip_cnt" ]]; then
                echo "${_T_LOG4SH_SPACE_ARR[@]:$prefix_sp_cnt:1}at $func_name ($file_name:$line_no)"
            fi
            ((++i))
        done
    elif [[ -n "$ZSH_VERSION" ]]; then
        local n="${#funcfiletrace[@]}"
        for ((i=1; i<=n; ++i)); do
            [[ "$i" -le "$skip_cnt" ]] && continue
            file_name="${funcfiletrace[$i]%\:*}"
            line_no="${funcfiletrace[$i]#*\:}"
            func_name="${funcstack[$i+1]}"
            [[ -z "$func_name" && "$i" -eq "$n" ]] && func_name=main
            echo "${_T_LOG4SH_SPACE_ARR[@]:$prefix_sp_cnt:1}at $func_name ($file_name:$line_no)"
        done
    fi
}


# Prints a log message with the current time, file name, line number, function
# name, and the given message.
#
# Arguments:
#   dump_trace      If true, dump the call stack. The default is false.
#   trace_skip_cnt  The number of stack frames to skip. The default is 0.
#   level           The log level. The default is 'INFO'.
#   msg             The log message.
#
# Examples:
#   _t_log_base true 0 "INFO" "Hello, world!"
#
function _t_log_base() {
    local dump_trace="$1"
    local trace_skip_cnt="$2"
    local level="$3"
    local msg="$4"
    local file_name line_no func_name

    if [[ -n "$BASH_VERSION" ]]; then
        file_name="${BASH_SOURCE[$trace_skip_cnt+1]##*/}"
        line_no="${BASH_LINENO[$trace_skip_cnt]}"
        func_name="${FUNCNAME[$trace_skip_cnt+1]}"
    elif [[ -n "$ZSH_VERSION" ]]; then
        file_name="${funcfiletrace[$trace_skip_cnt+1]%\:*}"
        file_name="${file_name##*\/}"
        line_no="${funcfiletrace[$trace_skip_cnt+1]#*\:}"
        func_name="${funcstack[$trace_skip_cnt+2]}"
    fi

    # local dt="$(TZ=UTC-7 date '+%F %T.%3N')"
    local dt="$(date '+%Y-%m-%d %H:%M:%S.%3N')"

    echo "$dt [$level] $file_name:$line_no: $func_name: $msg"
    # echo "$dt [$level] $func_name: $msg"

    (( ++trace_skip_cnt ))
    # _t_dump_trace "$trace_skip_cnt"
    if [[ "$dump_trace" == true ]]; then
        _t_dump_trace "$trace_skip_cnt"
    fi
}


################################################################################
#                                    API
################################################################################


function t_logdbg() {
    local msg="$1"
    _t_log_base false 1 "DEBUG" "$msg"
}
function t_loginfo() {
    local msg="$1"
    _t_log_base false 1 "INFO " "$msg"
}
function t_logwarn() {
    local msg="$1"
    _t_log_base false 1 "WARN " "$msg"
}
function t_logerr() {
    local msg="$1"
    _t_log_base false 1 "ERROR" "$msg"
}


function t_logdbg_st() {
    local msg="$1"
    _t_log_base true 1 "DEBUG" "$msg"
}
function t_loginfo_st() {
    local msg="$1"
    _t_log_base true 1 "INFO " "$msg"
}
function t_logwarn_st() {
    local msg="$1"
    _t_log_base true 1 "WARN " "$msg"
}
function t_logerr_st() {
    local msg="$1"
    _t_log_base true 1 "ERROR" "$msg"
}

