#!/bin/bash


################################################################################
#
# FILE NAME
#   t_proc_info.sh
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
#   This tool provides brief info of a process by using existed tools
#   (top, lsof...) and displays results in a visual, organized manner.
#
#   Supported OS: Linux
#   Supported shells: bash, zsh
#
#
#
# USAGE
#   t_proc_info.sh <PID>
#
#   Examples:
#       t_proc_info.sh 123
#
#
#
# NOTES
#   The tool may delay some seconds before displaying the result.
#
#
#
# DEPENDENCIES
#   - My common library: file t_util_lib.sh
#   - Commands: tr, cut, grep, cat, pwd, readlink, id, top, lsof
#
################################################################################






################################################################################
# INIT
################################################################################


_T_PROC_INFO_THIS_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    _T_PROC_INFO_THIS_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    _T_PROC_INFO_THIS_FILE_PATH="${0:a}"
else
    _T_PROC_INFO_THIS_FILE_PATH="$(readlink -f "$0")"
fi
_T_PROC_INFO_THIS_BASE_DIR="${_T_PROC_INFO_THIS_FILE_PATH%/*}"
_T_PROC_INFO_THIS_FILE_NAME="${_T_PROC_INFO_THIS_FILE_PATH##*/}"
# echo "_T_PROC_INFO_THIS_FILE_PATH: $_T_PROC_INFO_THIS_FILE_PATH"
# echo "_T_PROC_INFO_THIS_BASE_DIR: $_T_PROC_INFO_THIS_BASE_DIR"
# echo "_T_PROC_INFO_THIS_FILE_NAME: $_T_PROC_INFO_THIS_FILE_NAME"


. "$_T_PROC_INFO_THIS_BASE_DIR/t_util_lib.sh"


################################################################################
# FUNCTIONS
################################################################################



function print_basic_info() {
    local pid="$1"
    local bin_exe_path="$(readlink -f /proc/$pid/exe)"
    local cwd="$(readlink -f /proc/"$pid"/cwd)"
    local cmdline="$(tr '\0' ' ' < /proc/"$pid"/cmdline)"
    local proc_pid_status="$(cat /proc/"$pid"/status)"
    local user_id="$(grep -Po '(?<=Uid:\s)(\d+)' <<< "$proc_pid_status")"
    local user_name="$(id -nu $user_id)"
    local comm_name="$(grep -Po '(?<=Name:\s)(.+)' <<< "$proc_pid_status")"
    local ppid="$(grep -Po '(?<=PPid:\s)(.+)' <<< "$proc_pid_status")"
    local threads="$(grep -Po '(?<=Threads:\s)(\d+)' <<< "$proc_pid_status")"
    echo "pid: $pid, ppid: $ppid"
    echo "user: id=$user_id, name=$user_name"
    echo "comm_name: $comm_name"
    echo "threads: $threads"
    echo "cwd: $cwd"
    echo "bin_exe_path: $bin_exe_path"
    echo "cmdline: ${cmdline[@]}"
}


function print_top_cmd_info() {
    local pid="$1"
    local cmd_out_str="$(top -p "$pid" -b -n 2 -d 1 | tail -1)"

    if [[ -n "$BASH_VERSION" ]]; then
        IFS=' ' read -a cmd_out <<< "$cmd_out_str"
    elif [[ -n "$ZSH_VERSION" ]]; then
        IFS=' ' read -A cmd_out <<< "$cmd_out_str"
    else
        return
    fi

    # echo "cmd_out_str: $cmd_out_str"
    # echo "cmd_out: ${cmd_out[@]}"
    local virt_size_raw="${cmd_out[@]:4:1}"
    local rss_size_raw="${cmd_out[@]:5:1}"
    local shr_size_raw="${cmd_out[@]:6:1}"
    local cpu_util_percent="${cmd_out[@]:8:1}"
    # echo "virt_size_raw: $virt_size_raw"
    # echo "rss_size_raw: $rss_size_raw"
    # echo "shr_size_raw: $shr_size_raw"

    # parse unit of measurement
    # t_convert_data_size_bi_unit _ m "$virt_size"
    local virt_size="$(t_convert_data_size_bi_unit k _ "$virt_size_raw")"
    local rss_size="$(t_convert_data_size_bi_unit k _ "$rss_size_raw")"
    local shr_size="$(t_convert_data_size_bi_unit k _ "$shr_size_raw")"

    echo "cpu_util_percent: $cpu_util_percent"
    echo "virt_size: $virt_size"
    echo "rss_size: $rss_size"
    echo "shr_size: $shr_size"
}


function print_resources_usage() {
    local pid="$1"
    print_top_cmd_info "$pid"
}


