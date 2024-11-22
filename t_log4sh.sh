#!/bin/bash


################################################################################
#
# FILE NAME
#   t_log4sh.sh
#
# VERSION
#   1.0
#
# RELEASE DATE
#   2024-11-22
#
# AUTHOR
#   Thanh Nguyen (thanh.it1995@gmail.com)
#
# LICENSE
#   BSD-3-Clause license
#
#
#
# DESCRIPTION
#   This library provides the logging functions with common features:
#   - Log level control
#   - Log message formatting
#   - Multiple output channels
#   - Stack trace dump
#   - Configuration file
#
#   Supported OS: Linux
#   Supported shells: bash, zsh
#   Supported log levels: TRACE, DEBUG, INFO, WARN, ERROR, FATAL
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
#       The postfix "_st" indicates that the function will dump the call stack.
#       Please view the section "API" for details.
#
#       Examples:
#           t_logdbg "Hello, debug!"
#           t_loginfo "Hello, info!"
#           t_logwarn "Hello, warn!"
#           t_logerr "Hello, error!"
#           t_logwarn_st "Something happened unexpectedly"
#           t_logerr_st "Got error status in execution" >&2
#           t_logerr_st "Argument is invalid" >err.log
#
#
#
# EXAMPLES
#   See the complete example scripts in "examples/log4sh/"
#
#
#
# NOTES
#   - By default, the output is sent to stdout. If you want to send the logs
#     to a file, you may apply the configuration file.
#
#
#
# DEPENDENCIES
#   - Commands: readlink, date
#
################################################################################






################################################################################
# INIT
################################################################################


[[ $_T_LOG4SH_SOURCED ]] && return
_T_LOG4SH_SOURCED=1


_T_LOG4SH_THIS_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    _T_LOG4SH_THIS_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    _T_LOG4SH_THIS_FILE_PATH="${0:a}"
else
    _T_LOG4SH_THIS_FILE_PATH="$(readlink -f "$0")"
fi
_T_LOG4SH_THIS_BASE_DIR="${_T_LOG4SH_THIS_FILE_PATH%/*}"
_T_LOG4SH_THIS_FILE_NAME="${_T_LOG4SH_THIS_FILE_PATH##*/}"
# echo "_T_LOG4SH_THIS_FILE_PATH: $_T_LOG4SH_THIS_FILE_PATH"
# echo "_T_LOG4SH_THIS_BASE_DIR: $_T_LOG4SH_THIS_BASE_DIR"
# echo "_T_LOG4SH_THIS_FILE_NAME: $_T_LOG4SH_THIS_FILE_NAME"


################################################################################
# PRIVATE CONSTANTS
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

_T_LOG4SH_LV_STR_ARR=("LOG4SH" "TRACE" "DEBUG" "INFO " "WARN " "ERROR" "FATAL")
_T_LOG4SH_INTERNAL_LV=0
_T_LOG4SH_TRACE_LV=1
_T_LOG4SH_DEBUG_LV=2
_T_LOG4SH_INFO_LV=3
_T_LOG4SH_WARN_LV=4
_T_LOG4SH_ERROR_LV=5
_T_LOG4SH_FATAL_LV=6

_T_LOG4SH_STDOUT_CHN=stdout
_T_LOG4SH_STDERR_CHN=stderr
_T_LOG4SH_FILE_CHN=file
_T_LOG4SH_CMD_CHN=cmd
_T_LOG4SH_CHN_SET="$_T_LOG4SH_STDOUT_CHN|$_T_LOG4SH_STDERR_CHN|$_T_LOG4SH_FILE_CHN|$_T_LOG4SH_CMD_CHN"


################################################################################
# CONFIGURATIONS
################################################################################


_T_LOG4SH_CFG_CHANNELS="$_T_LOG4SH_STDOUT_CHN"
_T_LOG4SH_CFG_CHN_FILE_PATH=
_T_LOG4SH_CFG_CHN_CMD_CMDLINE=
_T_LOG4SH_CFG_LOG_FORMAT=
_T_LOG4SH_CFG_DATE_FORMAT=
_T_LOG4SH_CFG_DATE_TIME_ZONE=
_T_LOG4SH_CFG_TRACE_DUMP_RESOLVE_ABS_PATH=
_T_LOG4SH_CFG_THRESHOLD_MIN_LV=0
_T_LOG4SH_CFG_THRESHOLD_MAX_LV=7


################################################################################
# INTERNAL API (may expose later)
################################################################################


