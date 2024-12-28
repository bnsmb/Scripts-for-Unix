# Scripts-for-Unix

This repository contains some of my scripts for Unix. The scripts are tested in Solaris and Linux (Redhat)

Available are currently these scripts:

<hr>

**execute_on_all_hosts.sh**

**execute_on_all_hosts.sh** executes a command or script on a list of hosts either sequentiell or in parallel. The script uses scp and ssh to connect to the machines

Usage:
```
[xtrnaw7@t15g ~]$ execute_on_all_hosts.sh -h
[28.12.2024 13:50:52] execute_on_all_hosts.sh v2.4.0 started at Sat Dec 28 13:50:52 CET 2024 (The PID of this process is 643986). 
[28.12.2024 13:50:52] No config file ("execute_on_all_hosts.conf") found (use -C to create a default config file) 
  execute_on_all_hosts.sh v2.4.0 - copy a script to a list of hosts via scp and execute it on the hosts using ssh

  Usage: execute_on_all_hosts.sh [-v|+v] [-q|+q] [-h] [-l logfile|+l] [-y|+y] [-n|+n]
                    [-D debugswitch] [-a|+a] [-O|+O] [-f|+f] [-C] [-H] [-X] [-S n] [-V] [-T]
                    [-i hostlist{,hostlist1{,...}] [-s scriptfile] [-o outputfile] [-u sshuser|scp:scpuser|ssh:sshuser] [-I basedir]
                    [-c shell] [-k] [-U] [-p scpoptions] [-P sshoptions] [-K] [-R] [-B|+B] [-b ssh_keyfile|scp:scp_keyfile|ssh:ssh_keyfile]
                    [-x excludehost] [-A includehost] [-t ssh:ssh_template] [-t scp:scp_template] 
                    [-d|+d] [-W [timeout[/intervall]] [-w NoOfBackgroundProcs[/intervall[/timeout]]] [-e filename]
                    [hostlist [scriptfile [outputfile [sshuser]]]]

  The parameters scriptfile, outputfile, and sshuser overwrite the options; hostlist (or includehost) and scriptfile are mandatory either
  as parameter or as option.

  For optimal usage ssh login via public key should be enabled on the target hosts and
  the ssh agent should run on this host (the agent is currently running).

  Use "-D help" to view the known debug options.

  Use the parameter "-v -h [-v]" to view the detailed online help; use the parameter "-X" to view some usage examples.

  It is strongly recommended to test the script execution in dry run mode (parameter "-D dryrun") before doing the real work!

  see also http://bnsmb.de/solaris/execute_on_all_hosts.html


[28.12.2024 13:50:52] Use "-v -h", "-v -v -h", "-v -v -v -h" or "+h" for a long help text 
[28.12.2024 13:50:52] The log file used was "/tmp/execute_on_all_hosts.sh.643986.TEMP"  
[28.12.2024 13:50:52] execute_on_all_hosts.sh v2.4.0 started at Sat Dec 28 13:50:52 CET 2024 and ended at Sat Dec 28 13:50:52 CET 2024. 
[28.12.2024 13:50:52] The script runtime is (day:hour:minute:seconds) 0:00:00:00 (= 0 seconds) for  hosts 
[28.12.2024 13:50:52] The RC is 1. 
[xtrnaw7@t15g ~]$ 
```

