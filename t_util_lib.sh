#!/bin/bash


################################################################################
#
# DESCRIPTION
#   This library provides a set of utility functions.
#
#   Supported OS: Linux
#   Supported shells: bash, zsh
#
#
#
# USAGE
#   Importing the library:
#       . t_util_lib.sh
#       source t_util_lib.sh
#
#   Using the API:
#       Please view the section "API" for details.
#
#
#
# DEPENDENCIES
#   - Commands: bc, readlink
#
################################################################################






################################################################################
# INIT
################################################################################


[[ $_T_UTIL_LIB_SOURCED ]] && return
_T_UTIL_LIB_SOURCED=1


_T_UTIL_LIB_THIS_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    _T_UTIL_LIB_THIS_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    _T_UTIL_LIB_THIS_FILE_PATH="${0:a}"
else
    _T_UTIL_LIB_THIS_FILE_PATH="$(readlink -f "$0")"
fi
_T_UTIL_LIB_THIS_BASE_DIR="${_T_UTIL_LIB_THIS_FILE_PATH%/*}"
_T_UTIL_LIB_THIS_FILE_NAME="${_T_UTIL_LIB_THIS_FILE_PATH##*/}"
# echo "_T_UTIL_LIB_THIS_FILE_PATH: $_T_UTIL_LIB_THIS_FILE_PATH"
# echo "_T_UTIL_LIB_THIS_BASE_DIR: $_T_UTIL_LIB_THIS_BASE_DIR"
# echo "_T_UTIL_LIB_THIS_FILE_NAME: $_T_UTIL_LIB_THIS_FILE_NAME"


################################################################################
# GLOBAL CONSTANTS
################################################################################


declare -A T_CHAR_2_VAL_DATA_SIZE_UNIT_MP=(
    ["b"]=0
    ["k"]=1
    ["m"]=2
    ["g"]=3
    ["t"]=4
    ["p"]=5
)


T_VAL_2_CHAR_DATA_SIZE_UNIT_MP=(b k m g t p)


T_DATA_SIZE_BI_UNIT_POWER=(1 1024 1048576 1073741824 1099511627776 1125899906842624)


################################################################################
# PRIVATE FUNCTIONS
################################################################################


function _lo_printerr() {
    local line_no
    local func_name
    local tmp

    if [[ -n "$BASH_VERSION" ]]; then
        IFS=' ' read line_no func_name tmp <<< "$(caller 0)"
    elif [[ -n "$ZSH_VERSION" ]]; then
        func_name="${funcstack[2]}"
        line_no="${funcfiletrace[1]#*:}"
    else
        line_no=$LINENO
    fi

    echo "$_T_UTIL_LIB_THIS_FILE_NAME:$line_no $func_name(): $@" 1>&2
}


################################################################################
# API
################################################################################


# Clamps an integer value to a given range.
#
# This function takes three arguments: a minimum value, a maximum value, and a
# value to clamp. The function returns the clamped value.
#
# If the input value is less than the minimum, the minimum is returned.
# If the input value is greater than the maximum, the maximum is returned.
# Otherwise, the input value is returned unchanged.
#
# Arguments:
#   min         The minimum value to clamp
#   max         The maximum value to clamp
#   value       The value to clamp
#
function t_clamp() {
    local min="$1"
    local max="$2"
    local value="$3"

    [[ -z "$min" ]] && _lo_printerr "Missing argument: min" && exit 1
    [[ -z "$max" ]] && _lo_printerr "Missing argument: max" && exit 1
    [[ -z "$value" ]] && _lo_printerr "Missing argument: value" && exit 1

    if [[ "$value" -lt "$min" ]]; then
        echo "$min"
    elif [[ "$value" -gt "$max" ]]; then
        echo "$max"
    else
        echo "$value"
    fi
}