# Prints the call stack of the current function invocation.
#
# Arguments:
#   skip_cnt        The number of stack frames to skip. The default is 0.
#   prefix_sp_cnt   The number of spaces to prefix each line with. The default is 4.
#
# Examples:
#   _t_log4sh_dump_trace
#   _t_log4sh_dump_trace 1
#   _t_log4sh_dump_trace 0 8
#
function _t_log4sh_dump_trace() {
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
        local n="${#FUNCNAME[@]}"
        for ((i=1; i<n; ++i)); do
            [[ "$i" -le "$skip_cnt" ]] && continue
            file_name="${BASH_SOURCE[$i]}"
            line_no="${BASH_LINENO[$i-1]}"
            func_name="${FUNCNAME[$i]}"
            [[ "$_T_LOG4SH_CFG_TRACE_DUMP_RESOLVE_ABS_PATH" == "true" ]] && file_name="$(readlink -f "$file_name")"
            [[ -z "$func_name" && "$i" -eq "$n" ]] && func_name=main
            echo "${_T_LOG4SH_SPACE_ARR[@]:$prefix_sp_cnt:1}at $func_name ($file_name:$line_no)"
        done
        # while read -r line_no func_name file_name < <(caller $i); do
        #     # echo ">>>>>>> LOOP $i"
        #     if [[ "$i" -ge "$skip_cnt" ]]; then
        #         [[ "$_T_LOG4SH_CFG_TRACE_DUMP_RESOLVE_ABS_PATH" == "true" ]] && file_name="$(readlink -f "$file_name")"
        #         echo "${_T_LOG4SH_SPACE_ARR[@]:$prefix_sp_cnt:1}at $func_name ($file_name:$line_no)"
        #     fi
        #     ((++i))
        # done
    elif [[ -n "$ZSH_VERSION" ]]; then
        local n="${#funcfiletrace[@]}"
        for ((i=1; i<=n; ++i)); do
            [[ "$i" -le "$skip_cnt" ]] && continue
            file_name="${funcfiletrace[$i]%\:*}"
            line_no="${funcfiletrace[$i]#*\:}"
            func_name="${funcstack[$i+1]}"
            [[ "$_T_LOG4SH_CFG_TRACE_DUMP_RESOLVE_ABS_PATH" == "true" ]] && file_name="$(readlink -f "$file_name")"
            [[ -z "$func_name" && "$i" -eq "$n" ]] && func_name=main
            echo "${_T_LOG4SH_SPACE_ARR[@]:$prefix_sp_cnt:1}at $func_name ($file_name:$line_no)"
        done
    fi
}


function _t_log4sh_get_date_by_format() {
    if [[ -z "$_T_LOG4SH_CFG_DATE_TIME_ZONE" ]]; then
        date "+${_T_LOG4SH_CFG_DATE_FORMAT}"
    else
        TZ="$_T_LOG4SH_CFG_DATE_TIME_ZONE" date "+${_T_LOG4SH_CFG_DATE_FORMAT}"
    fi
}


# Prints a log message with the specified format.
#
# The format string can contain the following placeholders:
#   %d: date
#   %l: level
#   %f: file name
#   %L: line number
#   %F: function name
#   %m: message
#
# The function takes 7 arguments:
#   fmt         The format string
#   dt          The date string
#   level_str   The log level string
#   file_name   The file name string
#   line_no     The line number string
#   func_name   The function name string
#   msg         The message string
#
function _t_log4sh_print_by_format() {
    local fmt="$1"
    local dt="$2"
    local level_str="$3"
    local file_name="$4"
    local line_no="$5"
    local func_name="$6"
    local msg="$7"

    local res=
    local chr
    local fmt_len="${#fmt}"

    for (( i=0; i<fmt_len; ++i )); do
        chr="${fmt:$i:1}"
        if [[ "$chr" != "%" ]]; then
            res+="$chr"
            continue
        fi
        ((++i))
        chr="${fmt:$i:1}"
        if [[ "$chr" == "d" ]]; then
            res+="$dt"
        elif [[ "$chr" == "l" ]]; then
            res+="$level_str"
        elif [[ "$chr" == "f" ]]; then
            res+="$file_name"
        elif [[ "$chr" == "L" ]]; then
            res+="$line_no"
        elif [[ "$chr" == "F" ]]; then
            res+="$func_name"
        elif [[ "$chr" == "m" ]]; then
            res+="$msg"
        fi
    done

    echo "$res"
}