see [http://bnsmb.de/solaris/execute_on_all_hosts.html](http://bnsmb.de/solaris/execute_on_all_hosts.html) for details

<hr>

**execute_scripts.sh**

**execute_scripts.sh** executes multiple scripts or commands on a host either sequential or in parallel

Usage:
```
[xtrnaw7@t15g ~]$ execute_scripts.sh -h
[28.12.2024 13:51:31] execute_scripts.sh v1.0.0 started at Sat Dec 28 13:51:31 CET 2024. 
[28.12.2024 13:51:31] No config file ("execute_scripts.conf") found (use -C to create a default config file) 
  execute_scripts.sh v1.0.0 - execute multiple excecutables either parallel or sequentiell

  Usage: execute_scripts.sh [-v|+v] [-q|+q] [-h] [-l logfile|+l] [-y|+y] [-n|+n]
                           [-D debugswitch] [-a|+a] [-O|+O] [-f|+f] [-C] [-H] [-X] [-S n] [-V] [-T]
                           [-d|+d] [-W [timeout[/intervall]] [-w NoOfBackgroundProcs[/intervall[/timeout]]]] [-c shell] [-k|+k] [-r|+r] [-B|+B]
                           -I [listfile|directory|regex] [-i executable] [-x executable] [-o workdir] [-s startscript] [-z stopscript]

  The parameters -I or -i are mandatory.

  Use the parameter "-v -h [-v]" to view the detailed online help; use the parameter "-X" to view some usage examples.

  see also http://bnsmb.de/solaris/execute_scripts.html


[28.12.2024 13:51:31] Use "-v -h", "-v -v -h", "-v -v -v -h" or "+h" for a long help text 
[28.12.2024 13:51:31] The log file used was "/tmp/execute_scripts.sh.644329.TEMP"  
[28.12.2024 13:51:31] execute_scripts.sh v1.0.0 started at Sat Dec 28 13:51:31 CET 2024 and ended at Sat Dec 28 13:51:31 CET 2024. 
[28.12.2024 13:51:31] The RC is 1. 
[xtrnaw7@t15g ~]$ 
```
see [http://bnsmb.de/solaris/execute_scripts.html](http://bnsmb.de/solaris/execute_scripts.html) for details

<hr>

**execute_tasks.sh**

**execute_tasks.sh** executes tasks defined in an include file

Usage:
```
[xtrnaw7@t15g ~]$ execute_tasks.sh  -h
[28.12.2024 13:52 ] ### execute_tasks.sh started at 28.12.2024 13:52:46 (The PID of this process is 645051)
[28.12.2024 13:52 ] ### Processing the parameter ...
[28.12.2024 13:52 ] Tasks to execute are: "" 
[28.12.2024 13:52 ] Parameter for the function init_tasks are: "" 
egrep: warning: egrep is obsolescent; using grep -E
 Usage:    execute_tasks.sh [-v|--verbose] [-q|--quiet] [-f|--force] [-o|--overwrite] [-y|--yes] [-n|--no] [-l|--logfile filename]
               [-d{:dryrun_prefix}|--dryrun{:dryrun_prefix}] [-D|--debugshell] [-t fn|--tracefunc fn] [-L] 
               [-T|--tee] [-V|--version] [--var name=value] [--appendlog] [--nologrotate] [--noSTDOUTlog] [--disable_tty_check] [--nobackups]
               [--print_task_template [filename]] [--create_include_file_template [filename]] [--list [taskmask]] [--list_tasks [taskmask]]
               [--list_task_groups [groupmask]] [--list_default_tasks] [--abort_on_error] [--abort_on_task_not_found] [--abort_on_duplicates]
               [--checkonly] [--check] [--singlestep] [--unique] [--trace] [--info] [--print_includefile_help] [-i|--includefile [?]filename] 
               [--no_init_tasks[ [--no_finish_tasks] [--only_list_tasks] [--disabled_tasks task1[...,task#]] [--list_disabled_tasks] [--enable_all_tasks]
               [task1] [... task#] [-- parameter_for_init_tasks]

Current environment: ksh version: 93 | change function code supported: yes | tracing feature using $0 supported: yes

[28.12.2024 13:52 ] ### The logfile used was /var/tmp/execute_tasks.sh.log
[28.12.2024 13:52 ] ### The start time was 28.12.2024 13:52:46, the script runtime is (day:hour:minute:seconds) 0:00:00:00 (= 0 seconds)
[28.12.2024 13:52 ] ### execute_tasks.sh ended at 28.12.2024 13:52:46 (The PID of this process is 645051; the RC is 0)
[xtrnaw7@t15g ~]$ 
```

see [http://bnsmb.de/linux/execute_tasks_usage_help.html](http://bnsmb.de/linux/execute_tasks_usage_help.html) for details for the script execute_task.sh


see the include files with tasks to install and configure a ROM on an Android phone as example:

[https://github.com/bnsmb/scripts-for-Android/blob/main/scripts/prepare_phone.include](https://github.com/bnsmb/scripts-for-Android/blob/main/scripts/prepare_phone.include)


<hr>

**scriptt_mini.sh**

**scriptt_mini.sh** is a template for a kornshell script that should run on Linux, Solaris, or AIX

Predefined usage:
```
[xtrnaw7@t15g /data/develop/scripts]$ ./scriptt_mini.sh -h
[28.12.2024 13:53] ### scriptt_mini.sh started at 28.12.2024 13:53:55 (The PID of this process is 645764)
 Usage:    <scriptname> [-h|--help] [-v|--verbose] [-v:fn|--verbose:fn] [-q|--quiet] [-f|--force] [-o|--overwrite] [-y|--yes] [-n|--no]
               [-l|--logfile [filename[:n]|:n] [-d{:dryrun_prefix}|--dryrun{:dryrun_prefix}] [-D|--debugshell] [-t fn|--tracefunc fn] [-L]
               [-T|--tee] [-V|--version] [--var name=value] [--appendlog] [--nologrotate] [--noSTDOUTlog] [--print_runtime_vars]
               [--nocleanup] [--nobackups] [--disable_tty_check] [--norcm] [--no_appl_params] [--no_appl_file]

 Use the parameter "--help" to print the detailed help message; use the parameter "--help -v" to also print the list of supported environment variables

Current environment: ksh version: 93 | change function code supported: yes | tracing feature using $0 supported: yes

[28.12.2024 13:53] ### The start time was 28.12.2024 13:53:55, the script runtime is (day:hour:minute:seconds) 0:00:00:00 (= 0 seconds)
[28.12.2024 13:53] ### scriptt_mini.sh ended at 28.12.2024 13:53:55 (The PID of this process is 645764; the RC is 0)
[xtrnaw7@t15g /data/develop/scripts]$ 
```
see [http://bnsmb.de/solaris/scriptt_mini.html](http://bnsmb.de/solaris/scriptt_mini.html) for details.

<hr>

**scriptt.sh**

**scriptt.sh** is a more complex template for a kornshell script that should run on Linux, Solaris, or AIX

Predefined usage:
```
[xtrnaw7@t15g /data/develop/scripts]$ ./scriptt.sh -h
egrep: warning: egrep is obsolescent; using grep -E
[28.12.2024 13:54:12] scriptt.sh v1.0.0 started at Sat Dec 28 13:54:12 CET 2024. 
[28.12.2024 13:54:12] Reading the config file "/data/develop/scripts/scriptt.conf" ... 
  scriptt.sh v1.0.0 - ??? short description ???

  Usage: scriptt.sh [-v|+v] [-q|+q] [-h] [-l logfile|+l] [-y|+y] [-n|+n]
                    [-D debugswitch] [-a|+a] [-O|+O] [-f|+f] [-C] [-H] [-X] [-S n] [-V] [-T]

                    [??? add additional parameter here ???]


  Use the parameter "-v -h [-v]" to view the detailed online help; use the parameter "-X" to view some usage examples.

  see also http://bnsmb.de/solaris/scriptt.html



[28.12.2024 13:54:12] Use "-v -h", "-v -v -h", "-v -v -v -h" or "+h" for a long help text 
[28.12.2024 13:54:12] The log file used was "/tmp/scriptt.sh.646012.TEMP"  
[28.12.2024 13:54:12] scriptt.sh v1.0.0 started at Sat Dec 28 13:54:12 CET 2024 and ended at Sat Dec 28 13:54:12 CET 2024. 
[28.12.2024 13:54:12] The time used for the script is 0 minutes and 0 seconds. 
[28.12.2024 13:54:12] The RC is 1. 
[xtrnaw7@t15g /data/develop/scripts]$ 
```

see [http://bnsmb.de/solaris/scriptt.html](http://bnsmb.de/solaris/scriptt.html) for details

<hr>


