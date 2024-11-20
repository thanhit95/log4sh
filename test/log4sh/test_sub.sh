TEST_SUB_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    TEST_SUB_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    TEST_SUB_FILE_PATH="${0:a}"
fi
TEST_SUB_BASE_DIR="${TEST_SUB_FILE_PATH%/*}"


. "$TEST_SUB_BASE_DIR/../../t_log4sh.sh"


function do_bar() {
    t_logdbg "this is a msg with debug level"
    t_loginfo "this is a msg with info level"
    t_logwarn "this is a msg with warn level"
    t_logerr "this is a msg with err level"
    t_logwarn_st "something happened unexpectedly"
}


function do_foo() {
    do_bar
}