# Prints a log message with the current time, file name, line number, function
# name, and the given message.
#
# Arguments:
#   dump_trace      If true, dump the call stack. The default is false.
#   trace_skip_cnt  The number of stack frames to skip. The default is 0.
#   level           Level (int value)
#   msg             The log message.
#
# Examples:
#   _t_log4sh_log_base true 0 3 "Hello, world!"
#
function _t_log4sh_log_base() {
    local dump_trace="$1"
    local trace_skip_cnt="$2"
    local level="$3"
    local msg="$4"
    local dt
    local file_name line_no func_name
    local log_msg

    if [[ $level -ne _T_LOG4SH_INTERNAL_LV ]]; then
        [[ $level -lt _T_LOG4SH_CFG_THRESHOLD_MIN_LV || $level -gt _T_LOG4SH_CFG_THRESHOLD_MAX_LV ]] && return
    fi
    local level_str="${_T_LOG4SH_LV_STR_ARR[@]:$level:1}"

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

    if [[ -z "$_T_LOG4SH_CFG_DATE_FORMAT" ]]; then
        # dt="$(TZ=UTC-7 date '+%F %T.%3N')"
        dt="$(date '+%Y-%m-%d %H:%M:%S.%3N')"
    else
        dt="$(_t_log4sh_get_date_by_format)"
    fi

    if [[ -z "$_T_LOG4SH_CFG_LOG_FORMAT" ]]; then
        log_msg="$dt [$level_str] $file_name:$line_no: $func_name: $msg"
        # log_msg="$dt [$level_str] $func_name: $msg"
    else
        log_msg="$(_t_log4sh_print_by_format "$_T_LOG4SH_CFG_LOG_FORMAT" \
                "$dt" "$level_str" "$file_name" "$line_no" "$func_name" "$msg")"
    fi

    # (( ++trace_skip_cnt ))
    # _t_log4sh_dump_trace "$trace_skip_cnt"
    if [[ "$dump_trace" == true ]]; then
        stack_trace_str="$(_t_log4sh_dump_trace "(( trace_skip_cnt + 1 ))")"
        log_msg="$log_msg"$'\n'"$stack_trace_str"
    fi

    if [[ $level -eq _T_LOG4SH_INTERNAL_LV ]]; then
        echo "$log_msg" >&2
        return
    fi

    for channel in "${_T_LOG4SH_CFG_CHANNELS[@]}"; do
        case "$channel" in
            "$_T_LOG4SH_STDOUT_CHN")
                echo "$log_msg"
                ;;
            "$_T_LOG4SH_STDERR_CHN")
                echo "$log_msg" >&2
                ;;
            "$_T_LOG4SH_FILE_CHN")
                echo "$log_msg" >> "$_T_LOG4SH_CFG_CHN_FILE_PATH"
                ;;
            "$_T_LOG4SH_CMD_CHN")
                # echo "$log_msg" | $_T_LOG4SH_CFG_CHN_CMD_CMDLINE
                echo "$log_msg" | eval ${_T_LOG4SH_CFG_CHN_CMD_CMDLINE}
                ;;
            *)
                ;;
        esac
    done

    # if [[ -z "$_T_LOG4SH_CFG_CHN_FILE_PATH" ]]; then
    #     echo "$log_msg"
    # else
    #     echo "$log_msg" >> "$_T_LOG4SH_CFG_CHN_FILE_PATH"
    # fi
}


# function _t_log4sh_trap_last_err_cmd() {
#     local level_str="$1"
#     if [[ -n "$BASH_VERSION" ]]; then
#         trap "t_log_st ""$level_str"' "Error on executing cmd: ${BASH_COMMAND}"' ERR
#     elif [[ -n "$ZSH_VERSION" ]]; then
#         # I could not find a solution
#         trap "t_log_st ""$level_str"' "Error on executing a cmd"' ERR
#     else
#         :
#     fi
# }


################################################################################
# API
################################################################################


function t_log4sh_print_configs() {
    echo "log_format: $_T_LOG4SH_CFG_LOG_FORMAT"
    echo "date_format: $_T_LOG4SH_CFG_DATE_FORMAT"
    echo "date_time_zone: $_T_LOG4SH_CFG_DATE_TIME_ZONE"
    echo "trace_dump_resolve_abs_path: $_T_LOG4SH_CFG_TRACE_DUMP_RESOLVE_ABS_PATH"
    echo "threshold_min_level: $_T_LOG4SH_CFG_THRESHOLD_MIN_LV"
    echo "threshold_max_level: $_T_LOG4SH_CFG_THRESHOLD_MAX_LV"
    echo "channels: ${_T_LOG4SH_CFG_CHANNELS[@]}"
    echo "channel.file.path: $_T_LOG4SH_CFG_CHN_FILE_PATH"
    echo "channel.cmd.cmdline: $_T_LOG4SH_CFG_CHN_CMD_CMDLINE"
}