function print_fd_info() {
    local pid="$1"
    local cmd_out="$(lsof -p "$pid")"
    # echo "$cmd_out"

    if [[ -n "$BASH_VERSION" ]]; then
        :
    elif [[ -n "$ZSH_VERSION" ]]; then
        :
    else
        return
    fi

    declare -A raw_ds
    local num_fds=-1

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$num_fds" -lt 0 ]]; then
            # ignore the first line
            num_fds=0
            continue
        fi
        # echo "line is $line"

        if [[ -n "$BASH_VERSION" ]]; then
            IFS=' ' read -a fd_info <<< "$line"
        elif [[ -n "$ZSH_VERSION" ]]; then
            IFS=' ' read -A fd_info <<< "$line"
        else
            : # impossible
        fi
        # echo "fd_info is ${fd_info[@]}"


        if [[ "${fd_info[@]:3:1}" == "DEL" ]]; then
            # skip
            num_fds=$(( $num_fds + 1 ))
            continue
        fi

        # fd_info[8]="$(tr -s ' ' <<< "$line" | cut -d' ' -f 9-)"
        # echo "fd: ${fd_info[3]}, type: ${fd_info[4]}, inode: ${fd_info[7]}, path: ${fd_info[8]}"

        raw_ds[$num_fds,0]="${fd_info[@]:3:1}" # fd
        raw_ds[$num_fds,1]="${fd_info[@]:4:1}" # type
        raw_ds[$num_fds,2]="${fd_info[@]:7:1}" # inode
        raw_ds[$num_fds,3]="$(tr -s ' ' <<< "$line" | cut -d' ' -f 9-)" # name

        num_fds=$(( $num_fds + 1 ))
    done <<< "$cmd_out"

    # for ((i=0; i<$num_fds; ++i)); do
    #     echo "fd: ${raw_ds[$i,0]}, type: ${raw_ds[$i,1]}, inode: ${raw_ds[$i,2]}, path: ${raw_ds[$i,3]}"
    # done

    local ds_network_tcp_idx=()
    local ds_network_udp_idx=()
    local ds_memmap_idx=()
    local ds_regular_file_idx=()

    i=0
    [[ -n "$ZSH_VERSION" ]] && (( ++num_fds )) && i=1

    for ((; i<$num_fds; ++i)); do
        if [[ "${raw_ds[$i,2]}" == "TCP" ]]; then
            ds_network_tcp_idx+=($i)
        elif [[ "${raw_ds[$i,2]}" == "UDP" ]]; then
            ds_network_udp_idx+=($i)
        elif [[ "${raw_ds[$i,0]}" == "mem" ]]; then
            ds_memmap_idx+=($i)
        elif [[ "${raw_ds[$i,1]}" == "REG" && "${raw_ds[$i,0]}" =~ ^[0-9] ]]; then
            # ignore deleted files
            if [[ "${raw_ds[$i,3]}" != *" (deleted)" ]]; then
                ds_regular_file_idx+=($i)
            fi
        fi
        # echo "fd: ${raw_ds[$i,0]}, type: ${raw_ds[$i,1]}, inode: ${raw_ds[$i,2]}, path: ${raw_ds[$i,3]}"
    done

    # echo "ds_network_tcp_idx is ${ds_network_tcp_idx[@]}"
    # echo "ds_network_udp_idx is ${ds_network_udp_idx[@]}"
    # echo "ds_memmap_idx is ${ds_memmap_idx[@]}"
    # echo "ds_regular_file_idx is ${ds_regular_file_idx[@]}"

    # Sorting
    local n p q i j tmp

    p=0; n="${#ds_network_tcp_idx[@]}"
    [[ -n "$ZSH_VERSION" ]] && (( ++n )) && p=1

    for ((; p<$n; ++p)); do
        i="${ds_network_tcp_idx[$p]}"
        for ((q=$p+1; q<$n; ++q)); do
            j="${ds_network_tcp_idx[$q]}"
            if [[ "${raw_ds[$i,3]}" > "${raw_ds[$j,3]}" ]]; then
                tmp=${ds_network_tcp_idx[$p]}
                ds_network_tcp_idx[$p]=${ds_network_tcp_idx[$q]}
                ds_network_tcp_idx[$q]=$tmp
                tmp=$i
                i=$j
                j=$tmp
            fi
        done
    done

    p=0; n="${#ds_regular_file_idx[@]}"
    [[ -n "$ZSH_VERSION" ]] && (( ++n )) && p=1

    for ((; p<$n; ++p)); do
        i="${ds_regular_file_idx[$p]}"
        for ((q=$p+1; q<$n; ++q)); do
            j="${ds_regular_file_idx[$q]}"
            if [[ "${raw_ds[$i,3]}" > "${raw_ds[$j,3]}" ]]; then
                tmp=${ds_regular_file_idx[$p]}
                ds_regular_file_idx[$p]=${ds_regular_file_idx[$q]}
                ds_regular_file_idx[$q]=$tmp
                tmp=$i
                i=$j
                j=$tmp
            fi
        done
    done

    # Output
    echo "Network:"
    echo "  TCP:"
    for i in "${ds_network_tcp_idx[@]}"; do
        echo "    fd: ${raw_ds[$i,0]}, protocol: ${raw_ds[$i,2]} ${raw_ds[$i,1]}, addr: ${raw_ds[$i,3]}"
    done
    echo "  UDP:"
    for i in "${ds_network_udp_idx[@]}"; do
        echo "    fd: ${raw_ds[$i,0]}, protocol: ${raw_ds[$i,2]} ${raw_ds[$i,1]}, addr: ${raw_ds[$i,3]}"
    done
    echo; echo "Regular files:"
    for i in "${ds_regular_file_idx[@]}"; do
        echo "  fd: ${raw_ds[$i,0]}, path: ${raw_ds[$i,3]}"
    done
}


################################################################################
# MAIN
################################################################################


input_pid="$1"
# n="$(t_convert_data_size_bi_unit b _)" && echo "n is $n"


if [[ ! -d "/proc/$input_pid" ]]; then
    echo "No such pid: $input_pid"
    exit 1
fi


echo "BASIC INFO:"
print_basic_info "$input_pid" | t_echo_with_prefix "  "

echo; echo "RESOURCES USAGE:"
print_resources_usage "$input_pid" | t_echo_with_prefix "  "

echo; echo "FILE DESCRIPTORS:"
print_fd_info "$input_pid" | t_echo_with_prefix "  "

