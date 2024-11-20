# linux_shell_kit

Random Linux shell stuff.

This repository contains my random Linux shell stuff, including:

- The utility libraries
- The tools

## The utility libraries

### t_log4sh.sh

Logging library which supports stack trace dump and configurations.

Output example:

```shell
# Calling the API fuctions:
#   t_logdbg "this is a msg with debug level"
#   t_loginfo "this is a msg with info level"
#   t_logwarn "this is a msg with warn level"
#   t_logerr "this is a msg with err level"
#   t_logwarn_st "something happened unexpectedly"
#
# Output:
2024-11-20 22:11:13.486 [DEBUG] test_sub.sh:14: do_bar: this is a msg with debug level
2024-11-20 22:11:13.489 [INFO ] test_sub.sh:15: do_bar: this is a msg with info level
2024-11-20 22:11:13.492 [WARN ] test_sub.sh:16: do_bar: this is a msg with warn level
2024-11-20 22:11:13.494 [ERROR] test_sub.sh:17: do_bar: this is a msg with err level
2024-11-20 22:11:13.497 [WARN ] test_sub.sh:18: do_bar: something happened unexpectedly
    at do_bar (/home/thanh/linux_shell_kit/test/log4sh/test_sub.sh:18)
    at do_foo (/home/thanh/linux_shell_kit/test/log4sh/test_sub.sh:23)
    at do_sth (test/log4sh/test01.sh:17)
    at main (test/log4sh/test01.sh:21)
Done testing
```

### t_util_lib.sh
  - Data size conversion (e.g: from gibibytes to bytes)
  - Echo with prefix

## The tools

### t_proc_info.sh

Provides brief info of a process by using existed tools (top, lsof...) and displays results in a visual, organized manner.

Output example:

```shell
$ ./t_proc_info.sh 39614

BASIC INFO:
  pid: 39614, ppid: 39570
  user: id=1000, name=thanh
  comm_name: opera
  threads: 19
  cwd: /home/thanh
  bin_exe_path: /usr/lib64/opera/opera
  cmdline: /usr/lib64/opera/opera --type=utility --utility-sub-type=network.mojom.NetworkService --lang=en-US --service-sandbox-type=none --enable-quic --crashpad-handler-pid=39574 --change-stack-guard-on-fork=enable --with-feature:password-generator=off --with-feature:specific-keywords=on --with-feature:startpage-content-phase-1=off

RESOURCES USAGE:
  cpu_util_percent: 0.0
  virt_size: 32.7g
  rss_size: 115.007m
  shr_size: 90.535m

FILE DESCRIPTORS:
  Network:
    TCP:
      fd: 94u, protocol: TCP IPv4, addr: fedora:35506->111.65.248.197:https (ESTABLISHED)
      fd: 156u, protocol: TCP IPv4, addr: fedora:42420->93.243.107.34.bc.googleusercontent.com:https (ESTABLISHED)
      fd: 31u, protocol: TCP IPv4, addr: fedora:42888->vip01.trn.opera.technology:https (ESTABLISHED)
      fd: 51u, protocol: TCP IPv4, addr: fedora:56014->vip02.trn.opera.technology:https (ESTABLISHED)
      fd: 53u, protocol: TCP IPv4, addr: fedora:57322->118.69.17.18:https (CLOSE_WAIT)
    UDP:
      fd: 19u, protocol: UDP IPv4, addr: fedora:51151->nchkga-am-in-f14.1e100.net:https
      fd: 28u, protocol: UDP IPv4, addr: fedora:59742->42.119.208.140:https
      fd: 37u, protocol: UDP IPv4, addr: fedora:33352->edge-star-mini-shv-01-sin6.facebook.com:https
      fd: 59u, protocol: UDP IPv4, addr: mdns.mcast.net:mdns

  Regular files:
    fd: 39u, path: /home/thanh/.config/opera/Default/Cookies
    fd: 57u, path: /home/thanh/.config/opera/Default/Reporting and NEL
    fd: 26u, path: /home/thanh/.config/opera/Default/Safe Browsing Cookies
    fd: 29u, path: /home/thanh/.config/opera/Default/Shared Dictionary/db
    fd: 27u, path: /home/thanh/.config/opera/Default/Trust Tokens
    fd: 4r, path: /usr/lib64/opera/icudtl.dat
    fd: 12r, path: /usr/lib64/opera/localization/en-US.pak
```

## Author & license

Author: Thanh Nguyen

Email: thanh.it1995 (at) gmail.com

This repo is licensed under the 3-Clause BSD License.
