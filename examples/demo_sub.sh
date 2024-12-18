# This file is not intended to be executed directly
# It is included by other demo scripts


DEMO_SUB_FILE_PATH=
if [[ -n "$BASH_VERSION" ]]; then
    DEMO_SUB_FILE_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
elif [[ -n "$ZSH_VERSION" ]]; then
    DEMO_SUB_FILE_PATH="${0:a}"
else
    DEMO_SUB_FILE_PATH="$(readlink -f "$0")"
fi
DEMO_SUB_BASE_DIR="${DEMO_SUB_FILE_PATH%/*}"


. "$DEMO_SUB_BASE_DIR/../t_log4sh.sh"


function do_bar() {
    local a=(9 8 7)
    t_logtrace "msg with trace level"
    t_logdbg "msg with debug level"
    t_loginfo "msg with info level"
    t_logwarn "msg with warn level, plus array: ${a[*]}"
    t_logerr "msg with err level"
    t_logfatal "msg with fatal level, plus special chars: [] %d %l %F %f %L %m"
    t_logwarn_st "illegal string format [] %d %l"
}


function do_foo() {
    do_bar
}
