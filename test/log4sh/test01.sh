#!/bin/bash


TEST01_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    TEST01_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    TEST01_FILE_PATH="${0:a}"
else
    TEST01_FILE_PATH="$(readlink -f "$0")"
fi
TEST01_BASE_DIR="${TEST01_FILE_PATH%/*}"


. "$TEST01_BASE_DIR/test_sub.sh"


function do_sth() {
    do_foo
}


do_sth
echo "Done testing"


# Expected output:
#
# 2024-11-20 22:11:13.486 [DEBUG] test_sub.sh:14: do_bar: this is a msg with debug level
# 2024-11-20 22:11:13.489 [INFO ] test_sub.sh:15: do_bar: this is a msg with info level
# 2024-11-20 22:11:13.492 [WARN ] test_sub.sh:16: do_bar: this is a msg with warn level
# 2024-11-20 22:11:13.494 [ERROR] test_sub.sh:17: do_bar: this is a msg with err level
# 2024-11-20 22:11:13.497 [WARN ] test_sub.sh:18: do_bar: something happened unexpectedly
#     at do_bar (/home/thanh/linux_shell_kit/test/log4sh/test_sub.sh:18)
#     at do_foo (/home/thanh/linux_shell_kit/test/log4sh/test_sub.sh:23)
#     at do_sth (test/log4sh/test01.sh:17)
#     at main (test/log4sh/test01.sh:21)
# Done testing

