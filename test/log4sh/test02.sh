#!/bin/bash


TEST02_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    TEST02_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    TEST02_FILE_PATH="${0:a}"
else
    TEST02_FILE_PATH="$(readlink -f "$0")"
fi
TEST02_BASE_DIR="${TEST02_FILE_PATH%/*}"


. "$TEST02_BASE_DIR/test_sub.sh"


function do_sth() {
    do_foo
}


#t_log4sh_init_from_cfg_file "not_existed_file.ini"
t_log4sh_init_from_cfg_file "$TEST02_BASE_DIR/test02_config.ini"
echo


do_sth
echo "Done testing"


# Expected output in the file test02.log:
#
# [ 2024.11.20 22.30.56,19 ][ DEBUG ] do_bar() in file test_sub.sh (line 14): this is a msg with debug level
# [ 2024.11.20 22.30.56,20 ][ INFO  ] do_bar() in file test_sub.sh (line 15): this is a msg with info level
# [ 2024.11.20 22.30.56,20 ][ WARN  ] do_bar() in file test_sub.sh (line 16): this is a msg with warn level
# [ 2024.11.20 22.30.56,21 ][ ERROR ] do_bar() in file test_sub.sh (line 17): this is a msg with err level
# [ 2024.11.20 22.30.56,22 ][ WARN  ] do_bar() in file test_sub.sh (line 18): something happened unexpectedly
#     at do_bar (/home/thanh/linux_shell_kit/test/log4sh/test_sub.sh:18)
#     at do_foo (/home/thanh/linux_shell_kit/test/log4sh/test_sub.sh:23)
#     at do_sth (/home/thanh/linux_shell_kit/test/log4sh/test02.sh:17)
#     at main (/home/thanh/linux_shell_kit/test/log4sh/test02.sh:26)

