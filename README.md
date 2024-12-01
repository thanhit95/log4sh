# log4sh


## Introduction

Logging library supporting various features:

- Log level control (min/max threshold)
- Log message formatting
- Multiple output channels (stdout, stderr, file, cmd, syslog)
- Stack trace dump
- Configuration file

Output example:

```shell
# Using the API fuctions:
#   t_logdbg "msg with debug level"
#   t_loginfo "msg with info level"
#   t_log INFO "msg with info level (alias API)"
#   t_log_st WARN "illegal argument value"
#
# Output:
2024-11-30 16:25:14.862 [DEBUG] demo.sh:16: check_data: msg with debug level
2024-11-30 16:25:14.864 [INFO ] demo.sh:17: check_data: msg with info level
2024-11-30 16:25:14.866 [INFO ] demo.sh:18: check_data: msg with info level (alias API)
2024-11-30 16:25:14.868 [WARN ] demo.sh:19: check_data: illegal argument value
    at check_data (./demo.sh:19)
    at send_request (./demo.sh:24)
    at main (./demo.sh:29)
```


## Getting started

(I will update this section later)

You may checkout directory `examples`. It give complete demostrations step by step.


## Author & license

Author: Thanh Nguyen

Email: thanh.it1995 (at) gmail.com

This repo is licensed under the 3-Clause BSD License.