# Sets a configuration value.
#
# Arguments:
#   key         The key of the configuration value.
#   val         The value of the configuration value.
#   line        The line of the configuration file.
#               When key and val are both empty, use line from this as key and value.
#               Line syntax: <key>=<value>
# Example:
#   t_log4sh_set_config "log_format" "%d %l %f:%L %m"
#   t_log4sh_set_config "" "" "log_format=%d %l %f:%L %m"
#
# Config keys:
#   log_format: Log message format
#               Placeholders:
#                   %d: date
#                   %l: level
#                   %f: file name
#                   %L: line number
#                   %F: function name
#                   %m: message
#   date_format: Date format used in log message
#   date_time_zone: Time zone used in date
#   trace_dump_resolve_abs_path: Whether to convert relative path to absolute path
#   threshold_min_level: Minimum log level (integer)
#   threshold_max_level: Maximum log level (integer)
#                        Note: Log levels: 1=TRACE, 2=DEBUG, 3=INFO,
#                                          4=WARN, 5=ERROR, 6=FATAL
#   channels: Comma-separated list of channels
#             Available channels: stdout, stderr, file, cmd
#   channel.file.path: File path for 'file' channel
#   channel.cmd.cmdline: Command line for 'cmd' channel
#
function t_log4sh_set_config() {
    local key="$1"
    local val="$2"
    # when key($1) and val($2) are both empty, use line from $3
    # line syntax: <key>=<value>
    local line="$3"

    local arr arr2

    if [[ -z "$key" && -z "$val" ]]; then
        [[ -z "$line" ]] && return
        key="${line%=*}"
        val="${line#*=}"
    fi

    case "$key" in
        "log_format")
            _T_LOG4SH_CFG_LOG_FORMAT="$val"
            ;;
        "date_format")
            _T_LOG4SH_CFG_DATE_FORMAT="$val"
            ;;
        "date_time_zone")
            _T_LOG4SH_CFG_DATE_TIME_ZONE="$val"
            ;;
        "trace_dump_resolve_abs_path")
            _T_LOG4SH_CFG_TRACE_DUMP_RESOLVE_ABS_PATH="$val"
            ;;
        "threshold_min_level")
            _T_LOG4SH_CFG_THRESHOLD_MIN_LV="$val"
            ;;
        "threshold_max_level")
            _T_LOG4SH_CFG_THRESHOLD_MAX_LV="$val"
            ;;
        "channels")
            if [[ -n "$BASH_VERSION" ]]; then
                IFS=',' read -a arr <<< "$val"
            elif [[ -n "$ZSH_VERSION" ]]; then
                IFS=',' read -A arr <<< "$val"
            else
                :
            fi
            arr2=()
            for channel in "${arr[@]}"; do
                if [[ ! "$channel" =~ ^($_T_LOG4SH_CHN_SET)$ ]]; then
                    _t_log4sh_log_base true 0 "$_T_LOG4SH_INTERNAL_LV" \
                            "Illegal channel value: $channel"
                fi
                arr2+=("$channel")
            done
            _T_LOG4SH_CFG_CHANNELS=("${arr2[@]}")
            ;;
        "channel.file.path")
            _T_LOG4SH_CFG_CHN_FILE_PATH="$val"
            ;;
        "channel.cmd.cmdline")
            _T_LOG4SH_CFG_CHN_CMD_CMDLINE="$val"
            ;;
        *)
            ;;
    esac
}