# Prints the content with a prefix prepended to each line.
#
# This function takes two arguments: a prefix string and a content string.
# The content string is read line-by-line and each line is printed with the
# prefix prepended. If the content string is empty, the function reads from
# standard input instead.
#
# Arguments:
#   prefix      The prefix string to prepend to each line
#   content     The content string to print
#
function t_echo_with_prefix() {
    local prefix="$1"
    local content="$2"

    [[ -z "$prefix" ]] && _lo_printerr "Missing argument: prefix" && exit 1

    if [[ ! -z "$content" ]]; then
        while IFS= read -r line || [[ -n $line ]]; do
            echo "$prefix$line"
        done <<< "$content"
    else
        while IFS= read -r line || [[ -n $line ]]; do
            echo "$prefix$line"
        done
    fi
}


# Converts a data size from one unit to another.
#
# This function takes an input number with a source unit and converts it
# to a destination unit using base-2 (IEC standard) conversions. If the
# source or destination unit is specified as "_", the function will
# attempt to auto-detect the unit based on the input number or
# calculation.
#
# Arguments:
#   src_unit    Source unit character ("b", "k", "m", "g", "t", "p" or "_")
#                   b is bytes
#                   k is kibibytes
#                   m is mebibytes
#                   g is gibibytes
#                   t is tebibytes
#                   p is pebibytes
#                   _ is auto-detect
#   dst_unit    Destination unit character, values are the same as src_unit
#   num         The positive number to convert, with optional trailing unit
#
# Returns:
#   Converted data size with destination unit
#       If dst_unit is "_":
#           - The auto-detected unit will be included in the output.
#           - The number will be calculated to display appropriately.
#
# Example:
#                                                      Output
#   t_convert_data_size_bi_unit m k "10"               10240
#   t_convert_data_size_bi_unit _ k "10m"              10240
#   t_convert_data_size_bi_unit k g "1000000"          .953
#   t_convert_data_size_bi_unit _ g "1000000k"         .953
#   t_convert_data_size_bi_unit m _ "1025.67"          1025.67m
#   t_convert_data_size_bi_unit b _ "107378182"        102.403m
#   t_convert_data_size_bi_unit g _ "0.0000123"        13207b
#   t_convert_data_size_bi_unit _ _ "0.0000123g"       13207b
#   t_convert_data_size_bi_unit _ _ "0.000123g"        128k
#   t_convert_data_size_bi_unit _ _ "0.0000000123g"    13b
#   t_convert_data_size_bi_unit k _ "389164k"          380.042m
#   t_convert_data_size_bi_unit k _ "389164m"          380.042g
#
function t_convert_data_size_bi_unit() {
    local src_unit="$1"
    local dst_unit="$2"
    local num="$3"

    # debug
    # echo "input src_unit: $src_unit"
    # echo "input dst_unit: $dst_unit"
    # echo "input num: $num"

    [[ -z "$src_unit" ]] && _lo_printerr "Missing argument: src_unit" && exit 1
    [[ -z "$dst_unit" ]] && _lo_printerr "Missing argument: dst_unit" && exit 1
    [[ -z "$num" ]] && _lo_printerr "Missing argument: num" && exit 1

    local num_final_char="${num:0-1}"

    if [[ "$src_unit" == "_" || ! "$num_final_char" =~ [0-9] ]]; then
        # auto detect
        src_unit="${num:0-1}"
        if [[ "$src_unit" =~ [0-9] ]]; then
            src_unit=b
        else
            num="${num:0:-1}"
        fi
    fi

    local src_unit_enum="${T_CHAR_2_VAL_DATA_SIZE_UNIT_MP[$src_unit]}"
    local dst_unit_enum=
    # when dst_unit_enum="_" (autodetect), the postfix_unit will be set to autodetected unit
    local postfix_unit=

    # debug
    # echo "input2 src_unit: $src_unit"
    # echo "input2 dst_unit: $dst_unit"
    # echo "input2 num: $num"

    if [[ "$dst_unit" == "_" ]]; then
        # auto detect
        #
        # My algorithm:
        #   if num >= 1
        #       power2 = log2(num)
        #       num_3octets_to_divide = roundInt(power2 / 10) - 1
        #   else
        #       power2 = -log2(num)
        #       num_3octets_to_multiply = roundInt(power2 / 10) + 1
        #
        # Example:
        #   case num >= 1
        #       num = 107375182 bytes
        #       power2 = log2(num) = 26.68
        #       num_3octets_to_divide = roundInt(power2 / 10) - 1 = roundInt(26.68 / 10) - 1 = roundInt(2.68) - 1 = 3 - 1 = 2
        #       So we need to divide num by 2^(10 * num_3octets_to_divide) = 2^(10 * 2) = 2^20
        #       ==> num / (2^20) = 102.4 mebibytes
        #   case 0 <= num < 1
        #       num = 0.0000123 gibibytes
        #       power2 = -log2(num) = 16.31
        #       num_3octets_to_multiply = roundInt(power2 / 10) + 1 = roundInt(16.31 / 10) + 1 = roundInt(1.631) + 1 = 2 + 1 = 3
        #       So we need to mutiply num with 2^(10 * num_3octets_to_multiply) = 2^(10 * 3) = 2^30
        #       ==> num * (2^30) = 13207.024 bytes
        #
        if [[ "$(bc <<< "$num >= 1")" == "1" ]]; then
            local num_3octets_to_divide="$(bc -l <<< "x=10 * (l($num) / l(2) / 10 + 0.5 - 1); scale=0; x/10")"
            # echo "num_3octets_to_divide is $num_3octets_to_divide"
            dst_unit_enum="$(( $src_unit_enum + $num_3octets_to_divide ))"
        else
            local num_3octets_to_multiply="$(bc -l <<< "x=10 * (-l($num) / l(2) / 10 + 0.5 + 1); scale=0; x/10")"
            # echo "num_3octets_to_multiply is $num_3octets_to_multiply"
            dst_unit_enum="$(( $src_unit_enum - $num_3octets_to_multiply ))"
        fi
        dst_unit_enum="$(t_clamp 0 5 "$dst_unit_enum")"
        dst_unit="${T_VAL_2_CHAR_DATA_SIZE_UNIT_MP[@]:$dst_unit_enum:1}"
        postfix_unit="$dst_unit"
    else
        dst_unit_enum="${T_CHAR_2_VAL_DATA_SIZE_UNIT_MP[$dst_unit]}"
    fi

    # debug
    # echo "src_unit: $src_unit, src_unit_enum: $src_unit_enum"
    # echo "dst_unit: $dst_unit, dst_unit_enum: $dst_unit_enum"
    # echo "num: $num"

    local dst_src_diff="$(( $dst_unit_enum - $src_unit_enum ))"
    local src_dst_diff="$(( $src_unit_enum - $dst_unit_enum ))"

    if [ "$dst_src_diff" -eq 0 ]; then
        echo "$num$postfix_unit"
        return
    fi

    if [ "$dst_src_diff" -lt 0 ]; then
        echo "$(bc <<< "scale=0; $num * ${T_DATA_SIZE_BI_UNIT_POWER[@]:$src_dst_diff:1} / 1")$postfix_unit"
    else
        echo "$(bc <<< "scale=3; $num / ${T_DATA_SIZE_BI_UNIT_POWER[@]:$dst_src_diff:1}")$postfix_unit"
    fi
}


################################################################################
# TEST
################################################################################


# t_convert_data_size_bi_unit _ _ "63756"
# t_convert_data_size_bi_unit _ k "10m"
# t_convert_data_size_bi_unit _ k "10m" | t_echo_with_prefix "    Convert 10 mebibytes to kibibytes: "
# t_convert_data_size_bi_unit _ g "1000000k"
# t_convert_data_size_bi_unit _ _ "1025.67m"
# t_convert_data_size_bi_unit _ _ "0.0000123g"
# t_convert_data_size_bi_unit _ _ "0.000123g"
# t_convert_data_size_bi_unit _ _ "0.0000000123g"
# t_convert_data_size_bi_unit b _ "107378182"
# n="$(t_convert_data_size_bi_unit b _ "107378182")" && echo "n is $n"

# t_convert_data_size_bi_unit k _ "389164"
# t_convert_data_size_bi_unit k _ "389164k"
# t_convert_data_size_bi_unit k _ "389164m"

# n="$(t_convert_data_size_bi_unit b _)" && echo "n is $n"

# echo "Done testing"