# Initializes log4sh from a configuration file.
#
# Arguments:
#   cfg_file_path   Path to the configuration file.
#
# The configuration file format is as follows:
#   <key>=<value>
#   <key>=<value>
#   ...
#   <key>=<value>
#
#   key: log_format, date_format, date_time_zone, trace_dump_resolve_abs_path,
#        threshold_min_level, threshold_max_level, channels, channel.file.path,
#        channel.cmd.cmdline
#   value: value of the key
#
# Please refer to the function "t_log4sh_set_config" for details.
#
# Example content of configuration file:
#   log_format=%d %l %f:%L %m
#   date_format=%Y-%m-%d %H:%M:%S
#   date_time_zone=UTC-2
#   trace_dump_resolve_abs_path=true
#   threshold_min_level=1
#   threshold_max_level=6
#   channels=stderr,file
#   channel.file.path=/var/log/app.log
#
function t_log4sh_init_from_cfg_file() {
    local cfg_file_path="$1"

    if [[ ! -f "$cfg_file_path" ]]; then
        _t_log4sh_log_base true 0 "$_T_LOG4SH_INTERNAL_LV" \
                "Configuration file not found: $cfg_file_path"
        # echo "log4sh: Configuration file not found: $cfg_file_path" >&2
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "#"* ]]; then
            continue
        fi
        t_log4sh_set_config "" "" "$line"
    done < "$cfg_file_path"

    # t_log4sh_print_configs
    return 0
}


function t_log() {
    local level_str="$1"
    local msg="$2"

    case "$level_str" in
        "LOG4SH")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_INTERNAL_LV" "$msg" ;;
        "TRACE")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_TRACE_LV" "$msg" ;;
        "DBG" | "DEBUG")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_DEBUG_LV" "$msg" ;;
        "INFO")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_INFO_LV" "$msg" ;;
        "WARN")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_WARN_LV" "$msg" ;;
        "ERR" | "ERROR")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_ERROR_LV" "$msg" ;;
        "FATAL")
            _t_log4sh_log_base false 1 "$_T_LOG4SH_FATAL_LV" "$msg" ;;
        *)
            _t_log4sh_log_base true 0 "$_T_LOG4SH_INTERNAL_LV" \
                    "Illegal level_str: $level_str; Note: msg is $msg" ;;
    esac
}


function t_log_st() {
    local level_str="$1"
    local msg="$2"

    case "$level_str" in
        "LOG4SH")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_INTERNAL_LV" "$msg" ;;
        "TRACE")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_TRACE_LV" "$msg" ;;
        "DBG" | "DEBUG")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_DEBUG_LV" "$msg" ;;
        "INFO")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_INFO_LV" "$msg" ;;
        "WARN")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_WARN_LV" "$msg" ;;
        "ERR" | "ERROR")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_ERROR_LV" "$msg" ;;
        "FATAL")
            _t_log4sh_log_base true 1 "$_T_LOG4SH_FATAL_LV" "$msg" ;;
        *)
            _t_log4sh_log_base true 0 "$_T_LOG4SH_INTERNAL_LV" \
                    "Illegal level_str: $level_str; Note: msg is $msg" ;;
    esac
}


function t_logtrace() {
    local msg="$1"
    _t_log4sh_log_base false 1 "$_T_LOG4SH_TRACE_LV" "$msg"
}
function t_logdbg() {
    local msg="$1"
    _t_log4sh_log_base false 1 "$_T_LOG4SH_DEBUG_LV" "$msg"
}
function t_loginfo() {
    local msg="$1"
    _t_log4sh_log_base false 1 "$_T_LOG4SH_INFO_LV" "$msg"
}
function t_logwarn() {
    local msg="$1"
    _t_log4sh_log_base false 1 "$_T_LOG4SH_WARN_LV" "$msg"
}
function t_logerr() {
    local msg="$1"
    _t_log4sh_log_base false 1 "$_T_LOG4SH_ERROR_LV" "$msg"
}
function t_logfatal() {
    local msg="$1"
    _t_log4sh_log_base false 1 "$_T_LOG4SH_FATAL_LV" "$msg"
}


function t_logtrac_st() {
    local msg="$1"
    _t_log4sh_log_base true 1 "$_T_LOG4SH_TRACE_LV" "$msg"
}
function t_logdbg_st() {
    local msg="$1"
    _t_log4sh_log_base true 1 "$_T_LOG4SH_DEBUG_LV" "$msg"
}
function t_loginfo_st() {
    local msg="$1"
    _t_log4sh_log_base true 1 "$_T_LOG4SH_INFO_LV" "$msg"
}
function t_logwarn_st() {
    local msg="$1"
    _t_log4sh_log_base true 1 "$_T_LOG4SH_WARN_LV" "$msg"
}
function t_logerr_st() {
    local msg="$1"
    _t_log4sh_log_base true 1 "$_T_LOG4SH_ERROR_LV" "$msg"
}
function t_logfatal_st() {
    local msg="$1"
    _t_log4sh_log_base true 1 "$_T_LOG4SH_FATAL_LV" "$msg"
}

