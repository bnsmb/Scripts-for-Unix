#!/usr/bin/ksh
#
# Note: use "/usr/bin/ksh -i" if the signal handler do not work
#
# ****  Note: The main code starts after the line containing "# main:" ****
#             The main code for your script should start after "# main - your code"
#             Function statt after the line containing "# functions: "
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2006-2024 Bernd Schemmer  All rights reserved.
# Use is subject to license terms.
#
# Notes:
#
# - use "execute_on_all_hosts.sh {-v} {-v} {-v} -h" to get the usage help
#
# - use "execute_on_all_hosts.sh -H 2>execute_on_all_hosts.sh.doc" to get the documentation
#
# - use "execute_on_all_hosts.sh -X 2>execute_on_all_hosts.sh.examples.doc" to get some usage examples
#
# - this is a Kornshell script - it may not function correctly in other shells
# - the script was written and tested with ksh88 but should also work in ksh93
#   The script should also work in bash -- but that is NOT completly tested
#
# ??? Add usage examples here; the lines should start with ##EXAMPLE##
#

##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # create the documentation for the script
##EXAMPLE##
##EXAMPLE##   ./${__SCRIPTNAME} -H 2>./${__SCRIPTNAME}.doc
##EXAMPLE##
##EXAMPLE## # get the verbose usage for the script
##EXAMPLE##
##EXAMPLE##   ./${__SCRIPTNAME} -v -v -h
##EXAMPLE##
##EXAMPLE## # write a config file for the script
##EXAMPLE##
##EXAMPLE##   ./${__SCRIPTNAME} -C
##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # use another config file
##EXAMPLE##
##EXAMPLE##   CONFIG_FILE=myconfig.conf ./${__SCRIPTNAME}
##EXAMPLE##
##EXAMPLE## # use no config file at all
##EXAMPLE##
##EXAMPLE##   CONFIG_FILE=none ./${__SCRIPTNAME}
##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # write all output (STDOUT and STDERR) to the file
##EXAMPLE## #   /var/tmp/mylog.txt
##EXAMPLE##
##EXAMPLE##    __TEE_OUTPUT_FILE=/var/tmp/mylog.txt ./${__SCRIPTNAME} -T
##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # create a dump of the environment variables in the files
##EXAMPLE## #   /tmp/${__SCRIPTNAME}.envvars.\$\$
##EXAMPLE## #   /tmp/${__SCRIPTNAME}.exported_envvars.\$\$
##EXAMPLE## # (\$\$ is the PID of the process running the script)
##EXAMPLE##
##EXAMPLE##    __CREATE_DUMP=1 ./${__SCRIPTNAME}
##EXAMPLE##
##EXAMPLE## # create a dump of the environment variables in the files
##EXAMPLE## #   /var/tmp/debug/${__SCRIPTNAME}.envvars.\$\$
##EXAMPLE## #   /var/tmp/debug/${__SCRIPTNAME}.exported_envvars.\##EXAMPLE## # (\$\$ is the PID of the process running the script)
##EXAMPLE## # (\$\$ is the PID of the process running the script)
##EXAMPLE##
##EXAMPLE##    __CREATE_DUMP=/var/tmp/debug ./${__SCRIPTNAME}
##EXAMPLE##
#
# Note: The escape character in the commands below is only for the usage of execute_on_all_hosts.sh with the "-X" parameter!
#
##EXAMPLE## # use logger instead of echo to print the messages
##EXAMPLE##
##EXAMPLE##    LOGMSG_FUNCTION=\"logger -s -p user.info execute_on_all_hosts.sh\"  ./execute_on_all_hosts.sh
##EXAMPLE##
##EXAMPLE## # execute the script \"./ls_tmp\" as user \"support\" on the list of hostnames from the file \"machine_list\" 
##EXAMPLE## # in sequential mode using a timeout value for the ssh and scp commands from 10 seconds
##EXAMPLE## 
##EXAMPLE## ./execute_on_all_hosts.sh -D print_cmd  -W 10 -i machine_list  -K -s ./ls_tmp
##EXAMPLE## 
##EXAMPLE## # execute the script \"./ls_tmp\" as user \"unxxx4\" on the list of hostnames from the file \"machine_list\" 
##EXAMPLE## # in sequential mode using a timeout value for the ssh and scp commands from 10 seconds and an intervall 
##EXAMPLE## # between the hosts from 15 seconds
##EXAMPLE## 
##EXAMPLE## ./execute_on_all_hosts.sh -D print_cmd  -W 10/15 -i machine_list  -D sls_db_unxxx4 -K  -s ./ls_tmp
##EXAMPLE## 
##EXAMPLE## 
##EXAMPLE## # hint: add the parameter \"-d\" to the examples below to execute them in parallel sessions
##EXAMPLE## #
##EXAMPLE##
##EXAMPLE## # execute the command \"uname -a\" as user \"support\" on the list of hostnames from the file \"hostlist\"
##EXAMPLE## #
##EXAMPLE## ./execute_on_all_hosts.sh  -i hostlist -s \"uname -a\" -B
##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # execute the script \"testscript\" as user \"support\" on the list of hostnames from the file \"hostlist\"
##EXAMPLE## # and for the host myhost.mydomain.de but not for the host host1.mydomain.de
##EXAMPLE## # Use the interface \"a1\" to access the hosts
##EXAMPLE## #
##EXAMPLE## ./execute_on_all_hosts.sh  -i hostlist -s \"testscript\"  -K -D if=a1 -x host1.mydomain.de -A myhost.mydomain.de
##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # execute the command \"uname -a\" as \"root\" on the list of hostnames from the file \"hostlist\",
##EXAMPLE## # enable ForwardAgent for ssh and scp, cleanup and restore the known_hosts, use the user \"root\" for the ssh access
##EXAMPLE## #
##EXAMPLE## ./execute_on_all_hosts.sh  -i hostlist -s \"uname -a\" -B  +R -D enable_gh -u ssh:root
##EXAMPLE##
##EXAMPLE##
##EXAMPLE## # execute the script \"testscript\" on the list of hostnames from the file \"hostlist_fms\" as user \"root\"
##EXAMPLE## # via the user \"ghuser\" on the jump server \"goldenhost\" and the executable \"sls\" on the golden host:
##EXAMPLE## #
##EXAMPLE## ./execute_on_all_hosts.sh  -i hostlist_fms -s testscript -u ssh:root -t ssh:\"%b %k %o -t -t -A -l ghuser goldenhost sls -c %u@%H '%s' \"
##EXAMPLE##
##EXAMPLE## #

# 
# A timeout script for Operating systems without an executable timeout might look like this:
# 
# # cat /usr/bin/timeout
# #!/bin/ksh
# 
# #
# # ignore arguments for timeout
# #
# while [ $# -ne 0 ] ; do
#   if [[ $1 == --* ]] ; then
#     shift
#     continue
#   fi
#   break
# done
# 
# if [[ $1 == +([0-9]) ]] ; then
#   TIMEOUT=$1
#   shift
# 
#   CMD="$*"
#   (
#      	eval "$CMD" &
# 		CHILD=$!
# 		trap -- "" SIGTERM
# 		(
#          	sleep $TIMEOUT
# 			kill $CHILD 2> /dev/null
# 		) &
# 		wait $CHILD
#   )
# else
#   echo "%0 ERROR: The timeout value \"$1\" is not numeric"
#   exit 250
# fi
# 
# exit $?

# -----------------------------------------------------------------------------
####
#### execute_on_all_hosts.sh - copy a script to a list of hosts via scp and execute it on the hosts using ssh
####
#### Author: Bernd Schemmer (Bernd.Schemmer@gmx.de)
####
#### Version: see variable ${__SCRIPT_VERSION} below
####          (see variable ${__SCRIPT_TEMPLATE_VERSION} for the template version used)
####
#### Supported OS: Solaris and others
####
####
#### Description
#### -----------
####
#### copy a script to a list of hosts via scp and execute it on the hosts using ssh
##C#
##C# Configuration file
##C# ------------------
##C#
##C# This script supports a configuration file called <scriptname>.conf.
##C# The configuration file is searched in the working directory,
##C# the home directory of the user executing this script and in /etc
##C# (in this order).
##C#
##C# The configuration file is read before the parameter are processed.
##C#
##C# To override the default config file search set the variable
##C# CONFIG_FILE to the name of the config file to use.
##C#
##C# e.g. CONFIG_FILE=/var/myconfigfile ./execute_on_all_hosts.sh
##C#
##C# To disable the use of a config file use
##C#
##C#     CONFIG_FILE=none ./execute_on_all_hosts.sh
##C#
##C# See the variable __CONFIG_PARAMETER below for the possible entries
##C# in the config file.
##C#
####
#### Predefined parameter
#### --------------------
####
#### see the subroutines ShowShortUsage and ShowUsage
####
#### Note: The current version of the script template can be found here:
####
####       http://bnsmb.de/solaris/scriptt.html
####
####
##T# Troubleshooting support
##T# -----------------------
##T#
##T# Use
##T#
##T#   __CREATE_DUMP=<anyvalue|directory> <yourscript>
##T#
##T# to create a dump of the environment variables on program exit.
##T#
##T# e.g
##T#
##T#  __CREATE_DUMP=1 ./execute_on_all_hosts.sh
##T#
##T# will create a dump of the environment variables in the files
##T#
##T#   /tmp/execute_on_all_hosts.sh.envvars.$$
##T#   /tmp/execute_on_all_hosts.sh.exported_envvars.$$
##T#
##T# before the script ends
##T#
##T#  __CREATE_DUMP=/var/tmp/debug ./execute_on_all_hosts.sh
##T#
##T# will create a dump of the environment variables in the files
##T#
##T#   /var/tmp/debug/execute_on_all_hosts.sh.envvars.$$
##T#   /var/tmp/debug/execute_on_all_hosts.sh.exported_envvars.$$
##T#
##T# before the script ends (the target directory must already exist).
##T#
##T# Note that the dump files will always be created in case of a syntax
##T# error. To set the directory for these files use either
##T#
##T#   export __DUMPDIR=/var/tmp/debug
##T#   ./execute_on_all_hosts.sh
##T#
##T# or define __DUMPDIR in the script.
##T#
##T# To suppress creating the dump file in case of a syntax error add
##T# the statement
##T#
##T# __DUMP_ALREADY_CREATED=0
##T#
##T# to your script
##T#
##T# Use
##T#
##T#    CreateDump <uniqdirectory> [filename_add]
##T#
##T# to manually create the dump files from within the script.
##T#
##T# e.g.
##T#
##T#   CreateDump /var/debug
##T#
##T# will create the files
##T#
##T#   /var/debug/execute_on_all_hosts.sh.envvars.$$
##T#   /var/debug/execute_on_all_hosts.sh.exported_envvars.$$
##T#
##T#   CreateDump /var/debug pass2.
##T#
##T# will create the files
##T#
##T#   /var/debug/execute_on_all_hosts.sh.envvars.pass2.$$
##T#   /var/debug/execute_on_all_hosts.sh.exported_envvars.pass2.$$
##T#
####  Note:
####    The default action for the signal handler USR1 is
####    "Create an environment dump in /var/tmp"
####    The filenames for the dumps are
####
####      /var/tmp/<scriptname>.envvars.dump_no_<no>_<PID>
####      /var/tmp/<scriptname>.exported_envvars.dump_no_<no>_<PID>
####
####    where <no> is a sequential number, <PID> is the PID of the
####    process with the script, and <scriptname> is the name of the
####    script without the path.
####
####
#### User defined signal handler
#### ---------------------------
####
#### You can define various SIGNAL handlers to process signals received
#### by the script.
####
#### All SIGNAL handlers can use these variables:
####
#### __TRAP_SIGNAL -- the catched trap signal
#### INTERRUPTED_FUNCTION -- the function interrupted by the signal
####
####
#### To define one signal handler for all signals do:
####
####   __GENERAL_SIGNAL_FUNCTION=<signalhandler_name>
####
#### To define unique signal handler for the various signals do:
####
####   __SIGNAL_SIGUSR1_FUNCTION=<signalhandler_name>
####   __SIGNAL_SIGUSR2_FUNCTION=<signalhandler_name>
####   __SIGNAL_SIGHUP_FUNCTION=<signalhandler_name>
####   __SIGNAL_SIGINT_FUNCTION=<signalhandler_name>
####   __SIGNAL_SIGQUIT_FUNCTION=<signalhandler_name>
####   __SIGNAL_SIGTERM_FUNCTION=<signalhandler_name>
####
#### If both type of signal handler are defined the script first
#### executes the general signal handler.
#### If this handler returns 0 the handler for the catched signal will
#### also be executed (else not).
#### If the unique handler for the signal ends with 0 the default signal
#### handler for this signal will also be executed (else not)
####
####
#### Credits
#### -------
####
####   Hints regarding the code to create the lockfile
####     wpollock (http://wikis.sun.com/display/~wpollock)
####
####   Source for the function PrintWithTimeStamp (in version 2.x and newer):
####     http://unix.stackexchange.com/questions/26728/prepending-a-timestamp-to-each-line-of-output-from-a-command
####
####   Andreas Obermaier for a security issue in the lockfile routine
####     (see history section 1.22.45 07.06.2012)
####
####   The code used in executeCommandAndLog is from
####     http://www.unix.com/unix-dummies-questions-answers/13018-exit-status-command-pipe-line.html#post47559
####
####

#### History:
#### --------
##   27.02.2008 v0.0.1 /bs
##     initial release
##   28.02.2008 v0.0.2 /bs
##     added parameter hostlist, scriptfile, outputfile, and user
##     added the parameter -U
##     the script now supports multiple hostlists
##   03.03.2008 v0.0.3 /bs
##     added additional workarounds for CYGWIN
##     added the parameter -I
##     added a summary about failed hosts
##     changed __ONLY_ONCE to ${__FALSE}
##     added code to print a warning if ssh-agent is not running
##   04.03.2008 v0.0.4 /bs
##     changed the default output filename to "/var/tmp/${__SCRIPTNAME##*/}.$$.log"
##     added code to call dos2unix for the script file if running in CYGWIN
##   20.09.2008 v0.0.7 /bs
##     added the option -K / --nostrictkeys
##   20.04.2010 v0.0.8 /bs
##     added RCM support
##   22.12.2010 v0.0.9 /bs
##     added an initial RCM access check
##   30.03.2011 v0.0.10 /bs
##     added the parameter -b / --ssh_keyfile
##     added the parameter -B / +B
##   27.05.2013 v1.0.0 /bs
##     executeCommandAndLog rewritten using coprocesses (see also credits)
##     Info update: executeCommandAndLog does now return the RC of the executed
##                  command even if a logfile is defined
##     replaced the runtime system with scriptt.sh v2.0.0
##     the commands can now run in parallel in the background
##     (parameter -d, -w, and -W)
##
##   06.06.2013 v1.1.0 /bs
##     the parameter -W and now supports a syntax like -W /5 and the
##     "/" can be replaced by ","
##     the parameter -w and now supports a syntax like -w /5, -w /5/20,
##     or -w //10. "/ "can be replaced by ","
##     You can now use seconds, minutes, or hours for the time values
##     of the parameter -w and -W can now
##
##   28.05.2014 v1.2.0 /bs
##     use scriptt.sh v2.0.0.6
##     added the parameter -x (--excludehost)
##     added the parameter -A (--includehost)
##     enhanced support for binaries
##     enhanced support for binaries
##     reworked the usage help
##     replaced "which" whith "whence"
##
##   19.09.2014 v1.3.0 /bs
##     the script now supports the format user@host
##
##   27.09.2014 v1.3.1 /bs
##     added the keyword ignore_user_in_file for the parameter -D
##     added the keyword do_not_sort_hostlist for the parameter -D
##     added the keyword ssh_binary for the parameter -D
##     added the keyword scp_binary for the parameter -D
##     added the keyword dos2unix_binary for the parameter -D
##
##   24.07.2015 v2.0.0 /bs
##     added support for different user for ssh and scp (parameter -u)
##     added support for different ssh key files for the ssh and scp user
##     added an option to list all hosts to the question to start the script
##     added parameter to enable the forward agent for scp (parameter -D enable_ForwardAgent_for_scp)
##     added support for templates for the scp usage (parameter -t scp:scp_template)
##     added support for templates for the ssh usage (parameter -t ssh:ssh_template)
##       The scp/ssh templates are useful if a golden host is used to access the machines
##     added the debug options (parameter -D) from scriptt.sh version 2.1.0.7 21.07.2015
##     added single step mode for sequential usage (parameter -D singlestep)
##     added dry run mode (parameter -D dryrun)
##     added a parameter to cleanup the known_hosts (parameter -D clean_known_hosts)
##     added an example for golden host usage (parameter -D sls_db)
##     added the parameter "-D if=xx"
##     the parameter -K now also adds the options "-o NumberOfPasswordPrompts=0 -o ConnectTimeout=10"
##       to scp and ssh if running in parallel mode
##
##   09.10.2015 v2.0.1 /bs
##     added support for scp via sls; the sls parameter are now:
##       -D sls_scp_db     sls for scp for DB
##       -D sls_ssh_db     sls for ssh for DB
##       -D sls_ssh_fms    sls for ssh for FMS
##
##       -D sls_fms        sls for scp and ssh for FMS
##       -D sls_db         sls for scp and ssh for DB
##
##   24.10.2015 v2.1.0 /bs
##     added support for field separators in the hostlist files (filename[:separator])
##     added the keyword fieldsep=x to the parameter -D to change the default field separator
##     added the keyword printargs to the parameter -D
##     now the parameter -i hostlist is optional if -A hostname is used
##     now the parameter -x hostexcludelist supports a leading "?" for
##       optional hostexcludelist files
##     reworked the messages written by the script (in normal mode and
##     in verbose mode)
##     the parameter "-x none" did not work --fixed
##     the usage with "hostfile scriptfile .." did not work --fixed
##     the script now reset the current terminal using "stty sane" at
##     script end
##     the parameter -K now also adds the options "-o BatchMode=yes -o PasswordAuthentication=no"
##       to scp and ssh if running in parallel mode
##
##   27.10.2015 v2.2.0 /bs
##     execute_on_all_hosts.sh now creates up to 10 backups of the logfile
##     and rewrites the logfile every time.
##     To overwrite the number of backups use the following syntax for
##     the parameter -l:
##
##        -l logfile,[no_of_backups_of_the_logfile]
##
##     The default number of backups for the log file is configured in the variable
##     MAX_NO_OF_LOGFILES
##
##   25.11.2015 v2.2.1 /bs
##     the internal sed field separator is now "" so the pipe charachter
##     "|" can be used in commands to execute again (see the variable SED_SEP)
##
##   25.08.2017 v2.2.2 /bs
##     the parameter -t did not support templates with colon ":" - fixed
##     the script printed in some circumstances the wrong number of hosts to process in the summary (There are 2 hosts to process) - fixed
##
##   26.08.2017 v2.2.3 /bs
##     New macros for the parameter -D:
##
##       -D sls_scp_db_unxxx4     sls for scp for DB as user unxxx4
##       -D sls_ssh_db_unxxx4     sls for ssh for DB as user unxxx4
##       -D sls_db_unxxx4         sls for scp and ssh for DB as user unxxx4
##       -D ticket_id=x           define ticket id for DB access
##       -D use_ssh_wrapper       use my ssh and scp wrapper script for SLS
##       -D no_use_ssh_wrapper    do not use my ssh and scp wrapper script for SLS
##
##     the ticket string set with the parameter "-D ticket_id=x" is now part of the
##     default ssh and scp template (in the default the ticket string is empty)
##
##     improved some error messages to be more clear
##     in the code to enable the forward agent for scp (ENABLE_FORWARD_AGENT_FOR_SCP_CODE)
##       was a "=" missing so that it did not work -- fixed
##
##   21.07.2021 v2.3.0 /bs
##     the parameter "-W timeout/intervall" now defines the timeout for the scp and ssh commands and the intervall
##       between the ssh/scp commands for the machines if running in sequential mode
##       (note: a timeout value will only work if the executable "timeout" is available via the PATH; see the source code for 
##              a timeout implementation in a ksh script)
##     the script now prints a summary at script end like this :
##       (the 2nd line is only shown in sequential mode):
##
##       [16.07.2021 08:52:23] The script runtime is (day:hour:minute:seconds) 0:00:04:33 (= 273 seconds) for 84 hosts 
##       [16.07.2021 08:52:23]   ( -> about 4 second(s) her host) 
##
##     added the template sls_db_unxxx4_w_timeout (-D sls_db_unxxx4_w_timeout) : 
##       Use sls as user unxxx4 to connect with a timeout of 15 seconds for each ssh/scp command
##       Set the variable SSH_SCP_CMD_TIMEOUT before starting the script change the timeout value
##       (note: The template will only work if the executable "timeout" is available via the PATH; see the source code for 
##              a timeout implementation in a ksh script)
##     added the alias "sls" for sls_db_unxxx4_w_timeout
##     the macrco sls_db_unxxx4 (and also sls_db_unxxx4_w_timeout) now uses the scp and ssh binaries defined 
##       with the parameter "-D ssh_binary=x" or "-D scp_binary=x" if defined (def. values are /usr/bin/ssh and /usr/bin/scp)
##     the function die will now call the al<<ias __unsettraps if the script is running in Solaris 
##     LogRuntimeInfo rewritten -- the old syntax did not work in the ksh from Solaris 11
##     added the keyword log_ssh_cmds for the parameter -D
##     added the keyword do_not_log_ssh_cmds for the parameter -D
##     the value for the setting "-o ConnectTimeout" used if the parameter "-K" is used in parallel mode can be defined using the 
##       environment variable SSH_SCP_CMD_TIMEOUT or the parameter -W 
##     the script now prints the list of hosts on which the executed command ended with a non-zero return code
##       at script end if running in sequential mode
##     disabled a wrong error message regarding restoring the known_hosts file
##     the script ignored the return code of the scp command in sequential mode -- fixed
##     the output of the ssh and scp commands in sequential mode was not written to the logfile -- fixed
##       (use the parameter "-D do_not_log_ssh_cmds" to disable the logging of the ssh command output to the logfile)
##     fixed some typos
##     fixed some minor errors
##     ${__FUNCTION_EXIT} was executed twice in the function isNumber  -- fixed
##     the initial runtime code was missing in the functions LogHeader, rand, PrintLockFileErrorMsg, and USER_SIGNAL_HANDLER -- fixed
##     the script did not print the list of failed hosts at script end in sequential mode -- fixed
## 
##   08.09.2022 v2.3.1 /bs
##     the script now also removes the entries for the IP addresses from the known_hosts file if the parameter "-D clean_known_hosts" is used
##     the script now also uses ssh-keygen to remove entries from the known_hosts file if the parameter "-D clean_known_hosts" is used
##       (-> hashed entries in the file will also be removed)
##     added the keyword ssh-keygen_binary for the parameter -D
##     added the keyword nameserver for the parameter -D
##     added the keyword delete_known_hosts for the parameter -D
##     added the keyword clean_and_restore_known_hosts for the parameter -D
##     added the keyword delete_and_restore_known_hosts for the parameter -D
##     added the keyword ignore_known_hosts for the parameter -D
##     added the keyword SLS_db_unxxx4 for the parameter -D
##     added the keyword SLS_db_unxxx4_sudo for the parameter -D
##     added the keyword sls_db_unxxx4_sudo for the parameter -D
##     added the variable TRACE_MAIN (-> trace the main function if the variable TRACE_MAIN is set to 0 before starting the script)
##     added the variable TRACE_PROMPT (-> PS4 prompt used for tracing the main function; set this variable before starting the script)
##    
##   09.12.2022 v2.3.2 /bs
##     the macro sls_ssh_db_unxxx4 was not working -- fixed
## 
##   05.02.2023 v2.3.3 /bs
##     the function CalculateSeconds did not handle values ending with a "h" correct --fixed
##
##   20.02.2023 v2.3.4 /bs
##     the script did not like leading white spaces in the files with the host lists -- fixed

##   12.01.2024 v2.3.5 /bs
##     replaced "egrep" with "grep -E" (see variable EGREP)
##     corrected some minor bugs in the commands to print messages
##
##   22.01.2024 v2.3.6 /bs
##     "grep -E" is not supported by the grep from Solaris 10 -- fixed
##     use gsed instead of sed when available (necessary for Solaris 10)
##
##   03.02.2024 v2.4.0 /bs
##     "stty sane" should not be used if STDIN is not a terminal -- fixed
##     the function CheckInputDevice did not work if the variable __FUNCTION_EXIT was used --fixed
##     the script now prints the name of the hosts on which the script could not be executed or ended with an RC not zero
##     the cleanup function used "kill" instead of "kill -9" for the 2nd kill command -- fixed
##     added the parameter -e/--hosts_with_errors 
##     the script can now store the list of hosts with errors in a file (parameter -e/--hosts_with_errors)
##     fixed some typos in the messages
##

####
####

#### script template History
#### -----------------------
####   1.22.0 08.06.2006 /bs  (BigAdmin Version 1)
####      public release; starting history for the script template
####
####   1.22.1 12.06.2006 /bs
####      added true/false to CheckYNParameter and ConvertToYesNo
####
####   1.22.2. 21.06.2006 /bs
####      added the parameter -V
####      added the use of environment variables
####      added the variable __NO_TIME_STAMPS
####      added the variable __NO_HEADERS
####      corrected a bug in the function executeCommandAndLogSTDERR
####      added missing return commands
####
####   1.22.3 24.06.2006 /bs
####      added the function StartStop_LogAll_to_logfile
####      added the variable __USE_TTY (used in AskUser)
####      corrected an spelling error (dev/nul instead of /dev/null)
####
####   1.22.4 06.07.2006 /bs
####      corrected a bug in the parameter error handling routine
####
####   1.22.5 27.07.2006 /bs
####      corrected some minor bugs
####
####   1.22.6 09.08.2006 /bs
####      corrected some minor bugs
####
####   1.22.7 17.08.2006 /bs
####      add the CheckParameterCount function
####      added the parameter -T
####      added long parameter support (e.g --help)
####
####   1.22.8 07.09.2006 /bs
####      added code to save the env variable LANG and set it temporary to C
####
####   1.22.9 20.09.2006 /bs
####      corrected code to save the env variable LANG and set it temporary to C
####
####   1.22.10 21.09.2006 /bs
####      cleanup comments
####      the number of temporary files created automatically is now variable
####        (see the variable __NO_OF_TEMPFILES)
####      added code to install the trap handler in all functions
####
####   1.22.11 19.10.2006 /bs
####      corrected a minor bug in AskUser (/c was not interpreted by echo)
####      corrected a bug in the handling of the parameter -S (-S was ignored)
####
####   1.22.12 31.10.2006 /bs
####      added the variable __REQUIRED_ZONE
####
####   1.22.13 13.11.2006 /bs
####      the template now uses TMP or TEMP if set for the temporary files
####
####   1.22.14 14.11.2006 /bs
####      corrected a bug in the function AskUser (the default was y not n)
####
####   1.22.15 21.11.2006 /bs
####      added initial support for other Operating Systems
####
####   1.22.16 05.07.2007 /bs
####      enhanced initial support for other Operating Systems
####      Support for other OS is still not fully tested!
####
####   1.22.17 06.07.2007 /bs
####      added the global variable __TRAP_SIGNAL
####
####   1.22.18 01.08.2007 /bs
####      __OS_VERSION and __OS_RELEASE were not set - corrected
####
####   1.22.19 04.08.2007 /bs
####      wrong function used to print "__TRAP_SIGNAL is \"${__TRAP_SIGNAL}\"" - fixed
####
####   1.22.20 12.09.2007 /bs
####      the script now checks the ksh version if running on Solaris
####      made some changes for compatibility with ksh93
####
####   1.22.21 18.09.2007 /bs (BigAdmin Version 2)
####      added the variable __FINISHROUTINES
####      changed __REQUIRED_ZONE to __REQUIRED_ZONES
####      added the variable __KSH_VERSION
####      reworked the trap handling
####
####   1.22.22 23.09.2007 /bs
####      added the signal handling for SIGUSR1 and SIGUSR2 (variables __SIGUSR1_FUNC and __SIGUSR2_FUNC)
####      added user defined function for the signals HUP, BREAK, TERM, QUIT, EXIT, USR1 and USR2
####      added the variables __WARNING_PREFIX, __ERROR_PREFIX,  __INFO_PREFIX, and __RUNTIME_INFO_PREFIX
####      the parameter -T or --tee can now be on any position in the parameters
####      the default output file if called with -T or --tee is now
####        /var/tmp/${0##*/}.$$.tee.log
####
####   1.22.23 25.09.2007 /bs
####      added the environment variables __INFO_PREFIX, __WARNING_PREFIX,
####      __ERROR_PREFIX, and __RUNTIME_INFO_PREFIX
####      added the environment variable __DEBUG_HISTFILE
####      reworked the function to print the usage help :
####      use "-h -v" to view the extented usage help and use "-h -v -v" to
####          view the environment variables used also
####
####   1.22.24 05.10.2007 /bs
####      another minor fix for ksh93 compatibility
####
####   1.22.25 08.10.2007 /bs
####      only spelling errors corrected
####
####   1.22.26 19.11.2007 /bs
####      only spelling errors corrected
####
####   1.22.27 29.12.2007 /bs
####      improved the code to create the lockfile (thanks to wpollock for the info; see credits above)
####      improved the code to create the temporary files (thanks to wpollock for the info; see credits above)
####      added the function rand (thanks to wpollock for the info; see credits above)
####      the script now uses the directory name saved in the variable $TMPDIR for temporary files
####      if it's defined
####      now the umask used for creating temporary files can be changed (via variable __TEMPFILE_UMASK)
####
####   1.22.28 12.01.2008 /bs
####      corrected a syntax error in the show usage routine
####      added the function PrintWithTimestamp (see credits above)
####
####   1.22.29 31.01.2008 /bs
####      there was a bug in the new code to remove the lockfile which prevented
####      the script from removing the lockfile at program end
####      if the lockfile already exist the script printed not the correct error
####      message
####
####   1.22.30 28.02.2008 /bs
####      Info update: executeCommandAndLog does NOT return the RC of the executed
####      command if a logfile is defined
####      added inital support for CYGWIN
####      (tested with CYGWIN_NT-5.1 v..1.5.20(0.156/4/2)
####      Most of the internal functions are NOT tested yet in CYGWIN
####      GetCurrentUID now supports UIDs greater than 254; the function now prints the UID to STDOUT
####      Corrected bug in GetUserName (only a workaround, not the solution)
####      now using printf in the AskUserRoutine
####
####   1.22.30 28.02.2008 /bs
####     The lockfile is now also deleted if the script crashes because of a syntax error or something like this
####
####   1.22.31 18.03.2008 /bs
####     added the version number to the start and end messages
####     an existing config file is now removed (and not read) if the script is called with -C to create a config file
####
####   1.22.32 04.04.2008 /bs
####     minor changes for zone support
####
####   1.22.33 12.02.2009 /bs
####     disabled the usage of prtdiag due to the fact that prtdiag on newer Sun machines needs a long time to run
####     (-> __MACHINE_SUBTYPE is now always empty for Solaris machines)
####     added the variable __CONFIG_FILE_FOUND; this variable contains the name of the config file
####     read if a config file was found
####     added the variable __CONFIG_FILE_VERSION
####
####   1.22.34 28.02.2009 /bs
####     added code to check for the max. line no for the debug handler
####     (an array in ksh88 can only handle up to 4096 entries)
####     added the variable __PIDFILE
####
####  1.22.35 06.04.2009 /bs
####     added the variables
####       __NO_CLEANUP
####       __NO_EXIT_ROUTINES
####       __NO_TEMPFILES_DELETE
####       __NO_TEMPMOUNTS_UMOUNT
####       __NO_TEMPDIR_DELETE
####       __NO_FINISH_ROUTINES
####       __CLEANUP_ON_ERROR
####       CONFIG_FILE
####
####  1.22.36 11.04.2009 /bs
####     corrected a cosmetic error in the messages (wrong: ${TEMPFILE#} correct: ${__TEMPFILE#})
####
####  1.22.37 08.07.2011 /bs
####     corrected a minor error with the QUIET parameter
####     added code to dump the environment (env var __CREATE_DUMP, function CreateDump )
####     implemented work around for missing function whence in bash
####     added the function LogIfNotVerbose
####
####  1.22.38 22.07.2011 /bs
####     added code to make the trap handling also work in bash
####     added a sample user defined trap handler (function USER_SIGNAL_HANDLER)
####     added the function SetHousekeeping to enabe or disable house keeping
####     scriptt.sh did not write all messages to the logfile if a relative filename was used - fixed
####     added more help text for "-v -v -v -h"
####     now user defined signal handler can have arguments
####     the RBAC feature (__USE_RBAC) did not work as expected - fixed
####     added new scriptt testsuite for testing the script template on other OS and/or shells
####     added the function SaveEnvironmentVariables
####
####  1.22.39 24.07.2011 /bs
####     __INIT_FUNCTION now enabled for cygwin also
####     __SHELL did not work in all Unixes - fixed
####     __OS_FULLNAME is now also set in Solaris and Linux
####
####  1.22.40 25.07.2011 /bs
####     added some code for ksh93 (functions: substr)
####     Note: set __USE_ONLY_KSH88_FEATURES to ${__TRUE} to suppress using the ksh93 features
####     The default action for the signal handler USR1 is now "Create an env dump in /var/tmp"
####     The filenames for the dumps are
####
####      /var/tmp/<scriptname>.envvars.dump_no_<no>_<PID>
####      /var/tmp/<scriptname>.exported_envvars.dump_no_<no>_<PID>
####
####     where <no> is a sequential number, <PID> is the PID of the process with the script,
####     and <scriptname> is the name of the script without the path.
####
####  1.22.41 26.09.2011 /bs
####     added the parameter -X
####     disabled some ksh93 code because "ksh -x -n" using ksh88 does not like it
####
####  1.22.42 05.10.2011 /bs
####     added the function PrintDotToSTDOUT
####
####  1.22.43 15.10.2011 /bs
####     added support for disabling the config file feature with CONFIG_FILE=none ./scriptt.sh
####     corrected a minor bug in SaveEnvironmentVariables
####     corrected a bug in the function SaveEnvironmentVariables
####     corrected a bug in getting the value for the variable ${__ABSOLUTE_SCRIPTDIR}
####
####  1.22.44 22.04.2012 /bs
####     The script now uses nawk only if available (if not awk is used)
####     variables are now supported in the usage examples (prefixed with ##EXAMPLE##)
####     add a line with the current date and time to variable dumps, e.g.
####
####         ### /var/tmp/scriptt.sh.exported_envvars.dump_no_0_20074 - exported environment variable dump created on Sun Apr 22 11:35:38 CEST 2012
####
####         ### /var/tmp/scriptt.sh.envvars.dump_no_0_20074 - environment variable dump created on Sun Apr 22 11:35:38 CEST 2012
####
####     added experimental interactive mode to the signal handler for USR2
####     replaced /usr/bin/echo with printf
####     added the variable LOGMSG_FUNCTION
####
####  1.22.45 07.06.2012 /bs
####     added code to check if the symbolic link for the lockfile already exists before creating
####     the lock file
####
####  1.22.46 27.04.2013 /bs
####     executeCommandAndLog rewritten using coprocesses (see also credits)
####     Info update: executeCommandAndLog does now return the RC of the executed
####                  command even if a logfile is defined
####
#### -------------------------------------------------------------------
####
####  2.0.0.0 17.05.2013 /bs
####     added the variable __GENERAL_SIGNAL_FUNCTION: This variable
####       contains the name of a function that is called for all SIGNALs
####       before the special SIGNAL handler is called
####     removed the Debug Handler for single step execution (due to the
####       length of the template it is not useful anymore; use the
####       version 1.x of scriptt.sh if you still need the Debug Handler)
####     function executeCommandAndLogSTDERR rewritten
####     removed the function CheckParameterCount
####     use lsb_release in Linux to retrieve OS infos if available
####     minor fixes for code and comments
####     replaced PrintWithTimeStamp with code that does not use awk
####     isNumber replaced with code that does not use sed
####
####  2.0.0.1 06.08.2013 /bs
####     added the variable __MACHINE_SUB_CLASS. Possible values
####     for sun4v machines: either "GuestLDom" or "PrimaryLDom"
####
####  2.0.0.2 01.09.2013 /bs
####     added the variables __SYSCMDS and __SYSCMDS_FILE
####
####  2.0.0.3 16.12.2013 /bs
####     now the Log-* functions return ${__TRUE} if a message is printed
####     and ${__FALSE} if not
####
####  2.0.0.4 01.01.2014 /bs
####     the alias __settrap is renamed to settraps (with leading s)
####     two new aliase are defined: __ingoretraps and __unsettraps
####     whence function for non-ksh compatible shells rewritten
####       without using ksh
####     the switch -D is now used to toggle debug switches
####       known debug switches:
####        help  -- print the usage help for -D
####         msg  -- log debug messages to /tmp/<scriptname>.<pid>.debug
####       trace  -- activate tracing to the file /tmp/<scriptname>.<pid>.trace
####     AskUser now accepts also "yes" and "no"
####     function IsFunctionDefined rewritten
####     now __LOGON_USERID and __USERID are equal to $LOGNAME until I
####     find a working solution
####       (the code in the previous version did not work if STDIN is not a tty)
####
####   2.0.0.5 08.01.2014 /bs
####      added the function executeFunctionIfDefined
####
####   2.0.0.6 17.01.2014 /bs
####      added the function PrintLine
####      added the debug options fn_to_stderr and fn_to_tty
####      max. return value for a function is 255 and therefor
####        the function for the stack and the functions pos and lastpos
####        now abort the script if a value greater than 255 should be returned
####      added the variables __HASHTAG, __SCRIPT_SHELL, and __SCRIPT_SHELL_OPTIONS
####
####
####


# use "grep -E" instead of "egrep" if supported (this is OS independent)
#
echo test | grep -E test 2>/dev/null >/dev/null && EGREP="grep -E " || EGREP="egrep"

# use ggrep if available (necessary for Solaris 10)
#
GREP=$( whence ggrep ) || GREP="$( whence grep )"

# use gsed if available (necessary for Solaris 10)
#
SED="$( whence gsed )" || SED="$( whence sed )" 

#### ----------------
#### Version variables
####
#### __SCRIPT_VERSION - the version of your script
####
####

typeset  -r __SCRIPT_VERSION="$( ${GREP} "^##[[:space:]]*[0-9\.]* v[0-9]" $0 | awk '{ print $3}' |tail -1 )"

####

#### __SCRIPT_TEMPLATE_VERSION - version of the script template
####
typeset -r __SCRIPT_TEMPLATE_VERSION="2.0.0.6 17.01.2014"
####

#### ----------------
####
##R# Predefined return codes:
##R# ------------------------
##R#
##R#    0 - ok, no error
##R#    1 - show usage and exit
##R#    2 - invalid parameter found
##R#
##R#  210 - 255 reserved for the runtime system
##R#  230 - Script does not exist or is not readable
##R#  231 - Can not write to the file \"${CUR_VAR}\"
##R#  232 - Function SyntaxHelp NOT defined.
##R#  233 - Can not write to file handle 9
##R#  234 - The return value is greater than 255 in function x
##R#  235 - Invalid debug switch found
##R#  236 - syntax error
##R#  237 - Can not write to the debug log file
##R#  238 - unsupported Operating system
##R#  239 - script runs in a not supported zone
##R#  240 - internal error
##R#  241 - a command ended with an error (set -e is necessary to activate this trap)
##R#  242 - the current user is not allowed to execute this script
##R#  243 - invalid machine architecture
##R#  244 - invalid processor type
##R#  245 - invalid machine platform
##R#  246 - error writing the config file
##R#  247 - include script not found
##R#  248 - unsupported OS version
##R#  249 - Script not executed by root
##R#  250 - Script is already running
##R#
##R#  251 - QUIT signal received
##R#  252 - User break
##R#  253 - TERM signal received
##R#  254 - unknown external signal received
##R#

#### ----------------
#### Used environment variables
####
#
# The variable __USED_ENVIRONMENT_VARIABLES is used in the function ShowUsage
#
__USED_ENVIRONMENT_VARIABLES="
#### __DEBUG_CODE
#### __RT_VERBOSE_LEVEL
#### __QUIET_MODE
#### __VERBOSE_MODE
#### __VERBOSE_LEVEL
#### __OVERWRITE_MODE
#### __USER_BREAK_ALLOWED
#### __NO_TIME_STAMPS
#### __NO_HEADERS
#### __USE_COLORS
#### __USE_RBAC
#### __RBAC_BINARY
#### __TEE_OUTPUT_FILE
#### __INFO_PREFIX
#### __DEBUG_PREFIX
#### __WARNING_PREFIX
#### __ERROR_PREFIX
#### __RUNTIME_INFO_PREFIX
#### __NO_CLEANUP
#### __NO_EXIT_ROUTINES
#### __NO_TEMPFILES_DELETE
#### __NO_TEMPMOUNTS_UMOUNT
#### __NO_TEMPDIR_DELETE
#### __NO_FINISH_ROUTINES
#### __CLEANUP_ON_ERROR
#### __CREATE_DUMP
#### __DUMP_ALREADY_CREATED
#### __DUMPDIR
#### __USE_ONLY_KSH88_FEATURES
#### CONFIG_FILE
#### SSH_SCP_CMD_TIMEOUT
#### TRACE_MAIN
#### TRACE_PROMPT
"
####

#
# binaries and scripts used in this script:
#
# awk basename cat cp cpio cut date dd dirname egrep expr find grep id ln ls nawk pwd dig 
# reboot rm sed sh tee timeout touch tty umount uname who
#
# additional OS specific executables:
#
# Solaris: zonename gsed ggrep pfexec
#
# AIX: oslevel
#
# Linux: lsb_release
#
# -----------------------------------------------------------------------------
# variables for the trap handler

__FUNCTION="main"

# alias to install the trap handler
#
# Note: The statement LINENO=${LINENO} is necessary to use the variable LINENO in the trap command
#
alias __settraps="
  LINENO=\${LINENO}
  trap 'GENERAL_SIGNAL_HANDLER SIGHUP    \${LINENO} \${__FUNCTION}' 1
  trap 'GENERAL_SIGNAL_HANDLER SIGINT    \${LINENO} \${__FUNCTION}' 2
  trap 'GENERAL_SIGNAL_HANDLER SIGQUIT   \${LINENO} \${__FUNCTION}' 3
  trap 'GENERAL_SIGNAL_HANDLER SIGTERM   \${LINENO} \${__FUNCTION}' 15
  trap 'GENERAL_SIGNAL_HANDLER SIGUSR1   \${LINENO} \${__FUNCTION}' USR1
  trap 'GENERAL_SIGNAL_HANDLER SIGUSR2   \${LINENO} \${__FUNCTION}' USR2
"

# alias to ignore all traps
#
alias __ingoretraps="
  LINENO=\${LINENO}
  trap '' 1
  trap '' 2
  trap '' 3
  trap '' 15
  trap '' USR1
  trap '' USR2
"

# alias to reset all traps to the defaults
#
alias __unsettraps="
  LINENO=\${LINENO}
  trap 1
  trap 2
  trap 3
  trap 15
  trap USR1
  trap USR2
"

#### ----------------
#### ##### general hints
####
#### Do not use variable names beginning with __ (these are reserved for
#### internal use)
####

# save the language setting and switch the language temporary to C
#
__SAVE_LANG="${LANG}"
LANG=C
export LANG

# -----------------------------------------------------------------------------
#### 
#### constants
####
#### __TRUE - true (0)
#### __FALSE - false (1)
####
####
typeset -r __TRUE=0
typeset -r __FALSE=1

# -----------------------------------------------------------------------------
#### __KSH_VERSION - ksh version (either 88 or 93)
####   If the script is not executed by ksh the shell is compatible to
###    ksh version $__KSH_VERSION
####
  __KSH_VERSION=88 ; f() { typeset __KSH_VERSION=93 ; } ; f ;

# use ksh93 features?
#
if [ "${__KSH_VERSION}"x = "93"x ] ; then
  __USE_ONLY_KSH88_FEATURES=${__USE_ONLY_KSH88_FEATURES:=${__FALSE}}
else
  __USE_ONLY_KSH88_FEATURES=${__USE_ONLY_KSH88_FEATURES:=${__TRUE}}
fi

#### __OS - Operating system (e.g. SunOS)
####
__OS="$( uname -s )"


# ----------------------------------------------------------------------
# read the hash tag of the script
#
#### __HASHTAG - hash tag of the script
#### __SCRIPT_SHELL - shell in the hash tag of the script
#### __SCRIPT_SHELL_OPTIONS - shell options in the hash tag of the script
####
####
  __HASHTAG="$( head -1 $0 )"
  __SCRIPT_SHELL="${__HASHTAG#*!}"
  __SCRIPT_SHELL="${__SCRIPT_SHELL% *}"
  __SCRIPT_SHELL_OPTIONS="${__HASHTAG#* }"
  [ "${__SCRIPT_SHELL_OPTIONS}"x = "${__HASHTAG}"x ] && __SCRIPT_SHELL_OPTIONS=""

# -----------------------------------------------------------------------------
# specific settings for the various operating systems 
#
#
case ${__OS} in
  CYGWIN* )
    set +o noclobber
    ;;

  SunOS | AIX )
    :
    ;;

  Linux )
    :
    ;;


# Darwin = MacOS
  Darwin )
    :
    ;;

  * )
    :
    ;;

esac

# -----------------------------------------------------------------------------
# specific settings for various shells
#

#### __SHELL - name of the current shell executing this script
####
__SHELL="$( ps -p $$ -o comm= )"

__SHELL=${__SHELL##*/}

: ${__SHELL:=ksh}

# -----------------------------------------------------------------------------
# specific settings for the various shells
#
case "${__SHELL}" in

  "bash" )
# set shell options for alias expanding if running in bash
    shopt -s expand_aliases
    ;;

esac


# -----------------------------------------------------------------------------
# define whence if necessary
#

# old definition for whence:
#
# whence whence 2>/dev/null 1>/dev/null || function whence { ksh whence -p $* ; }

# new definition for whence:
#
whence whence 2>/dev/null 1>/dev/null || function whence {
  if typeset -f $1 1>/dev/null ; then
    echo $1
  elif alias $1 2>/dev/null 1>/dev/null  ; then
    echo $1
  else
    which $1 2>/dev/null
  fi
}


#### --------------------------------------------------------------------------
#### internal variables


# -----------------------------------------------------------------------------
####
#### __LOG_DEBUG_MESSAGES - log debug messages if set to true
####   This can be activated with the parameter -D msg
####
  __LOG_DEBUG_MESSAGES=${__FALSE}

# -----------------------------------------------------------------------------
#### __ACTIVATE_TRACE - log trace messages (set -x) if set to true
####   This can be activated with the parameter -D trace
###
  __ACTIVATE_TRACE=${__FALSE}

# -----------------------------------------------------------------------------
####
#### __TRAP_SIGNAL - current trap caught by the trap handler
####   This is a global variable that can be used in the exit routines
####
__TRAP_SIGNAL=""

# -----------------------------------------------------------------------------
#### __USE_RBAC - set this variable to ${__TRUE} to execute this script
####   with RBAC
####   default is ${__FALSE}
####
####   Note: You can also set this environment variable before starting the script
####
: ${__USE_RBAC:=${__FALSE}}

# -----------------------------------------------------------------------------
#### __RBAC_BINARY - pfexec binary
####
####   default is /usr/bin/pfexec
####
####   Note: You can also set this environment variable before starting the script
####
: ${__RBAC_BINARY:=/usr/bin/pfexec}

# -----------------------------------------------------------------------------
#
# user executing this script (works only if using a ssh session with specific
# ssh versions that export these variables!)
#
SCRIPT_USER="$(  echo $SSH_ORIGINAL_USER  | tr "=" " " | cut -f 5 -d " " )"
SCRIPT_USER_MSG="${SCRIPT_USER}"

# -----------------------------------------------------------------------------
#### __TEE_OUTPUT_FILE - name of the output file if called with the parameter -T
####   default: /var/tmp/$( basename $0 ).$$.tee.log
####
####   Note: You can also set this environment variable before starting the script
####
: ${__TEE_OUTPUT_FILE:=/var/tmp/${0##*/}.$$.tee.log}

# -----------------------------------------------------------------------------
# process the parameter -q or --quiet
#
if [[ \ $*\  == *\ -q* || \ $*\  == *\ --quiet\ * ]] ; then
  __NO_HEADERS=${__TRUE}
  __QUIET_MODE=${__TRUE}
fi

# -----------------------------------------------------------------------------
# config file found or not
#
__CONFIG_FILE_FOUND=""

# -----------------------------------------------------------------------------
# use the parameter -T or --tee to automatically call the script and pipe
# all output to tee

if [ "${__PPID}"x = ""x ] ; then
  __PPID=$PPID ; export __PPID
  if [[ \ $*\  == *\ -T* || \ $*\  == *\ --tee\ * ]] ; then
    echo "Saving STDOUT and STDERR to \"${__TEE_OUTPUT_FILE}\" ..."
    exec $0 $@ 2>&1 | tee -a "${__TEE_OUTPUT_FILE}"
    __MAINRC=$?
    echo "STDOUT and STDERR saved in \"${__TEE_OUTPUT_FILE}\"."
    exit ${__MAINRC}
  fi
fi

: ${__PPID:=$PPID} ; export __PPID

# -----------------------------------------------------------------------------
#
# Set the variable ${__USE_RBAC} to ${__TRUE} to activate RBAC support
#
# Allow the use of RBAC to control who can access this script. Useful for
# administrators without root permissions
#
if [ "${__USE_RBAC}" = "${__TRUE}" ] ; then
  if [ "$_" != "${__RBAC_BINARY}" -a -x "${__RBAC_BINARY}" ]; then
    __USE_RBAC=${__FALSE} "${__RBAC_BINARY}" $0 $*
    exit $?
  else
    echo "${0%%*/} ERROR: \"${__RBAC_BINARY}\" not found or not executable!" >&2
    exit 238
  fi
fi

# -----------------------------------------------------------------------------
####
#### ##### defined variables that may be changed
####

#### __DEBUG_CODE - code executed at start of every sub routine
####   Note: Use always "__DEBUG_CODE="eval ..." if you want to use variables or aliases
####         Default debug code : none
####
####   sample debug code:
####   __DEBUG_CODE="  eval echo Entering the subroutine \${__FUNCTION} ...  "
####
####   Note: Use an include script for more complicated debug code, e.g.
####   __DEBUG_CODE=" eval . /var/tmp/mydebugcode"
####
__DEBUG_CODE=""

#### __FUNCTION_INIT - code executed at start of every sub routine
####   (see the hints for __DEBUG_CODE)
####   Default init code : install the trap handlers
####
#  __FUNCTION_INIT=" eval __settraps; echo  \"Now in function \${__FUNCTION}\" "
__FUNCTION_INIT=" eval __settraps "

#### __FUNCTION_EXIT - code executed at end of every sub routine
####   (see the hints for __DEBUG_CODE)
####   Default exit code : ""
####
__FUNCTION_EXIT="eval __FUNCTION=\"\" "

### variables for debugging
###
### __NO_CLEANUP - do not call the cleanup routine at all at script end if ${__TRUE}
###
: ${__NO_CLEANUP:=${__FALSE}}

#### __NO_EXIT_ROUTINES  - do not execute the exit routines if ${__TRUE}
####
: ${__NO_EXIT_ROUTINES:=${__FALSE}}

#### __NO_TEMPFILES_DELETE - do not remove temporary files at script end if ${__TRUE}
####
: ${__NO_TEMPFILES_DELETE:=${__FALSE}}

#### __NO_TEMPMOUNTS_UMOUNT - do not umount temporary mount points at script end if ${__TRUE}
####
: ${__NO_TEMPMOUNTS_UMOUNT:=${__FALSE}}

#### __NO_TEMPDIR_DELETE - do not remove temporary directories at script end if ${__TRUE}
####
: ${__NO_TEMPDIR_DELETE:=${__FALSE}}

#### __NO_FINISH_ROUTINES - do not execute the finish routeins at script end if ${__TRUE}
####
: ${__NO_FINISH_ROUTINES:=${__FALSE}}

#### __CLEANUP_ON_ERROR - call cleanup if the script was aborted by a syntax error
####
: ${__CLEANUP_ON_ERROR:=${__FALSE}}


# default log file for debug messages
#
# This filename is already defined here to catch all debug log messages
# The file will be deleted if the debug switch for writing this log
# is missing.
# To use this file enter the parameter "-D msg"
#
__DEBUG_LOGFILE="/tmp/${0##*/}.$$.debug"

# default log file for trace output
# To use this file enter the parameter "-D trace"
#
__TRACE_LOGFILE="/tmp/${0##*/}.$$.trace"

#### code for the ssh wrapper to enable the forward agent for scp
####
#### Note: For some old ssh version the parameter ForwardAgent must be
####       used without a "=" - in this case define the variable
####       ENABLE_FORWARD_AGENT_FOR_SCP_CODE in the config file for
####       the script
####
ENABLE_FORWARD_AGENT_FOR_SCP_CODE="#!/usr/bin/perl

exec '/usr/bin/ssh', map {\$_ eq '-oForwardAgent=no' ? (  ) : \$_} @ARGV;
"

#### __CONFIG_PARAMETER
####   The variable __CONFIG_PARAMETER contains the configuration variables
####
#### The defaults for these variables are defined here. You
#### can use a config file to overwrite the defaults.
####
#### Use the parameter -C to create a default configuration file
####
#### Note: The config file is read and interpreted via ". configfile"
####       therefore you can also add some code here
####
__CONFIG_PARAMETER="__CONFIG_FILE_VERSION=\"${__SCRIPT_VERSION}\"
"'

# directory for temporary files in parallel mode if -U is not used
#
  TMP_OUTPUT_DIR=""

# extension for backup files
#
  DEFAULT_BACKUP_EXTENSION=".$$.backup"

# MAX_NO_OF_LOGFILES - no. of backups for the log file
#
# Default: create up to 10 backups of the log file
#
  DEFAULT_MAX_NO_OF_LOGFILES=10

# field  separator for sed commands
#
  DEFAULT_SED_SEP=""

# allow the debug shell in AskUser
#
  __DEBUG_SHELL_IN_ASKUSER=${__TRUE}

#### __DUMP_ALREADY_CREATED - do not automatically create another dump if
####   this variable is ${__TRUE}
####
#    __DUMP_ALREADY_CREATED=${__TRUE}


#### __CREATE_DUMP - create an environment dump if the scripts exits with
####   error
####   (replace <dumpdir> with either 0 or the directory for
####   the dumps) to always create a dump at script end
####
#    __CREATE_DUMP=<dumpdir>

#### DEFAULT_DUMPDIR - default directory for environment dumps
####
  DEFAULT_DUMP_DIR="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"


# variables that can be changed via parameter
#

# interface of the hosts to use
# default for the parameter -D if=xxx
#
  DEFAULT_HOST_INTERFACE=""

# default RCM server
# default for the parameter -D rcm_server=server
#
  DEFAULT_RCM_SERVER=""

# remove all hosts from the known_hosts file before executing ssh or scp
# default for the parameter -D delete_known_hosts
#
  DEFAULT_DELETE_KNOWN_HOSTS=${__FALSE}

# known_hosts file used
#
  DEFAULT_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
  DEFAULT_KNOWN_HOSTS_FILE_BACKUP="/var/tmp/known_hosts.$$.org"

# remove the host from the known_hosts file before executing ssh or scp
# default for the parameter -D clean_known_hosts
#
  DEFAULT_CLEAN_KNOWN_HOSTS=${__FALSE}


# restore the known_hosts file at script end 
# default for the parameter -D restore_known_hosts
#  
  DEFAULT_RESTORE_KNOWN_HOSTS=${__FALSE}

# default name server to use ("" = use the configured nameserver)
# default for the parameter -D nameserver
#
  DEFAULT_CUR_NAMESERVER=""
  
# print the scp and ssh commands before executing them
# default for the parameter -D print_cmd
#
  DEFAULT_PRINT_CMD=${__FALSE}

# execute the commands in "single-step" mode
# default for the parameter -D singlestep
#
  DEFAULT_SINGLE_STEP=${__FALSE}

# variables for enable the forward agent for scp
# default for the parameter -D enable_ForwardAgent_for_scp
#
  DEFAULT_SCP_WITH_FORWARD_AGENT_ENABLED=${__FALSE}

# temp. ssh wrapper script to enable forward agent for scp
#
  DEFAULT_SSH_WRAPPER_FOR_SCP="/tmp/ssh_wrapper.$$.sh"

# default for the ssh template
# default for the parameter -t ssh:ssh_template
#
  DEFAULT_SSH_TEMPLATE=" %b %o %k %t%u@%i %c %s "

# default for the scp template
# default for the parameter -t scp:ssh_template
#
  DEFAULT_SCP_TEMPLATE=" %b %o %k %S %t%u@%i:%s "


# prefix for the dry run mode
# default for the parameter -D dryrun
#
  DEFAULT_ECHO="$( which echo )"
  DEFAULT_PREFIX=""

# default for the parameter -b
#
  DEFAULT_SSH_KEYFILE=""
  DEFAULT_SCP_KEYFILE=""

# default for the parameter -B
#
  DEFAULT_DO_NOT_COPY_FILE=${__FALSE}

# default for the parameter -K
#
  DEFAULT_NOSTRICTKEYS=${__FALSE}

# default for the parameter -i
#
  DEFAULT_HOSTFILE=""

# default for the parameter -I
#
  DEFAULT_FILE_BASEDIR=""

# default for the parameter -s
#
  DEFAULT_SCRIPTFILE=""

# default for the parameter -o
#
  DEFAULT_OUTPUTFILE="/var/tmp/${__SCRIPTNAME##*/}.$$.cmds.log"

# default for the parameter -u ssh
#
  DEFAULT_SSHUSER="support"

# default for the parameter -u for scp (def: use ssh user)
#
  DEFAULT_SCPUSER=""

# default for the parameter -c
#
  DEFAULT_SHELL_TO_USE="/usr/bin/ksh"

# default for the parameter -k
#
  DEFAULT_ADD_COMMENTS=${__TRUE}

# default for the parameter -U
#
  DEFAULT_UNIQUE_LOGFILES=${__FALSE}

# default for the parameter -P
#
  DEFAULT_SSH_OPTIONS=""

# default for the parameter -p
  DEFAULT_SCP_OPTIONS=""

# execute the command in parallel? -- default for the parameter -d
#
 DEFAULT_EXECUTE_PARALLEL=${__FALSE}

# wait time in seconds for the background processes
#   -- 1st default for the parameter -W
  DEFAULT_MAX_RUN_WAIT_TIME=1h

# wait intervall in seconds for the background processes
#   -- 2nd default for the parameter -W
#
  DEFAULT_RUN_WAIT_INTERVALL=2s

# maximum number of background processes
#   -- 1st default for the parameter -w
#
  DEFAULT_MAX_NO_OF_BACKGROUND_PROCESSES=-1

# wait intervall for starting the background processes
#   -- 2nd default for the parameter -w
#
  DEFAULT_START_PROC_WAIT_INTERVALL=5s

# timeout value for the start of the parallel background processes
#  -- 3rd default for the parameter -w
#
  DEFAULT_START_PROC_TIMEOUT=5m

# hosts on the host exclude list -- default for the parameter -x
#
  DEFAULT_EXCLUDE_HOSTS=""

# hosts on the host include list -- default for the parameter -A
#
  DEFAULT_INCLUDE_HOSTS=""

# output file for the list of hosts with errors -- default for the parameter -e
#
DEFAULT_FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS=""


# default for the RCM support
#
  DEFAULT_COPY_TABLE_BINARY=$( whence copy_table.pl )
  [ "${DEFAULT_COPY_TABLE_BINARY}"x = ""x ] && DEFAULT_COPY_TABLE_BINARY=$( whence copy_table.pl )
  [ "${DEFAULT_COPY_TABLE_BINARY}"x = "no"x ] && DEFAULT_COPY_TABLE_BINARY=""
  [ -x "${DEFAULT_COPY_TABLE_BINARY}" ] && DEFAULT_RCM_SUPPORT=${__TRUE} || DEFAULT_RCM_SUPPORT=${__FALSE}


# ignore users from the hostlists 
# default for the parameter -D ignore_user_in_file
#
  DEFAULT_IGNORE_USER_IN_FILE=${__FALSE}

# do not sort the host list 
# default for the parameter -D do_not_sort_hostlist
#
  DEFAULT_DO_NOT_SORT_HOSTLIST=${__FALSE}

# ssh binary to use 
# default for the parameter -D ssh_binary
#
  DEFAULT_NEW_SSH_BINARY=""

# scp binary to use 
# default for the parameter -D scp_binary
#
  DEFAULT_NEW_SCP_BINARY=""

# ssh-keygen binary to use 
# default for the parameter -D ssh-keygen_binary
#
  DEFAULT_SSH_KEYGEN_BINARY="$( whence ssh-keygen )"

# dos2unix binary to use 
# default for the parameter -D dos2unix_binary
#
  DEFAULT_NEW_DOS2UNIX_BINARY=""


# default field separator for input files
# default for the parameter -D fieldsep=x
  DEFAULT_FIELD_SEPARATOR=" "


# ---------------------------------------------------------------------

# variables that can NOT be changed with parameter

# binaries used
#
  DEFAULT_SSH_BINARY="ssh"
  DEFAULT_SCP_BINARY="scp"
  DEFUALT_SSH_KEYGEN_BINARY="ssh-keygen"

  DEFAULT_DOS2UNIX_BINARY="$( whence dos2unix )"

# defaults for the tickets for the DB access
#
  DEFAULT_TICKET_ID_STRING=""
  DEFAULT_NEW_TICKET_ID=""
  DEFAULT_USE_SSH_WRAPPER=${__TRUE}
  DEFAULT_PASSTHROUGH_TICKET="9999"

  DEFAULT_TICKET_STRING="ticket_id="


# default value for the ssh/scp timemout
#
  DEFAULT_GLOBAL_SSH_SCP_CMD_TIMEOUT=10

# default setting for logging the ssh output into the logfile
#
  DEFAULT_DO_NOT_LOG_SSH_COMMANDS_IN_LOGFILE=${__FALSE}

# only change the following variables if you know what you are doing #

# no further internal variables defined yet
#
# Note you can redefine any variable that is initialized before calling
# ReadConfigFile here!

'
# end of config parameters

#### __SHORT_DESC - short description (for help texts, etc)
####   Change to your need
####
typeset -r __SHORT_DESC="copy a script to a list of hosts via scp and execute it on the hosts using ssh"

#### __LONG_USAGE_HELP - Additional help if the script is called with
####   the parameter "-v -h"
####
####   Note: To use variables in the help text use the variable name without
####         an escape character, eg. ${OS_VERSION}
####
__LONG_USAGE_HELP='
      -i hostlist[:fieldseparator]
              \"hostlist\" is the file with the list of hosts to process.
              Format: one hostname per line (use user@host to use an explicit
              user for a host; this user is then used for scp and ssh to this host);
              empty lines and lines beginning with a hash \"#\" are ignored.
              The script only reads the first field of each line. The field
              separator is \"${FIELD_SEPARATOR}\". To change the field separator
              add \":fieldseparator\" to the filename.
              The comma \",\" can not be used as field separator; use
                -D fieldsep=\",\"
              to change the default field separator instead.
              Use a comma \",\" to separate multiple hostlists or use the
              parameter \"-i\" more than one time.
              All hostlists are merged and sorted. Each host in the list(s)
              is only processed one time.
              Missing hostlist files are treated as error. To ignore a
              missing hostlist file add a leading \"?\" to the filename.
              Current Value: \"${HOSTFILE}\"
              Long format: --hostlist

      -x hostname
      -x hostexcludelist[:fieldseparator]
              exclude the host \"hostname\" from the execution
              This parameter can be used multiple times; regular expressions
              for \"hostname\" are allowed.
              Use \"-x none\" to clear the list of hosts to exclude.
              Use a relative or absolute filename for \"hostname\" to read the
              hosts to exclude from a file. Format of the file:
              one hostname per line; empty lines and lines beginning with \"#\"
              are ignored.
              The script only reads the first field of each line. The field
              separator is \"${FIELD_SEPARATOR}\". To change the field separator
              add \":fieldseparator\" to the filename.
              The comma \",\" can not be used as field separator; use
                -D fieldsep=\",\"
              to change the default field separator instead.
              Missing hostexcludelist files are treated as error. To ignore a
              missing hostexcludelist file add a leading \"?\" to the filename.
              Current Value: \"${EXCLUDE_HOSTS}\"
              Long format: --excludehost

      -A hostname
              add the host \"hostname\" to the list of hosts
              This parameter can be used multiple times; regular expressions
              for \"hostname\" are not allowed.
              Use \"-A none\" to clear the list of hosts to include.
              Current Value: \"${INCLUDE_HOSTS}\"
              Long format: --includehost

      -s scriptfile
              scriptfile is the script or executable to execute on all hosts.
              It will be copied to each host using the user \"scpuser\" and
              executed on each host with the user \"sshuser\".
              If \"scriptfile\" is a binary it will be executed directly;
              if \"scriptfile\" is not a binary it will be executed
              either by the default shell for \"sshuser\" or by the
              shell specified with the parameter \"-c\".
              If this script is running in a cygwin session and the binary
              dos2unix is available via the path the script will be converted
              to Unix style using dos2unix before copying it to the hosts.
              If \"-B\" is used, the value for this parameter is a command to
              execute on the hosts without first copying it to the host. In
              this case the command is executed by the user \"sshuser\"
              without calling a shell.
              Use \\; in this case to separate multiple commands to execute.
              e.g: -s \"uname -a \\; uptime \"
              Current value: \"${SCRIPTFILE}\"
              Long format: --scriptfile

      -u sshuser
              \"sshuser\" is the userid to use for ssh and scp on the target
              hosts
              To use different user for ssh and scp use:
              -u ssh:sshuser
              -u scp:scpuser
              If \"-u scp:scpuser\" is not used the sshuser is also used for scp.
              Current value for sshuser is \"${SSHUSER}\"
              Current value for scpuser is \"${SCPUSER}\"
              Long format: --sshuser

      -c shell_to_use
              \"shell_to_use\" is the shell to execute the script on the hosts
              Use \"none\" to execute the script with the default shell
              of the \"sshuser\".
              If \"-B\" is used or if the command to execute (parameter \"-s\")
              is a binary this parameter is ignored and the command
              is always executed directly.
              Current value \"${SHELL_TO_USE}\"
              Long format: --shell

      -I basedir
              \"basedir\" is the directory with the hostlist and the
              script files; if this parameter is found the script searches
              the hostlist files and the script files in this directory also
              Current value: \"${FILE_BASEDIR}\"
              Long format: --basedir

      -o outputfile
              \"outputfile\" is the name of the file for the output generated
              by the commands. If \"-U\" is also used the output for each host
              is logged into a separate file named \"<outputfile>.<hostname>\"
              Current value \"${OUTPUTFILE}\"
              Long format: --outputfile

      -p scpoptions
              \"scpoptions\" are additional options for scp, e.g
                 -p \"-o StrictHostKeyChecking=no\"
              Current value \"${SCP_OPTIONS}\"
              Long format: --scpoptions

      -P sshoptions
              \"sshoptions\" are additional options for ssh
              Current value \"${SSH_OPTIONS}\"
              Long format: --sshoptions

      -t ssh:ssh_template
      -t scp:scp_template
              Define a new template for the scp or ssh command
              (see below for the known template placeholder)
              The scp/ssh templates are useful if a golden host is used
              to access the machines
              Current value:  ssh template: ${SSH_TEMPLATE}
                              scp template: ${SCP_TEMPLATE}
              Long format --template

      -K|+K use the option \"StrictHostKeyChecking=no\" for ssh and scp.
              In parallel mode also add the ssh and scp options
                \"-o NumberOfPasswordPrompts=0 -o ConnectTimeout=${SSH_SCP_CMD_TIMEOUT_IN_SEC} -o BatchMode=yes -o PasswordAuthentication=no\"
              The timeout value used can be changed with the variable SSH_SCP_CMD_TIMEOUT
              Current value: $( ConvertToYesNo ${NOSTRICTKEYS} )
              Long format: --nostrictkeys

      -k|+k add comments to the output file
              Current value: $( ConvertToYesNo "${ADD_COMMENTS}" )
              Long format: --nocomments

      -B|+B do not upload a script to the hosts
              In this case the value for the parameter \"-s\" is interpreted
              as command to execute and the value for the shell to
              use (parameter \"-c\") is ignored.
              Note: For commands with options like \"uname -a\" you should use a script
              Current value: $( ConvertToYesNo ${DO_NOT_COPY_FILE} )
              Long format: --do_not_copy

      -b ssh_keyfile
              Use the ssh key file \"ssh_keyfile\" for ssh and scp.
              Default:
              Use the default ssh key files for the user \"sshuser\" for ssh
              and the default key file for the user \"scpuser\" for scp
              To use different key files for ssh and scp use:
              -b ssh:ssh_keyfile
              -b scp:ssh_keyfile
              Current value for ssh_keyfile is: \"${SSH_KEYFILE}\"
              Current value for scp_keyfile is: \"${SCP_KEYFILE}\"
              Long format: --ssh_keyfile

      -U|+U create unique log files
              (see parameter \"-o\")
              Current value: $( ConvertToYesNo "${UNIQUE_LOGFILES}" )
              Long format: --uniquelogfiles

      -R|+R  use RCM methods
              The default value depends on the existence of copy_table.pl
              in the PATH.
              Use the environment variables RCM_USERID and RCM_PASSWORD
              to set the RCM userid and password. If these variables are
              not set the script will prompt the user for them.
              Current value: $( ConvertToYesNo "${RCM_SUPPORT}" )
              Long format: --rcm

      -d|+d execute the commands in parallel in the background
              Current value: $( ConvertToYesNo "${EXECUTE_PARALLEL}" )
              Long format: --parallel

      -W timeout[/intervall]
              Usage in parallel mode:
              
              \"timeout\" is the timeout for background processes and
              \"intervall\" is the wait intervall for background processes.
              Use \"-1\" or \"none\" for the timeout value to disable the
              timeout.
              Current values:
                Timeout: ${MAX_RUN_WAIT_TIME} (= $( CalculateSeconds ${MAX_RUN_WAIT_TIME} ) second(s) )
                Intervall: ${RUN_WAIT_INTERVALL} (= $( CalculateSeconds ${RUN_WAIT_INTERVALL} ) second(s) )
              Use a trailing \"m\" for times in minutes or a trailing \"h\"
              for times in hours; \"s\" is for seconds which is the default
              if neither \"m\" nor \"h\" is used.
              Use \"default\" for any value to use the default value.
              Use \" -W /intervall\" to only change the intervall.
              You can also use \",\" to separate the values.
              
              Usage in sequentiell mode:
              
              In sequentiell mode the parameter
              
              -W timeout/intervall
              
              can be used to define the timeout for the scp and ssh commands 
              and the intervall between the ssh/scp commands for the hosts.
              \"timeout\" is the timeout for the scp and ssh commands (This 
              will only work if the executable \"timeout\" is available via PATh variable).
              \"intervall\" is the time to wait between the ssh/scp commands
              for the hosts.
              Alternatively, the timeout for ssh/scp commands can be defined in the 
              environment variable SSH_SCP_CMD_TIMEOUT.
              (see above for the supported format for both values)
              Long format: --timeout

      -w noOfBackgroundprocesses[/startIntervall[/maxStartTime]]
              \"noOfBackgroundprocesses\" is the max. number of background
              processes running at the same time, \"startIntervall\" is the
              wait intervall and \"maxStartTime\" is the timeout for starting
              the background processes.
              Use \"-1\" or \"none\" for an unlimited number of parallel
              background processes.
              Use \"-1\" or \"none\" for the timeout value to disable
              the timeout.
              Current values:
                Max. number of parallel running background processes: ${MAX_NO_OF_BACKGROUND_PROCESSES}
                Wait intervall: ${START_PROC_WAIT_INTERVALL} (= $( CalculateSeconds ${START_PROC_WAIT_INTERVALL} ) second(s) )
                Timeout value: ${START_PROC_TIMEOUT} (= $( CalculateSeconds ${START_PROC_TIMEOUT} ) second(s) )
              Use a trailing \"m\" for times in minutes or a trailing \"h\"
              for times in hours; \"s\" is for seconds which is the default
              if neither \"m\" nor \"h\" is used.
              Use \"default\" for any value to use the default value.
              Use \" -w /startIntervall\" to only change the start intervall.
              Use \" -w //maxStartTime\" to only change the timeout
              You can also use \",\" to separate the values.
              This parameter is only used if the commands are executed
              in parallel (parameter \"-d\")
              Long format: --noOfbackgroundProcesses

      -e filename
              write the list of hosts with errors executing the scp/ssh commands to the file \"filename\"
              The format of the entries in this file is 
              
              hostname # error description


Placeholder in the ssh and scp templates are:

Placeholder  usage                              used for scp?    used for ssh?     parameter
-------------------------------------------------------------------------------------------------
%%           %                                  yes              yes               n/a
%b           scp binary                         yes              no                -D scp_binary
%b           ssh binary                         no               yes               -D ssh_binary

%S           source script or command           yes              yes               -s
%s           script/binary on the target host   yes              yes               n/a
%c           shell to use                       no               yes               -c

%u           scp user                           yes              no                -u scp:
%u           ssh user                           no               yes               -u ssh:
%t           ticket ID string                   yes              yes               -D ticket_id=x

%h           target host (FQN)                  yes              yes               n/a
%H           target host (short hostname)       yes              yes               n/a
%d           DNS domain                         yes              yes               n/a
%i           target host interface              yes              yes               n/a

%o           scp options                        yes              no                -p
%o           ssh options                        no               yes               -P

%k           ssh key for ssh                    no               yes               -b ssh:
%k           ssh key for scp                    yes              no                -b scp:

Do not use the characters ^A or ^X in any of the parameter!
'

#### __SHORT_USAGE_HELP - Additional help if the script is called with the parameter "-h"
####
####   Note: To use variables in the help text use the variable name without an escape
####         character, eg. ${OS_VERSION}
####
__SHORT_USAGE_HELP='                    [-i hostlist{,hostlist1{,...}] [-s scriptfile] [-o outputfile] [-u sshuser|scp:scpuser|ssh:sshuser] [-I basedir]
                    [-c shell] [-k] [-U] [-p scpoptions] [-P sshoptions] [-K] [-R] [-B|+B] [-b ssh_keyfile|scp:scp_keyfile|ssh:ssh_keyfile]
                    [-x excludehost] [-A includehost] [-t ssh:ssh_template] [-t scp:scp_template] 
                    [-d|+d] [-W [timeout[/intervall]] [-w NoOfBackgroundProcs[/intervall[/timeout]]] [-e filename]
                    [hostlist [scriptfile [outputfile [sshuser]]]]

  The parameters scriptfile, outputfile, and sshuser overwrite the options; hostlist (or includehost) and scriptfile are mandatory either
  as parameter or as option.

  For optimal usage ssh login via public key should be enabled on the target hosts and
  the ssh agent should run on this host (the agent is currently ${SSH_AGENT_STATUS}).

  Use \"-D help\" to view the known debug options.

  Use the parameter \"-v -h [-v]\" to view the detailed online help; use the parameter \"-X\" to view some usage examples.

  It is strongly recommended to test the script execution in dry run mode (parameter \"-D dryrun\") before doing the real work!

  see also http://bnsmb.de/solaris/execute_on_all_hosts.html
'

#### __MUST_BE_ROOT - run script only by root (def.: false)
####   set to ${__TRUE} for scripts that must be executed by root only
####
__MUST_BE_ROOT=${__FALSE}

#### __REQUIRED_USERID - required userid to run this script (def.: none)
####   use blanks to separate multiple userids
####   e.g. "oracle dba sysdba"
####   "" = no special userid required (see also the variable __MUST_BE_ROOT)
####
__REQUIRED_USERID=""

#### __REQUIRED_ZONES - required zones (either global, non-global or local
####    or the names of the valid zones)
####   This is a Solaris only feature!
####   (def.: none)
####   "" = no special zone required
####
__REQUIRED_ZONES=""

#### __ONLY_ONCE - run script only once at a time (def.: false)
####   set to ${__TRUE} for scripts that can not run more than one instance at
####   the same time
####
__ONLY_ONCE=${__FALSE}

#### __ REQUIRED_OS - required OS (uname -s) for the script (def.: none)
####    use blanks to separate the OS names if the script runs under multiple OS
####    e.g. "SunOS"
####
__REQUIRED_OS=""

#### __REQUIRED_OS_VERSION - required OS version for the script (def.: none)
####   minimum OS version necessary, e.g. 5.10
####   "" = no special version necessary
####
__REQUIRED_OS_VERSION=""

#### __REQUIRED_MACHINE_PLATFORM - required machine platform for the script (def.: none)
####   required machine platform (uname -i) , e.g "i86pc"; use blanks to separate
####   the multiple machine types, e.g "Sun Fire 3800 i86pc"
####   "" = no special machine type necessary
####
__REQUIRED_MACHINE_PLATFORM=""

#### __REQUIRED_MACHINE_CLASS - required machine class for the script (def.: none)
####   required machine class (uname -m) , e.g "i86pc" ; use blanks to separate
####   the multiple machine classes, e.g "sun4u i86pc"
####   "" = no special machine class necessary
####
__REQUIRED_MACHINE_CLASS=""

#### __REQUIRED_MACHINE_ARC - required machine architecture for the script (def.: none)
####   required machine architecture (uname -p) , e.g "i386" ; use blanks to separate
####   the machine architectures if more than one entry, e.g "sparc i386"
####   "" = no special machine architecture necessary
####
__REQUIRED_MACHINE_ARC=""

#### __VERBOSE_LEVEL - count of -v parameter (def.: 0)
####
####   Note: You can also set this environment variable before starting the script
####
typeset -i __VERBOSE_LEVEL=${__VERBOSE_LEVEL:=0}

#### __RT_VERBOSE_LEVEL - level of -v for runtime messages (def.: 1)
####
####   e.g. 1 = -v -v is necessary to print info messages of the runtime system
####        2 = -v -v -v is necessary to print info messages of the runtime system
####
####   Note: You can also set this environment variable before starting the script
####
typeset -i __RT_VERBOSE_LEVEL=${__RT_VERBOSE_LEVEL:=1}

#### __QUIET_MODE - do not print messages to STDOUT (def.: false)
####   use the parameter -q/+q to change this variable
####
####   Note: You can also set this environment variable before starting the script
####
: ${__QUIET_MODE:=${__FALSE}}

#### __VERBOSE_MODE - print verbose messages (def.: false)
####   use the parameter -v/+v to change this variable
####
####   Note: You can also set this environment variable before starting the script
####
: ${__VERBOSE_MODE:=${__FALSE}}

#### __NO_TIME_STAMPS - Do not use time stamps in the messages (def.: false)
####
####   Note: You can also set this environment variable before starting the script
####
: ${__NO_TIME_STAMPS:=${__FALSE}}

#### __NO_HEADERS - Do not print headers and footers (def.: false)
####
####   Note: You can also set this environment variable before starting the script
####
: ${__NO_HEADERS:=${__FALSE}}

#### __FORCE - do the action anyway (def.: false)
####   If this variable is set to ${__TRUE} the function "die" will return
####   if called with an RC not zero (instead of aborting the script)
####   use the parameter -f/+f to change this variable
####
__FORCE=${__FALSE}

#### __USE_COLORS - use colors (def.: false)
####   use the parameter -a/+a to change this variable
####
####   Note: You can also set this environment variable before starting the script
####
: ${__USE_COLORS:=${__FALSE}}

#### __USER_BREAK_ALLOWED - CTRL-C aborts the script or not (def.: true)
####   (no parameter to change this variable)
####
####   Note: You can also set this environment variable before starting the script
####
: ${__USER_BREAK_ALLOWED:=${__TRUE}}

#### __NOECHO - turn echo off while reading input from the user
####   do not echo the user input in AskUser if __NOECHO is set to ${__TRUE}
####
__NOECHO=${__FALSE}

#### __USE_TTY - write prompts and read user input from /dev/tty (def.: false)
####   If __USE_TTY is ${__TRUE} the function AskUser writes the prompt to /dev/tty
####   and the reads the user input from /dev/tty . This is useful if STDOUT is
####   redirected to a file.
####
__USE_TTY=${__FALSE}

#### __OVERWRITE mode - overwrite existing files or not (def.: false)
####   use the parameter -O/+O to change this variable
####
####   Note: You can also set this environment variable before starting the script
####
: ${__OVERWRITE_MODE:=${__FALSE}}

#### __TEMPDIR - directory for temporary files
####   The default is $TMPDIR (if defined), or $TMP (if defined),
####   or $TEMP (if defined) or /tmp if none of the variables is
####   defined
####
__TEMPDIR="${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"

#### __NO_OF_TEMPFILES
####   number of automatically created tempfiles that are deleted at program end
####   (def. 2)
####   Note: The variable names for the tempfiles are __TEMPFILE1, __TEMPFILE2, etc.
####
__NO_OF_TEMPFILES=2

#### __TEMPFILE_UMASK
####   umask for creating temporary files (def.: 177)
####
__TEMPFILE_UMASK=177

#### __LIST_OF_TMP_MOUNTS - list of mounts that should be umounted at program end
####
__LIST_OF_TMP_MOUNTS=""

#### __LIST_OF_TMP_DIRS - list of directories that should be removed at program end
####
__LIST_OF_TMP_DIRS=""

#### __LIST_OF_TMP_FILES - list of files that should be removed at program end
####
__LIST_OF_TMP_FILES=""

#### __SYSCMDS - list of commands execute via one of the execute... functions
###
__SYSCMDS=""

#### __SYSCMDS_FILE - write the list of executed commands via the execute function to
####   this file at program end
####
__SYSCMDS_FILE=""

#### __EXITROUTINES - list of routines that should be executed before the script ends
####   Note: These routines are called *before* temporary files, temporary
####         directories, and temporary mounts are removed
####
__EXITROUTINES=""

#### __FINISHROUTINES - list of routines that should be executed before the script ends
####   Note: These routines are called *after* temporary files, temporary
####         directories, and temporary mounts are removed
####
__FINISHROUTINES=""

#### __GENERAL_SIGNAL_FUNCTION  - name of the function to execute if a signal is received
####   default signal handling: none
####
####   This variable can be used to define a general user defined signal handler for
####   all signals catched. If this signal handler is defined it will be called first
####   for every signal. If the handler returns 0 the user defined signal handler for
####   the signal will be called (if defined). If the handler returns a value other
####   than 0 no other signal handler is called.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__GENERAL_SIGNAL_FUNCTION=""


#### __SIGNAL_SIGUSR1_FUNCTION  - name of the function to execute if the signal SIGUSR1 is received
####   default signal handling: create variable dump
####
####   If a user defined function ends with a return code not equal zero the default
####   action for the SIGUSR1 signal is not executed.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__SIGNAL_SIGUSR1_FUNCTION=""

#### __SIGNAL_SIGUSR2_FUNCTION  - name of the function to execute if the signal SIGUSR2 is received
####   default signal handling: call an interactive shell (experimental!)
####
####   If a user defined function ends with a return code not equal zero the default
####   action for the SIGUSR2 signal is not executed.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__SIGNAL_SIGUSR2_FUNCTION=""

#### __SIGNAL_SIGHUP_FUNCTION  - name of the function to execute if the signal SIGHUP is received
####   default signal handling: switch verbose mode on or off
####
####   If a user defined function ends with a return code not equal zero the default
####   action for the SIGHUP signal is not executed.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__SIGNAL_SIGHUP_FUNCTION=""

#### __SIGNAL_SIGINT_FUNCTION  - name of the function to execute if the signal SIGINT is received
####   default signal handling: end the script if ${__USER_BREAK_ALLOWED} is ${__TRUE} else ignore the signal
####
####   If a user defined function ends with a return code not equal zero the default
####   action for the SIGINT signal is not executed.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__SIGNAL_SIGINT_FUNCTION=""

#### __SIGNAL_SIGQUIT_FUNCTION  - name of the function to execute if the signal SIGQUIT is received
####   default signal handling: end the script
####
####   If a user defined function ends with a return code not equal zero the default
####   action for the SIGQUIT signal is not executed.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__SIGNAL_SIGQUIT_FUNCTION=""

#### __SIGNAL_SIGTERM_FUNCTION  - name of the function to execute if the signal SIGTERM is received
####   default signal handling: end the script
####
####   If a user defined function ends with a return code not equal zero the default
####   action for the SIGTERM signal is not executed.
####
####   see USER_SIGNAL_HANDLER for an example user signal handler
####
__SIGNAL_SIGTERM_FUNCTION=""

#### __REBOOT_REQUIRED - set to true to reboot automatically at
####   script end (def.: false)
####
####   Note:
####   To use this feature it must be enabled in the function RebootIfNecessary!
####
__REBOOT_REQUIRED=${__FALSE}

#### __REBOOT_PARAMETER - parameter for the reboot command (def.: none)
####
__REBOOT_PARAMETER=""


#### __DEBUG_PREFIX - prefix for debug messages
####   default: "DEBUG: "
####
: ${__DEBUG_PREFIX:=DEBUG: }


#### __INFO_PREFIX - prefix for INFO messages printed if __VERBOSE_MODE = ${__TRUE}
####   default: "INFO: "
####
: ${__INFO_PREFIX:=INFO: }

#### __WARNING_PREFIX - prefix for WARNING messages
####   default: "WARNING: "
####
: ${__WARNING_PREFIX:=WARNING: }

#### __ERROR_PREFIX - prefix for ERROR messages
####   default: "ERROR: "
####
: ${__ERROR_PREFIX:=ERROR: }

#### __RUNTIME_INFO_PREFIX - prefix for INFO messages of the runtime system
####   default: "RUNTIME INFO: "
####
: ${__RUNTIME_INFO_PREFIX:=RUNTIME INFO: }

#### __PRINT_LIST_OF_WARNINGS_MSGS - print the list of warning messages at program end (def.: false)
####
__PRINT_LIST_OF_WARNINGS_MSGS=${__FALSE}

#### __PRINT_LIST_OF_ERROR_MSGS - print the list of error messages at program end (def.: false)
####
__PRINT_LIST_OF_ERROR_MSGS=${__FALSE}

#### __PRINT_SUMMARIES - print error/warning msg summaries at script end
####
####   print error and/or warning message summaries at program end
####   known values:
####       0 = do not print summaries
####       1 = print error msgs
####       2 = print warning msgs
####       3 = print error and warning mgs
####   use the parameter -S to change this variable
####
__PRINT_SUMMARIES=0

#### __MAINRC - return code of the program
####
__MAINRC=0

# -----------------------------------------------------------------------------
#

# -----------------------------------------------------------------------------
# init the global variables
#

#### 
##### defined variables that should not be changed
####

# init the variable for the TRAP handlers
#   __INCLUDE_SCRIPT_RUNNING contains the name of the included script if
#   a sourced-in script is currently running
#
__INCLUDE_SCRIPT_RUNNING=""

#
# internal variables for push/pop
#
typeset -i __STACK_POINTER=0
__STACK[0]=${__STACK_POINTER}

# variable used for input by the user
#
__USER_RESPONSE_IS=""

# __STTY_SETTINGS
#   saved stty settings before switching off echo in AskUser
#
__STTY_SETTINGS=""

#### __SCRIPTNAME - name of the script without the path
####
typeset -r __SCRIPTNAME="${0##*/}"

#### __SCRIPTDIR - path of the script (as entered by the user!)
####
__SCRIPTDIR="${0%/*}"

#### __REAL_SCRIPTDIR - path of the script (real path, maybe a link)
####
__REAL_SCRIPTDIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )

#### __CONFIG_FILE - name of the default config file
####   (use ReadConfigFile to read the config file;
####   use WriteConfigFile to write it)
####   use none to disable the config file feature
####
__CONFIG_FILE="${__SCRIPTNAME%.*}.conf"

#### __PIDFILE - save the pid of the script in a file
####
#### example usage: __PIDFILE="/tmp/${__SCRIPTNAME%.*}.pid"
####
__PIDFILE=""

#### __HOSTNAME - hostname
####
__HOSTNAME="$( uname -n )"

#### __NODENAME - nodename
####
__NODENAME=${__HOSTNAME}
[ -f /etc/nodename ] && __NODENAME="$( cat /etc/nodename )"

#### __OS_FULLNAME - Operating system (e.g. CYGWIN_NT-5.1)
####
__OS_FULLNAME=""

#### __ZONENAME - name of the current zone if running in Solaris 10 or newer
####

#### __OS_VERSION - Operating system version (e.g 5.8)
####

#### __OS_RELEASE - Operating system release (e.g. Generic_112233-08)
####

#### __MACHINE_CLASS - Machine class (e.g sun4u)
####

#### __MACHINE_SUB_CLASS - Machine sub class
####   either GuestLDom or PrimaryLDom for sun4v LDoms
####
__MACHINE_SUB_CLASS=""

#### __MACHINE_PLATFORM - hardware platform (e.g. SUNW,Ultra-4)
####

#### __MACHINE_SUBTYPE - machine type (e.g  Sun Fire 3800)
####

#### __MACHINE_ARC - machine architecture (e.g. sparc)
####

#### __RUNLEVEL - current runlevel
####
# __RUNLEVEL="$( set -- $( who -r )  ; echo $7 )"

case ${__OS} in

    "SunOS" )
       [ -r /etc/release ] && __OS_FULLNAME="$( grep Solaris /etc/release | tr -s " " |  cut -f2- -d " " )"
       __ZONENAME="$( zonename 2>/dev/null )"
       __OS_VERSION="$( uname -r )"
       __OS_RELEASE="$( uname -v )"
       __MACHINE_CLASS="$( uname -m )"
       if [ "${__MACHINE_CLASS}"x = "sun4v"x -a "${__ZONENAME}"x = "global"x ] ; then
         [ ! -d  /dev/usb ] && __MACHINE_SUB_CLASS="GuestLDom" || __MACHINE_SUB_CLASS="PrimaryLDom"
       fi
       __MACHINE_PLATFORM="$( uname -i )"
       __MACHINE_SUBTYPE=""
#       if [ "${__ZONENAME}"x = ""x  -o  "${__ZONENAME}"x = "global"x ] ; then
#         [  -x /usr/platform/${__MACHINE_PLATFORM}/sbin/prtdiag ] &&   \
#           ( set -- $( /usr/platform/${__MACHINE_PLATFORM}/sbin/prtdiag | grep "System Configuration" ) ; shift 5; echo $* ) 2>/dev/null | read  __MACHINE_SUBTYPE
#        else
#         __MACHINE_SUBTYPE=""
#        fi
         __MACHINE_ARC="$( uname -p )"
       __RUNLEVEL=$( who -r  2>/dev/null | tr -s " " | cut -f8 -d " " )
       ;;

    "AIX" )
       __ZONENAME=""
       __MACHINE_PLATFORM="$( oslevel )"
       __OS_VERSION="$( oslevel -r )"
       __OS_RELEASE="$( uname -v )"
       __MACHINE_CLASS="$( uname -m )"
       __MACHINE_PLATFORM="$( uname -M )"
       __MACHINE_SUBTYPE=""
       __MACHINE_ARC="$( uname -p )"
       __RUNLEVEL=$( who -r  2>/dev/null | tr -s " " | cut -f8 -d " " )
       ;;

    "Linux" )
       __OS_FULLNAME="$( lsb_release -d -s 2>/dev/null )"
       [  "${__OS_FULLNAME}"x = ""x -a -r /etc/lsb-release ] && eval __OS_FULLNAME="$( grep DISTRIB_DESCRIPTION= /etc/lsb-release | cut -f2- -d "=" )"
       __ZONENAME=""
       __OS_VERSION="$( uname -r )"
       __OS_RELEASE="$( uname -v )"
       __MACHINE_CLASS="$( uname -m )"
       __MACHINE_PLATFORM="$( uname -i )"
       __MACHINE_SUBTYPE=""
       __MACHINE_ARC="$( uname -p )"
       __RUNLEVEL=$( who -r  2>/dev/null | tr -s " " | cut -f3 -d " " )
       ;;

     CYGWIN* )
       __OS_FULLNAME="$__OS"
       __OS="CYGWIN"
       __ZONENAME=""
       __OS_VERSION="$( uname -r )"
       __OS_RELEASE="$( uname -v )"
       __MACHINE_CLASS="$( uname -m )"
       __MACHINE_PLATFORM="$( uname -i )"
       __MACHINE_SUBTYPE=""
       __MACHINE_ARC="$( uname -p )"
       __RUNLEVEL=$( who -r  2>/dev/null )
       ;;

   "Darwin" )
       __ZONENAME=""
       __OS_VERSION="$( uname -r )"
       __OS_RELEASE="$( uname -v )"
       __MACHINE_CLASS="$( uname -m )"
       __MACHINE_PLATFORM=""
       __MACHINE_SUBTYPE=""
       __MACHINE_ARC="$( uname -p )"
       __RUNLEVEL=$( who -r  2>/dev/null | tr -s " " | cut -f4 -d " " )
       ;;

    * )
       __ZONENAME=""
       __OS_VERSION=""
       __OS_RELEASE=""
       __MACHINE_PLATFORM=""
       __MACHINE_CLASS=""
       __MACHINE_PLATFORM=""
       __MACHINE_SUBTYPE=""
       __MACHINE_ARC=""
       __RUNLEVEL="?"
       ;;

esac

#### __START_DIR - working directory when starting the script
####
__START_DIR="$( pwd )"

#### __LOGFILE - fully qualified name of the logfile used
####   use the parameter -l to change the logfile
####
if [ -d /var/tmp ] ; then
  __DEF_LOGFILE="/var/tmp/${__SCRIPTNAME%.*}.LOG"
else
  __DEF_LOGFILE="/tmp/${__SCRIPTNAME%.*}.LOG"
fi

__LOGFILE="${__DEF_LOGFILE}"

#### LOGMSG_FUNCTION - function to write log messages
####   default: use "echo " to write in log functions
####
: ${LOGMSG_FUNCTION:=echo}


# __GLOBAL_OUTPUT_REDIRECTION
#   status variable used by StartStop_LogAll_to_logfile
#
__GLOBAL_OUTPUT_REDIRECTION=""


# lock file (used if ${__ONLY_ONCE} is ${__TRUE})
# Note: This is only a symbolic link
#
__LOCKFILE="/tmp/${__SCRIPTNAME}.lock"
__LOCKFILE_CREATED=${__FALSE}

#### __NO_OF_WARNINGS - Number of warnings found
####
typeset -i __NO_OF_WARNINGS=0

#### __LIST_OF_WARNINGS - List of warning messages
####
__LIST_OF_WARNINGS=""

#### __NO_OF_ERRORS - Number of errors found
####
typeset -i __NO_OF_ERRORS=0

#### __LIST_OF_ERRORS - List of error messages
####
__LIST_OF_ERRORS=""

#### __LOGON_USERID - ID of the user opening the session
####
: ${__LOGIN_USERID:=${LOGNAME}}

#### __USERID - ID of the user executing this script (e.g. xtrnaw7)
####
: ${__USERID:=${LOGNAME}}


# -----------------------------------------------------------------------------
# color variables

#### Foreground Color variables:
#### __COLOR_FG_BLACK, __COLOR_FG_RED,     __COLOR_FG_GREEN, __COLOR_FG_YELLOW
#### __COLOR_FG_BLUE,  __COLOR_FG_MAGENTA, __COLOR_FG_CYAN,  __COLOR_FG_WHITE
####
#### Background Color variables:
#### __COLOR_BG_BLACK, __COLOR_BG_RED,     __COLOR_BG_GREEN, __COLOR_BG_YELLOW
#### __COLOR_BG_BLUE,  __COLOR_BG_MAGENTA, __COLOR_BG_CYAN,  __COLOR_BG_WHITE
####
if [ ${__USE_COLORS} = ${__TRUE} ] ; then
  __COLOR_FG_BLACK="\033[30m"
  __COLOR_FG_RED="\033[31m"
  __COLOR_FG_GREEN="\033[32m"
  __COLOR_FG_YELLOW="\033[33m"
  __COLOR_FG_BLUE="\033[34m"
  __COLOR_FG_MAGENTA="\033[35m"
  __COLOR_FG_CYAN="\033[36m"
  __COLOR_FG_WHITE="\033[37m"

  __COLOR_BG_BLACK="\033[40m"
  __COLOR_BG_RED="\033[41m"
  __COLOR_BG_GREEN="\033[42m"
  __COLOR_BG_YELLOW="\033[43m"
  __COLOR_BG_BLUE="\033[44m"
  __COLOR_BG_MAGENTA="\033[45m"
  __COLOR_BG_CYAN="\033[46m"
  __COLOR_BG_WHITE="\033[47m"

####
#### Colorattributes:
#### __COLOR_OFF, __COLOR_BOLD, __COLOR_NORMAL, - normal, __COLOR_UNDERLINE
#### __COLOR_BLINK, __COLOR_REVERSE, __COLOR_INVISIBLE
####

  __COLOR_BOLD="\033[1m"
  __COLOR_NORMAL="\033[2m"
  __COLOR_UNDERLINE="\033[4m"
  __COLOR_BLINK="\033[5m"
  __COLOR_REVERSE="\033[7m"
  __COLOR_INVISIBLE="\033[8m"
  __COLOR_OFF="\033[0;m"
fi

# position cursor:       ESC[row,colH or ESC[row;colf  (1,1 = upper left corner)
# Clear rest of line:    ESC[K
# Clear screen:          ESC[2J
# Save Cursor Pos        ESC[s
# Restore Cursor Pos     ESC[u
# Cursor Up # lines      ESC{colsA
# Cursor down # lines    ESC{colsB
# Cursor right # columns ESC{colsC
# Cursor left # columns  ESC{colsD
# Get Cursor Pos         ESC[6n
#

# -----------------------------------------------------------------------------

####
#### ##### defined sub routines
####

#### --------------------------------------
#### ReadConfigFile
####
#### read the config file
####
#### usage: ReadConfigFile [configfile]
####
#### where:   configfile - name of the config file
####          default: search ${__CONFIG_FILE} in the current directory,
####          in the home directory, and in /etc (in this order)
####
#### returns: ${__TRUE} - ok config read
####          ${__FALSE} - error config file not found or not readable
####
function ReadConfigFile {
  typeset __FUNCTION="ReadConfigFile"; ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THIS_CONFIG="$1"
  typeset THISRC=${__FALSE}

  if [ "${THIS_CONFIG}"x = "none"x ] ; then
    LogInfo "The use of a config file is disabled."
  else
    if [ "${THIS_CONFIG}"x = ""x ] ; then
      THIS_CONFIG="$PWD/${__CONFIG_FILE}"
      [ ! -f "${THIS_CONFIG}" ] && THIS_CONFIG="${HOME}/${__CONFIG_FILE}"
      [ ! -f "${THIS_CONFIG}" ] && THIS_CONFIG="/etc/${__CONFIG_FILE}"
    fi

    if [ -f "${THIS_CONFIG}" ] ; then
      LogHeader "Reading the config file \"${THIS_CONFIG}\" ..."

      includeScript "${THIS_CONFIG}"

      __CONFIG_FILE_FOUND="${THIS_CONFIG}"

     THISRC=${__TRUE}
    else
      LogHeader "No config file (\"${__CONFIG_FILE}\") found (use -C to create a default config file)"
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### WriteConfigFile
####
#### write the variable ${__CONFIG_PARAMETER} to the config file
####
#### usage: WriteConfigFile [configfile]
####
#### where:  configfile - name of the config file
####         default: write ${__CONFIG_FILE} in the current directory
####
#### returns: ${__TRUE} - ok config file written
####          ${__FALSE} - error writing the config file
####
function WriteConfigFile {
  typeset __FUNCTION="WriteConfigFile" ; ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THIS_CONFIG_FILE="$1"
  typeset THISRC=${__FALSE}

  if [ "${THIS_CONFIG}"x = "none"x ] ; then
    LogInfo "The use of a config file is disabled."
  else
    [ "${THIS_CONFIG_FILE}"x = ""x ] && THIS_CONFIG_FILE="./${__CONFIG_FILE}"

    [ -f "${THIS_CONFIG_FILE}" ] &&  BackupFileIfNecessary "${THIS_CONFIG_FILE}"
    LogMsg "Writing the config file \"${THIS_CONFIG_FILE}\" ..."

    cat <<EOT >"${THIS_CONFIG_FILE}"
# config file for ${__SCRIPTNAME} ${__SCRIPT_VERSION}, created $( date )

${__CONFIG_PARAMETER}
EOT
    THISRC=$?
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### NoOfStackElements
####
#### return the no. of stack elements
####
#### usage: NoOfStackElements; var=$?
####
#### returns: no. of elements on the stack
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####
function NoOfStackElements {
  typeset __FUNCTION="NoOfStackElements";  ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  [ ${__STACK_POINTER} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  ${__FUNCTION_EXIT}
  return ${__STACK_POINTER}
}

#### --------------------------------------
#### FlushStack
####
#### flush the stack
####
#### usage: FlushStack
####
#### returns: no. of elements on the stack before flushing it
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####
function FlushStack {
  typeset __FUNCTION="FlushStack";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=${__STACK_POINTER}
  __STACK_POINTER=0

  [ ${__STACK_POINTER} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### push
####
#### push one or more values on the stack
####
#### usage: push value1 [...] [value#]
####
#### returns: 0
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####
function push {
  typeset __FUNCTION="push";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

   while [ $# -ne 0 ] ; do
    (( __STACK_POINTER=__STACK_POINTER+1 ))
    __STACK[${__STACK_POINTER}]="$1"
    shift
  done

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### pop
####
#### pop one or more values from the stack
####
#### usage: pop variable1 [...] [variable#]
####
#### returns: 0
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####
function pop {
  typeset __FUNCTION="pop";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset NEWALUE=""

  while [ $# -ne 0 ] ; do
    if [ ${__STACK_POINTER} -eq 0 ] ; then
      NEWVALUE=""
    else
      NEWVALUE="${__STACK[${__STACK_POINTER}]}"
      (( __STACK_POINTER=__STACK_POINTER-1 ))
    fi
    eval $1="\"${NEWVALUE}\""
    shift
  done

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### push_and_set
####
#### push a variable to the stack and set the variable to a new value
####
#### usage: push_and_set variable new_value
####
#### returns: 0
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####
function push_and_set {
  typeset __FUNCTION="push_and_set";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  if [ $# -ne 0 ] ; then
    typeset VARNAME="$1"
    eval push \$${VARNAME}

    shift
    eval ${VARNAME}="\"$*\""
  fi

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### CheckYNParameter
####
#### check if a parameter is y, n, 0, or 1
####
#### usage: CheckYNParameter parameter
####
#### returns: ${__TRUE} - the parameter is equal to yes
####          ${__FALSE} - the parameter is equal to no
####
function CheckYNParameter {
  typeset __FUNCTION="CheckYNParameter";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=255

  case $1 in
   "y" | "Y" | "yes" | "YES" | "true"  | "TRUE"  | 0 ) THISRC=${__TRUE} ;;
   "n" | "N" | "no"  | "NO"  | "false" | "FALSE" | 1 ) THISRC=${__FALSE} ;;
   * ) THISRC=255 ;;
  esac

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### ConvertToYesNo
####
#### convert the value of a variable to y or n
####
#### usage: ConvertToYesNo parameter
####
#### returns: 0
####          prints y, n or ? to STDOUT
####
function ConvertToYesNo {
  typeset __FUNCTION="ConvertToYesNo";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  case $1 in
   "y" | "Y" | "yes" | "YES" | "Yes" | "true" | "True"  | "TRUE"  | 0 ) echo "y" ;;
   "n" | "N" | "no"  | "NO"  | "No" | "false" | "False" | "FALSE" | 1 ) echo "n" ;;
   * ) echo "?" ;;
  esac

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### InvertSwitch
####
#### invert a switch from true to false or vice versa
####
#### usage: InvertSwitch variable
####
#### returns 0
####         switch the variable "variable" from ${__TRUE} to
####         ${__FALSE} or vice versa
####
function InvertSwitch {
  typeset __FUNCTION="InvertSwitch";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  eval "[ \$$1 -eq ${__TRUE} ] && $1=${__FALSE} || $1=${__TRUE} "

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### CheckInputDevice
####
#### check if the input device is a terminal
####
#### usage: CheckInputDevice
####
#### returns: 0 - the input device is a terminal (interactive)
####          1 - the input device is NOT a terminal
####
function CheckInputDevice {
  typeset __FUNCTION="CheckInputDevice";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0
  
  tty -s
  THISRC=$?
  
  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### GetProgramDirectory
####
#### get the directory where a program resides
####
#### usage: GetProgramDirectory [programpath/]programname [resultvar]
####
#### returns: 0
####          the variable PRGDIR contains the directory with the program
####          if the parameter resultvar is missing
####
function GetProgramDirectory {
  typeset __FUNCTION="GetProgramDirectory";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset PRG=""
  typeset RESULTVAR=$2

  if [ ! -L $1 ] ; then
    PRG=$( cd -P -- "$(dirname -- "$(command -v -- "$1")")" && pwd -P )
  else
# resolve links - $1 may be a softlink
    PRG="$1"

    while [ -h "$PRG" ] ; do
      ls=$(ls -ld "$PRG")
      link=$( expr "$ls" : '.*-> \(.*\)$' )
      if expr "$link" : '.*/.*' > /dev/null; then
        PRG="$link"
      else
        PRG=$(dirname "$PRG")/"$link"
      fi
    done
    PRG="$(dirname ${PRG})"
  fi

  if [ "${RESULTVAR}"x != ""x ] ; then
     eval ${RESULTVAR}=\"${PRG}\"
  else
    PRGDIR="${PRG}"
  fi

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### substr
####
#### get a substring of a string
####
#### usage: variable=$( substr sourceStr pos length )
####     or substr sourceStr pos length resultVariable
####
#### returns: 1 - parameter missing
####          0 - parameter okay
####
function substr {
  typeset __FUNCTION="substr";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset resultstr=""
  typeset THISRC=1

  if [ "$1"x != ""x ] ; then
    typeset s="$1" p="$2" l="$3"
    : ${l:=${#s}}
    : ${p:=1}

    resultstr="$( echo $s | cut -c${p}-$((${p}+${l}-1)) )"
    THISRC=0
  else
    THISRC=1
    resultstr="$1"
  fi

  if [ "$4"x != ""x ] ; then
    eval $4=\"${resultstr}\"
  else
    echo "${resultstr}"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### replacestr
####
#### replace a substring with another substring
####
#### usage: variable=$( replacestr sourceStr oldsubStr newsubStr )
####     or replacestr sourceStr oldsubStr newsubStr resultVariable
####
#### returns: 0 - substring replaced
####          1 - substring not found
####          3 - error, parameter missing
####
####          writes the substr to STDOUT if resultvariable is missing
####
function replacestr {
  typeset __FUNCTION="replacestr";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=3

  typeset sourcestring="$1"
  typeset oldsubStr="$2"
  typeset newsubStr="$3"

  if [ "${sourcestring}"x != ""x -a "${oldsubStr}"x != ""x ] ; then
    if [[ "${sourcestring}" == *${oldsubStr}* ]] ; then
      sourcestring="${sourcestring%%${oldsubStr}*}${newsubStr}${sourcestring#*${oldsubStr}}"
      THISRC=0
    else
      THISRC=1
    fi
  fi

  if [ "$4"x != ""x ] ; then
    eval $4=\"${sourcestring}\"
  else
    echo "${sourcestring}"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### pos
####
#### get the first position of a substring in a string
####
#### usage: pos searchstring sourcestring
####
#### returns: 0 - searchstring is not part of sourcestring
####          else the position of searchstring in sourcestring
####
function pos {
  typeset __FUNCTION="pos";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset searchstring="$1"
  typeset sourcestring="$2"
  typeset THISRC=0

  if [[ "${sourcestring}" == *${searchstring}* ]] ; then
    typeset f="${sourcestring%%${searchstring}*}"
    THISRC=$((  ${#f}+1 ))
  fi

  [ ${THISRC} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### lastpos
####
#### get the last position of a substring in a string
####
#### usage: lastpos searchstring sourcestring
####
#### returns: 0 - searchstring is not part of sourcestring
####          else the position of searchstring in sourcestring
####
function lastpos {
  typeset __FUNCTION="lastpos";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset searchstring="$1"
  typeset sourcestring="$2"
  typeset THISRC=0

  if [[ "${sourcestring}" == *${searchstring}* ]] ; then
    typeset f="${sourcestring%${searchstring}*}"
    THISRC=$((  ${#f}+1 ))
  fi

  [ ${THISRC} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### isNumber
####
#### check if a value is an integer
####
#### usage: isNumber testValue
####
#### returns: ${__TRUE} - testValue is a number else not
####
function isNumber {
  typeset __FUNCTION="isNumber";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

# old code:
#  typeset TESTVAR="$(echo "$1" | ${SED} 's/[0-9]*//g' )"
#  [ "${TESTVAR}"x = ""x ] && return ${__TRUE} || return ${__FALSE}

  [[ $1 == +([0-9]) ]] && THISRC=${__TRUE}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### ConvertToHex
####
#### convert the value of a variable to a hex value
####
#### usage: ConvertToHex value
####
#### returns: 0
####          prints the value in hex to STDOUT
####
function ConvertToHex {
  typeset __FUNCTION="ConvertToHex";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset -i16 HEXVAR
  HEXVAR="$1"
  echo ${HEXVAR##*#}

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### ConvertToOctal
####
#### convert the value of a variable to a octal value
####
#### usage: ConvertToOctal value
####
#### returns: 0
####          prints the value in octal to STDOUT
####
function ConvertToOctal {
  typeset __FUNCTION="ConvertToOctal";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset -i8 OCTVAR
  OCTVAR="$1"
  echo ${OCTVAR##*#}

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### ConvertToBinary
####
#### convert the value of a variable to a binary value
####
#### usage: ConvertToBinary value
####
#### returns: 0
####          prints the value in binary to STDOUT
####
function ConvertToBinary {
  typeset __FUNCTION="ConvertToBinary";  ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset -i2 BINVAR
  BINVAR="$1"
  echo ${BINVAR##*#}

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### toUppercase
####
#### convert a string to uppercase
####
#### usage: toUppercase sourceString | read resultVariable
####    or   targetString=$( toUppercase sourceString )
####    or   toUppercase sourceString resultVariable
####
#### returns: 0
####          writes the converted string to STDOUT if resultString is missing
####
function toUppercase {
  typeset __FUNCTION="toUppercase";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset -u testvar="$1"

  if [ "$2"x != ""x ] ; then
    eval $2=\"${testvar}\"
  else
    echo "${testvar}"
  fi

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### toLowercase
####
#### convert a string to lowercase
####
#### usage: toLowercase sourceString | read resultVariable
####    or   targetString=$( toLowercase sourceString )
####    or   toLowercase sourceString resultVariable
####
#### returns: 0
####          writes the converted string to STDOUT if resultString is missing
####
function toLowercase {
  typeset __FUNCTION="toLowercase";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset -l testvar="$1"

  if [ "$2"x != ""x ] ; then
    eval $2=\"${testvar}\"
  else
    echo "${testvar}"
  fi

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### StartStop_LogAll_to_logfile
####
#### redirect STDOUT and STDERR into a file
####
#### usage: StartStop_LogAll_to_logfile [start|stop] logfile
####
#### returns: 0 - okay, redirection started / stopped
####          1 - error, can not write to the logfile
####          2 - invalid usage (to much or not enough parameter)
####          3 - invalid parameter
####          4 - tracing is enabled
####
#### To explicitly write to STDOUT after calling this function with the
#### parameter "start" use
####   echo "This goes to STDOUT" >&3
####
#### To explicitly write to STDERR after calling this function with the
#### parameter "start" use
####   echo "This goes to STDERR" >&4
####
function StartStop_LogAll_to_logfile {
  typeset __FUNCTION="StartStop_LogAll_to_logfile";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=0

  if [ ${__ACTIVATE_TRACE} = ${__TRUE} ] ; then
    LogError "StartStop_LogAll_to_logfile can NOT be used if tracing is enabled (\"-D trace\")".

    ${__FUNCTION_EXIT}
    return 4
  fi

  if [ $# -ne 0 ] ; then
    case $1 in

     'start' )
        if [ $# -gt 1 ] ; then
          touch "$2" 2>/dev/null
          if [ $? -eq 0 ] ; then
            LogInfo "Logging STDOUT and STDERR to \"$2\" ... "
            exec 3>&1
            exec 4>&2
            if [ "${__OVERWRITE_MODE}" = "${__TRUE}" ] ; then
              exec 1>$2 2>&1
            else
              exec 1>>$2 2>&1
            fi
            __GLOBAL_OUTPUT_REDIRECTION="$2"
          else
            THISRC=1
          fi
        else
          THISRC=2
        fi
        ;;

      'stop' )
        if [ "${__GLOBAL_OUTPUT_REDIRECTION}"x != ""x ] ; then
          exec 2>&4
          exec 1>&3
          LogInfo "Stopping logging of STDOUT and STDERR to \"${__GLOBAL_OUTPUT_REDIRECTION}\""
          __GLOBAL_OUTPUT_REDIRECTION=""
        fi
        ;;

      * )
        THISRC=3
        ;;
    esac
  else
    THISRC=2
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### executeCommand
####
#### execute a command
####
#### usage: executeCommand command parameter
####
#### returns: the RC of the executed command
####
function executeCommand {
  typeset __FUNCTION="executeCommand";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=0

  __SYSCMDS="${__SYSCMDS}
$@"

  set +e

  LogRuntimeInfo "Executing \"$@\" "

  eval "$@"
  THISRC=$?

  __SYSCMDS="${__SYSCMDS}
# RC=${THISRC}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### executeCommandAndLog
####
#### execute a command and write STDERR and STDOUT also to the logfile
####
#### usage: executeCommandAndLog command parameter
####
#### returns: the RC of the executed command (even if a logfile is used!)
####
function executeCommandAndLog {
  typeset __FUNCTION="executeCommandAndLog";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  set +e
  typeset THISRC=0

  __SYSCMDS="${__SYSCMDS}
$@"

  LogRuntimeInfo "Executing \"$@\" "

  if [ "${__LOGFILE}"x != ""x -a -f "${__LOGFILE}" ] ; then
    # LogMsg "# "$* 1>&2

    # The following trick is from
    # http://www.unix.com/unix-dummies-questions-answers/13018-exit-status-command-pipe-line.html#post47559
    exec 5>&1
    tee -a "${__LOGFILE}" >&5 |&
    exec >&p
    eval "$*" 2>&1
    THISRC=$?
    exec >&- >&5
    wait

# alternative:
#
#    THISRC=$( ( ( eval "$*" 2>&1; echo $? >&4 ) |tee "${__LOGFILE}" >&3 ) 4>&1 )

  else
    eval "$@"
    THISRC=$?
  fi

  __SYSCMDS="${__SYSCMDS}
# RC=${THISRC}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### executeCommandAndLogSTDERR
####
#### execute a command and write STDERR also to the logfile
####
#### usage: executeCommandAndLogSTDERR command parameter
####
#### returns: the RC of the executed command
####
function executeCommandAndLogSTDERR {
  typeset __FUNCTION="executeCommandAndLogSTDERR";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  set +e
  typeset THISRC=0

  __SYSCMDS="${__SYSCMDS}
$@"

  LogRuntimeInfo "Executing \"$@\" "

  if [ "${__LOGFILE}"x != ""x -a -f "${__LOGFILE}" ] ; then
    # The following trick is from
    # http://www.unix.com/unix-dummies-questions-answers/13018-exit-status-command-pipe-line.html#post47559
    exec 5>&2
    tee -a "${__LOGFILE}" >&5 |&
    exec 2>&p
    eval "$*"
    THISRC=$?
    exec  2>&5
    wait
  else
    eval "$@"
    THISRC=$?
  fi

  __SYSCMDS="${__SYSCMDS}
# RC=${THISRC}"

  ${__FUNCTION_EXIT}
  return ${THISRC}

}

#### --------------------------------------
#### UserIsRoot
####
#### validate the user id
####
#### usage: UserIsRoot
####
#### returns: ${__TRUE} - the user is root; else not
####
function UserIsRoot {
  typeset __FUNCTION="UserIsRoot";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typset THISRC=${__FALSE}

  [ "$( id | ${SED} 's/uid=\([0-9]*\)(.*/\1/' )" = 0 ] && THISRC=${__TRUE}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### UserIs
####
#### validate the user id
####
#### usage: UserIs USERID
####
#### where: USERID - userid (e.g oracle)
####
#### returns: 0 - the user is this user
####          1 - the user is NOT this user
####          2 - the user does not exist on this machine
####          3 - missing parameter
####
function UserIs {
  typeset __FUNCTION="UserIs";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=3
  typeset USERID=""

  if [ "$1"x != ""x ] ; then
    THISRC=2
    USERID=$( grep "^$1:" /etc/passwd | cut -d: -f3 )
    if [ "${USERID}"x != ""x ] ; then
      UID="$( id | ${SED} 's/uid=\([0-9]*\)(.*/\1/' )"
      [ ${UID} = ${USERID} ] && THISRC=0 || THISRC=1
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### GetCurrentUID
####
#### get the UID of the current user
####
#### usage: GetCurrentUID
####
#### where: -
####
#### returns: the function writes the UID to STDOUT
####
function GetCurrentUID {
  typeset __FUNCTION="GetCurrentUID";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  echo "$(id | ${SED} 's/uid=\([0-9]*\)(.*/\1/')"
}

#### --------------------------------------
#### GetUserName
####
#### get the name of a user
####
#### usage: GetUserName UID
####
#### where: UID - userid (e.g 1686)
####
#### returns: 0
####          __USERNAME contains the user name or "" if
####           the userid does not exist on this machine
####
function GetUserName {
  typeset __FUNCTION="GetUserName";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  [ "$1"x != ""x ] &&  __USERNAME=$( grep ":x:$1:" /etc/passwd | cut -d: -f1 )  || __USERNAME=""

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### GetUID
####
#### get the UID for a username
####
#### usage: GetUID username
####
#### where: username - user name (e.g nobody)
####
#### returns: 0
####          __USER_ID contains the UID or "" if
####          the username does not exist on this machine
####
function GetUID {
  typeset __FUNCTION="GetUID";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  [ "$1"x != ""x ] &&  __USER_ID=$( grep "^$1:" /etc/passwd | cut -d: -f3 ) || __USER_ID=""

  ${__FUNCTION_EXIT}
  return 0
}

# ======================================

#### --------------------------------------
#### PrintWithTimestamp
####
#### print the output of a command to STDOUT with a timestamp
####
#### usage: PrintWithTimestamp command_to_execute [parameter]
####
#### returns: 0
####
#### Note: This function does not write to the log file!
####
#### Source:  in v2.x and newer
####          http://unix.stackexchange.com/questions/26728/prepending-a-timestamp-to-each-line-of-output-from-a-command
####
function PrintWithTimestamp {
  typeset COMMAND="$*"
  LogInfo "Executing \"${COMMAND}\" ..."

  ${COMMAND} | while IFS= read -r line; do
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line";
  done
}

#### --------------------------------------
#### LogMsg
####
#### print a message to STDOUT and write it also to the logfile
####
#### usage: LogMsg message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
#### Notes: Use "- message" to suppress the date stamp
####        Use "-" to print a complete blank line
####
function LogMsg {
  typeset __FUNCTION="LogMsg";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  if [ "$1"x = "-"x ] ; then
    shift
    typeset THISMSG="$*"
  elif [ "${__NO_TIME_STAMPS}"x = "${__TRUE}"x ] ; then
    typeset THISMSG="$*"
  else
    typeset THISMSG="[$(date +"%d.%m.%Y %H:%M:%S")] $*"
  fi

  if [  ${__QUIET_MODE} -ne ${__TRUE} ] ; then
    ${LOGMSG_FUNCTION} "${THISMSG} "
    THISRC=${__TRUE}
  fi

  [ "${__LOGFILE}"x != ""x ] && [ -f "${__LOGFILE}" ] &&  echo "${THISMSG}" >>"${__LOGFILE}"

  [ "${__DEBUG_LOGFILE}"x != ""x ] && [ -f "${__DEBUG_LOGFILE}" ] && echo "${THISMSG}" 2>/dev/null >>"${__DEBUG_LOGFILE}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### LogOnly
####
#### write a message to the logfile
####
#### usage: LogOnly message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
function LogOnly {
  typeset __FUNCTION="LogOnly";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  typeset THISMSG="[$(date +"%d.%m.%Y %H:%M:%S")] $*"

  if [ "${__LOGFILE}"x != ""x ] ; then
    if [ -f "${__LOGFILE}" ] ; then
      echo "${THISMSG}" >>"${__LOGFILE}"
      THISRC=${__TRUE}
    fi
  fi

  [ "${__DEBUG_LOGFILE}"x != ""x ] && [ -f "${__DEBUG_LOGFILE}" ] && echo "${THISMSG}" 2>/dev/null  >>"${__DEBUG_LOGFILE}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### LogIfNotVerbose
####
#### write a message to stdout and the logfile if we are not in verbose mode
####
#### usage: LogIfNotVerbose message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
function LogIfNotVerbose {
  typeset __FUNCTION="LogIfNotVerbose";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  if [ "${__VERBOSE_LEVEL}"x = "0"x ] ; then
    LogMsg "$*"
    THISRC=$?
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### PrintDotToSTDOUT
####
#### write a message to stdout only if we are not in verbose mode
####
#### usage: PrintDotToSTDOUT [msg]
####
#### default for msg is "." without a LF; use "\n" to print a LF
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
function PrintDotToSTDOUT {
  typeset __FUNCTION="PrintDotToSTDOUT";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=$?
  typeset THISMSG=".\c"
  [ $# -ne 0 ] && THISMSG="$*"
  if [ "${__VERBOSE_LEVEL}"x = "0"x ] ; then
    printf "${THISMSG}"
    THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### LogInfo
####
#### print a message to STDOUT and write it also to the logfile
#### only if in verbose mode
####
#### usage: LogInfo [loglevel] message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
#### Notes: Output goes to STDERR, default loglevel is 0
####
function LogInfo {
  typeset __FUNCTION="LogInfo";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

#  [ ${__VERBOSE_MODE} -eq ${__TRUE} ] && LogMsg "INFO: $*"

  typeset THIS_TIMESTAMP="[$(date +"%d.%m.%Y %H:%M:%S")] "

  typeset THISLEVEL=0
  typeset THISRC=1


  if [ $# -gt 1 ] ; then
    isNumber $1
    if [ $? -eq ${__TRUE} ] ; then
      THISLEVEL=$1
      shift
    fi
  fi

  if [ "${__VERBOSE_MODE}" = "${__TRUE}" ] ; then
    if [ ${__VERBOSE_LEVEL} -gt ${THISLEVEL} ] ; then
      LogMsg "${__INFO_PREFIX}$*" >&2
      THISRC=$?
    fi
  fi

  [ ${THISRC} = 1 -a "${__DEBUG_LOGFILE}"x != ""x  ] && echo "${THIS_TIMESTAMP}${__INFO_PREFIX}$*" 2>/dev/null  >>"${__DEBUG_LOGFILE}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#
# internal sub routine for info messages from the runtime system
#
# returns: ${__TRUE} - message printed
#	   ${__FALSE} - message not printed
#
function LogRuntimeInfo {
  typeset __FUNCTION="LogRuntimeInfo";	  ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  typeset ORG_INFO_PREFIX="${__INFO_PREFIX}"

  __INFO_PREFIX="${__RUNTIME_INF_PREFIX}"

  LogInfo "${__RT_VERBOSE_LEVEL}" "$*"
  THISRC=$?

  __INFO_PREFIX="${ORG_INFO_PREFIX}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


# internal sub routine for header messages
#
# returns: ${__TRUE} - message printed
#          ${__FALSE} - message not printed
#
function LogHeader {
  typeset __FUNCTION="LogHeader";	  ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  if [ "${__NO_HEADERS}"x != "${__TRUE}"x ] ; then
    LogMsg "$*"
    THISRC=${__TRUE}
  else
    [ "${__DEBUG_LOGFILE}"x != ""x ] && [ -f "${__DEBUG_LOGFILE}" ] && echo "$*" 2>/dev/null  >>"${__DEBUG_LOGFILE}"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### LogWarning
####
#### print a warning to STDERR and write it also to the logfile
####
#### usage: LogWarning message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
#### Notes: Output goes to STDERR
####
function LogWarning {
  typeset __FUNCTION="LogWarning";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  LogMsg "${__WARNING_PREFIX}$*" >&2
  THISRC=$?
  (( __NO_OF_WARNINGS = __NO_OF_WARNINGS +1 ))
  __LIST_OF_WARNINGS="${__LIST_OF_WARNINGS}
${__WARNING_PREFIX}$*"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### LogError
####
#### print an error message to STDERR and write it also to the logfile
####
#### usage: LogError message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
#### Notes: Output goes to STDERR
####
function LogError {
  typeset __FUNCTION="LogError";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=$?

  if [ ${__ACTIVATE_TRACE} = ${__TRUE} ] ; then
    LogMsg "${__ERROR_PREFIX}$*" >&3
    THISRC=$?
  else
    LogMsg "${__ERROR_PREFIX}$*" >&2
    THISRC=$?
  fi

  (( __NO_OF_ERRORS=__NO_OF_ERRORS + 1 ))
  __LIST_OF_ERRORS="${__LIST_OF_ERRORS}
${__ERROR_PREFIX}$*"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### LogDebugMsg
####
#### print a debug message to STDERR and write it also to the logfile
####
#### usage: LogDebugMsg message
####
#### returns: ${__TRUE} - message printed
####          ${__FALSE} - message not printed
####
#### Notes: Output goes to STDERR
####
function LogDebugMsg {
  typeset __FUNCTION="LogDebugMsg";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  LogMsg "${__DEBUG_PREFIX}$*" >&2
  THISRC=$?

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### ---------------------------------------
#### BackupFileIfNecessary
####
#### create a backup of a file if ${__OVERWRITE_MODE} is set to ${__FALSE}
####
#### usage: BackupFileIfNecessary [file1} ... {filen}
####
####        file is the filename of the file to backup, format:
####
####           filename[,no_of_backups]
####
####        If no_of_backups is ommitted only one backup is created; the
####        name of the backup is
####
####             ${CURFILE}${BACKUP_EXTENSION}
####
####        The default value for ${BACKUP_EXTENSION} is ".[pid]"
####
####        If no_of_backups is specified for one file the functions keeps
####        up to no_of_backup backups of the file and the name(s) of
####        the backup files
####
####             ${CURFILE}.0
####             ${CURFILE}.1
####             ${CURFILE}.2
####              ...
####             ${CURFILE}.[no_of_backups - 1]
####
#### returns: 0 - done; else error
####
#### If successfull ${__BACKUP_FILE} contains the name of the backup file.
#### If no backup was created ${__BACKUP_FILE} is empty
####
function BackupFileIfNecessary {
  typeset __FUNCTION="BackupFileIfNecessary";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  : ${BACKUP_EXTENSION:=".$$"}

  typeset FILES_TO_BACKUP="$*"
  typeset CURFILE=""
  typeset CUR_BKP_FILE=""
  typeset NO_OF_BACKUPS=
  typeset -i i=
  typeset -i j=
  typeset THISRC=0

  __BACKUP_FILE=""

  if [ ${__OVERWRITE_MODE} -eq ${__FALSE} ] ; then
    for CURFILE in ${FILES_TO_BACKUP} ; do

      NO_OF_BACKUPS="${CURFILE#*,}"
      CURFILE="${CURFILE%,*}"

      [ ! -f "${CURFILE}" ] && continue

      if [ "${CURFILE}"x = "${NO_OF_BACKUPS}"x ] ; then
        CUR_BKP_FILE="${CURFILE}${BACKUP_EXTENSION}"
        LogMsg "Creating a backup of \"${CURFILE}\" in \"${CUR_BKP_FILE}\" ..."
        cp "${CURFILE}" "${CUR_BKP_FILE}"
        THISRC=$?
        if [ ${THISRC} -ne 0 ] ; then
          LogError "Error creating the backup of the file \"${CURFILE}\""
          break
        else
          __BACKUP_FILE="${CUR_BKP_FILE}"
        fi
      elif ! isNumber ${NO_OF_BACKUPS}  ; then
        LogError "Backup file ${CURFILE}: Specified backup count (${NO_OF_BACKUPS}) is not a number, creating only one backup"
        BackupFileIfNecessary "${CURFILE}"
      elif [ ${NO_OF_BACKUPS} = 0 ] ; then
        return
      else
        i="${NO_OF_BACKUPS}"
        CUR_BKP_FILE="${CURFILE}"

        LogRuntimeInfo "Creating up to ${NO_OF_BACKUPS} backups of the file \"${CURFILE}\" ..."

        (( i = i - 1 ))
        if [ -r "${CUR_BKP_FILE}.${i}" ] ; then
          LogRuntimeInfo "  Removing the old backup file \"${CUR_BKP_FILE}.${i}\" "
          rm "${CUR_BKP_FILE}.${i}"
        fi

        while [ $i -ge 1 ] ; do
          (( j = i - 1 ))
          if [ -r "${CUR_BKP_FILE}.${j}" ] ; then
            LogRuntimeInfo "  Renaming \"${CUR_BKP_FILE}.${j}\" to \"${CUR_BKP_FILE}.${i}\" ..."
            mv "${CUR_BKP_FILE}.${j}" "${CUR_BKP_FILE}.${i}"
          fi
          (( i = i - 1 ))

        done
        LogRuntimeInfo "  Renaming \"${CUR_BKP_FILE}\" to \"${CUR_BKP_FILE}.${i}\" ..."
        mv "${CURFILE}" "${CUR_BKP_FILE}.${i}"
      fi

    done
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### ---------------------------------------
#### CopyDirectory
####
#### copy a directory
####
#### usage: CopyDirectory sourcedir targetDir
####
#### returns:  0 - done;
####           else error
####
function CopyDirectory {
  typeset __FUNCTION="CopyDirectory";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=1
  if [ "$1"x != ""x -a "$2"x != ""x  ] ; then
     if [ -d "$1" -a -d "$2" ] ; then
        LogMsg "Copying all files from \"$1\" to \"$2\" ..."
        cd "$1" && find . -depth -print | cpio -pdumv "$2"
        THISRC=$?
        cd "${OLDPWD}"
     fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### DebugShell
####
#### Open a simple debug shell
####
#### Usage: DebugShell
####
#### returns: ${__TRUE}
####
#### Input is always read from /dev/tty; output always goes to /dev/tty
####
function DebugShell {
  typeset THISRC=${__TRUE}

  typeset USER_INPUT=""

  while true ; do
    printf "\n ------------------------------------------------------------------------------- \n"
    printf "${__SCRIPTNAME} - debug shell - enter a command to execute (\"exit\" to leave the shell)\n"
    printf ">> "
    read USER_INPUT

    case "${USER_INPUT}" in
      "exit" )
        break;
        ;;

      "functions" | "func" | "funcs" )
        typeset -f | grep "\{$"
        ;;

      "" )
        :
        ;;

      * )
        eval ${USER_INPUT}
        ;;
    esac

  done </dev/tty >/dev/tty

  "return" ${THISRC}
}

#### --------------------------------------
#### AskUser
####
#### Ask the user (or use defaults depending on the parameter -n and -y)
####
#### Usage: AskUser "message"
####
#### returns: ${__TRUE} - user input is yes
####          ${__FALSE} - user input is no
####          USER_INPUT contains the user input
####
#### Notes: "all" is interpreted as yes for this and all other questions
####        "none" is interpreted as no for this and all other questions
####
#### If __NOECHO is ${__TRUE} the user input is not written to STDOUT
#### __NOECHO is set to ${__FALSE} again in this function
####
#### If __USE_TTY is ${__TRUE} the prompt is written to /dev/tty and the
#### user input is read from /dev/tty . This is useful if STDOUT is redirected
#### to a file.
####
function AskUser {
  typeset __FUNCTION="AskUser";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=""

  if [ "${__USE_TTY}"x = "${__TRUE}"x ] ; then
    typeset mySTDIN="</dev/tty"
    typeset mySTDOUT=">/dev/tty"
  else
    typeset mySTDIN=""
    typeset mySTDOUT=""
  fi

  case ${__USER_RESPONSE_IS} in

   "y" ) USER_INPUT="y" ; THISRC=${__TRUE}
         ;;

   "n" ) USER_INPUT="n" ; THISRC=${__FALSE}
         ;;

     * ) while true ; do
           [ $# -ne 0 ] && eval printf "\"$* \"" ${mySTDOUT}
           if [ ${__NOECHO} = ${__TRUE} ] ; then
             __STTY_SETTINGS="$( stty -g )"
             stty -echo
           fi

           eval read USER_INPUT ${mySTDIN}
           if [ "${USER_INPUT}"x = "shell"x -a ${__DEBUG_SHELL_IN_ASKUSER} = ${__TRUE} ] ; then
             DebugShell
           else
             [ "${USER_INPUT}"x = "#last"x ] && USER_INPUT="${LAST_USER_INPUT}"
             break
           fi
         done

         if [ ${__NOECHO} = ${__TRUE} ] ; then
           stty ${__STTY_SETTINGS}
           __STTY_SETTINGS=""
         fi

         case ${USER_INPUT} in

           "y" | "Y" | "yes" | "Yes") THISRC=${__TRUE}  ;;

           "n" | "N" | "no" | "No" ) THISRC=${__FALSE} ;;

           "all" ) __USER_RESPONSE_IS="y"  ; THISRC=${__TRUE}  ;;

           "none" )  __USER_RESPONSE_IS="n" ;  THISRC=${__FALSE} ;;

           * )  THISRC=${__FALSE} ;;

        esac
        ;;
  esac

  [ "${USER_INPUT}"x != ""x ] && LAST_USER_INPUT="${USER_INPUT}"

  __NOECHO=${__FALSE}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### GetKeystroke
####
#### read one key from STDIN
####
#### Usage: GetKeystroke "message"
####
#### returns: 0
####          USER_INPUT contains the user input
####
function GetKeystroke {
  typeset __FUNCTION="GetKeystroke";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  trap "" 2 3
  [ $# -ne 0 ] && LogMsg "${THISMSG}"

  __STTY_SETTINGS="$( stty -g )"

  stty -echo raw
  USER_INPUT=$( dd count=1 2> /dev/null )

  stty ${__STTY_SETTINGS}
  __STTY_SETTINGS=""

  trap 2 3

  ${__FUNCTION_EXIT}
  return 0
}

#### --------------------------------------
#### RebootIfNecessary
####
#### Check if a reboot is necessary
####
#### Usage: RebootIfNecessary
####
#### Notes
####   The routine asks the user if neither the parameter -y nor the
####   parameter -n is used
####   Before using this routine uncomment the reboot command!
####
function RebootIfNecessary {
  typeset __FUNCTION="RebootIfNecessary";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  if [ ${__REBOOT_REQUIRED} -eq 0 ] ; then
    LogMsg "The changes made to the system require a reboot"

    AskUser "Do you want to reboot now (y/n, default is NO)?"
    if [ $? -eq ${__TRUE} ] ; then
      LogMsg "Rebooting now ..."
      echo "???" reboot ${__REBOOT_PARAMETER}
    fi
  fi

  ${__FUNCTION_EXIT}
  return 0
}

#### ---------------------------------------
#### die
####
#### print a message and end the program
####
#### usage: die returncode {message}
####
#### returns: $1 (if it returns)
####
#### Notes:
####
#### This routine
####     - calls cleanup
####     - prints an error message if any (if returncode is not zero)
####       or the message if any (if returncode is zero)
####     - prints all warning messages again if ${__PRINT_LIST_OF_WARNING_MSGS}
####       is ${__TRUE}
####     - prints all error messages again if ${__PRINT_LIST_OF_ERROR_MSGS}
####       is ${__TRUE}
####     - prints a program end message and the program return code
#### and
####     - and ends the program or reboots the machine if requested
####
#### If the variable ${__FORCE} is ${__TRUE} and the return code is NOT zero
#### die() will only print the error message and return
####
function die {
  typeset __FUNCTION="die";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  [ "${__TRAP_SIGNAL}"x != ""x ] &&  LogRuntimeInfo "__TRAP_SIGNAL is \"${__TRAP_SIGNAL}\""

  if [ "${__OS}"x = "SunOS"x ] ; then
    LogRuntimeInfo "function ${__FUNCTION}: Current OS is \"${__OS}\" -- will unset all traps now"
    __unsettraps
  fi
  
  typeset THISRC=$1
  [ $# -ne 0 ] && shift

  typeset TESTVAR
  
  if [ "$*"x != ""x ] ; then
    [ ${THISRC} = 0 ] && LogMsg "$*" || LogError "$*"
  fi

  [ ${__FORCE} = ${__TRUE} -a ${THISRC}x != 0x ] && return

  if [ "${__NO_CLEANUP}"x != ${__TRUE}x  ] ; then
    cleanup
  else
    LogInfo "__NO_CLEANUP set -- skipping the cleanup at script end at all"
  fi

  if [ "${__NO_OF_WARNINGS}" != "0" -a ${__PRINT_LIST_OF_WARNINGS_MSGS} -eq ${__TRUE} ] ; then
    LogMsg "*** CAUTION: One or more WARNINGS found ***"
    LogMsg "*** please check the logfile ***"

    LogMsg "Summary of warnings:
${__LIST_OF_WARNINGS}
"
  fi

  if [ "${__NO_OF_ERRORS}" != "0" -a ${__PRINT_LIST_OF_ERROR_MSGS} -eq ${__TRUE} ] ; then
    LogMsg "*** CAUTION: One or more ERRORS found ***"
    LogMsg "*** please check the logfile ***"

    LogMsg "Summary of error messages
${__LIST_OF_ERRORS}
"
  fi

  [[ -n "${__LOGFILE}" ]] && LogHeader "The log file used was \"${__LOGFILE}\" "
  [[ ${__LOG_DEBUG_MESSAGES} = ${__TRUE} ]] && LogHeader "The debug messages are logged to \"${__DEBUG_LOGFILE}\" "
  [[ ${__ACTIVATE_TRACE} = ${__TRUE} ]] && LogHeader "The trace messages are logged to \"${__TRACE_LOGFILE}\" "


#  __QUIET_MODE=${__FALSE}
  __END_TIME="$( date )"
  
  __ENDTIME_IN_SECONDS="$( perl -e 'print int(time)' )"

  if isNumber ${__STARTTIME_IN_SECONDS} -a isNumber ${__ENDTIME_IN_SECONDS}  ; then
    (( __RUNTIME_IN_SECONDS = __ENDTIME_IN_SECONDS - __STARTTIME_IN_SECONDS ))
    __RUNTIME_IN_HUMAN_READABLE_FORMAT="$( echo ${__RUNTIME_IN_SECONDS} | awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}'  )"
  else
    __RUNTIME_IN_SECONDS="?"
    __RUNTIME_IN_HUMAN_READABLE_FORMAT=""
  fi

  LogHeader "${__SCRIPTNAME} ${__SCRIPT_VERSION} started at ${__START_TIME} and ended at ${__END_TIME}."
  
  if [ "${__RUNTIME_IN_SECONDS}"x != "?"x ] ; then
    LogHeader "The script runtime is (day:hour:minute:seconds) ${__RUNTIME_IN_HUMAN_READABLE_FORMAT} (= ${__RUNTIME_IN_SECONDS} seconds) for ${COUNT} hosts"

    if [ ${EXECUTE_PARALLEL} != ${__TRUE} ] ; then
      if isNumber ${COUNT} ; then
        (( __RUNTIME_PER_HOST = __RUNTIME_IN_SECONDS / COUNT ))
        (( TESTVAR = __RUNTIME_PER_HOST * COUNT ))
        [ 0${TESTVAR} != 0${__RUNTIME_IN_SECONDS} ] && (( __RUNTIME_PER_HOST = __RUNTIME_PER_HOST + 1 ))
        LogHeader "  ( -> about ${__RUNTIME_PER_HOST} second(s) her host)"
      fi
    fi
  fi
  
  LogHeader "The RC is ${THISRC}."

  __EXIT_VIA_DIE=${__TRUE}

  if [ "${__GLOBAL_OUTPUT_REDIRECTION}"x != ""x ]  ; then
    StartStop_LogAll_to_logfile "stop"
  fi

  RemoveLockFile

  RebootIfNecessary


  exit ${THISRC}
}

#### ---------------------------------------
#### includeScript
####
#### include a script via . [scriptname]
####
#### usage: includeScript [scriptname]
####
#### returns: 0
####
#### notes:
####
function includeScript {
  typeset __FUNCTION="includeScript";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  if [ $# -ne 0 ] ; then

    LogRuntimeInfo "Including the script \"$*\" ..."

# set the variable for the TRAP handlers
    [ ! -f "$1" ] && die 247 "Include script \"$1\" not found"
    __INCLUDE_SCRIPT_RUNNING="$1"

# include the script
    . $*

# reset the variable for the TRAP handlers
    __INCLUDE_SCRIPT_RUNNING=""

  fi
}

#### ---------------------------------------
#### executeFunctionIfDefined
####
#### execute a function if it's defined
####
#### usage: executeFunctionIfDefined [function_name] {function_parameter}
####
#### returns: the RC of the function [function_name] or 255 if the function
####          is not defined
####
#### notes:
####
function executeFunctionIfDefined {
  typeset __FUNCTION="executeFunctionIfDefined";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=255

  if [ $# -ne 0 ] ; then
    typeset THIS_FUNCTION="$1"
    shift

    LogRuntimeInfo "Searching the function \"${THIS_FUNCTION}\" ..."

    IsFunctionDefined "${THIS_FUNCTION}"
    if [ $? -eq ${__TRUE} ] ; then
      LogRuntimeInfo "The function \"${THIS_FUNCTION}\" is defined; now calling wit \"${THIS_FUNCTION} $@\" ..."
      ${THIS_FUNCTION} "$@"
      THISRC=$?
    fi

  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### rand
####
#### print a random number to STDOUT
####
#### usage: rand
####
#### returns: ${__TRUE} - random number printed to STDOUT
####          ${__FALSE} - can not create a random number
####
####
#### notes:
####
#### This function prints the contents of the environment variable RANDOM
#### to STDOUT. If that variable is not defined, it uses nawk to create
#### a random number. If nawk is not available the function prints nothng to
#### STDOUT
####
function rand {
  typeset __FUNCTION="rand";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset __THISRC=${__FALSE}

  if [ "${RANDOM}"x != ""x ] ; then
    echo ${RANDOM}
    __THISRC=${__TRUE}
  elif whence nawk >/dev/null ; then
    nawk 'BEGIN { srand(); printf "%d\n", (rand() * 10^8); }'
    __THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${__THISRC}
}

# ======================================

####
#### ##### defined internal sub routines (do NOT use; these routines are called
####       by the runtime system!)
####

# --------------------------------------
#### PrintLockFileErrorMsg
#
# Print the lockfile already exist error message to STDERR
#
# usage: PrintLockFileErrorMsg
#
# returns: 250
#
function PrintLockFileErrorMsg {
  typeset __FUNCTION="PrintLockFileErrorMsg";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
	
  cat >&2  <<EOF

  ERROR:

  Either another instance of this script is already running
  or the last execution of this script crashes.
  In the first case wait until the other instance ends;
  in the second case delete the lock file

      ${__LOCKFILE}

  manually and restart the script.

EOF

  ${__FUNCTION_EXIT}
  return 250 "Script is already running"
}

# --------------------------------------
#### CreateLockFile
#
# Create the lock file (which is really a symbolic link if using the "old method") if possible
#
# usage: CreateLockFile
#
# returns: 0 - lock created
#          1 - lock already exist or error creating the lock
#
# Note: The old method uses a symbolic link because this is should always be a atomic operation
#
function CreateLockFile {
  typeset __FUNCTION="CreateLockFile";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

# for compatibilty reasons the old code can still be activated if necessary
  typeset __USE_OLD_CODE=${__FALSE}

  typeset LN_RC=""

  typeset THISRC

  LogRuntimeInfo "Trying to create the lock semaphore \"${__LOCKFILE}\" ..."
  if [ ${__USE_OLD_CODE} = ${__TRUE} ] ; then
# old code using ln
    ln -s  "$0" "${__LOCKFILE}" 2>/dev/null
    LN_RC=$?
  else
    __INSIDE_CREATE_LOCKFILE=${__TRUE}

# improved code from wpollock (see credits)
    if [ -L "${__LOCKFILE}" ] ; then
      LN_RC=1
    else
      set -C  # or: set -o noclobber
      : > "${__LOCKFILE}" 2>/dev/null
      LN_RC=$?
    fi
    __INSIDE_CREATE_LOCKFILE=${__FALSE}
  fi

  if [ ${LN_RC} = 0 ] ; then
    __LOCKFILE_CREATED=${__TRUE}

    THISRC=0
  else
    THISRC=1
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# --------------------------------------
#### RemoveLockFile
#
# Remove the lock file if possible
#
# usage: RemoveLockFile
#
# returns: 0 - lock file removed
#          1 - lock file does not exist
#          2 - error removing the lock file
#
function RemoveLockFile {
  typeset __FUNCTION="RemoveLockFile";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset THISRC=2

  if [ ! -L "${__LOCKFILE}" -a ! -f "${__LOCKFILE}" ] ; then
    THISRC=1
  else
    if [ ${__LOCKFILE_CREATED} -eq ${__TRUE} ] ; then
      LogRuntimeInfo "Removing the lock semaphore ..."

      rm "${__LOCKFILE}" 1>/dev/null 2>/dev/null
      [ $? -eq 0 ] && THISRC=0
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# ======================================

# --------------------------------------
#### CreateTemporaryFiles
#
# create the temporary files
#
# usage: CreateTemporaryFiles
#
# returns: 0
#
# notes:
#  The variables with the tempfiles are called
#  __TEMPFILE1, __TEMPFILE2, ..., __TEMPFILE#
#
function CreateTemporaryFiles {
  typeset __FUNCTION="CreateTemporaryFiles";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset CURFILE=

  typeset THISRC=0

  typeset i=1

# for compatibilty reasons the old code can still be activated if necessary
  typeset __USE_OLD_CODE=${__FALSE}

  __TEMPFILE_CREATED=${__TRUE}

# save the current umask and set the temporary umask
  __ORIGINAL_UMASK=$( umask )

  umask ${__TEMPFILE_UMASK}

  LogRuntimeInfo "Creating the temporary files  ..."

  while [ ${i} -le ${__NO_OF_TEMPFILES} ]  ; do
    if [  ${__USE_OLD_CODE} = ${__TRUE} ] ; then
      eval __TEMPFILE${i}="${__TEMPDIR}/${__SCRIPTNAME}.$$.TEMP${i}"
      eval CURFILE="\$__TEMPFILE${i}"
      LogRuntimeInfo "Creating the temporary file \"${CURFILE}\"; the variable is \"\${__TEMPFILE${i}}"

      echo >"${CURFILE}" ||
      if [ $? -ne 0 ] ; then
        THISRC=$?
        break
      fi
    else
# improved code from wpollock (see credits)
      set -C  # turn on noclobber shell option

      while : ; do
        eval __TEMPFILE${i}="${__TEMPDIR}/${__SCRIPTNAME}.$$.$( rand ).TEMP${i}"
        eval CURFILE="\$__TEMPFILE${i}"
        LogRuntimeInfo "Creating the temporary file \"${CURFILE}\"; the variable is \"\${__TEMPFILE${i}}"
        : > ${CURFILE}  && break
      done
    fi
    eval __LIST_OF_TMP_FILES=\"${__LIST_OF_TMP_FILES} \${__TEMPFILE${i}}\"

    (( i = i +1 ))
  done

# restore the umask
  umask ${__ORIGINAL_UMASK}
  __ORIGINAL_UMASK=""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# ======================================

# ======================================

####
#### ---------------------------------------
#### cleanup
####
#### house keeping at program end
####
#### usage: [called by the runtime system]
####
#### returns: 0
####
#### notes:
####  execution order is
####    - write executed commands to ${__SYSCMDS_FILE} if requested
####    - call exit routines from ${__EXITROUTINES}
####    - remove files from ${__LIST_OF_TMP_FILES}
####    - umount mount points ${__LIST_OF_TMP_MOUNTS}
####    - remove directories ${__LIST_OF_TMP_DIRS}
####    - call finish routines from ${__FINISHROUTINES}
####
function cleanup {
  typeset __FUNCTION="cleanup";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset EXIT_ROUTINE=
  typeset OLDPWD="$( pwd )"

  cd /tmp

# write __SYSCMDS
  if [ "${__SYSCMDS_FILE}"x != ""x -a "${__SYSCMDS}"x != ""x ] ; then
    LogRuntimeInfo "Writing the list of executed commands to the file \"${__SYSCMDS_FILE}\" ..."
    echo "${__SYSCMDS}" >>"${__SYSCMDS_FILE}"
  fi

# restore the umask if necessary
  if [ "${__ORIGINAL_UMASK}"x != ""x ] ; then
    umask ${__ORIGINAL_UMASK}
    __ORIGINAL_UMASK=""
  fi

# reset tty settings if necessary
  if [ "${__STTY_SETTINGS}"x != ""x ] ; then
    stty ${__STTY_SETTINGS}
    __STTY_SETTINGS=""
  fi

# call the defined exit routines
   if [ "${__NO_EXIT_ROUTINES}"x != "${__TRUE}"x  ] ; then

     LogRuntimeInfo "Executing the exit routines \"${__EXITROUTINES}\" ..."
     if [ "${__EXITROUTINES}"x !=  ""x ] ; then
      for EXIT_ROUTINE in ${__EXITROUTINES} ; do
        typeset +f | grep "^${EXIT_ROUTINE}" >/dev/null
        if [ $? -eq 0 ] ; then
        LogRuntimeInfo "Now calling the exit routine \"${EXIT_ROUTINE}\" ..."
        eval ${EXIT_ROUTINE}
      else
        LogError "Exit routine \"${EXIT_ROUTINE}\" is NOT defined!"
      fi
      done
    fi
  else
    LogInfo "__NO_EXIT_ROUTINES is set -- skipping executing the exit routines"
  fi

# remove temporary files
   if [ "${__NO_TEMPFILES_DELETE}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Removing temporary files ..."
    for CURENTRY in ${__LIST_OF_TMP_FILES} ; do
      LogRuntimeInfo "Removing the file \"${CURENTRY}\" ..."
      if [ -f "${CURENTRY}" ] ; then
        rm "${CURENTRY}"
        [ $? -ne 0 ] && LogWarning "Error removing the file \"${CURENTRY}\" "
      fi
    done
  else
    LogInfo "__NO_TEMPFILES_DELETE is set -- skipping removing temporary files"
  fi


# remove temporary mounts
   if [ "${__NO_TEMPMOUNTS_UMOUNT}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Removing temporary mounts ..."
    typeset CURENTRY
    for CURENTRY in ${__LIST_OF_TMP_MOUNTS} ; do
      mount | grep "^${CURENTRY} " 1>/dev/null 2>/dev/null
     if [ $? -eq 0 ] ; then
         LogRuntimeInfo "Umounting \"${CURENTRY}\" ..."
        umount "${CURENTRY}"
        [ $? -ne 0 ] && LogWarning "Error umounting \"${CURENTRY}\" "
      fi
    done
  else
    LogInfo "__NO_TEMPMOUNTS_UMOUNT is set -- skipping umounting temporary mounts"
  fi

# remove temporary directories
   if [ "${__NO_TEMPDIR_DELETE}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Removing temporary directories ..."
    for CURENTRY in ${__LIST_OF_TMP_DIRS} ; do
      LogRuntimeInfo "Removing the directory \"${CURENTRY}\" ..."
      if [ -d "${CURENTRY}" ] ; then
        rm -r "${CURENTRY}" 2>/dev/null
        [ $? -ne 0 ] && LogWarning "Error removing the directory \"${CURENTRY}\" "
      fi
    done
  else
    LogInfo "__NO_TEMPDIR_DELETE is set -- skipping removing temporary directories"
  fi

# call the defined finish routines
   if [ "${__NO_FINISH_ROUTINES}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Executing the finish routines \"${__FINISHROUTINES}\" ..."
    if [ "${__FINISHROUTINES}"x !=  ""x ] ; then
      for FINISH_ROUTINE in ${__FINISHROUTINES} ; do
        typeset +f | grep "^${FINISH_ROUTINE}" >/dev/null
        if [ $? -eq 0 ] ; then
          LogRuntimeInfo "Now calling the finish routine \"${FINISH_ROUTINE}\" ..."
          eval ${FINISH_ROUTINE}
        else
          LogError "Finish routine \"${FINISH_ROUTINE}\" is NOT defined!"
        fi
      done
    fi
  else
    LogInfo "__NO_FINISH_ROUTINES is set -- skipping executing the finish routines"
  fi

  [ -d "${OLDPWD}" ] && cd "${OLDPWD}"

  ${__FUNCTION_EXIT}
  return 0
}


#### --------------------------------------
#### CreateDump
####
#### save the current environment of the script
####
#### usage: CreateDump [targetdir] [filename_add]
####
#### returns:  ${__TRUE} - ok, dump created (or dump was already created)
####           ${__FALSE} - error creating the dump
####
####
function CreateDump {
  typeset __FUNCTION="CreateDump";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

#    typeset __FUNCTION="CreateDump";     ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}
  typeset __DUMPDIR=""${__DUMPDIR:=${DEFAULT_DUMP_DIR}}""
  typeset TMPFILE=""
  typeset THISPARAM1="$1"
  typeset THISPARAM2="$2"

  if [ "${THISPARAM1}"x != ""x ] ; then
    __DUMPDIR="${THISPARAM1}"

  else
    if [ "${__DUMP_ALREADY_CREATED}"x = "${__TRUE}"x ] ; then
      LogRuntimeInfo "Dump of the current script environment already created."

      ${__FUNCTION_EXIT}
      return ${__TRUE}
    fi
    __DUMP_ALREADY_CREATED=${__TRUE}
    [ -d "${__CREATE_DUMP}" ] && __DUMPDIR="${__CREATE_DUMP}" || LogWarning "Dumpdir \"${__CREATE_DUMP}\" is no existing directory, using ${__DUMPDIR}"
  fi

  if [ "${__DUMPDIR}"x != ""x ] ; then

    LogMsg "Saving the current script environment to \"${__DUMPDIR}\" ..."
    LogMsg "The PID used for the filenames is $$"

    TMPFILE="${__DUMPDIR}/${__SCRIPTNAME}.envvars.${THISPARAM2}$$"
    LogMsg "Saving the current environment variables in the file \"${TMPFILE}\" ..."
    echo "### ${TMPFILE} - environment variable dump created on $( date)" >"${TMPFILE}"
    set >>"${TMPFILE}"

    TMPFILE="${__DUMPDIR}/${__SCRIPTNAME}.exported_envvars.${THISPARAM2}$$"
    LogMsg "Saving the current exported environment variables in the file \"${TMPFILE}\" ..."
    echo "### ${TMPFILE} - exported environment variable dump created on $( date)" >"${TMPFILE}"
    env >>"${TMPFILE}"

    THISRC=${__TRUE}
  fi


  ${__FUNCTION_EXIT}
  return ${THISRC}
}

####
#### ##### defined trap handler (you may change them)
####

#### ---------------------------------------
#### IsFunctiondefined
####
#### check if a function is defined in this script
####
#### usage: IsFunctionDefined name_of_the_function
####
#### returns:  ${__TRUE} - the function is defined
####           ${__FALSE} - the function is not defined
####
####
function IsFunctionDefined {
  typeset __FUNCTION="IsFunctionDefined";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

  typeset THISRC=${__FALSE}

  [ $# -eq 1 ] && typeset -f $1 >/dev/null && THISRC=${__TRUE}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### ---------------------------------------
#### GENERAL_SIGNAL_HANDLER
####
#### general trap handler
####
#### usage: called automatically;
####        parameter: $1 = signal number
####                   $2 = LineNumber
####                   $3 = function name
####
#### returns: -
####
####
function GENERAL_SIGNAL_HANDLER {
  typeset __RC=$?

  __TRAP_SIGNAL=$1
   __LINENO=$2
  INTERRUPTED_FUNCTION=$3

  LogRuntimeInfo "GENERAL_SIGNAL_HANDLER: TRAP \"${__TRAP_SIGNAL}\" occured in the function \"${INTERRUPTED_FUNCTION}\", Line No \"${__LINENO}\" "
  LogRuntimeInfo "__EXIT_VIA_DIE=\"${__EXIT_VIA_DIE}\" "
  LogRuntimeInfo "Parameter for the trap routine are: \"$*\"; the RC is $?"

  typeset __FUNCTION="GENERAL_SIGNAL_HANDLER";    ${__DEBUG_CODE}

# get the name of a user defined trap routine
  typeset __USER_DEFINED_FUNCTION=""
  eval __USER_DEFINED_FUNCTION="\$__SIGNAL_${__TRAP_SIGNAL}_FUNCTION"

  if [ "${__EXIT_VIA_DIE}"x != "${__TRUE}"x -a ${__TRAP_SIGNAL} != "exit" ] ; then
    LogRuntimeInfo "Trap \"${__TRAP_SIGNAL}\" caught"

    [ "${__INCLUDE_SCRIPT_RUNNING}"x != ""x ] && LogMsg "Trap occurred inside of the include script \"${__INCLUDE_SCRIPT_RUNNING}\" "

    LogRuntimeInfo "Signal ${__TRAP_SIGNAL} received: Line: ${__LINENO} in function: ${INTERRUPTED_FUNCTION}"
  fi

  case ${__TRAP_SIGNAL} in
    0 ) __TRAP_SIGNAL="EXIT" ;;
    1 ) __TRAP_SIGNAL="SIGHUP" ;;
    2 ) __TRAP_SIGNAL="SIGINT" ;;
    3 ) __TRAP_SIGNAL="SIGQUIT" ;;
   15 ) __TRAP_SIGNAL="SIGTERM"
  esac

  if [ "${__GENERAL_SIGNAL_FUNCTION}"x != ""x ] ; then
    LogRuntimeInfo "General user defined signal handler is declared: \"${__GENERAL_SIGNAL_FUNCTION}\" "
    IsFunctionDefined "${__GENERAL_SIGNAL_FUNCTION}"
    if [ $? -ne ${__TRUE} ] ; then
      LogRuntimeInfo "The general user defined signal handler is declared but not defined"
    else
      LogRuntimeInfo "Calling the general user defined signal handler now ..."
      ${__GENERAL_SIGNAL_FUNCTION}
      if [ $? -ne 0 ] ; then
        LogRuntimeInfo "General user defined signal handler \"${__GENERAL_SIGNAL_FUNCTION}\" ended with RC=$? -> not executing the other signal handler"
        return
      else
        LogRuntimeInfo "General user defined signal handler \"${__GENERAL_SIGNAL_FUNCTION}\" ended with RC=$? -> executing the other signal handler now"
      fi
    fi
  else
    LogRuntimeInfo "No general user defined signal handler defined."
  fi

  typeset __DEFAULT_ACTION_OK=${__TRUE}
  if [ "${__USER_DEFINED_FUNCTION}"x = ""x  ] ; then
    LogRuntimeInfo "No user defined function for signal \"${__TRAP_SIGNAL}\" declared"
  else
    LogRuntimeInfo "The user defined function for signal \"${__TRAP_SIGNAL}\" is \"${__USER_DEFINED_FUNCTION}\""
    IsFunctionDefined "${__USER_DEFINED_FUNCTION}"
    if [ $? -ne ${__TRUE} ] ; then
      LogRuntimeInfo "Function \"${__USER_DEFINED_FUNCTION}\" is declared but not defined "
      __USER_DEFINED_FUNCTION=""
    else
      LogRuntimeInfo "Executing the user defined function for signal \"${__TRAP_SIGNAL}\"  \"${__USER_DEFINED_FUNCTION}\" ..."
      ${__USER_DEFINED_FUNCTION}
      __USER_DEFINED_FUNCTION_RC=$?
      LogRuntimeInfo "The return code of the user defined signal function is ${__USER_DEFINED_FUNCTION_RC}"

      if [ ${__USER_DEFINED_FUNCTION_RC} -ne 0 ]  ; then
        LogRuntimeInfo "  -->> Will not execute the default action for this signal"
      __DEFAULT_ACTION_OK=${__FALSE}
      fi
    fi
  fi

  if [ ${__DEFAULT_ACTION_OK} = ${__TRUE} ] ; then

    case ${__TRAP_SIGNAL} in

      1 | "SIGHUP" )
          LogWarning "SIGHUP signal received"

          InvertSwitch __VERBOSE_MODE
          LogMsg "Switching verbose mode to $( ConvertToYesNo ${__VERBOSE_MODE} )"
        ;;


      2 | "SIGINT" )

          if [ ${__USER_BREAK_ALLOWED} -eq ${__TRUE} ] ; then
            LogMsg "-"
            die 252 "Script aborted by the user via signal BREAK (CTRL-C)"
          else
            LogRuntimeInfo "Break signal (CTRL-C) received and ignored (Break is disabled)"
          fi
        ;;

      3 | "SIGQUIT" )

          die 251 "QUIT signal received"
        ;;

     15 | "SIGTERM" )
          die 253 "Script aborted by the external signal SIGTERM"
        ;;


     "SIGUSR1" )
           (( __SIGUSR1_DUMP_NO = ${__SIGUSR1_DUMP_NO:=-1} +1 ))
          CreateDump  "/var/tmp" "dump_no_${__SIGUSR1_DUMP_NO}_"
        ;;

     "SIGUSR2" )
          CheckInputDevice
          if [ $? -eq 0 ] ; then
            printf "*** Entering interactive mode ***\n"
          while [ 0 = 0 ] ; do
            printf "Enter command to execute (exit to leave interactive mode): "
            printf "\n"
            read __USERINPUT
            [ "${__USERINPUT}"x = "exit"x ] && break
            eval ${__USERINPUT}
          done
          printf "*** Leaving interactive mode ***\n"
        else
          LogWarning "SIGUSR2: Input device is not a terminal"
        fi
        ;;

     "ERR" )
          LogMsg "A command ended with an error; the RC is ${__RC}"
        ;;

   "exit" | "EXIT" | 0 )
          if [ "${__INSIDE_CREATE_LOCKFILE}"x = "${__TRUE}"x ]; then
            PrintLockFileErrorMsg
          elif [ "${__EXIT_VIA_DIE}"x != "${__TRUE}"x ] ; then
            LogError "EXIT signal received; the RC is ${__RC}"
            [ "${__INCLUDE_SCRIPT_RUNNING}"x != ""x ] && LogMsg "exit occurred inside of the include script \"${__INCLUDE_SCRIPT_RUNNING}\" "
            RemoveLockFile
            if [ "${__CLEANUP_ON_ERROR}"x  = "${__TRUE}"x ] ; then
              LogMsg "__CLEANUP_ON_ERROR set -- calling the function \"die\" anyway"
              die 236 "You should use the function \"die\" to end the program"
            else
              LogWarning "You should use the function \"die\" to end the program"
            fi
            [ "${__CREATE_DUMP}"x = ""x ] && __CREATE_DUMP="${__DUMPDIR:=${DEFAULT_DUMP_DIR}}"
            CreateDump
          else
            [ "${__CREATE_DUMP}"x != ""x ] && CreateDump
          fi
        ;;

      * )
          die 254 "Unknown signal caught: ${__TRAP_SIGNAL}"
        ;;

    esac
  fi

}

# ======================================


#### ---------------------------------------
#### InitScript
####
#### init the script runtime
####
#### usage: [called by the runtime system]
####
#### returns: 0
####
function InitScript {
  typeset __FUNCTION="InitScript";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

# use a temporary log file until we know the real log file
  __TEMPFILE_CREATED=${__FALSE}
  __MAIN_LOGFILE=${__LOGFILE}

  __LOGFILE="/tmp/${__SCRIPTNAME}.$$.TEMP"
  echo >${__LOGFILE}

  if [ "${__DEBUG_LOGFILE}"x != ""x ] ; then
    echo 2>/dev/null >"${__DEBUG_LOGFILE}"
  fi

  __START_TIME="$( date )"
  __STARTTIME_IN_SECONDS="$( perl -e 'print int(time)' )"
  
  LogHeader "${__SCRIPTNAME} ${__SCRIPT_VERSION} started at ${__START_TIME} (The PID of this process is $$)."

  LogInfo "Script template used is \"${__SCRIPT_TEMPLATE_VERSION}\" ."

  __WRITE_CONFIG_AND_EXIT=${__FALSE}

# init the variables
  eval "${__CONFIG_PARAMETER}"

  if [[ ! \ $*\  == *\ -C* ]]  ; then
# read the config file
    [ "${CONFIG_FILE}"x != ""x ] && LogInfo "User defined config file is \"${CONFIG_FILE}\" "
    ReadConfigFile ${CONFIG_FILE}
  fi

  ${__FUNCTION_EXIT}
  return 0
}

#### ---------------------------------------
#### SetEnvironment
####
#### set and check the environment
####
#### usage: [called by the runtime system]
####
#### returns: 0
####
function SetEnvironment {
  typeset __FUNCTION="SetEnvironment";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

# copy the temporary log file to the real log file

  if [ "${__NEW_LOGFILE}"x = "nul"x ] ; then
    LogHeader "Running without a log file"
    __MAIN_LOGFILE=""
# delete the temporary logfile
    rm "${__LOGFILE}" 2>/dev/null
    __LOGFILE=""
  else

    [ "${__NEW_LOGFILE}"x != ""x ] && __MAIN_LOGFILE="${__NEW_LOGFILE}"

    NO_OF_BACKUPS="${__MAIN_LOGFILE#*,}"
     __MAIN_LOGFILE="${__MAIN_LOGFILE%,*}"
    [ "${NO_OF_BACKUPS}"x = "${__MAIN_LOGFILE}"x ] && NO_OF_BACKUPS=${MAX_NO_OF_LOGFILES}

    LogRuntimeInfo "Initializing the log file\"${__MAIN_LOGFILE}\" "

    if [ "${NO_OF_BACKUPS}"x != ""x ] ; then
      isNumber ${NO_OF_BACKUPS}
      if [ $? -eq 0 ] ; then
        LogRuntimeInfo "Creating up to ${NO_OF_BACKUPS} backups of the logfile"
        BackupFileIfNecessary "${__MAIN_LOGFILE},${NO_OF_BACKUPS}"
        echo 2>/dev/null >"${__MAIN_LOGFILE}"
      else
        LogError "The value for the number of backups of the logfile \"${NO_OF_BACKUPS}\" is NOT a number. Now appending the log messages to the logfile \"${__MAIN_LOGFILE}\"."
      fi
    fi


    touch "${__MAIN_LOGFILE}" 2>/dev/null
    cat "${__LOGFILE}" >>"${__MAIN_LOGFILE}" 2>/dev/null
    if [ $? -ne 0 ]   ; then
      LogWarning "Error writing to the logfile \"${__MAIN_LOGFILE}\"."
      LogWarning "Using the log file \"${__LOGFILE}\" "
    else
      rm "${__LOGFILE}" 2>/dev/null
      __LOGFILE="${__MAIN_LOGFILE}"
    fi
    LogHeader "Using the log file \"${__LOGFILE}\" "
  fi

  if [ "${__REQUIRED_OS}"x != ""x ] ; then
    pos " ${__OS} " " ${__REQUIRED_OS} " && \
      die 238 "This script can not run on this operating system (${__OS}); known Operating systems are \"${__REQUIRED_OS}\""
  fi

  if [ "${__REQUIRED_OS_VERSION}"x != ""x ] ; then

    LogRuntimeInfo "Current OS version is \"${__OS_VERSION}\"; required OS version is \"${__REQUIRED_OS_VERSION}\""

    __OS_VERSION_OKAY=${__TRUE}

    __CUR_MAJOR_VER="${__OS_VERSION%.*}"
    __CUR_MINOR_VER="${__OS_VERSION#*.}"

    __REQ_MAJOR_VER="${__REQUIRED_OS_VERSION%.*}"
    __REQ_MINOR_VER="${__REQUIRED_OS_VERSION#*.}"

    [ "${__CUR_MAJOR_VER}" -lt "${__REQ_MAJOR_VER}" ] && __OS_VERSION_OKAY=${__FALSE}
    [ "${__CUR_MAJOR_VER}" -eq "${__REQ_MAJOR_VER}"  -a "${__CUR_MINOR_VER}" -lt "${__REQ_MINOR_VER}" ] && __OS_VERSION_OKAY=${__FALSE}

     [ ${__OS_VERSION_OKAY} = ${__FALSE} ] && die 248 "Unsupported OS Version: ${__OS_VERSION}; necessary OS version is ${__REQUIRED_OS_VERSION}"

  fi

  if [ "${__REQUIRED_MACHINE_PLATFORM}"x != ""x ] ; then
    pos " ${__MACHINE_PLATFORM} " " ${__REQUIRED_MACHINE_PLATFORM} " && \
      die 245 "This script can not run on this platform (${__MACHINE_PLATFORM}); necessary platforms are \"${__REQUIRED_MACHINE_PLATFORM}\""
  fi

  if [ "${__REQUIRED_MACHINE_CLASS}"x != ""x ] ; then
    pos " ${__MACHINE_CLASS} " " ${__REQUIRED_MACHINE_CLASS} " && \
      die 244 "This script can not run on this machine class (${__MACHINE_CLASS}); necessary machine classes are \"${__REQUIRED_MACHINE_CLASS}\""
  fi

  if [ "${__REQUIRED_MACHINE_ARC}"x != ""x ] ; then
    pos " ${__MACHINE_ARC} " " ${__REQUIRED_MACHINE_ARC} " && \
      die 243 "This script can not run on this machine architecture (${__MACHINE_ARC}); necessary machine architectures are \"${__REQUIRED_MACHINE_ARC}\""
  fi

  if  [ "${__ZONENAME}"x != ""x -a "${__OS}"x = "SunOS"x ] ; then
    case "${__REQUIRED_ZONES}" in

     "global" )
       [ "${__ZONENAME}"x != "global"x ] && \
         die 239 "This script must run in the global zone; the current zone is \"${__ZONENAME}\""
       ;;

     "non-global" | "local" )
       [ "${__ZONENAME}"x = "global"x ] && \
         die 239 "This script can not run in the global zone"
       ;;

     "" ) :
       ;;

     * )
       pos " ${__ZONENAME} " " ${__REQUIRED_ZONES} " && \
         die 239 "This script must run in one of the zones \"${__REQUIRED_ZONES}\"; the current zone is \"${__ZONENAME}\" "
       ;;

    esac

  fi

  if [ ${__MUST_BE_ROOT} -eq ${__TRUE} ] ; then
    UserIsRoot || die 249 "You must be root to execute this script"
  fi

  if [ "${__REQUIRED_USERID}"x != ""x ] ; then
    pos " ${__USERID} "  " ${__REQUIRED_USERID} " && \
      die 242 "This script can only be executed by one of the users: ${__REQUIRED_USERID}"
  fi

  if [ ${__ONLY_ONCE} -eq ${__TRUE} ] ; then
    CreateLockFile
    if [ $? -ne 0 ] ; then
      PrintLockFileErrorMsg
      die 250
    fi

# remove the lock file at program end
    __EXITROUTINES="${__EXITROUTINES}"
  fi

# __ABSOLUTE_SCRIPTDIR real absolute directory (no link)
#
  GetProgramDirectory "${__SCRIPTDIR}/${__SCRIPTNAME}" __ABSOLUTE_SCRIPTDIR

# create temporary files
  CreateTemporaryFiles

# check for the parameter -C
  if [   "${__WRITE_CONFIG_AND_EXIT}" = ${__TRUE} ] ; then
    NEW_CONFIG_FILE="${__CONFIG_FILE}"
    LogMsg "Creating the config file \"${NEW_CONFIG_FILE}\" ..."
    WriteConfigFile "${NEW_CONFIG_FILE}"
    [ $? -ne 0 ] && die 246 "Error writing the config file \"${NEW_CONFIG_FILE}\""
    die 0 "Configfile \"${NEW_CONFIG_FILE}\" successfully written."
  fi

}

####
#### ##### defined sub routines
####


#### ---------------------------------------
#### ShowShortUsage
####
#### print the (short) usage help
####
#### usage: ShowShortUsage
####
#### returns: 0
####
function ShowShortUsage {
  typeset __FUNCTION="ShowShortUsage";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  eval "__SHORT_USAGE_HELP=\"${__SHORT_USAGE_HELP}\""

cat <<EOT
  ${__SCRIPTNAME} ${__SCRIPT_VERSION} - ${__SHORT_DESC}

  Usage: ${__SCRIPTNAME} [-v|+v] [-q|+q] [-h] [-l logfile|+l] [-y|+y] [-n|+n]
                    [-D debugswitch] [-a|+a] [-O|+O] [-f|+f] [-C] [-H] [-X] [-S n] [-V] [-T]
${__SHORT_USAGE_HELP}

EOT

  ${__FUNCTION_EXIT}
  return 0
}

#### ---------------------------------------
#### ShowUsage
####
#### print the (long) usage help
####
#### usage: ShowUsage
####
#### returns: 0
####
function ShowUsage {
  typeset __FUNCTION="ShowUsage";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  eval "__LONG_USAGE_HELP=\"${__LONG_USAGE_HELP}\""

  ShowShortUsage
cat <<EOT

 Note: Use -{switch} or --{longswitch} to turn an option on;
       use +{switch} or ++{longswitch} to turn an option off

       The long format of the parameter (--parameter/++parameter) is not supported by all ksh implementations


    Parameter:

      -v|+v - turn verbose mode on/off; current value: $( ConvertToYesNo "${__VERBOSE_MODE}" )
              Long format: --verbose / ++verbose
      -q|+q - turn quiet mode on/off; current value: $( ConvertToYesNo "${__QUIET_MODE}" )
              Long format: --quiet / ++quiet
      -h    - show usage
              Long format: --help
      -l    - set the logfile
              current value: ${__NEW_LOGFILE:=${__DEF_LOGFILE}}
              use "-l [logfile,no_of_backups]" to define the number of retained backups
              of the logfile; the default no of backups is ${MAX_NO_OF_LOGFILES}
              Long format: --logfile
      +l    - do not write a logfile
              Long format: ++logfile
      -y|+y - assume yes to all questions or not
              Long format: --yes / ++yes
      -n|+n - assume no to all questions or not
              Long format: --no /++no
      -D|+D - debug switch
              current value: ${__DEBUG_SWITCHES}
              use "-D help" to list the known debug switches
              Long format: --debug / ++debug
      -a|+a - turn colors on/off; current value: $( ConvertToYesNo "${__USE_COLORS}" )
              Long format: --color / ++color
      -O|+O - overwrite existing files or not; current value: $( ConvertToYesNo "${__OVERWRITE_MODE}" )
              Long format: --overwrite / ++overwrite
      -f|+f - force; do it anyway; current value: $( ConvertToYesNo "${__FORCE}" )
              Long format: --force / ++force
      -C    - write a default config file in the current directory and exit
              Long format: --writeconfigfile
      -H    - write extended usage to STDERR and exit
              Long format: --doc
      -X    - write usage examples to STDERR and exit
              Long format: --view_examples
      -S n  - print error/warning summaries:
              n = 0 no summariess, 1 = print error msgs,
              2 = print warning msgs, 3 = print error and warning mgs
              Current value: ${__PRINT_SUMMARIES}
              Long format: --summaries
      -V    - write version number to STDOUT and exit
              Long format: --version
      -T    - append STDOUT and STDERR to the file "${__TEE_OUTPUT_FILE}"
              Long format: --tee
${__LONG_USAGE_HELP}
EOT

  if [ ${__VERBOSE_LEVEL} -gt 1 ] ; then
    typeset __ENVVARS=$( IFS="#" ; printf "%s " ${__USED_ENVIRONMENT_VARIABLES}  )
    cat <<EOT
Environment variables that are used if set (0 = TRUE, 1 = FALSE):

EOT

    for __CURVAR in ${__ENVVARS} ; do
      echo "  ${__CURVAR} (Current value: \"$( eval echo \$${__CURVAR} )\")"
    done
  fi

  [ ${__VERBOSE_LEVEL} -gt 2 ] && ${EGREP} "^##[CRT]#" "$0" | cut -c5- 1>&2


  ${__FUNCTION_EXIT}
  return 0
}

# -----------------------------------------------------------------------------


#### --------------------------------------
#### SetHousekeeping
####
#### do or do not house keeping (remove tmp files/directories; execute exit routines/finish routines) at script end
####
#### usage: SetHousekeeping [${__TRUE}|${__FALSE}]
####
#### parameter: ${__TRUE} | all - do house keeping
####            ${__FALSE} | none - no house keeping
####            nodelete - do all house keeping except removing temporary files and directories
####
#### returns:  0 - okay
####           1 - invalid usage
####
####
function SetHousekeeping {
  typeset __FUNCTION="SetHousekeeping";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

  case ${1} in

    ${__TRUE} | "all" )
      LogRuntimeInfo "Switching cleanup at script end on"
      __NO_CLEANUP=${__FALSE}
      __NO_EXIT_ROUTINES=${__FALSE}
      __NO_TEMPFILES_DELETE=${__FALSE}
      __NO_TEMPMOUNTS_UMOUNT=${__FALSE}
      __NO_TEMPDIR_DELETE=${__FALSE}
      __NO_FINISH_ROUTINES=${__FALSE}
     ;;

    ${__FALSE} | "none" )
      LogRuntimeInfo "Switching cleanup at script end off"
      __NO_CLEANUP=${__TRUE}
      __NO_EXIT_ROUTINES=${__TRUE}
      __NO_TEMPFILES_DELETE=${__TRUE}
      __NO_TEMPMOUNTS_UMOUNT=${__TRUE}
      __NO_TEMPDIR_DELETE=${__TRUE}
      __NO_FINISH_ROUTINES=${__TRUE}
      ;;

    "nodelete" )
      LogRuntimeInfo "Switching cleanup at script end to do-not-delete-files"
      __NO_CLEANUP=${__FALSE}
      __NO_EXIT_ROUTINES=${__FALSE}
      __NO_TEMPFILES_DELETE=${__TRUE}
      __NO_TEMPMOUNTS_UMOUNT=${__FALSE}
      __NO_TEMPDIR_DELETE=${__TRUE}
      __NO_FINISH_ROUTINES=${__FALSE}
      ;;

    * )
      LogError "Internal Error: SetHousekeeping called with an invalid parameter: \"${1}\" "
      THISRC=1
        ;;
  esac

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### PrintRuntimeVariables
####
#### print the values of the runtime variables
####
#### usage: PrintRuntimeVariables
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####           else - invalid usage
####
####
function PrintRuntimeVariables {
  typeset __FUNCTION="PrintRuntimeVariables";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset CURVAR CURVALUE

  typeset __RUNTIME_VARIABLES="
__KSH_VERSION
__SAVE_LANG
__SCRIPTNAME
__REAL_SCRIPTDIR
__CONFIG_FILE
__HOSTNAME
__NODENAME
__OS
__OS_VERSION
__ZONENAME
__OS_RELEASE
__MACHINE_CLASS
__MACHINE_SUB_CLASS
__START_DIR
__MACHINE_PLATFORM
__MACHINE_SUBTYPE
__MACHINE_ARC
__LOGFILE
__LOGIN_USERID
__USERID
__RUNLEVEL
"

# init the return code
  THISRC=255

  if [ $# -eq 0 ] ; then
    THISRC=${_TRUE}

    for CURVAR in ${__RUNTIME_VARIABLES} ; do
      eval CURVALUE="\$${CURVAR}"
      LogMsg "Variable \"${CURVAR}\" is \"${CURVALUE}\" "
    done
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


####
#### other subroutines that can be used in your code

#### --------------------------------------
#### GetOtherDate
####
#### get the date for today +/- n ( 1 <= n <= 6)
####
#### usage: GetOtherDate [+|-]no_of_days [format]
####
#### where
####   +/-no_of_days - relative date (e.g -1, -2, etc)
####   format - format for the date (def.: %Y-%m-%d)
####
#### returns:  writes the date to STDOUT
####
#### notes:
####  - = date in the future
####  + = date in the past
####  max. date difference : +/- 6 days
####
#### This function was only tested successfull in Solaris!
####
function GetOtherDate {
  typeset __FUNCTION="GetOtherDate";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

#    typeset __FUNCTION="GetOtherDate";     ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}
  typeset FORMAT_STRING="%Y-%m-%d"

  if [ $# -ge 1 ] ; then
    [ "$2"x != ""x ] && FORMAT_STRING=$2
    (( TIME_DIFF= $1 * 24 ))
    TZ=$TZ${TIME_DIFF} date "+${FORMAT_STRING}"
    THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### SaveEnvironmentVariables
####
#### save selected environment variables to a file
####
#### usage: SaveEnvironmentVariables filename [[pattern1]...[pattern#]]
####
#### where: filename - name of the file for the environment variables
####        pattern# - egrep pattern to select the environment variables to save
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
#### Notes:
####   To reuse the file later use the function includeScript
####
function SaveEnvironmentVariables {
  typeset __FUNCTION="SaveEnvironmentVariables";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

#    typeset __FUNCTION="SaveEnvironmentVariables";     ${__DEBUG_CODE}

# init the return code
  THISRC=${__FALSE}

  if [ $# -ne 0 ] ; then
    typeset THIS_FILE="$1"
    LogMsg "Writing the selected environment variables to \"${THIS_FILE}\" ..."
    shift

    BackupFileIfNecessary "${THIS_FILE}"
    touch "${THIS_FILE}" 2>/dev/null
    if [ $? -ne 0 ] ; then
      LogError "SaveEnvironmentVariables: Error $? writing to the file \"${THIS_FILE}\" "
    else
      typeset OUTPUT=""
      typeset NEW_OUTPUT=""
      if [ $# -eq 0 ] ; then
        OUTPUT="$( set )"
      else
        for i in $* ; do
          CUR_PATTERN="$i"
          LogRuntimeInfo "Processing the pattern \"$i\" ..."
          NEW_OUTPUT="$( set | ${EGREP} "$i" )"
          LogRuntimeInfo "  The result of this pattern is:
${NEW_OUTPUT}
"

          OUTPUT="${OUTPUT}
${NEW_OUTPUT}"
        done
      fi
      LogRuntimeInfo "Writing the file \"${THIS_FILE}\" ..."

      echo "${OUTPUT}" | sort | uniq | grep -v "^$" >"${THIS_FILE}"
      if [ $? -ne 0 ] ; then
        LogError "SaveEnvironmentVariables: Error $? writing to the file \"${THIS_FILE}\" "
      else
        THISRC=${__TRUE}
      fi
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### PrintLine
####
#### print a line with n times the character c
####
#### usage: PrintLine [n] {c}
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function PrintLine {
  typeset __FUNCTION="PrintLine";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  if [ $# -ge 1 ] ; then
    typeset n=$1
    typeset c=$2
    typeset c=${c:=-}
    eval printf \'%0.1s\' "$c"\{1..$n\}
    typeset THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# -----------------------------------------------------------------------------
# functions:
#

#### --------------------------------------
#### CalculateSeconds
####
#### convert a string like nnX where
####  X is s for seconds, m for minutes, and h for hours
####  to the approbiate number of seconds
####
#### usage: CalculateSeconds timeValue [resultVar]
####
#### returns:  ${__TRUE} - ok, if the parameter resultVar is found
####           resultVar contains the number of seconds else the
####           number of seconds is written to STDOUT.
####           ${__FALSE} - error, invalid format
####
####
function CalculateSeconds {
  typeset __FUNCTION="CalculateSeconds";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__TRUE}

  typeset TIME_VALUE="$1"
  typeset RESULT_VAR="$2"

  typeset TIME_CHAR="$( echo ${TIME_VALUE} | cut -c${#TIME_VALUE} )"

  typeset PARAMETER_VALUE="${TIME_VALUE%${TIME_CHAR}}"
  
  typeset TIME_IN_SECONDS=""
  typeset FORMULAR=""
  
  case ${TIME_CHAR} in
    
    "h" | "H" )
    
      FORMULAR="(( TIME_IN_SECONDS = PARAMETER_VALUE * 60 * 60 ))"
      ;;

    "m" | "M" )
      FORMULAR="(( TIME_IN_SECONDS = PARAMETER_VALUE * 60 ))"
      ;;

    "s" | "S")
      FORMULAR="(( TIME_IN_SECONDS = PARAMETER_VALUE ))"
      ;;

     * )
      PARAMETER_VALUE="${TIME_VALUE}"
      FORMULAR="(( TIME_IN_SECONDS = PARAMETER_VALUE ))"
      ;;
       
  esac

  if isNumber ${PARAMETER_VALUE} ; then
    eval ${FORMULAR}
  else
    THISRC=${__FALSE}
  fi 
  
  if [ ${THISRC} = ${__TRUE} ] ; then
    if [ "${RESULT_VAR}"x != ""x ] ; then
      eval ${RESULT_VAR}="${TIME_IN_SECONDS}"
    else
      echo "${TIME_IN_SECONDS}"
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### check_SSH_agent_status
####
#### check if the ssh agent is running
####
#### usage: check_SSH_agent_statuscheck_SSH_agent_status
####
#### returns:  ${__TRUE} - ssh agent is running, SSH_AGENT_RUNNING is ${__TRUE}
####           ${__FALSE} - ssh agent is not running, SSH_AGENT_RUNNING is ${__FALSE}
####
####
function check_SSH_agent_status {
  typeset __FUNCTION="check_SSH_agent_status";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

  SSH_AGENT_RUNNING=${__FALSE}
  if [ "${SSH_AUTH_SOCK}"x != ""x ] ; then
    [ -S "${SSH_AUTH_SOCK}" ] && SSH_AGENT_RUNNING=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${SSH_AGENT_RUNNING}
}

#### --------------------------------------
#### GetNumberOfRunningProcesses
####
#### get the number of still running processes
####
#### usage: GetNumberOfRunningProcesses {list_of_pids}
####
#### returns:  writes the number of still running processes to STDOUT
####
####
function GetNumberOfRunningProcesses {
  typeset __FUNCTION="GetNumberOfRunningProcesses";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  typeset BACKGROUND_PIDS=$*
  typeset NO_OF_RUNNING_PIDS=0

  if [ "${BACKGROUND_PIDS}"x != ""x ] ; then

    if [[ "${__OS}"x == CYGWIN*  ]] ; then
      typeset i
      NO_OF_RUNNING_PIDS=0
      for i in ${BACKGROUND_PIDS} ; do
        ps -p $i >/dev/null && (( NO_OF_RUNNING_PIDS = NO_OF_RUNNING_PIDS + 1 ))
      done
    else
      set -- $( ps -o pid= -p "${BACKGROUND_PIDS}" )
      NO_OF_RUNNING_PIDS=$#
    fi
    THISRC=${__TRUE}
  fi
  echo ${NO_OF_RUNNING_PIDS}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### get_curhost_interface
####
#### get the admin interface for a host
####
#### usage: get_curhost_interface hostid
####
#### returns:  CUR_HOST_INTERFACE contains the ip address of the admin interface
####           or the hostid if no admin interface was found
####
####
function get_curhost_interface {
  typeset __FUNCTION="get_curhost_interface";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

#    typeset __FUNCTION="get_curhost_interface";     ${__DEBUG_CODE}

# init the return code
  THISRC=${__FALSE}

  typeset TEMPVAR=""
  typeset CURHOSTID="$1"
  CUR_HOST_INTERFACE="${CURHOSTID}"

  if [ $# -eq 1 ] ; then
    if [ ${RCM_SUPPORT} = ${__FALSE} ] ; then
      if [ "${HOST_INTERFACE}"x != ""x ] ; then
        CUR_HOST_INTERFACE="${CURHOSTID%%.*}${HOST_INTERFACE}.${CURHOSTID#*.}"
        THISRC=${__TRUE}
      fi
    else
      LogInfo "Retrieving the admin interface for \"${CURHOSTID}\" from the RCM ..."
      TEMPVAR=$( ${COPY_TABLE_BINARY} ${COPY_TABLE_PARAMETER} -t RCM.HOST_IF_PURPOSE -q "HOSTID=\"${CURHOSTID}\" AND purpose=\"Admin access\" " | grep hostname | cut -f2 -d '"' )
      if [ "${TEMPVAR}"x != ""x ] ; then
        LogInfo "The admin interface for \"${CURHOSTID}\" is \"${TEMPVAR}\" "
        CUR_HOST_INTERFACE=${TEMPVAR}
        THISRC=${__TRUE}
      else
        LogWarning "No admin interface for \"${CURHOSTID}\" configured in the RCM"
        if [ "${HOST_INTERFACE}"x != ""x ] ; then
          CUR_HOST_INTERFACE="${CURHOSTID%%.*}${HOST_INTERFACE}.${CURHOSTID#*.}"
          THISRC=${__TRUE}
        fi
      fi
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### mycleanup
####
#### Housekeeping:
####   write the summaries
####   cleanup the temporary files
####   kill still running background processes if running in parallel mode
####
#### usage: mycleanup
####
#### returns:  nothing
####
function mycleanup {
  typeset __FUNCTION="mycleanup";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

#
# reset the terminal 
#
  CheckInputDevice && \
    executeCommand  "stty sane"

  if [ "${RESTORE_KNOWN_HOSTS}"x = "${__TRUE}"x -a "${KNOWN_HOST_FILE_EDITED}"x = "${__TRUE}"x ] ; then
    if [ -r "${KNOWN_HOSTS_FILE_BACKUP}" ] ; then
      LogMsg "Restoring the file \"${KNOWN_HOSTS_FILE}\" from \"${KNOWN_HOSTS_FILE_BACKUP}\" ..."
      cp "${KNOWN_HOSTS_FILE_BACKUP}"  "${KNOWN_HOSTS_FILE}" && rm "${KNOWN_HOSTS_FILE_BACKUP}" || \
        LogError "Error restoring the knonwn_hosts file"
    else
      LogError "Restoring the known_hosts file requested but the backup file \"${KNOWN_HOSTS_FILE_BACKUP}\" does not exist"
    fi
  fi

  if [ ${EXECUTE_PARALLEL} != ${__TRUE} ] ; then
#
# processes started sequential 
#  
    if [ "${HOST_PROCESSING_STARTED}"x = "${__TRUE}"x ] ; then
      LogMsg     ""
      LogMsg     "All done, ${COUNT} host(s) processed:"
      LogMsg "-" "    ${HOSTS_PROCESSED}"
      LogMsg     ""

      if [ "${HOSTS_EXCLUDED}"x != ""x ] ; then
        LogMsg "Not processed hosts on the host exclude list are:"
        for CUR_HOST in ${HOSTS_EXCLUDED} ; do
          LogMsg "-" "    ${CUR_HOST}"
        done
        LogMsg ""
      fi

      if [ "${INVALID_HOSTS_LIST}"x != ""x ] ; then
        LogMsg "The following hosts could NOT be processed due to an error:"
        for CURHOST in ${INVALID_HOSTS_LIST} ; do
          LogMsg "-" "    ${CURHOST}"
        done
      fi
      LogMsg ""

      if [ "${HOSTS_WITH_RC_NOT_ZERO}"x != ""x ] ; then
        LogMsg "The command execute ended with a non-zero return code on the following hosts:"
        for CURHOST in ${HOSTS_WITH_RC_NOT_ZERO} ; do
          LogMsg "-" "    ${CURHOST}"
        done
      fi
      LogMsg ""

      if [ "${HOSTS_IGNORED_ON_USER_REQUEST}"x != ""x ] ; then
        LogMsg "Hosts not processed on user request are:"
        for CUR_HOST in ${HOSTS_IGNORED_ON_USER_REQUEST} ; do
          LogMsg "    ${CUR_HOST}"
        done
        LogMsg ""
      fi

    fi
  else
#
# processes started parallel 
#  

    if [ "${PROCESSING_STARTED}"x = "${__TRUE}"x ] ; then

      typeset STILL_RUNNING_PIDS=""
      typeset KEEP_LOGFILES=${__FALSE}
      typeset CLEANUP_OUTPUT=""
      typeset CUR_PID=""
      typeset CUR_HOST=""

      typeset RUNNING_PROCS="$( echo "${STILL_RUNNING_PROCS}" | tr ";" "\n" | cut -f1 -d "/" )"
      
      LogMsg ""
      if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
        LogMsg "The output of the commands is logged in the file"
        LogMsg "    ${OUTPUTFILE}"
      else
        LogMsg "The output of the commands is logged in the files"
        LogMsg "    ${OUTPUTFILE}.<hostname>"
      fi
      LogMsg ""

      if [ "${INVALID_HOSTS_LIST}"x != ""x ] ; then
        LogMsg "The following hosts could NOT be processed due to an error:"
        for CURHOST in ${INVALID_HOSTS_LIST} ; do
          LogMsg "    ${CURHOST}"
        done
      fi
      LogMsg ""
#
# kill still running background processes
#
      for CUR_PID in ${BACKGROUND_PIDS} ; do
        CUR_OUTPUT="$( ps -fp ${CUR_PID} )"
        if [ $? -eq 0 ] ; then

          CUR_HOST="$( echo "${RUNNING_PROCS}" | grep "#${CUR_PID}#" | cut -f1 -d "#" )"
          LogMsg "-"
          LogMsg "The process ${CUR_PID} for the host \"${CUR_HOST}\" is still running: "

          HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}
${CUR_HOST} # the script on the host is running in the timeout" 

          LogMsg "Process ${CUR_PID} is still running: "
          LogMsg "${CUR_OUTPUT}"
          LogMsg "Killing the process ${CUR_PID} now  ..."
          kill ${CUR_PID}

       fi
      done

      for CUR_PID in ${BACKGROUND_PIDS} ; do
        CUR_OUTPUT="$( ps -fp ${CUR_PID} )"
        if [ $? -eq 0 ]  ; then

          LogMsg "The process ${CUR_PID} for the host \"${CUR_HOST}\" is still running: "
        
          LogMsg "${CUR_OUTPUT}"
          LogMsg "Killing the process ${CUR_PID} now with -9  ..."
          kill -9 ${CUR_PID}
        fi
      done

      for CUR_PID in ${BACKGROUND_PIDS} ; do
        ps -p ${CUR_PID} >/dev/null && STILL_RUNNING_PIDS="${STILL_RUNNING_PIDS} ${CUR_PID}"
      done

      if [ "${STILL_RUNNING_PIDS}"x != ""x ] ; then
        LogMsg "-"
        LogError "There are still running background processes (kill -9 did not work): ${STILL_RUNNING_PIDS}"
        ps -p ${STILL_RUNNING_PIDS}

        KEEP_LOGFILES=${__TRUE}
      fi

      if [ "${TMP_OUTPUT_DIR}"x != ""x ] ; then
        if [ -d "${TMP_OUTPUT_DIR}" ] ; then
          if [ "${__TRAP_SIGNAL}"x != ""x -o "${KEEP_LOGFILES}" = "${__TRUE}" ] ; then
            LogWarning "Script ended with an error -- will not remove the temporary directory \"${TMP_OUTPUT_DIR}\"!"
          else
            __LIST_OF_TMP_DIRS="${__LIST_OF_TMP_DIRS} ${TMP_OUTPUT_DIR}"
          fi
        fi
      fi
    fi
  fi

  HOSTS_WITH_ERRORS="$( echo "${HOSTS_WITH_ERRORS}" | ${EGREP} -v "^$" )"
  
  NO_OF_HOSTS_WITH_ERRORS=$( printf "${HOSTS_WITH_ERRORS}" | wc -l | tr -d " "   )

  if [ ${NO_OF_HOSTS_WITH_ERRORS} != 0 ] ; then
    LogMsg "-"
    LogWarning "Errors executing the script/command found on ${NO_OF_HOSTS_WITH_ERRORS} host(s)"
    if [ "${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}"x = ""x ] ; then
      LogMsg "Use the parameter \"-e filname\" to save the list of hosts with errors into a file"
    fi

    LogMsg  "The list of hosts with errors is : " 
    LogMsg "-" 
    LogMsg "-" "${HOSTS_WITH_ERRORS}" 
    LogMsg "-"

  fi

  if [ "${HOSTS_WITH_ERRORS}"x != ""x -a "${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}"x != ""x ] ; then
    LogMsg "Writing the list of hosts with errors to the file \"${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}\" ..."
    CUR_OUTPUT="$( ( echo "${HOSTS_WITH_ERRORS}" >>"${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}" ) 2>&1 )"
    if [ $? -ne 0 ] ; then
      LogWarningMsg "Error writing the list of hosts with errors to the file \"${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}\" "
    fi
  fi

  if [ "${PREFIX}"x != ""x ] ; then
    LogMsg "CAUTION: dry run -only -- NO scp or ssh command was executed"
  fi
}

#### --------------------------------------
#### list_returncodes
####
#### list all return codes used by a script
####
#### usage: list_returncodes {scriptname}
####
#### returns:  the functions prints a list of all returncodes to STDOUT
####           This works only if only the function die is used to end
####           the script.
####
####
function list_returncodes {
  typeset __FUNCTION="list_returncodes";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  typeset -R5 RC_P="RC"
  typeset     RC_S="Error Message"

  typeset MSG="${RC_P} ${RC_S}"
  typeset OUTPUT=""
  typeset DIE_PARAMETER=""
  typeset DIE_MSG=""
  typeset DIE_RC=""
  typeset DIE_UNKNWON=""
  typeset INVALID_RC_FOUND=${__FALSE}

  typeset SCRIPTFILE="$1"
  [ "${SCRIPTFILE}"x = ""x ] && SCRIPTFILE="${__SCRIPTDIR}/${__SCRIPTNAME}"

  [ ! -r "${SCRIPTFILE}" ] && die 230  "${SCRIPTFILE} does not exist or is not readable"

  echo "${MSG}"

  grep "die " ${SCRIPTFILE} | ${EGREP} -v "^#|grep|function die|__MAINRC|DIE" | while read line ; do

    DIE_PARAMETER="${line#*die }"

    DIE_MSG="${DIE_PARAMETER#* }"
    DIE_RC="${DIE_PARAMETER%% *}"

    if [ "${DIE_RC}"x = ""x ] ; then
      DIE_UNKNOWN="${DIE_UNKNOWN}
${line}
"
      continue
    fi

    [ "${DIE_RC}"x = "${DIE_MSG}"x ] && DIE_MSG=""

if [ 0 = 1 ] ; then
    [ "${DIE_RC}"x =    "0"x -a "${DIE_MSG}"x = ""x ] && DIE_MSG="(no error)"
    [ "${DIE_RC}"x =    "1"x -a "${DIE_MSG}"x = ""x ] && DIE_MSG="(show usage)"
    [ "${DIE_RC}"x =    "2"x -a "${DIE_MSG}"x = ""x ] && DIE_MSG="One or more invalid parameters found"
    [ "${DIE_RC}"x =  "250"x -a "${DIE_MSG}"x = ""x ] && DIE_MSG="Script is already running"
fi

    isNumber ${DIE_RC}
    if [ $? -ne 0 ] ; then
      DIE_UNKNOWN="${DIE_UNKNOWN}
${line}
"
      continue
    fi

    if [ ${DIE_RC} -ge 210 -o ${DIE_RC} = 1 -o ${DIE_RC} = 0 -o ${DIE_RC} = 2 ] ; then
      if [ "${DIE_MSG}"x = ""x ] ; then
        DIE_MSG="$( grep "##R# "  "${SCRIPTFILE}" | grep " ${DIE_RC} " | tr -s " "  | cut -f4- -d " " )"
      fi
    fi

    if [ 0 = 1 ] ; then
      echo "$line"
      echo "  P    = ${DIE_PARAMETER}"
      echo "  RC  = ${DIE_RC}"
      echo "  MSG = ${DIE_MSG}"
    fi

    RC_P="${DIE_RC}"
    RC_S="${DIE_MSG}"

    if [ ${DIE_RC} -gt 255 ] ; then
      INVALID_RC_FOUND=${__TRUE}
      MSG="${RC_P} ${RC_S} (*)"
    else
      MSG="${RC_P} ${RC_S}"
    fi
    OUTPUT="${OUTPUT}
${MSG}"

  done

  echo "${OUTPUT}" | grep -v "^$" | sort -b -n | uniq

  if [ ${INVALID_RC_FOUND} = ${__TRUE} ] ; then
    echo "
(*) WARNING: Returncodes greater than 255 do not work in scripts!"
  fi

  if [ "${DIE_UNKNOWN}"x != ""x ] ; then
    echo "
Lines with unknown usage of the function \"die\":

${DIE_UNKNOWN}
"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### ProcessDebugSwitch
####
#### process the debug switches
####
#### usage: ProcessDebugSwitch debugswitch
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function ProcessDebugSwitch {
  typeset __FUNCTION="ProcessDebugSwitch";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  typeset CUR_DEBUG_SWITCH="$*"

  typeset CUR_STATEMENT=""
  typeset CUR_VALUE=""
  typeset CUR_VAR=""

  typeset DEBUG_PARAMETER_OKAY=${__FALSE}

  LogInfo "Processing the debug switch \"${CUR_DEBUG_SWITCH}\" ..."


  case ${CUR_DEBUG_SWITCH} in

    "help" )
       cat <<EOT
Note:

Be aware that the order of some of the -D parameter is important (see below)!

Known debug switches (for -D / --debug):

  help          -- show this usage and exit
  create_documentation
                -- create the script documentation
  printargs     -- print the script arguments
  list_rc       -- list return codes used by this script and exit
  listfunc      -- list all functions defined and exit
  msg           -- log debug messages to the file ${__DEBUG_LOGFILE}
  trace         -- activate tracing to the file ${__TRACE_LOGFILE} 
                   Note: set the variable TRACE_MAIN to 0 to enable tracing the main function before starting the script
                         set the variable TRACE_PROMPT to the prompt to use for tracing before starting the script
  fn_to_stderr  -- print the function names to STDERR
  fn_to_tty     -- print the function names to /dev/tty
  fn_to_handle9 -- print the function names to the file handle 9
  fn_to_device=filename
                -- print the function names to the file "filename"
  debugcode="x" -- execute the debug code "x" at every function start
  tracefunc=f1[,...,f#]
                -- enable tracing for the functions f1 to f#
                   Note: Use either debugcode=x or tracefunc=f1 - but NOT both
  debug         -- start debug env
  setvar:name=value
                -- set the variable "name" to "value"
  create_dump=d -- enable environment dumps; target directory is d
  SyntaxHelp    -- print syntax usage examples for the functions in the template
                   and exit
  dryrun        -- dry run only, do not execute commands
                   default prefix for dryrun is: "${ECHO} "
  dryrun=prefix -- dry run only, add the prefix "prefix" to all commands

  fieldsep=x    -- change the default field separator to x
  ignore_user_in_file
               -- ignore user names from the host lists
  do_not_sort_hostlist
               -- do not sort the list of hosts
  ssh_binary=x
               -- use the ssh binary x
  scp_binary=x
               -- use the scp binary x
  ssh-keygen_binary=x
               -- use the ssh-keygen binary x
  dos2unix_binary=x
               -- use the dos2unix binary x
  if=x         -- use the host interface x, e.g.
                  if=a1; hostname=myhost.mydom.net -> interface to use is myhosta1.mydom.net
  enable_ForwardAgent_for_scp
               -- enable "ForwardAgent yes" for scp
  disable_ForwardAgent_for_scp
               -- disable "ForwardAgent yes" for scp
  singlestep   -- execute the commands in single step mode if running in sequential mode
  print_cmd    -- write scp and ssh commands to STDOUT
  clean_known_hosts
               -- remove each host from the known_hosts file before doing the scp and ssh
  clean_and_restore_known_hosts
               -- remove each host from the known_hosts file before doing the scp and ssh
                  and restore the known_hosts file at script end
  delete_known_hosts
               -- remove all hosts from the known_hosts file before doing the scp and ssh
  delete_and_restore_known_hosts | ignore_known_hosts
               -- remove all hosts from the known_hosts file before doing the scp and ssh
                  and restore the known_hosts file at script end
  restore_known_hosts
               -- restore the known_hosts file before the script ends
  nameserver   -- define the name server to use
               
  do_not_log_ssh_cmds
               -- do not log the output of the ssh commands in the log file of the script
  log_ssh_cmds
               -- log the output of the ssh commands in the log file of the script

  rcm_server=x    -- RCM server to use
  rcm_user=x      -- RCM user
  rcm_password=x  -- RCM password

    ---- Macros ----

  enable_gh    -- enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts

  ticket_id=x  -- set the ticket id for the SLS access to x; use 
                  "ticket_id=none" for no ticket id; use "ticket_id=default" 
                  to use the default ticket number which is ${PASSTHROUGH_TICKET}.
                  Current value is "$( [ "${NEW_TICKET_ID}"x = "none"x ] && echo "no ticket used" || echo "${TICKET_ID_STRING}" | cut -f2- -d "=" | tr -d "@" )"
                  
  use_ssh_wrapper
               -- use my ssh and scp wrapper script
                  Current value is $( ConvertToYesNo ${USE_SSH_WRAPPER} )

  Hints for the sls* Parameter listed below:
 
  To use another ticket id with the sls* parameter add the parameter "-D ticket_id=n" BEFORE the 
  sls* Parameter!

  sls_db_unxxx4 
               -- use DB SLS for ssh and scp access using the user unxxx4
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the ssh user and scp user to unxxx4

  sls_db_unxxx4_sudo 
               -- use DB SLS for ssh and scp access using the user unxxx4
                  use sudo to execute the command
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the ssh user and scp user to unxxx4

  SLS_db_unxxx4 
               -- use DB SLS for ssh and scp access using the user unxxx4
                  enable ForwardAgent for ssh and scp,
                  use the option "StrictHostKeyChecking=no" for ssh and scp,
                  temporary remove all entries from the known_hosts,
                  enable RCM access,
                  and set the ssh user and scp user to unxxx4

  SLS_db_unxxx4_sudo 
               -- use DB SLS for ssh and scp access using the user unxxx4
                  use sudo to execute the command
                  enable ForwardAgent for ssh and scp,
                  use the option "StrictHostKeyChecking=no" for ssh and scp,
                  temporary remove all entries from the known_hosts,
                  enable RCM access,
                  and set the ssh user and scp user to unxxx4

  sls_db_unxxx4_w_timeout or sls
               -- use DB SLS for ssh and scp access using the user unxxx4
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the ssh user and scp user to unxxx4
                  use a timeout of 15 seconds for each ssh and sls command
                  (set the variable SSH_SCP_CMD_TIMEOUT to change the timeout 
                   value)
                  
  sls_scp_db_unxxx4
               -- use DB SLS for scp access using the user unxxx4,
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the scp user to unxxx4

  sls_ssh_db_unxxx4
               -- use DB SLS for ssh access using the user unxxx4
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the ssh user to unxxx4
  
  sls_db       -- use DB SLS for ssh and scp access,
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the ssh user and scp user to root

  sls_scp_db   -- use DB SLS for scp access,
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the scp user to root

  sls_ssh_db   -- use DB SLS for ssh access,
                  enable ForwardAgent for ssh and scp,
                  cleanup and restore the known_hosts,
                  enable RCM access,
                  and set the ssh user to root

  sls_fms      -- use FMS SLS for ssh and scp access,
                  enable ForwardAgent for ssh and scp,
                  enable RCM access,
                  set the interface to use to a1,
                  and set the ssh and the scp user to root

  sls_ssh_fms  -- use FMS SLS for ssh access,
                  enable ForwardAgent for ssh and scp,
                  enable RCM access,
                  set the interface to use to a1,
                  and set the ssh to root and the scp user to support
EOT
        DEBUG_PARAMETER_OKAY=${__TRUE}
        die 0
        ;;

    do_not_log_ssh_cmds )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        DO_NOT_LOG_SSH_COMMANDS_IN_LOGFILE=${__TRUE}
        LogDebugMsg "Adding the output of the ssh commands to the logfile is now disabled"
        ;;

    log_ssh_cmds )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        DO_NOT_LOG_SSH_COMMANDS_IN_LOGFILE=${__FALSE}
        LogDebugMsg "Adding the output of the ssh commands to the logfile is now enabled"
        ;;

    list_rc )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        list_returncodes
        die 0
        ;;

    printargs )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "The script parameter are: "
        LogDebugMsg "${THIS_PARAMETER}"

#        typeset i=0 ; typeset p=""
#        while  [ $i -lt $# ] ; do
#          (( i = i + 1 ))
#          eval p="\${i}"
#          LogDebugMsg "  The parameter $i is: <${p}>"
#        done
        ;;

    fieldsep=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        FIELD_SEPARATOR="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Setting the default field separator to \"${FIELD_SEPARATOR}\" "
        if [ ${#FIELD_SEPARATOR} != 1 ] ; then
          die 2 "-D ${CUR_DEBUG_SWITCH} : The field separator must be a single character"
        fi
        ;;

    if=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        HOST_INTERFACE="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Using the host interface ${HOST_INTERFACE} "
        ;;

    nameserver=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        NEW_NAMESERVER="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Using the nameserver ${NEW_NAMESERVER} "
        ;;

# parameter for the RCM support
#
#
    rcm_user=* | rcm_userid=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        RCM_USERID="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Setting the RCM userid to use to \"${RCM_USERID}\" "
        [ "${RCM_USERID}"x != ""x ] && RCM_SUPPORT=${__TRUE}
        ;;

    rcm_password=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        RCM_PASSWORD="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Setting the RCM password "
        [ "${RCM_PASSWORD}"x != ""x ] && RCM_SUPPORT=${__TRUE}
        ;;

    rcm_server=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        RCM_SERVER="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Setting the RCM server to use to \"${RCM_SERVER}\" "
        [ "${RCM_SERVER}"x != ""x ] && RCM_SUPPORT=${__TRUE}
        ;;

    print_cmd )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling printing the scp and ssh commands to STDOUT."
        PRINT_CMD=${__TRUE}
        ;;

    no_print_cmd )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling printing the scp and ssh commands to STDOUT."
        PRINT_CMD=${__FALSE}
        ;;

    restore_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling the restore of the known_hosts file"
        RESTORE_KNOWN_HOSTS=${__TRUE}
        ;;

    no_restore_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling the restore of the known_hosts file"
        RESTORE_KNOWN_HOSTS=${__TRUE}
        ;;


    clean_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling removing the hosts from the known_hosts file"
        CLEAN_KNOWN_HOSTS=${__TRUE}
        ;;

    clean_and_restore_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling temporary removing the hosts from the known_hosts file"
        CLEAN_KNOWN_HOSTS=${__TRUE}
        RESTORE_KNOWN_HOSTS=${__TRUE}
        ;;

    no_clean_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling removing the hosts from the known_hosts file"
        CLEAN_KNOWN_HOSTS=${__FALSE}
        ;;

    delete_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enable removing all entries from the known_hosts file"
        DELETE_KNOWN_HOSTS=${__TRUE}
        ;;

    delete_and_restore_known_hosts | ignore_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling temporary removing all entries from the known_hosts file"
        DELETE_KNOWN_HOSTS=${__TRUE}
        RESTORE_KNOWN_HOSTS=${__TRUE}
        ;;

    no_delete_known_hosts )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling removing all entries from the known_hosts file"
        DELETE_KNOWN_HOSTS=${__FALSE}
        ;;


    singlestep )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling single step mode"
        SINGLE_STEP=${__TRUE}
        ;;

    no_singlestep )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling single step mode"
        SINGLE_STEP=${__FALSE}
        ;;


#  macros for various customer
#

    no_sls_db )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        die 45 "Parameter \"-D nosls_db\" is NOT implemented!"
        ;;

    no_sls_fms )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        die 46 "Parameter \"-D nosls_fms\" is NOT implemented!"
        ;;

    no_enable_gh )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        die 47 "Parameter \"-D no_enable_gh\" is NOT implemented!"
        ;;

    enable_gh  )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
        ;;

    use_ssh_wrapper )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        USE_SSH_WRAPPER=${__TRUE}
        ;;

    no_use_ssh_wrapper )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        USE_SSH_WRAPPER=${__FALSE}
        ;;

    ticket_id=* )    
        DEBUG_PARAMETER_OKAY=${__TRUE}
        NEW_TICKET_ID="${CUR_DEBUG_SWITCH#*=}"

        if [ "${NEW_TICKET_ID}"x = "default"x  ] ; then
          NEW_TICKET_ID=""
          TICKET_ID_STRING=""
        elif [ "${NEW_TICKET_ID}"x = ""x -o "${NEW_TICKET_ID}"x = "none"x ] ; then
          TICKET_ID_STRING=""
        else
          TICKET_ID_STRING="${TICKET_STRING}${NEW_TICKET_ID}@"
        fi
        LogDebugMsg "Setting the ticket_id string to \"${TICKET_ID_STRING}\" "
        ;;

    sls_db )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using DB SLS for root access for ssh and scp"

        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"
        
        if [ ${USE_SSH_WRAPPER} = ${__TRUE} ] ; then

### --------------------------------------------------------------------
### Code for using my ssh wrapper script        
#
          SCP_TEMPLATE="%b %k %o %S sls4root@sls.${TEMPVAR}:/%u@%H%s"
          SCPUSER="root"

# CAUTION: -t -t  is required here!!!
          SSH_TEMPLATE="%b %k %o -t -t -A -l sls4root sls.${TEMPVAR} sls -c %u@%H '%s' "
          SSHUSER="root"

        else
### --------------------------------------------------------------------
### Code for using the default ssh and scp binaries
#
          [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

          SCPUSER="root"
	   	  SCP_BINARY="/usr/bin/scp"
          SCP_TEMPLATE="%b %k %o %S %tsls4root@sls.${TEMPVAR}:/%u@%H%s " 

# CAUTION: -t -t  is required here!!!
#
          SSHUSER="root"
          SSH_BINARY="/usr/bin/ssh"
          SSH_TEMPLATE="%b %k %o -t -t -A %tsls4root@sls.${TEMPVAR} sls -c %u@%H '%s' "
        fi
### --------------------------------------------------------------------

        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"

        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the scp user to \"${SCPUSER}\"; setting the ssh user to \"${SSHUSER}\" "
        ;;

    sls_scp_db )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using DB SLS for root access for scp"
# CAUTION: -t -t  is required here!!!
        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"


        if [ ${USE_SSH_WRAPPER} = ${__TRUE} ] ; then

### --------------------------------------------------------------------
### Code for using my ssh wrapper script        
#
          SCP_TEMPLATE="%b %k %o %S sls4root@sls.${TEMPVAR}:/%u@%H%s"
          SCPUSER="root"

        else
### --------------------------------------------------------------------
### Code for using the default ssh and scp binaries
#
          [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

          SCPUSER="root"
	   	  SCP_BINARY="/usr/bin/scp"
          SCP_TEMPLATE="%b %k %o %S %tsls4root@sls.${TEMPVAR}:/%u@%H%s " 

        fi
### --------------------------------------------------------------------

        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"
        SCPUSER="root"
        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the scp user to \"${SCPUSER}\""
        ;;

    sls_ssh_db )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using DB SLS for root access for ssh."
## CAUTION: -t -t  is required here!!!
        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"
 
        if [ ${USE_SSH_WRAPPER} = ${__TRUE} ] ; then

### --------------------------------------------------------------------
### Code for using my ssh wrapper script        
#

# CAUTION: -t -t  is required here!!!
          SSH_TEMPLATE="%b %k %o -t -t -A -l sls4root sls.${TEMPVAR} sls -c %u@%H '%s' "
          SSHUSER="root"

        else
### --------------------------------------------------------------------
### Code for using the default ssh and scp binaries
#
          [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

# CAUTION: -t -t  is required here!!!
#
          SSHUSER="root"
          SSH_BINARY="/usr/bin/ssh"
          SSH_TEMPLATE="%b %k %o -t -t -A %tsls4root@sls.${TEMPVAR} sls -c %u@%H '%s' "
        fi
  
        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"
        SSHUSER="root"
        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the ssh user to \"${SSHUSER}\" "
        ;;


    sls_db_unxxx4 | SLS_db_unxxx4 | sls_db_unxxx4_sudo | SLS_db_unxxx4_sudo )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using DB SLS for access as unxxx4 for ssh and scp"
        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"

        [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

        SCPUSER="unxxx4"
#        SCP_BINARY="/usr/bin/scp"
        SCP_BINARY="${NEW_SCP_BINARY:=/usr/bin/scp}"

        SCP_TEMPLATE="%b %k %o %S %tsls4unx4@sls.${TEMPVAR}:/%u@%H%s " 
#
# CAUTION: -t -t  is required here!!!
#

#        SSH_BINARY="/usr/bin/ssh"
        SSH_BINARY="${NEW_SSH_BINARY:=/usr/bin/ssh}"

        SSHUSER="unxxx4"
        
        if [[ ${CUR_DEBUG_SWITCH} == *sudo* ]] ; then
          LogDebugMsg "Caution: Using \"sudo\" to execute the command on the host"
          SSH_TEMPLATE="%b %k %o -t -t -A %tsls4unx4@sls.${TEMPVAR} sls -c %u@%H 'sudo %s' "
        else
          SSH_TEMPLATE="%b %k %o -t -t -A %tsls4unx4@sls.${TEMPVAR} sls -c %u@%H '%s' "
        fi

        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        
        if [[ ${CUR_DEBUG_SWITCH} = sls_db_unxxx4* ]] ; then
          ProcessDebugSwitch "clean_known_hosts"
        else
          ProcessDebugSwitch "delete_known_hosts"
          NOSTRICTKEYS=${__TRUE}
        fi

        ProcessDebugSwitch "restore_known_hosts"
#        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"
        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the scp user to \"${SCPUSER}\"; setting the ssh user to \"${SSHUSER}\" "      
        ;;



    sls_db_unxxx4_w_timeout | sls )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        if [ "${SSH_SCP_CMD_TIMEOUT}"x = ""x ] ; then
          SSH_SCP_CMD_TIMEOUT=${DEFAULT_GLOBAL_SSH_SCP_CMD_TIMEOUT}
        fi

        CalculateSeconds ${SSH_SCP_CMD_TIMEOUT} SSH_SCP_CMD_TIMEOUT_IN_SEC
        if [ $? -ne ${__TRUE} ] ; then
          die 49 "The value of the variable SSH_SCP_CMD_TIMEOUT (${SSH_SCP_CMD_TIMEOUT}) is not a number"
        fi
        LogDebugMsg "Using the value of the variable SSH_SCP_CMD_TIMEOUT (${SSH_SCP_CMD_TIMEOUT} = ${SSH_SCP_CMD_TIMEOUT_IN_SEC} seconds) for the timeout "
         
        LogDebugMsg "Using DB SLS for access as unxxx4 for ssh and scp and a timeout of ${SSH_SCP_CMD_TIMEOUT_IN_SEC} seconds"

        TIMEOUT_EXECUTABLE="$( whence timeout 2>/dev/null )"
        if [ "${TIMEOUT_EXECUTABLE}"x = ""x ] ; then
           die 50 "The executable \"timeout\" does not exist"
        fi

        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"

        [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

        SCPUSER="unxxx4"
        SCP_BINARY="${NEW_SCP_BINARY:=/usr/bin/scp}"
        SCP_TEMPLATE="${TIMEOUT_EXECUTABLE} --foreground --preserve-status ${SSH_SCP_CMD_TIMEOUT_IN_SEC} %b %k %o %S %tsls4unx4@sls.${TEMPVAR}:/%u@%H%s " 
#
# CAUTION: -t -t  is required here!!!
#
        SSH_BINARY="${NEW_SSH_BINARY:=/usr/bin/ssh}"
        SSHUSER="unxxx4"
        SSH_TEMPLATE="${TIMEOUT_EXECUTABLE} --foreground --preserve-status ${SSH_SCP_CMD_TIMEOUT_IN_SEC} %b %k %o -t -t -A %tsls4unx4@sls.${TEMPVAR} sls -c %u@%H '%s' "

        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
#        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"
        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the scp user to \"${SCPUSER}\"; setting the ssh user to \"${SSHUSER}\" "      
        ;;

    sls_scp_db_unxxx4 )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using DB SLS for access as unxxx4 for scp"

        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"

        [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

        SCPUSER="unxxx4"
	    SCP_BINARY="/usr/bin/scp"
        SCP_TEMPLATE="%b %k %o %S %tsls4unx4@sls.${TEMPVAR}:/%u@%H%s " 

        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"
        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the scp user to \"${SCPUSER}\""
        ;;

    sls_ssh_db_unxxx4 )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using DB SLS for access as unxxx4 for ssh."

# CAUTION: -t -t  is required here!!!
#
        [ "${NEW_TICKET_ID}"x = ""x ] && TICKET_ID_STRING="${TICKET_STRING}${PASSTHROUGH_TICKET}@"

        TEMPVAR="$( echo rz2.d2.db.c4m | tr "12345" "aeiou" )"

        SSHUSER="unxxx4"
        SSH_BINARY="/usr/bin/ssh"
        SSH_TEMPLATE="%b %k %o -t -t -A %tsls4unx4@sls.${TEMPVAR} sls -c %u@%H '%s' "

        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "clean_known_hosts"
        ProcessDebugSwitch "restore_known_hosts"
        ProcessDebugSwitch "rcm_server=rcm.${TEMPVAR}"
#        SSHUSER="root"
        RCM_SUPPORT=${__FALSE}

        LogDebugMsg "Setting the ssh user to \"${SSHUSER}\" "
        ;;

    sls_fms )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using FMS SLS for root access for ssh and scp"
#        
## CAUTION: -t -t  is required here!!!
#
        TEMPVAR="$( echo f4595808x1.23r4.f45-56.27 | tr "234567890" "dcmsgeopb" )"
        ProcessDebugSwitch "enable_ForwardAgent_for_scp"

        SSH_TEMPLATE="%b %k %o -t -t -A -l sls4root ${TEMPVAR} sls -c %u@%H '%s' "
        SCP_TEMPLATE="%b %k %o %S sls4root@${TEMPVAR}:/%u@%H%s"

        TEMPVAR="$( echo r23.frankfurt.16.4ni.ib3.2o3 | tr "123456" "dcmsge" )"
        ProcessDebugSwitch "rcm_server=${TEMPVAR}"


        SCPUSER="root"
        SSHUSER="root"

        RCM_SUPPORT=${__FALSE}
        LogDebugMsg "Setting the scp user to \"${SCPUSER}\"; setting the ssh user to \"${SSHUSER}\" "
        ;;

    sls_ssh_fms )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Using FMS SLS for root access for ssh"

#
## CAUTION: -t -t  is required here!!!
#
        TEMPVAR="$( echo f4595808x1.23r4.f45-56.27 | tr "234567890" "dcmsgeopb" )"
        ProcessDebugSwitch "enable_ForwardAgent_for_scp"
        ProcessDebugSwitch "if=a1"

        SSH_TEMPLATE="%b %k %o -t -t -A -l sls4root ${TEMPVAR} sls -c %u@%H '%s' "
        SSHUSER="root"

#        SCP_TEMPLATE="%b %k %o %S sls4root@${TEMPVAR}:/%u@%H%s"
        SCPUSER="support"

        TEMPVAR="$( echo r23.frankfurt.16.4ni.ib3.2o3 | tr "123456" "dcmsge" )"
        ProcessDebugSwitch "rcm_server=${TEMPVAR}"

        RCM_SUPPORT=${__FALSE}
        LogDebugMsg "Setting the ssh user to \"${SSHUSER}\" "
        ;;

    no_enable_ForwardAgent_for_scp | disable_ForwardAgent_for_scp )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling agent forwarding for scp NOT implemented."
        ;;

    enable_ForwardAgent_for_scp | no_disable_ForwardAgent_for_scp )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        if [ ${SCP_WITH_FORWARD_AGENT_ENABLED} != ${__TRUE} ] ; then
          LogDebugMsg "Enabling agent forwarding for scp."
          SCP_WITH_FORWARD_AGENT_ENABLED=${__TRUE}
          SCP_OPTIONS="${SCP_OPTIONS} -S ${SSH_WRAPPER_FOR_SCP} "
        fi
        ;;

    dryrun=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        PREFIX="${CUR_DEBUG_SWITCH#*=} "
        LogDebugMsg "Enabling dry-run mode -- the command prefix is \"${PREFIX}\" "
        ;;

    dryrun )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        PREFIX="${ECHO} "
        LogDebugMsg "Enabling dry-run mode -- the command prefix is \"${PREFIX}\" "
        ;;

    nodryrun )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        if [ "${PREFIX}"x != ""x ] ; then
          LogDebugMsg "Disabling dry-run mode"
        fi
        PREFIX=""
        ;;

    ssh_binary=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        NEW_SSH_BINARY="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "The ssh binary to use is \"${NEW_SSH_BINARY}\"."
        ;;

    scp_binary=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        NEW_SCP_BINARY="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "The scp binary to use is \"${NEW_SCP_BINARY}\"."
        ;;

    ssh-keygen_binary=* | ssh_keygen_binary=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        NEW_SSH_KEYGEN_BINARY="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "The ssh-keygen binary to use is \"${NEW_SSH_KEYGEN_BINARY}\"."
        ;;
    
    dos2unix_binary=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        NEW_DOS2UNIX_BINARY="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "The dos2unix binary to use is \"${NEW_DOS2UNIX_BINARY}\"."
        ;;

    "ignore_user_in_file" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling user specifications from the input files"
        IGNORE_USER_IN_FILE=${__TRUE}
        ;;

    "no_ignore_user_in_file" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling user specifications from the input files"
        IGNORE_USER_IN_FILE=${__FALSE}
        ;;

    "do_not_sort_hostlist" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Disabling sort of the input files"
        DO_NOT_SORT_HOSTLIST=${__TRUE}
        ;;

    "no_do_not_sort_hostlist" | "sort_hostlist" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Enabling sort of the input files"
        DO_NOT_SORT_HOSTLIST=${__FALSE}
        ;;


    create_dump=* | create_dump )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        CUR_VALUE="${CUR_DEBUG_SWITCH#*=}"
        [ "${CUR_VALUE}"x = "${CUR_DEBUG_SWITCH}"x ] && \
          __CREATE_DUMP=1 || \
          __CREATE_DUMP="${CUR_VALUE}"
        if [ "${CUR_VALUE}"x != ""x ] ; then
          if [ -d "${CUR_VALUE}" ]  ;then
            LogDebugMsg "Writing environment dumps to \"${CUR_VALUE}\" "
          else
            LogDebugMsg "Writing environment dumps to \"/tmp\" "
          fi
        fi
        ;; 

    create_documentation )
        CUR_VALUE="${__SCRIPTDIR}/${__SCRIPTNAME}"

        CUR_VAR="${__SCRIPTNAME}.long_usage.txt"
        LogDebugMsg "Writing the long usage documentation to ${CUR_VAR} ..."
        ${CUR_VALUE} -v -v -h 2>/dev/null >"${CUR_VAR}"

        CUR_VAR="${__SCRIPTNAME}.debug_switches.txt"
        LogDebugMsg "Writing the debug switch documentation to ${CUR_VAR} ..."
        ${CUR_VALUE} -D help >"${CUR_VAR}"

        CUR_VAR="${__SCRIPTNAME}.txt"
        LogDebugMsg "Writing the script documentation to ${CUR_VAR} ..."
        ${CUR_VALUE} -H 2>"${CUR_VAR}" 1>/dev/null

        CUR_VAR="${__SCRIPTNAME}.usage_examples.txt"
        LogDebugMsg "Writing the script usage examples to ${CUR_VAR} ..."
        ${CUR_VALUE} -X 2>"${CUR_VAR}" 1>/dev/null

        CUR_VAR="${__SCRIPTNAME}.function_examples.txt"
        LogDebugMsg "Writing the function usage examples to ${CUR_VAR} ..."
        ${CUR_VALUE} -D SyntaxHelp 2>"${CUR_VAR}" 1>/dev/null

        DEBUG_PARAMETER_OKAY=${__TRUE}
        die 0
        ;;


    debugcode=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        CUR_STATEMENT="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "Adding the debug code \"${CUR_STATEMENT}\" to all functions."
        __DEBUG_CODE="${CUR_STATEMENT}"
        ;;

    debug* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        CUR_STATEMENT="${CUR_DEBUG_SWITCH#*=}"
        if [ "${CUR_STATEMENT}"x != ""x  -a "${CUR_STATEMENT}"x != "debug"x ] ; then
          LogDebugMsg "Executing \"${CUR_STATEMENT}\" ..."
          ${CUR_STATEMENT}
        else
          LogDebugMsg "Starting debug environment ..."
          set +e
          while true ; do
            printf ">> "
            read USER_INPUT
            eval ${USER_INPUT}
            if [ "${USER_INPUT}"x = "quiet"x -o "${USER_INPUT}"x = "q"x  ] ; then
              break
            elif [ "${USER_INPUT}"x = "exit"x ] ; then
              die 10 "Script aborted by the user"
            fi
          done
        fi
        ;;

    setvar:* )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        CUR_STATEMENT="${CUR_DEBUG_SWITCH#*:}"
        CUR_VALUE="${CUR_STATEMENT#*=}"
        CUR_VAR="${CUR_STATEMENT%%=*}"
        LogDebugMsg "Setting the variable \"${CUR_VAR}\" to \"${CUR_VALUE}\" "
        eval ${CUR_VAR}=\"${CUR_VALUE}\"
        ;;

    "SyntaxHelp" )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        IsFunctionDefined SyntaxHelp
        if [ $? -eq ${__TRUE} ] ; then
          SyntaxHelp
          die 0
        else
          die 232 "Function SyntaxHelp NOT defined."
        fi
        ;;

    fn_to_device=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        CUR_VAR="${CUR_DEBUG_SWITCH#*=}"
        if [ "${CUR_VAR}"x = ""x ] ; then
          LogDebugMsg "Disabling printing all function names executed"
          __FUNCTION_INIT=" eval __settraps"
          __FUNCTION_EXIT=""
        else
          LogDebugMsg "Now Printing all function names executed to ${CUR_VAR}"
          touch "${CUR_VAR}" || die 231 "Can not write to the file \"${CUR_VAR}\""

          __FUNCTION_INIT=' eval __settraps; printf "Now in the function \"${__FUNCTION}\"; ; the parameter are \"$*\" (sec: $SECONDS): \n" >>'${CUR_VAR}
          __FUNCTION_EXIT="eval echo \"Now leaving the function \"\${__FUNCTION}\"; THISRC is \"\${THISRC}\" (sec: \$SECONDS) \" >>${CUR_VAR} "
        fi
        ;;

    "fn_to_stderr" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Now Printing all function names executed to STDERR"

        __FUNCTION_INIT=' eval __settraps; printf "Now in the function \"${__FUNCTION}\"; ; the parameter are \"$*\" (sec: $SECONDS): \n" >&2 '
        __FUNCTION_EXIT="eval echo \"Now leaving the function \"\${__FUNCTION}\"; THISRC is \"\${THISRC}\" (sec: \$SECONDS) \" >&2  "
        ;;

    "fn_to_tty" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Now Printing all function names executed to /dev/tty"

        __FUNCTION_INIT=' eval __settraps; printf "Now in the function \"${__FUNCTION}\"; ; the parameter are \"$*\" (sec: $SECONDS): \n" >/dev/tty '
        __FUNCTION_EXIT="eval echo \"Now leaving the function \"\${__FUNCTION}\"; THISRC is \"\${THISRC}\" (sec: \$SECONDS) \" >/dev/tty "
        ;;

    "fn_to_handle9" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Now Printing all function names executed to the file handle 9"

        echo 2>/dev/null >&9 || die 233 "Can not write to file handle 9"
        __FUNCTION_INIT=' eval __settraps; printf "Now in the function \"${__FUNCTION}\"; ; the parameter are \"$*\" (sec: $SECONDS): \n" >&9 '
        __FUNCTION_EXIT="eval echo \"Now leaving the function \"\${__FUNCTION}\"; THISRC is \"\${THISRC}\" (sec: \$SECONDS) \" >&9 "
        ;;

    "msg" )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        __LOG_DEBUG_MESSAGES=${__TRUE}
        LogDebugMsg "Debug messages enabled; the output goes into the file \"${__DEBUG_LOGFILE}\"."
        ;;

    "trace" )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        __ACTIVATE_TRACE=${__TRUE}
        exec 3>&2
        exec 2>"${__TRACE_LOGFILE}"
        typeset -ft $( typeset +f )
        set -x
        PS4='LineNo: $LINENO (sec: $SECONDS): >> '
        LogDebugMsg "Tracing enabled; the output goes to the file \"${__TRACE_LOGFILE}\". "
        LogDebugMsg "WARNING: All output to STDERR now goes into the file \"${__TRACE_LOGFILE}\"; use \">&3\" to print to real STDERR."
        ;;

  esac

  if [ ${DEBUG_PARAMETER_OKAY} != ${__TRUE} ] ; then

# replace "," with blanks now
#
    echo "${CUR_DEBUG_SWITCH}" | grep "," >/dev/null && \
      CUR_DEBUG_SWITCH=$( IFS=, ; printf "%s " ${CUR_DEBUG_SWITCH}  )

    case ${CUR_DEBUG_SWITCH} in

      listfunc )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        LogDebugMsg "Functions defined in the script are:"
        typeset -f | grep "^function " | awk '{print $2 };'
        die 0
        ;;

      tracefunc=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        CUR_VAR="${CUR_DEBUG_SWITCH#*=}"

        CUR_STATEMENT="[ 0 = 1 "
        for CUR_VALUE in ${CUR_VAR} ; do
          typeset -f  ${CUR_VALUE} | grep "\${__DEBUG_CODE}" >/dev/null || LogWarning  "tracefunc: function ${CUR_VALUE} is not defined or does not support debug code"
          CUR_STATEMENT="${CUR_STATEMENT} -o \"\${__FUNCTION}\"x = \"${CUR_VALUE}\"x "
        done
        CUR_STATEMENT="eval ${CUR_STATEMENT} ] && printf \"\n*** Enabling trace for the function \${__FUNCTION} ...\n\" >&2 && set -x "

        LogDebugMsg "Adding the debug code \"${CUR_STATEMENT}\" to all functions."
        __DEBUG_CODE="${CUR_STATEMENT}"

        ;;

      * )
#        DEBUG_PARAMETER_OKAY=${__TRUE}

        die 235 "Invalid debug switch found: \"${CUR_DEBUG_SWITCH}\" -- use \"-d help\" to list the known debug switches"
        ;;

    esac
  fi


  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### USER_SIGNAL_HANDLER
####
#### template for a user defined trap handler
####
#### usage:
####   to define one signal handler for all signals do:
####
####     __GENERAL_SIGNAL_FUNCTION=USER_SIGNAL_HANDLER
####
####   to define unique signal handler for the various signals do:
####
####     __SIGNAL_<signal>_FUNCTION="USER_SIGNAL_HANDLER"
####
####   e.g.:
####
####     __SIGNAL_SIGUSR1_FUNCTION=USER_SIGNAL_HANDLER
####     __SIGNAL_SIGUSR2_FUNCTION=USER_SIGNAL_HANDLER
####     __SIGNAL_SIGHUP_FUNCTION=USER_SIGNAL_HANDLER
####     __SIGNAL_SIGINT_FUNCTION=USER_SIGNAL_HANDLER
####     __SIGNAL_SIGQUIT_FUNCTION=USER_SIGNAL_HANDLER
####     __SIGNAL_SIGTERM_FUNCTION=USER_SIGNAL_HANDLER
####
#### returns:  0 - execute the next action for this signal
####           else - do not execute the next action for this signal
####
#### Notes:
####    Depending on the return code of the signal handler the other
####    signal handler are called (RC=0) or not (RC<>0)
####
####    The call order is
####       - general user defined signal handler (if defined)
####       - signal specific user defined signal handler (if defined)
####       - default specific signal handler
####
function USER_SIGNAL_HANDLER {
  typeset __FUNCTION="USER_SIGNAL_HANDLER";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}
  typeset THISRC=0

  LogMsg "***"
  LogMsg "User defined signal handler called"
  LogMsg ""
  LogMsg "Trap signal is \"${__TRAP_SIGNAL}\" "
  LogMsg "Interrupted function: \"${INTERRUPTED_FUNCTION}\", Line No: \"${__LINENO}\" "
  LogMsg "***"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### host_on_the_exclude_list
####
#### check if a host is on the host exclude list
####
#### usage: host_on_the_exclude_list
####
#### returns:  ${__TRUE} -  yes
####           ${__FALSE} - no
####
####
function host_on_the_exclude_list {
  typeset __FUNCTION="host_on_the_exclude_list";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# parameter
  typeset CUR_HOST="$1"

# local variables
#
  typeset HOST_EXCLUDE_MASK=""

# init the return code
  typeset THISRC=${__FALSE}

  if [ "${CUR_HOST}"x != ""x ] ; then
    for HOST_EXCLUDE_MASK in ${EXCLUDE_HOSTS} ; do
      if [[ ${CUR_HOST} == ${HOST_EXCLUDE_MASK} ]] ; then
        HOSTS_EXCLUDED="${HOSTS_EXCLUDED} ${CUR_HOST}"
        THISRC=${__TRUE}
        break
      fi
    done
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### retrieve_ssh_and_scp_user
####
#### get the ssh and scp user for accessing the current host
####
#### usage: retrieve_ssh_and_scp_user hostname
####
#### returns:  -
####           CUR_HOST, CUR_SSH_USER, and CUR_SCP_USER are set
####
####
retrieve_ssh_and_scp_user() {
  typeset __FUNCTION="retrieve_ssh_and_scp_user";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# parameter
  typeset THIS_HOST="$1"

  typeset CUR_USER=""

# init the return code
  typeset THISRC=${__TRUE}

  CUR_SSH_USER="${SSHUSER}"
  CUR_SCP_USER="${SCPUSER}"

# get the values from the file for this host
#
  CUR_USER="${THIS_HOST%@*}"
  CUR_HOST="${THIS_HOST#*@}"

  if [ "${CUR_USER}"x != "${CUR_HOST}"x ] ; then
    if [ ${IGNORE_USER_IN_FILE} = ${__TRUE} ] ; then
      LogMsg "++++ The user from the hostlist \"${CUR_USER}\" for the host \"${CUR_HOST}\" will be ignored."
    else
      CUR_SSH_USER="${CUR_USER}"
      CUR_SCP_USER="${CUR_USER}"
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### evaluate_template
####
#### process the ssh or scp template for the current host
####
#### usage: evaluate_template [ssh|scp]
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
#### this functions prints the evaluated template to STDOUT
#####
function evaluate_template {
  typeset __FUNCTION="evaluate_template";  
   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  typeset DNS_DOMAIN="${CUR_HOST#*.}"
  typeset SHORTHOST="${CUR_HOST%%.*}"

  case $1 in
    "ssh" )
      echo "${SSH_TEMPLATE}" | ${SED} \
        -e "s${SED_SEP}%%${SED_SEP}\x01${SED_SEP}g" \
        -e "s${SED_SEP}%b${SED_SEP}${SSH_BINARY}${SED_SEP}g" \
        -e "s${SED_SEP}%s${SED_SEP}${TARGET_COMMAND}${SED_SEP}g" \
        -e "s${SED_SEP}%u${SED_SEP}${CUR_SSH_USER}${SED_SEP}g" \
        -e "s${SED_SEP}%h${SED_SEP}${CUR_HOST}${SED_SEP}g" \
        -e "s${SED_SEP}%H${SED_SEP}${SHORTHOST}${SED_SEP}g" \
        -e "s${SED_SEP}%d${SED_SEP}${DNS_DOMAIN}${SED_SEP}g" \
        -e "s${SED_SEP}%i${SED_SEP}${CUR_HOST_INTERFACE}${SED_SEP}g" \
        -e "s${SED_SEP}%o${SED_SEP}${SSH_OPTIONS}${SED_SEP}g" \
        -e "s${SED_SEP}%k${SED_SEP}${SSH_KEY_PARM}${SED_SEP}g" \
        -e "s${SED_SEP}%c${SED_SEP}${SHELL_TO_USE}${SED_SEP}g" \
        -e "s${SED_SEP}%t${SED_SEP}${TICKET_ID_STRING}${SED_SEP}g" \
        -e "s${SED_SEP}\x01${SED_SEP}%${SED_SEP}g"
      THISRC=${__TRUE}
      ;;

    "scp" )
      echo "${SCP_TEMPLATE}" | ${SED} \
        -e "s${SED_SEP}%%${SED_SEP}\x01${SED_SEP}g" \
        -e "s${SED_SEP}%b${SED_SEP}${SCP_BINARY}${SED_SEP}g" \
        -e "s${SED_SEP}%S${SED_SEP}${SCRIPTFILE}${SED_SEP}g" \
        -e "s${SED_SEP}%s${SED_SEP}${TARGET_COMMAND}${SED_SEP}g" \
        -e "s${SED_SEP}%u${SED_SEP}${CUR_SCP_USER}${SED_SEP}g" \
        -e "s${SED_SEP}%h${SED_SEP}${CUR_HOST}${SED_SEP}g" \
        -e "s${SED_SEP}%H${SED_SEP}${SHORTHOST}${SED_SEP}g" \
        -e "s${SED_SEP}%d${SED_SEP}${DNS_DOMAIN}${SED_SEP}g" \
        -e "s${SED_SEP}%i${SED_SEP}${CUR_HOST_INTERFACE}${SED_SEP}g" \
        -e "s${SED_SEP}%o${SED_SEP}${SCP_OPTIONS}${SED_SEP}g" \
        -e "s${SED_SEP}%k${SED_SEP}${SCP_KEY_PARM}${SED_SEP}g" \
        -e "s${SED_SEP}%t${SED_SEP}${TICKET_ID_STRING}${SED_SEP}g" \
        -e "s${SED_SEP}\x01${SED_SEP}%${SED_SEP}g"
      THISRC=${__TRUE}
      ;;

    * )
      LogError "${__FUNCTION} called with an invalid parameter: $1"
      ;;
  esac

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### Remove_host_from_known_hosts_file
####
#### template for a user defined function
####
#### usage: Remove_host_from_known_hosts_file [host1...host#]
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function Remove_host_from_known_hosts_file {
  typeset __FUNCTION="Remove_host_from_known_hosts_file";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}
  
# init the return code
  typeset THISRC=${__TRUE}

# add code here

  typeset HOSTS_TO_REMOVE="$*"

  typeset CUR_OUTPUT=""
  typeset TEMPRC=""

  typeset CUR_HOST=""
  typeset HOST_IPS=""
  typeset CUR_IP=""

  typeset CUR_HOSTNAME=""
  typeset CUR_HOSTNAMES=""

  typeset CUR_KNOWN_HOSTS_CONTENTS=""
  typeset NEW_KNOWN_HOSTS_CONTENTS=""

  typeset ENTRIES_TO_REMOVE=""

  typeset REGEX="^#dummy"
   
  [ "${KNOWN_HOSTS_FILE}"x = ""x ] && typeset KNOWN_HOSTS_FILE="${HOME}/.ssh/known_hosts"

  if [ ! -r "${KNOWN_HOSTS_FILE}" ] ; then
    LogInfo "File \"${KNOWN_HOSTS_FILE}\" not found "
  else
    CUR_KNOWN_HOSTS_CONTENTS="$( cat "${KNOWN_HOSTS_FILE}" 2>&1 )"
    if [ $? -ne 0 ] ; then
      LogMsg "-" "${CUR_KNOWN_HOSTS_CONTENTS}"

      LogError "Error reading the file \"${KNOWN_HOSTS_FILE}\" "
      THISRC=${__FALSE}
    elif [ "${CUR_KNOWN_HOSTS_CONTENTS}"x = ""x ] ; then
#
# the known_hosts file is empty - do nothing
#
      LogInfo "The file \"${KNOWN_HOSTS_FILE}\" is empty"
      :  
    else

      for CUR_HOST in ${HOSTS_TO_REMOVE} ; do
        LogMsg "Removing the entries for the host \"${CUR_HOST}\" from the file \"${KNOWN_HOSTS_FILE}\" ..."

        LogInfo "Removing the entry \"${CUR_HOST}\"  "

        REGEX="${REGEX}|^${CUR_HOST}[, ]"
        ENTRIES_TO_REMOVE="${ENTRIES_TO_REMOVE} ${CUR_HOST}"

        if [[ ${CUR_HOST} != [0-9]* ]] ; then
          HOST_IPS="$( dig ${CUR_NAMESERVER} ${CUR_HOST} +short 2>/dev/null )"

          LogInfo "The IPs for the hostname \"${CUR_HOST}\" are: " && \
            LogMsg "-" "${HOST_IPS}"
            
          for CUR_IP in ${HOST_IPS} ; do
            LogInfo "Removing the entry \"${CUR_IP}\"  "
      
            ENTRIES_TO_REMOVE="${ENTRIES_TO_REMOVE} ${CUR_IP}"

            REGEX="${REGEX}|^${CUR_IP}[, ]"
          done
        else
          CUR_HOSTNAMES="$( dig ${CUR_NAMESERVER} -x ${CUR_HOST} +short 2>/dev/null )"

          LogInfo "The hostnames for the IP \"${CUR_HOST}\" are: " && \
            LogMsg "-" "${CUR_HOSTNAMES}"

          for CUR_HOSTNAME in ${CUR_HOSTNAMES} ; do
            [[ ${CUR_HOSTNAME} == *\. ]] && CUR_HOSTNAME="${CUR_HOSTNAME%.*}"

            LogInfo "Removing the entry  \"${CUR_HOSTNAME}\"  "

            ENTRIES_TO_REMOVE="${ENTRIES_TO_REMOVE} ${CUR_HOSTNAME}"

            REGEX="${REGEX}|^${CUR_HOSTNAME}[, ]"
          done
        fi
      done

      if [ "${ENTRIES_TO_REMOVE}"x != ""x ] ; then
        echo "${CUR_KNOWN_HOSTS_CONTENTS}" | ${EGREP} "${REGEX}" >/dev/null
        if [ $? -ne 0 ] ; then
          LogMsg "No entries found for \"${CUR_HOST}\" in the file \"${KNOWN_HOSTS_FILE}\" "
        else

          LogInfo "Removing the entries \"${ENTRIES_TO_REMOVE}\" from the file \"${KNOWN_HOSTS_FILE}\" ..."

          CUR_OUTPUT=""
          if [ "${SSH_KEYGEN_BINARY}"x != ""x ] ; then
            for CUR_HOST in ${ENTRIES_TO_REMOVE} ; do
              CUR_OUTPUT="${CUR_OUTPUT}
#
# removing the entry ${CUR_HOST} via ${SSH_KEYGEN}
#
$( ${SSH_KEYGEN_BINARY} -R ${CUR_HOST} 2>&1 )
"
            done

            LogInfo "Output of the removal via ${SSH_KEYGEN_BINARY}: " && \
              LogMsg "-" "${CUR_OUTPUT}" 

          fi
   
          NEW_KNOWN_HOSTS_CONTENTS="$( echo "${CUR_KNOWN_HOSTS_CONTENTS}" | ${EGREP} -v "${REGEX}" )"
          CUR_OUTPUT="$( ( echo "${NEW_KNOWN_HOSTS_CONTENTS}" >"${KNOWN_HOSTS_FILE}" ) 2>&1 )"
          TEMPRC=$?
          if [ ${TEMPRC} -ne 0 ] ; then
            LogMsg "-" "${CUR_OUTPUT}"
            LogError "Error removing the host entries from the known_hosts file"
            THISRC=${__FALSE}
           else
            LogMsg "... entries removed."
          fi
        fi
      fi
    fi
  fi
  
  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### template for a new user function
####

#### --------------------------------------
#### YourRoutine
####
#### template for a user defined function
####
#### usage: YourRoutine
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function YourRoutine {
  typeset __FUNCTION="YourRoutine";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

# add code here

  [ ${THISRC} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}



# -----------------------------------------------------------------------------
# main:
#
  __FUNCTION="main"

  HOST_PROCESSING_STARTED=${__FALSE}

# trace main routine
#
if [ "${TRACE_MAIN}"x = "0"x ] ; then
  LogMsg "The variable TRACE_MAIN is 0 -- will activate trace for the main function of the script"
  
  if [ "${TRACE_PROMPT}"x != ""x ] ; then
    LogMsg "Using the string \"${TRACE_PROMPT}\" from the environment variable \"TRACE_PROMPT\" for the variable PS4"
    PS4="${TRACE_PROMPT}"
  else
    PS4='LineNo: $LINENO (sec: $SECONDS): >> '
  fi
  set -x
fi

# Note: This statement seems to be necessary to use ${LINENO} in the trap statement
#
  LINENO=${LINENO}

# install trap handler
  __settraps

  trap 'GENERAL_SIGNAL_HANDLER EXIT  ${LINENO} ${__FUNCTION}' exit

# trace also all function defined before this line (!)
#
# typeset -ft $( typeset +f )

  InitScript $*


# init variables with the defaults
#
# format var=${DEFAULT_var}
#

# to process all variables beginning with DEFAULT_ use
#
  for CURVAR in $( set | grep "^DEFAULT_"  | cut -f1 -d"=" ) ; do
    P1="${CURVAR%%=*}"
    P2="${P1#DEFAULT_*}"

# for debugging (no parameter are processed until now)
#
    if [ 1 = 0 ] ; then
      push_and_set __VERBOSE_MODE ${__TRUE}
      push_and_set __VERBOSE_LEVEL ${__RT_VERBOSE_LEVEL}
      LogInfo 0 "Setting variable $P2 to \"$( eval "echo \"\$$P1\"")\" "
      pop __VERBOSE_MODE
      pop __VERBOSE_LEVEL
    fi

    eval "$P2="\"\$$P1\"""
  done

# --- variables for the cleanup routine:
#
# add mounts that should be automatically be unmounted at script end to this variable
#
#  __LIST_OF_TMP_MOUNTS="${__LIST_OF_TMP_MOUNTS} "

# add directories that should be automatically removed at script end to this variable
#
#  __LIST_OF_TMP_DIRS="${__LIST_OF_TMP_DIRS} "

# add files that should be automatically removed at script end to this variable
#  __LIST_OF_TMP_FILES="${__LIST_OF_TMP_FILES} "

# add functions that should be called automatically at program end
# before removing temporary files, directories, and mounts
# to this variable
#
#  __EXITROUTINES="${__EXITROUTINES} "

  BACKGROUND_PIDS=""
  __EXITROUTINES="${__EXITROUTINES} mycleanup"

# add functions that should be called automatically at program end
# after removing temporary files, directories, and mounts
# to this variable
#
#  __FINISHROUTINES="${__FINISHROUTINES} "

  check_SSH_agent_status && SSH_AGENT_STATUS="running" || SSH_AGENT_STATUS="not running"

# variables used by getopts:
#    OPTIND = index of the current argument
#    OPTARG = current function character
#
  THIS_PARAMETER="$*"

  INVALID_PARAMETER_FOUND=${__FALSE}

  TIMEOUT_PARAMETER_FOUND=${__FALSE}
  INTERVALL_PARAMETER_FOUND=${__FALSE}
  
  __PRINT_USAGE=${__FALSE}
  CUR_SWITCH=""
  OPTARG=""

  set -o noglob

#
  [ "${__OS}"x = "Linux" ] &&  GETOPT_COMPATIBLE="0"


  __GETOPTS="+:ynvqhHD:fl:aOS:CVTXi:o:s:u:c:kUI:p:P:KRb:BdW:w:x:A:t:e:"
  if [ "${__OS}"x = "SunOS"x -a "${__SHELL}"x = "ksh"x ] ; then
    if [ "${__OS_VERSION}"x  = "5.10"x -o  "${__OS_VERSION}"x  = "5.11"x ] ; then
      __GETOPTS="+:y(yes)n(no)v(verbose)q(quiet)h(help)H(doc)D:(debug)f(force)l:(logfile)\
a(color)O(overwrite)S:(summaries)C(writeconfigfile)V(version)T(tee)X(view_examples)\
i:(hostlist)o:(outputfile)s:(scriptfile)u:(sshuser)c:(shell)k(nocomments)U(uniquelogfiles)\
I:(basedir)p:(scpoptions)P:(sshoptions)K(nostrictkeys)R(rcm)b:(ssh_keyfile)B(do_not_copy)\
d(parallel)W:(timeout)w:(noOfbackgroundProcesses)x:(excludehost)A:(includehost)t:(template)e:(hosts_with_errors)"
    fi
  fi

  while getopts ${__GETOPTS} CUR_SWITCH  ; do

# for debugging only
#
# -----------------------------------------------------------------------------
# Debug Hint
#
# Use
#
#     __PRINT_ARGUMENTS=0 [scriptname]
#
# to debug the parameter handling
#
# -----------------------------------------------------------------------------
    if [  "${__PRINT_ARGUMENTS}" = "${__TRUE}" ] ; then
      LogMsg "CUR_SWITCH is $CUR_SWITCH"
      LogMsg "OPTIND = $OPTIND"
      LogMsg "OPTARG = $OPTARG"
      LogMsg "\$* is \"$*\" "
    fi

    if [ "${CUR_SWITCH}" = ":" ] ; then
      CUR_SWITCH=${OPTARG}
      OPTARG=""
    fi

    case ${CUR_SWITCH} in

       "C" ) __WRITE_CONFIG_AND_EXIT=${__TRUE} ;;

       "D" ) ProcessDebugSwitch "${OPTARG}"
             ;;

      "+v" ) __VERBOSE_MODE=${__FALSE}  ;;

       "v" ) __VERBOSE_MODE=${__TRUE} ; (( __VERBOSE_LEVEL=__VERBOSE_LEVEL+1 )) ;;

      "+q" ) __QUIET_MODE=${__FALSE} ;;

       "q" ) __QUIET_MODE=${__TRUE} ;;

      "+a" ) __USE_COLORS=${__FALSE} ;;

       "a" ) __USE_COLORS=${__TRUE} ;;

      "+O" ) __OVERWRITE_MODE=${__FALSE} ;;

       "O" ) __OVERWRITE_MODE=${__TRUE} ;;

       "f" ) __FORCE=${__TRUE} ;;

      "+f" ) __FORCE=${__FALSE} ;;

       "l" )
             __NEW_LOGFILE="${OPTARG:=nul}"
             [ "$( substr ${__NEW_LOGFILE} 1 1 )"x != "/"x ] && __NEW_LOGFILE="$PWD/${__NEW_LOGFILE}"
             ;;

      "+l" ) __NEW_LOGFILE="nul" ;;

      "+h" ) __VERBOSE_MODE=${__TRUE}
             __PRINT_USAGE=${__TRUE}
             ;;

       "h" ) __PRINT_USAGE=${__TRUE} ;;

       "T" ) : # parameter already processed
             ;;

       "H" )

echo " -----------------------------------------------------------------------------------------------------" >&2
echo " ${__SCRIPTNAME} ${__SCRIPT_VERSION} (Scripttemplate: ${__SCRIPT_TEMPLATE_VERSION})  ">&2
echo " Documentation" >&2
echo " -----------------------------------------------------------------------------------------------------" >&2

             grep "^##" "$0" | grep -v "##EXAMPLE##" | cut -c5- 1>&2
             die 0
             ;;

       "X" )

echo " -----------------------------------------------------------------------------------------------------" >&2
echo " ${__SCRIPTNAME} ${__SCRIPT_VERSION} ">&2
echo " Documentation" - Examples>&2
echo " -----------------------------------------------------------------------------------------------------" >&2

             T=$( grep "^##EXAMPLE##" "$0" | cut -c12- )
       eval T1="\"$T\""
       echo "$T1" 1>&2
             die 0
             ;;

       "V" ) LogMsg "Script version: ${__SCRIPT_VERSION}"
             if [ ${__VERBOSE_MODE} = ${__TRUE} ] ; then
               LogMsg "Script template version: ${__SCRIPT_TEMPLATE_VERSION}"
               if [ "${__CONFIG_FILE_FOUND}"x != ""x ] ; then
                 LogMsg "Script config file: \"${__CONFIG_FILE_FOUND}\""
                 LogMsg "Script config file version : ${__CONFIG_FILE_VERSION}"
               fi
             fi
             die 0
             ;;


      "+y" ) __USER_RESPONSE_IS="" ;;

       "y" ) __USER_RESPONSE_IS="y" ;;

      "+n" ) __USER_RESPONSE_IS="" ;;

       "n" ) __USER_RESPONSE_IS="n" ;;

       "S" ) case ${OPTARG} in

                0 | 1 | 2 | 3 ) __PRINT_SUMMARIES=${OPTARG}
                                    ;;

                * )  LogError "Unknown value for -S found: \"${OPTARG}\""
                      INVALID_PARAMETER_FOUND=${__TRUE}
                      ;;
                esac
                ;;


        "K" ) NOSTRICTKEYS=${__TRUE}  ;;

       "+K" ) NOSTRICTKEYS=${__FALSE}  ;;

        "R" ) RCM_SUPPORT=${__TRUE}  ;;

       "+R" ) RCM_SUPPORT=${__FALSE}  ;;

        "i" | "+i")
              if [ "${CUR_SWITCH}"x = "+i"x ] ; then
                HOSTFILE=""
                LogInfo "Parameter \"+i\" found hostlist set to an empty string again"
              fi
              for CUR_HOSTFILE in $( echo ${OPTARG} | tr "," " " ) ; do
                CUR_FIELD_SEPARATOR="${CUR_HOSTFILE#*:}"
                CUR_FILE_NAME="${CUR_HOSTFILE%%:*}"
                [ "${CUR_FILE_NAME}"x = "${CUR_FIELD_SEPARATOR}"x ] && CUR_FIELD_SEPARATOR="${FIELD_SEPARATOR}"

                if [ ${#CUR_FIELD_SEPARATOR} != 1 ] ; then
                  LogError "The field separator for the parameter \"-i (${CUR_FILE_NAME}:${CUR_FIELD_SEPARATOR})\" must be a single character"
                  INVALID_PARAMETER_FOUND=${__TRUE}
                fi
                HOSTFILE="${HOSTFILE},${CUR_HOSTFILE}"
              done
              LogInfo "Parameter \"-i ${OPTARG}\" processed, HOSTFILE is now \"${HOSTFILE}\" "
              ;;

        "s" ) [ "${SCRIPTFILE}"x != ""x ] && LogWarning "Parameter -s found more than once -- using only the last one"
              SCRIPTFILE="${OPTARG}" ;;

        "o" ) OUTPUTFILE="${OPTARG}"
              [ "${OUTPUTFILE}"x = "none"x ] && OUTPUTFILE=""
              ;;

        "u" ) ARG_KEY="${OPTARG%:*}" ; ARG_VALUE="${OPTARG#*:}"
              if [ "${ARG_KEY}"x = "${ARG_VALUE}"x ] ; then
                SSHUSER="${ARG_VALUE}"
              elif [ "${ARG_KEY}"x = "ssh"x ] ; then
                SSHUSER="${ARG_VALUE}"
              elif [ "${ARG_KEY}"x = "scp"x ] ; then
                SCPUSER="${ARG_VALUE}"
              else
                LogError "Invalid value for the parameter \"-u\" found: \"${OPTARG}\" (\"${ARG_KEY}\" is invalid)"
                INVALID_PARAMETER_FOUND=${__TRUE}
              fi
              ;;

        "c" ) case ${OPTARG} in
               "default" | "DEFAULT" )
                  SHELL_TO_USE="${DEFAULT_SHELL_TO_USE}"
                  ;;
               "none" | "NONE" )
                  SHELL_TO_USE=""
                  ;;
                *)
                  SHELL_TO_USE="${OPTARG}"
                  ;;
              esac
              ;;

        "k" ) ADD_COMMENTS=${__FALSE} ;;

       "+k" ) ADD_COMMENTS=${__TRUE} ;;

        "U" ) UNIQUE_LOGFILES=${__TRUE} ;;

       "+U" ) UNIQUE_LOGFILES=${__FALSE} ;;

        "B" ) DO_NOT_COPY_FILE=${__TRUE}
              SHELL_TO_USE=""
              ;;

       "+B" ) DO_NOT_COPY_FILE=${__FALSE} ;;

        "t" ) ARG_KEY="${OPTARG%%:*}" ; ARG_VALUE="${OPTARG#*:}"
              if [ "${ARG_KEY}"x = "${ARG_VALUE}"x ] ; then
                LogError "Invalid usage for the parameter \"-T\" found: \"${OPTARG}\" "
                INVALID_PARAMETER_FOUND=${__TRUE}
              elif [ "${ARG_KEY}"x = "ssh"x ] ; then
                if [ "${ARG_VALUE}"x = "default"x -o "${ARG_VALUE}"x = "none"x ] ; then
                  SSH_TEMPLATE="${DEFAULT_SSH_TEMPLATE}"
                else
                  SSH_TEMPLATE="${ARG_VALUE}"
                fi
              elif [ "${ARG_KEY}"x = "scp"x ] ; then
                if [ "${ARG_VALUE}"x = "default"x -o "${ARG_VALUE}"x = "none"x ] ; then
                  SCP_TEMPLATE="${DEFAULT_SCP_TEMPLATE}"
                else
                  SCP_TEMPLATE="${ARG_VALUE}"
                fi
              else
                LogError "Invalid value for the parameter \"-t\" found: \"${OPTARG}\" (\"${ARG_KEY}\" is invalid)"
                INVALID_PARAMETER_FOUND=${__TRUE}
              fi
              ;;

        "b" ) ARG_KEY="${OPTARG%%:*}" ; ARG_VALUE="${OPTARG#*:}"
              if [ "${ARG_KEY}"x = "${ARG_VALUE}"x ] ; then
                if [ "${ARG_VALUE}"x = "default"x -o "${ARG_VALUE}"x = "none"x ] ; then
                  SSH_KEYFILE=""
                  SCP_KEYFILE=""
                else
                  SSH_KEYFILE="${ARG_VALUE}"
                  SCP_KEYFILE="${ARG_VALUE}"
                fi
              elif [ "${ARG_KEY}"x = "ssh"x ] ; then
                if [ "${ARG_VALUE}"x = "default"x -o "${ARG_VALUE}"x = "none"x ] ; then
                  SSH_KEYFILE=""
                else
                  SSH_KEYFILE="${ARG_VALUE}"
                fi
              elif [ "${ARG_KEY}"x = "scp"x ] ; then
                if [ "${ARG_VALUE}"x = "default"x -o "${ARG_VALUE}"x = "none"x ] ; then
                  SCP_KEYFILE=""
                else
                  SCP_KEYFILE="${ARG_VALUE}"
                fi
              else
                LogError "Invalid value for the parameter \"-b\" found: \"${OPTARG}\" (\"${ARG_KEY}\" is invalid)"
                INVALID_PARAMETER_FOUND=${__TRUE}
              fi
              ;;

        "I" ) FILE_BASEDIR="${OPTARG}" ;;

        "p" ) SCP_OPTIONS="${SCP_OPTIONS}  ${OPTARG}" ;;

        "P" ) SSH_OPTIONS="${SSH_OPTIONS}  ${OPTARG}" ;;

       "+p" ) SCP_OPTIONS="${OPTARG}" ;;

       "+P" ) SSH_OPTIONS="${OPTARG}" ;;

        "d" ) EXECUTE_PARALLEL=${__TRUE} ;;

       "+d" ) EXECUTE_PARALLEL=${__FALSE} ;;

        "W" ) TIMEOUT_PARAMETER="${OPTARG}" 
              ;;

        "w" ) START_TIMEOUT_PARAMETER="${OPTARG}"  ;;


        "A" ) if [ "${OPTARG}"x = "none"x ] ; then
                INLCUDE_HOSTS=""
                continue
              fi

              INCLUDE_HOSTS="${INCLUDE_HOSTS},${OPTARG}"
              ;;

        "x" ) if [ "${OPTARG}"x = "none"x ] ; then
                EXCLUDE_HOSTS=""
                continue
              fi

              pos "/" "${OPTARG}"
              if [ $? -ne 0 ] ; then
                CUR_FIELD_SEPARATOR="${OPTARG#*:}"
                CUR_FILE_NAME="${OPTARG%%:*}"
                [ "${CUR_FILE_NAME}"x = "${CUR_FIELD_SEPARATOR}"x ] && CUR_FIELD_SEPARATOR="${FIELD_SEPARATOR}"

                if [ ${#CUR_FIELD_SEPARATOR} != 1 ] ; then
                  LogError "The field separator for the parameter \"-x ${OPTARG}\" (${CUR_FIELD_SEPARATOR}) must be one character only"
                  INVALID_PARAMETER_FOUND=${__TRUE}
                fi

                IGONRE_MISSING_FILE=${__FALSE}
                if [ "${CUR_FILE_NAME#*\?}"x != "${CUR_FILE_NAME}"x ] ; then
                  CUR_FILE_NAME="${CUR_FILE_NAME#*?}"
                  IGONRE_MISSING_FILE=${__TRUE}
                fi

                if [ ! -r "${CUR_FILE_NAME}" ] ; then
                  if [ ${IGONRE_MISSING_FILE} = ${__TRUE} ] ; then
                    LogWarning "Host exclude file \"${CUR_FILE_NAME}\" not found or not readable -- the file will be ignored."
                  else
                    LogError "Can NOT read the host exclude file \"${CUR_FILE_NAME}\" (Parameter \"-x ${OPTARG}\")"
                    INVALID_PARAMETER_FOUND=${__TRUE}
                  fi
                else
                  EXCLUDE_HOSTS="${EXCLUDE_HOSTS}, $( ${EGREP} -v "^$|^#" "${CUR_FILE_NAME}" | cut -f1 -d "${CUR_FIELD_SEPARATOR}"  )"
                fi
              else
                EXCLUDE_HOSTS="${EXCLUDE_HOSTS},${OPTARG}"
              fi
              ;;


        "e" ) if [ "${OPTARG}"x = "none"x ] ; then
                FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS=""
              else
                FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS="${OPTARG}"
              fi
              ;;

        \? ) LogError "Unknown parameter found: \"${OPTARG}\" "
             INVALID_PARAMETER_FOUND=${__TRUE}
             break
          ;;

         * ) LogError "Unknown parameter found: \"${CUR_SWITCH}\""
             INVALID_PARAMETER_FOUND=${__TRUE}
             break ;;

    esac
  done

  case ${__PRINT_SUMMARIES} in
     0 )  __PRINT_LIST_OF_WARNINGS_MSGS=${__FALSE}
          __PRINT_LIST_OF_ERROR_MSGS=${__FALSE}
          ;;

    1 )   __PRINT_LIST_OF_WARNINGS_MSGS=${__FALSE}
          __PRINT_LIST_OF_ERROR_MSGS=${__TRUE}
          ;;

    2 )   __PRINT_LIST_OF_WARNINGS_MSGS=${__TRUE}
          __PRINT_LIST_OF_ERROR_MSGS=${__FALSE}
          ;;

    3 )   __PRINT_LIST_OF_WARNINGS_MSGS=${__TRUE}
          __PRINT_LIST_OF_ERROR_MSGS=${__TRUE}
          ;;

    * ) : this should never happen but who knows ...
          __PRINT_LIST_OF_WARNINGS_MSGS=${__FALSE}
          __PRINT_LIST_OF_ERROR_MSGS=${__FALSE}
  esac


if [ 0 = 1 ] ; then
  while true ;do
    printf "Enter command to execute: "
    read USER_INPUT
    eval $USER_INPUT
  done
  
  exit 0
  
fi

  LogRuntimeInfo "Parameter after processing the default parameter are: " "\"$*\" "

  if [ ${__PRINT_USAGE} = ${__TRUE} ] ; then
    if [ ${__VERBOSE_MODE} -eq ${__TRUE} ] ; then
      ShowUsage
      __VERBOSE_MODE=${__FALSE}
    else
      ShowShortUsage
      LogMsg "Use \"-v -h\", \"-v -v -h\", \"-v -v -v -h\" or \"+h\" for a long help text"
    fi
    die 1
  fi


  shift $(( OPTIND - 1 ))

  NOT_PROCESSED_PARAMETER="$*"

  LogRuntimeInfo "Not processed parameter: \"${NOT_PROCESSED_PARAMETER}\""

  if [ "${NOT_PROCESSED_PARAMETER}"x != ""x ] ; then
    if [ $# -ne 0 ] ; then
      CUR_FIELD_SEPARATOR="${1#*:}"
      CUR_FILE_NAME="${1%%:*}"
      [ "${CUR_FILE_NAME}"x = "${CUR_FIELD_SEPARATOR}"x ] && CUR_FIELD_SEPARATOR="${FIELD_SEPARATOR}"
      if [ ${#CUR_FIELD_SEPARATOR} != 1 ] ; then
        LogError "The field separator for the parameter \"hostfile\" (${CUR_FILE_NAME}:${CUR_FIELD_SEPARATOR}) must be one character only"
        INVALID_PARAMETER_FOUND=${__TRUE}
      fi
      HOSTFILE="$1"
      shift
    fi

    if [ $# -ne 0 ] ; then
      SCRIPTFILE="$1"
      shift
    fi

    if [ $# -ne 0 ] ; then
      OUTPUTFILE="$1"
      shift
    fi

    if [ $# -ne 0 ] ; then
      SSHUSER="$1"
      shift
    fi

    NOT_PROCESSED_PARAMETER=""
  fi

  if [ ${__LOG_DEBUG_MESSAGES} != ${__TRUE} ] ; then
    rm "${__DEBUG_LOGFILE}" 2>/dev/null 1>/dev/null
    __DEBUG_LOGFILE=""
  else
    echo 2>/dev/null >>"${__DEBUG_LOGFILE}" || \
      die 237 "Can not write to the debug log file \"${__DEBUG_LOGFILE}\" "
  fi

#
# set INVALID_PARAMETER_FOUND to ${__TRUE} if the script
# should abort due to an invalid parameter
#
  if [ "${NOT_PROCESSED_PARAMETER}"x != ""x ] ; then
    LogError "Unknown parameter found: \"${NOT_PROCESSED_PARAMETER}\" "
    INVALID_PARAMETER_FOUND=${__TRUE}
  fi

  if [ "${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}"x != ""x ] ; then
    LogInfo "Checking write access to the file \"${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}\" ..."

    CUR_OUTPUT="$( exec 2>&1 ; \rm -f  "${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}" ; touch "${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}" )"
    if [ $? -ne 0 ] ; then
      LogMsg "-" "${CUR_OUTPUT}"
      LogError "Can not write to the file \"${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}\" "
      INVALID_PARAMETER_FOUND=${__TRUE}     
    fi
  fi
    
  if [ "${START_TIMEOUT_PARAMETER}"x != ""x ] ; then

    oIFS="${IFS}" ; IFS="," ; set -- $( echo "${START_TIMEOUT_PARAMETER}" | tr "/" "," )  ; V1="$1" ; V2="$2"; V3="$3"; IFS="${oIFS}"
    MAX_NO_OF_BACKGROUND_PROCESSES=${V1:=${MAX_NO_OF_BACKGROUND_PROCESSES}}
    START_PROC_WAIT_INTERVALL=${V2:=${START_PROC_WAIT_INTERVALL}}
    START_PROC_TIMEOUT=${V3:=${START_PROC_TIMEOUT}}

    [ "${MAX_NO_OF_BACKGROUND_PROCESSES}"x = "default"x ] && MAX_NO_OF_BACKGROUND_PROCESSES="${DEFAULT_MAX_NO_OF_BACKGROUND_PROCESSES}"
    [ "${START_PROC_WAIT_INTERVALL}"x = "default"x      ] && START_PROC_WAIT_INTERVALL="${DEFAULT_START_PROC_WAIT_INTERVALL}"
    [ "${START_PROC_TIMEOUT}"x = "default"x             ] && START_PROC_TIMEOUT="${DEFAULT_START_PROC_TIMEOUT}"

    [ "${MAX_NO_OF_BACKGROUND_PROCESSES}"x = "none"x ] && MAX_NO_OF_BACKGROUND_PROCESSES="-1"
    [ "${START_PROC_TIMEOUT}"x = "none"x             ] && START_PROC_TIMEOUT="-1"

    if [ "${MAX_NO_OF_BACKGROUND_PROCESSES}"x != "-1"x  ] ; then
      isNumber "${MAX_NO_OF_BACKGROUND_PROCESSES}"
      if [ $? -ne 0 ] ; then
        LogError "Invalid parameter found: The value for the number of parallel background processes (${MAX_NO_OF_BACKGROUND_PROCESSES}) is not a number"
        LogError "This is the 1st value for the parameter -w"
        INVALID_PARAMETER_FOUND=${__TRUE}
      fi
    fi

    CalculateSeconds "${START_PROC_WAIT_INTERVALL}" START_PROC_WAIT_INTERVALL_IN_SEC
    if [ $? -ne 0 ] ; then
      LogError "Invalid parameter found: The value for wait intervall (${START_PROC_WAIT_INTERVALL}) for starting the background processes is not a number"
      LogError "This is the 2nd value for the parameter -w"
      INVALID_PARAMETER_FOUND=${__TRUE}
    fi

    if [ "${START_PROC_TIMEOUT}"x != "-1"x  ] ; then
      CalculateSeconds "${START_PROC_TIMEOUT}" START_PROC_TIMEOUT_IN_SEC
      if [ $? -ne 0 ] ; then
        LogError "Invalid parameter found: The value for the timeout for starting the parallel background processes (${START_PROC_TIMEOUT}) is not a number"
        LogError "This is the 3rd value for the parameter -w"
        INVALID_PARAMETER_FOUND=${__TRUE}
      fi
    fi

  fi

  if [ "${SSH_SCP_CMD_TIMEOUT}"x != ""x ] ; then
    LogMsg "The environment variable SSH_SCP_CMD_TIMEOUT is defined (SSH_SCP_CMD_TIMEOUT is \"${SSH_SCP_CMD_TIMEOUT}\")"
    CalculateSeconds "${SSH_SCP_CMD_TIMEOUT}" SSH_SCP_CMD_TIMEOUT_IN_SEC
    if [ $? -eq ${__TRUE} ] ; then
      LogMsg "The ssh/scp timeout defined in the variable SSH_SCP_CMD_TIMEOUT is ${SSH_SCP_CMD_TIMEOUT_IN_SEC} seconds"

      TIMEOUT_PARAMETER_FOUND=${__TRUE}
      MAX_RUN_WAIT_TIME_IN_SEC=${SSH_SCP_CMD_TIMEOUT_IN_SEC}
    else
      LogError "The value for timeout in the variable SSH_SCP_CMD_TIMEOUT (${SSH_SCP_CMD_TIMEOUT}) is not a number"
      INVALID_PARAMETER_FOUND=${__TRUE}
    fi
  fi

  if [ "${TIMEOUT_PARAMETER}"x != ""x ] ; then

    oIFS="${IFS}" ; IFS="," ; set -- $( echo "${TIMEOUT_PARAMETER}" | tr "/" "," )  ; V1="$1" ; V2="$2"; IFS="${oIFS}"
    
    if [ "${V1}"x != ""x ] ;then
      TIMEOUT_PARAMETER_FOUND=${__TRUE}
      if [ "${SSH_SCP_CMD_TIMEOUT}"x != ""x ] ;then
        LogWarning "The value of the parameter \"-W\" (${V1}) will overwrite the value of the environment variable SSH_SCP_CMD_TIMEOUT (${SSH_SCP_CMD_TIMEOUT})"
      fi
    fi
    
    [ "${V2}"x != ""x ] && INTERVALL_PARAMETER_FOUND=${__TRUE}

    MAX_RUN_WAIT_TIME=${V1:=${MAX_RUN_WAIT_TIME}}
    RUN_WAIT_INTERVALL=${V2:=${RUN_WAIT_INTERVALL}}

    [ "${MAX_RUN_WAIT_TIME}"x = "default"x  ] && MAX_RUN_WAIT_TIME="${DEFAULT_MAX_RUN_WAIT_TIME}"
    [ "${RUN_WAIT_INTERVALL}"x = "default"x ] && RUN_WAIT_INTERVALL="${DEFAULT_RUN_WAIT_INTERVALL}"

    [ "${MAX_RUN_WAIT_TIME}"x = "none"x ] && MAX_RUN_WAIT_TIME="-1"

    if [ "${MAX_RUN_WAIT_TIME}"x != "-1"x  ] ; then
      CalculateSeconds "${MAX_RUN_WAIT_TIME}" MAX_RUN_WAIT_TIME_IN_SEC
      if [ $? -ne 0 ] ; then
        LogError "Invalid parameter found: The value for timeout (${MAX_RUN_WAIT_TIME}) is not a number"
        LogError "This is the 1st value for the parameter -W"
        INVALID_PARAMETER_FOUND=${__TRUE}
      else
        SSH_SCP_CMD_TIMEOUT_IN_SEC=${MAX_RUN_WAIT_TIME_IN_SEC}
      fi
    fi

    CalculateSeconds "${RUN_WAIT_INTERVALL}" RUN_WAIT_INTERVALL_IN_SEC
    if [ $? -ne 0 ] ; then
      LogError "Invalid parameter found: The value for timeout (${RUN_WAIT_INTERVALL}) is not a number"
      LogError "This is the 2nd value for the parameter -W"
      INVALID_PARAMETER_FOUND=${__TRUE}
    fi
  fi

# use defaults if necessary

  [ "${START_PROC_WAIT_INTERVALL_IN_SEC}"x = ""x ] && CalculateSeconds ${START_PROC_WAIT_INTERVALL} START_PROC_WAIT_INTERVALL_IN_SEC
  [ "${START_PROC_TIMEOUT_IN_SEC}"x = ""x ] && CalculateSeconds ${START_PROC_TIMEOUT} START_PROC_TIMEOUT_IN_SEC
  [ "${MAX_RUN_WAIT_TIME_IN_SEC}"x = ""x ] && CalculateSeconds ${MAX_RUN_WAIT_TIME} MAX_RUN_WAIT_TIME_IN_SEC
  [ "${RUN_WAIT_INTERVALL_IN_SEC}"x = ""x ] && CalculateSeconds ${RUN_WAIT_INTERVALL} RUN_WAIT_INTERVALL_IN_SEC

  echo "${THIS_PARAMETER}" | grep "${SED_SEP}" >/dev/null
  if [ $? -eq 0 ] ; then
    LogError "The pipe character \"${SED_SEP}\" is NOT allowed in any parameter"
    INVALID_PARAMETER_FOUND=${__TRUE}
  fi

# exit the program if there are one or more invalid parameter
#
  if [ ${INVALID_PARAMETER_FOUND} -eq ${__TRUE} ] ; then
    LogError "One or more invalid parameters found"
    ShowShortUsage
    die 2
  fi

  SetEnvironment

# create the PID file (if requested)
#
  if [ "${__PIDFILE}"x != ""x ] ; then
    LogRuntimeInfo "Writing the PID $$ to the PID file \"${__PIDFILE}\" ..."
    echo $$>"${__PIDFILE}" && __LIST_OF_TMP_FILES="${__LIST_OF_TMP_FILES} ${__PIDFILE}" || \
      LogWarning "Can not write the pid to the PID file \"${__PIDFILE}\" "
  fi

# restore the language setting
#
  LANG=${__SAVE_LANG}
  export LANG

# -----------------------------------------------------------------------------

# check for RCM support
  if [ ${RCM_SUPPORT} = ${__TRUE} ] ; then

    COPY_TABLE_PARAMETER=""
    [ ! -x "${COPY_TABLE_BINARY}" ] && die 3 "RCM support requested but copy_table.pl was not found"
    while [ "${RCM_USERID}"x  = ""x ] ; do
      push ${__USER_RESPONSE_IS}
      __USER_RESPONSE_IS=""
      AskUser "Please enter the RCM userid (none<return> to disable RCM support): "
      pop __USER_RESPONSE_IS
      if [ "${USER_INPUT}"x = "none"x ] ; then
        LogMsg "RCM support disabled."
        RCM_SUPPORT=${__FALSE}
        break
      else
        RCM_USERID="${USER_INPUT}"
      fi
    done

    if [ "${RCM_USERID}"x != ""x ] ; then
      while [ "${RCM_PASSWORD}"x  = ""x ] ; do
        push ${__USER_RESPONSE_IS}
        push __NOECHO
        __NOECHO=${__TRUE}
        __USER_RESPONSE_IS=""
        AskUser "Please enter the RCM password (none<return> to disable RCM support): "
        pop __NOECHO
        pop __USER_RESPONSE_IS
        echo ""
        if [ "${USER_INPUT}"x = "none"x ] ; then
          LogMsg "RCM support disabled."
          RCM_SUPPORT=${__FALSE}
          break
        else
          RCM_PASSWORD="${USER_INPUT}"
        fi
      done
    fi

    if [ ${RCM_SUPPORT} = ${__TRUE} ] ; then

      [ "${RCM_USERID}"x != ""x ] && COPY_TABLE_PARAMETER="${COPY_TABLE_PARAMETER} -u ${RCM_USERID} "
      [ "${RCM_PASSWORD}"x != ""x ] && COPY_TABLE_PARAMETER="${COPY_TABLE_PARAMETER} -p ${RCM_PASSWORD} "

      if [ "${RCM_SERVER}"x != ""x ] ; then
        COPY_TABLE_PARAMETER="${COPY_TABLE_PARAMETER} -S ${RCM_SERVER}"
      fi

      LogMsg "Checking RCM access ...."
      TEMPVAR=$( ${COPY_TABLE_BINARY} ${COPY_TABLE_PARAMETER} -t RCM.USER_VW -q "USERID=\"${RCM_USERID}\" " )
      [ "${TEMPVAR}"x = ""x ] && die 4 "Error accessing the RCM!"
    fi
  fi

# -----------------------------------------------------------------------------

  LogInfo "Config file version is: \"${__CONFIG_FILE_VERSION}\" "

# print all internal variables
#
  if [ 1 = 0 ] ; then
    for i in $( set | grep "^__" | cut -f1 -d"=" ) ; do
     if [[ $i != __COLOR* ]] ; then
        echo "$i : \"$( eval echo \"\$$i\" )\" "
      else
         echo "$i is set "
      fi
    done
  fi


# "


# -----------------------------------------------------------------------------
# print script environment

  if [ ${__VERBOSE_MODE} = ${__TRUE} ] ; then
    LogMsg "-"
    LogMsg "----------------------------------------------------------------------"
    LogMsg "Scriptname is \"${__SCRIPTNAME}\" "
    LogMsg "Scriptversion is \"${__SCRIPT_VERSION}\" "
    LogMsg "Script template version is \"${__SCRIPT_TEMPLATE_VERSION}\" "
    LogMsg " "
    LogMsg "OS is \"${__OS}\" (Fullname: \"${__OS_FULLNAME}\") "
    LogMsg "OS Version is \"${__OS_VERSION}\" "
    LogMsg "OS Release is \"${__OS_RELEASE}\" "
    LogMsg "The current shell is \"${__SHELL}\"; this shell is compatible to ksh${__KSH_VERSION}"
    LogMsg "The userid running this script is \"${__USERID}\""
    LogMsg ""
    LogMsg "The PID of this process is $$"
    LogMsg ""
    LogMsg "The script hashtag is \"${__HASHTAG}\""
    LogMsg "The shell in the hashtag is \"${__SCRIPT_SHELL}\" "
    LogMsg "The shell options in the hashtag are \"${__SCRIPT_SHELL_OPTIONS}\" "
    LogMsg "----------------------------------------------------------------------"
    LogMsg ""
  fi

# -----------------------------------------------------------------------------

# defined Log routines:
#
# LogMsg
# LogInfo
# LogWarning
# LogError
# LogOnly
# LogIfNotVerbose
# PrintDotToSTDOUT

  PARAMETER_OKAY=${__TRUE}

  KNOWN_HOST_FILE_EDITED=${__FALSE}

  HOSTFILE_LIST=""
  INVALID_HOSTS_LIST=""
  HOSTS_WITH_RC_NOT_ZERO=""
 
  HOSTS_WITH_ERRORS=""
  
  HOSTS_FAILED=""
  HOSTS_PROCESSED=""
  
  LogInfo "Hostlist file(s) found are: \"${HOSTFILE_LIST}\""
  LogInfo "Now checking the hostlist files ...."

  if [ "${HOSTFILE}"x = ""x -a "${INCLUDE_HOSTS}"x = ""x ] ; then
    PARAMETER_OKAY=${__FALSE}
    LogError "Parameter \"-i\" for hostlist and \"-a\" not specified - one of them is mandatory"
  else
    for CURFILE_X in $( echo ${HOSTFILE} | tr -s "," " " ) ; do
      LogInfo "  Checking the file ${CURFILE_X} ..."
      CURFILE="${CURFILE_X%%:*}"

      if [ "${CURFILE#*\?}"x != "${CURFILE}"x ] ; then
        CURFILE="${CURFILE#*?}"
        IGONRE_MISSING_FILE=${__TRUE}
      else
        IGONRE_MISSING_FILE=${__FALSE}
      fi
      if [ ! -r "${CURFILE}" ] ; then
        if [ "${FILE_BASEDIR}" != ""x -a ! -r "${FILE_BASEDIR}/${CURFILE}" ] ; then
          if [ ${IGONRE_MISSING_FILE} = ${__FALSE} ] ; then
            LogError "Can not read the hostlist file \"${CURFILE}\" "
            PARAMETER_OKAY=${__FALSE}
          else
            LogWarning "Hostlist file \"${CURFILE}\" not found or not readable"
          fi
        else
          HOSTFILE_LIST="${HOSTFILE_LIST} ${FILE_BASEDIR}/${CURFILE_X}"
        fi
      else
        HOSTFILE_LIST="${HOSTFILE_LIST} ${CURFILE_X}"
      fi
    done
  fi
  LogInfo "Hostlist file(s) found are: \"${HOSTFILE_LIST}\""

  if [ "${HOSTFILE_LIST}"x = ""x -a "${INCLUDE_HOSTS}"x = ""x ] ; then
    PARAMETER_OKAY=${__FALSE}
    LogError "No hostlist file found and no hostname specified on the command line"
  fi

  EXCLUDE_HOSTS="$( echo "${EXCLUDE_HOSTS}" | tr "," " " )"
  HOSTS_EXCLUDED=""

  if [[ ${INCLUDE_HOSTS} == *\** || ${INCLUDE_HOSTS} == *\?* ]] ; then
    PARAMETER_OKAY=${__FALSE}
    LogError "Regular expressions for the parameter \"-i\" are NOT allowed."
  else
    INCLUDE_HOSTS="$( echo "${INCLUDE_HOSTS}" | tr "," " " | tr " " "\n" )"
  fi

  if [ "${SCRIPTFILE}"x = ""x ] ; then
    PARAMETER_OKAY=${__FALSE}
    LogError "Scriptfile not specified (parameter \"-s\")"
  elif [ ${DO_NOT_COPY_FILE} = ${__FALSE} ] ; then
    if [ ! -r "${SCRIPTFILE}"  ] ; then
      if [ "${FILE_BASEDIR}" != ""x -a ! -r "${FILE_BASEDIR}/${SCRIPTFILE}" ] ; then
        PARAMETER_OKAY=${__FALSE}
        LogError "Scriptfile \"${SCRIPTFILE}\" not found or not readable"
      else
        SCRIPTFILE="${FILE_BASEDIR}/${SCRIPTFILE}"
      fi
    fi
  fi

  if [ -r "${SCRIPTFILE}" -a ! -x "${SCRIPTFILE}" ] ; then
    chmod 755 "${SCRIPTFILE}" || LogWarning "Can not change the permissions for \"${SCRIPTFILE}\""
  fi

  if [ "${NEW_SSH_BINARY}"x != ""x ] ; then
    if [ ! -x "${NEW_SSH_BINARY}" ] ; then
      LogError "The ssh binary \"${NEW_SSH_BINARY}\" does not exist or is not executable."
      PARAMETER_OKAY=${__FALSE}
    else
      SSH_BINARY="${NEW_SSH_BINARY}"
    fi
  fi

  if [ "${NEW_SCP_BINARY}"x != ""x ] ; then
    if [ ! -x "${NEW_SCP_BINARY}" ] ; then
      LogError "The scp binary \"${NEW_SCP_BINARY}\" does not exist or is not executable."
      PARAMETER_OKAY=${__FALSE}
    else
      SCP_BINARY="${NEW_SCP_BINARY}"
    fi
  fi

  if [ "${NEW_SSH_KEYGEN_BINARY}"x != ""x ] ; then
    if [ ! -x "${NEW_SSH_KEYGEN_BINARY}" ] ; then
      LogError "The ssh-keygen binary \"${NEW_SSH_KEYGEN_BINARY}\" does not exist or is not executable."
      PARAMETER_OKAY=${__FALSE}
    else
      SSH_KEYGEN_BINARY="${NEW_SSH_KEYGEN_BINARY}"
    fi
  fi

  if [ "${NEW_DOS2UNIX_BINARY}"x != ""x ] ; then
    if [ ! -x "${NEW_DOS2UNIX_BINARY}" ] ; then
      LogError "The ssh binary \"${NEW_DOS2UNIX_BINARY}\" does not exist or is not executable."
      PARAMETER_OKAY=${__FALSE}
    else
      DOS2UNIX_BINARY="${NEW_DOS2UNIX_BINARY}"
    fi
  fi

  if [ "${NEW_NAMESERVER}"x != ""x ] ; then
    if [[ ${NEW_NAMESERVER} != @* ]] ; then
      CUR_NAMESERVER="@${NEW_NAMESERVER}"
    else
      CUR_NAMESERVER="${NEW_NAMESERVER}"
    fi
  fi

# do not use a shell for binaries
#
  if [ "${SCRIPTFILE}"x != ""x ] ; then
    if [ -r "${SCRIPTFILE}" ] ; then
      file "${SCRIPTFILE}" | ${EGREP} " LSB | MSB " >/dev/null && SHELL_TO_USE=""
    fi
  fi

# do not use a shell if -B is used
#
  if [ ${DO_NOT_COPY_FILE} = ${__TRUE} ] ; then
    SHELL_TO_USE=""
  fi

# convert the file using dos2unix if running in a cygwin session
#
  if [[ ${__OS} == CYGWIN*  ]] ; then
    if [ "${DO_NOT_COPY_FILE}" = ${__FALSE} -a ${IS_SCRIPT_FILE} = ${__TRUE}  ] ; then
      if [ "${DOS2UNIX_BINARY}"x != ""x ] ; then
        LogMsg "Calling dos2unix for the script file \"${SCRIPTFILE}\" "
        ${DOS2UNIX_BINARY} "${SCRIPTFILE}"
      else
        LogWarning "This script is running in a cygwin session but dos2unix is not found in the PATH - can not convert the script file"
      fi
    fi
  fi

  if [ "${SSH_KEYFILE}"x != ""x ] ; then
    if [ ! -r "${SSH_KEYFILE}" ] ; then
      PARAMETER_OKAY=${__FALSE}
      LogError "ssh keyfile \"${SSH_KEYFILE}\" not found or not readable"
    fi
  fi

  if [ "${SCP_KEYFILE}"x != ""x ] ; then
    if [ ! -r "${SCP_KEYFILE}" ] ; then
      PARAMETER_OKAY=${__FALSE}
      LogError "scp keyfile \"${SCP_KEYFILE}\" not found or not readable"
    fi
  fi

  if [ "${OUTPUTFILE}"x = ""x ] ; then
    OUTPUTFILE="${__SCRIPTNAME}.$$.log"
  elif [ -d "${OUTPUTFILE}" ] ; then
    OUTPUTFILE="${OUTPUTFILE}/${__SCRIPTNAME}.$$.log"
  fi

  [ "${OUTPUTFILE%/*}"x = "${OUTPUTFILE}"x ] && OUTPUTFILE="./${OUTPUTFILE}"
  OUTPUTFILE="$( cd "${OUTPUTFILE%/*}" ; pwd )/${OUTPUTFILE##*/}"

  if [ -r "${OUTPUTFILE}" -a ! -f "${OUTPUTFILE}" ] ; then
    PARAMETER_OKAY=${__FALSE}
    LogError "The outputfile \"${OUTPUTFILE}\" (parameter -o) is not a file"
  fi

  if [ "${SCPUSER}"x = ""x ] ; then
    SCPUSER="${SSHUSER}"
    [ "${SSH_KEYFILE}"x != ""x -a "${SCP_KEYFILE}"x = ""x ] && SCP_KEYFILE="${SSH_KEYFILE}"
  fi

  if [ "${SSHUSER}"x = ""x ] ; then
    PARAMETER_OKAY=${__FALSE}
    LogError "ssh user not specified and no default value found"
  fi

  [ ${PARAMETER_OKAY} != ${__TRUE} ] && die 5 "Errors found - exiting."

  if [ ${NOSTRICTKEYS} =  ${__TRUE} ] ; then
  
    [ "${SSH_SCP_CMD_TIMEOUT_IN_SEC}"x = ""x ] && SSH_SCP_CMD_TIMEOUT_IN_SEC=${DEFAULT_GLOBAL_SSH_SCP_CMD_TIMEOUT}

    SCP_OPTIONS="${SCP_OPTIONS} -o StrictHostKeyChecking=no "
    SSH_OPTIONS="${SSH_OPTIONS} -o StrictHostKeyChecking=no "
    if [ ${EXECUTE_PARALLEL} = ${__TRUE} ] ; then
      SCP_OPTIONS="${SCP_OPTIONS}  -o NumberOfPasswordPrompts=0 -o ConnectTimeout=${SSH_SCP_CMD_TIMEOUT_IN_SEC} -o BatchMode=yes -o PasswordAuthentication=no"
      SSH_OPTIONS="${SSH_OPTIONS}  -o NumberOfPasswordPrompts=0 -o ConnectTimeout=${SSH_SCP_CMD_TIMEOUT_IN_SEC} -o BatchMode=yes -o PasswordAuthentication=no"
    fi
  fi

  LogMsg ""
  [ "${SHELL_TO_USE}"x = ""x ] && MSG1="executable" || MSG1="script"
  if [ "${DO_NOT_COPY_FILE}" = ${__FALSE} ] ; then
    TARGET_COMMAND="/tmp/tmp_$$_$( basename $0 )"
    LogMsg "Executing the ${MSG1} "
    LogMsg "    ${SCRIPTFILE}"
  else
    TARGET_COMMAND="${SCRIPTFILE}"
    LogMsg "Executing the command "
    LogMsg "    ${SCRIPTFILE}"
  fi

  [ "${SSH_KEYFILE}"x != ""x ] && ADD_MSG="( The ssh key file to use is \"${SSH_KEYFILE}\" )" || ADD_MSG="(using the default ssh key file)"
  LogMsg "as ssh user "
  LogMsg "    ${SSHUSER} ${ADD_MSG}"

  if [ "${HOSTFILE_LIST}"x != ""x ] ; then
    LogMsg "on every host listed in the file(s) "

    for CUR_HOSTFILE in ${HOSTFILE_LIST} ; do
      CUR_FIELD_SEPARATOR="${CUR_HOSTFILE#*:}"
      CUR_FILE_NAME="${CUR_HOSTFILE%%:*}"
      [ "${CUR_FILE_NAME}"x = "${CUR_FIELD_SEPARATOR}"x ] && CUR_FIELD_SEPARATOR="${FIELD_SEPARATOR}"
      LogMsg "    ${CUR_FILE_NAME} (the field separator is \"${CUR_FIELD_SEPARATOR}\") "
    done

    if [ "${INCLUDE_HOSTS}"x != ""x ] ; then
      LogMsg "and on each of these hosts:"
      for CUR_HOST in ${INCLUDE_HOSTS} ; do
        LogMsg "    ${CUR_HOST}"
      done
    fi
  else
    LogMsg "and on each of these hosts:"
    for CUR_HOST in ${INCLUDE_HOSTS} ; do
      LogMsg "    ${CUR_HOST}"
    done
  fi

  if [ "${DO_NOT_COPY_FILE}" = ${__FALSE} ] ; then
    [ "${SCP_KEYFILE}"x != ""x ] && ADD_MSG="( The scp key file to use is \"${SCP_KEYFILE}\" )" || ADD_MSG="(using the default ssh key file)"
    LogMsg "The scp user to copy the files is "
    LogMsg "    ${SCPUSER} ${ADD_MSG}"
  fi


  if [ "${EXCLUDE_HOSTS}"x != ""x ] ; then
    LogMsg ""
    LogMsg "Hosts to exclude are: "
    for CUR_HOST in ${EXCLUDE_HOSTS} ; do
      LogMsg "    ${CUR_HOST}"
    done
  fi

  if [ ${DO_NOT_SORT_HOSTLIST}  = ${__TRUE} ] ; then
    LogMsg "The list of hosts will be used without modifications"
  fi

  if [ ${IGNORE_USER_IN_FILE} = ${__TRUE} ] ; then
    LogMsg "The users from the hostlists will be ignored."
  fi

  if [ "${SHELL_TO_USE}"x != ""x ] ; then
    LogMsg ""
    LogMsg "The shell to execute the command is "
    LogMsg "    ${SHELL_TO_USE}"
    LogMsg ""
  else
    LogMsg ""
    LogMsg "The shell to execute the command is "
    LogMsg "    the default shell of the user \"${SSHUSER}\" "
    LogMsg ""
  fi

  LogMsg "Using the ssh binary \"${SSH_BINARY}\"."
  LogMsg "Using the scp binary \"${SCP_BINARY}\"."
  if [[ ${__OS} == CYGWIN*  ]] ; then
    LogMsg "Using the dos2unix binary \"${DOS2UNIX_BINARY}\"."
  fi

  if [ "${SCP_OPTIONS}"x != ""x ] ; then
    LogMsg "The additional options for scp are:"
    LogMsg "    ${SCP_OPTIONS}"
  fi

  if [ "${SSH_OPTIONS}"x != ""x ] ; then
    LogMsg "The additional options for ssh are:"
    LogMsg "    ${SSH_OPTIONS}"
  fi

  LogMsg "The template for scp commands used is:"
  LogMsg "    ${SCP_TEMPLATE}"

  LogMsg "The template for ssh commands used is:"
  LogMsg "    ${SSH_TEMPLATE}"

#  if [ "${SSH_KEYFILE}"x != ""x ] ; then
#    LogMsg "Using the ssh keyfile "
#    LogMsg "    ${SSH_KEYFILE}"
#  fi

#  if [ "${SCP_KEYFILE}"x != ""x ] ; then
#    LogMsg "Using the scp keyfile "
#    LogMsg "    ${SCP_KEYFILE}"
#  fi


  if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
    LogMsg "The output of the commands will be logged in the file"
    LogMsg "    ${OUTPUTFILE}"
  else
    LogMsg "The output of the commands will be logged in the files"
    LogMsg "    ${OUTPUTFILE}.<hostname>"
  fi

  LogMsg ""
  if [ ${RCM_SUPPORT} = ${__TRUE} ] ; then
    LogMsg "RCM support is used (The RCM Userid is \"${RCM_USERID}\")"
  else
    LogMsg "RCM support is not used"
  fi


  if [ ${EXECUTE_PARALLEL} = ${__TRUE} ] ; then
    LogMsg ""
    LogMsg "The scp/ssh processes will run parallel in the background."
    LogMsg ""
    LogMsg "The maximum number of parallel background processes is ${MAX_NO_OF_BACKGROUND_PROCESSES} (Parameter -w ${MAX_NO_OF_BACKGROUND_PROCESSES},x,x -1 = not limited)."
    LogMsg "  The wait intervall for starting the background processes is ${START_PROC_WAIT_INTERVALL_IN_SEC} second(s) (Parameter -w x,${START_PROC_WAIT_INTERVALL},x); "
    LogMsg "  the timeout for starting the background processes is ${START_PROC_TIMEOUT_IN_SEC} second(s) (Parameter -w x,x,${START_PROC_TIMEOUT} -1 = not limited)."
    LogMsg ""
    LogMsg "Waiting up to ${MAX_RUN_WAIT_TIME_IN_SEC} second(s) for the background processes to finish (Parameter -W ${MAX_RUN_WAIT_TIME},x, -1 = not limited)."
    LogMsg "  The wait intervall for waiting for the background processes to finish is ${RUN_WAIT_INTERVALL_IN_SEC} second(s) (Parameter -W x,${RUN_WAIT_INTERVALL} )"
    LogMsg ""
  else
    LogMsg ""
    LogMsg "The scp/ssh processes will run sequential one after the other."
    if [ "${PREFIX}"x != ""x ] ; then
      LogMsg "CAUTION: dry run mode is activated - no scp or ssh commands are executed!"
    fi

    TIMEOUT_PREFIX=""
    WAIT_TIME_BETWEEN_THE_SSH_CMDS=""

    if [ ${TIMEOUT_PARAMETER_FOUND} = ${__TRUE} ] ; then

      if [ "${MAX_RUN_WAIT_TIME_IN_SEC}"x != ""x -a "${MAX_RUN_WAIT_TIME_IN_SEC}"x != "-1"x  ] ; then
  
        TIMEOUT="$( whence timeout 2>/dev/null )"
        if [ "${TIMEOUT}"x = ""x ] ; then
          die 44 "Timeout parameter for found but the executable \"timeout\" is not available via the PATH"
        fi
        LogMsg "Timeout value for the sequential ssh/scp commands is ${MAX_RUN_WAIT_TIME_IN_SEC} seconds"
        TIMEOUT_PREFIX="${TIMEOUT} --foreground --preserve-status ${MAX_RUN_WAIT_TIME_IN_SEC} "
      fi
    fi

    if [ ${INTERVALL_PARAMETER_FOUND} = ${__TRUE} ] ; then

      if [ "${RUN_WAIT_INTERVALL}"x != ""x -a "${RUN_WAIT_INTERVALL}"x != "-1"x ] ; then
        LogMsg "The intervall between the scp/ssh commands for each machine is ${RUN_WAIT_INTERVALL} seconds"
        WAIT_TIME_BETWEEN_THE_SSH_CMDS=${RUN_WAIT_INTERVALL}
      fi
      
      LogMsg ""
    fi
  fi

  if [ ${SINGLE_STEP} = ${__TRUE} ] ; then
    if [ ${EXECUTE_PARALLEL} = ${__TRUE} ] ; then
      LogWarning "The parameter \"-D singlestep\" is not valid for parallel execution"
    else
      LogMsg "The scp and ssh commands will be executed in single step mode."
    fi
  fi

  check_SSH_agent_status
  if [ "${SSH_AGENT_RUNNING}" != "${__TRUE}" ] ; then
    LogMsg ""
    LogWarning "ssh-agent seems not to run or not to be configured"
  fi

  if [ "${DO_NOT_COPY_FILE}" = ${__FALSE} ] ; then
    LogMsg ""
    LogInfo "The temporary file on the hosts is \"${TARGET_COMMAND}\" "
  fi

  if [ "${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}"x != ""x ] ; then
    LogMsg ""
    LogMsg "The list of hosts with errors executing the script will be written to the file \"${FILE_FOR_THE_LIST_OF_HOSTS_WITH_ERRORS}\" "
  fi

  LogMsg ""

  TEMP_LIST=""
  LogInfo "Now reading the hostlist files ..."
  for CUR_HOSTFILE in ${HOSTFILE_LIST} ; do
    CUR_FIELD_SEPARATOR="${CUR_HOSTFILE#*:}"
    CUR_FILE_NAME="${CUR_HOSTFILE%%:*}"
    [ "${CUR_FILE_NAME}"x = "${CUR_FIELD_SEPARATOR}"x ] && CUR_FIELD_SEPARATOR="${FIELD_SEPARATOR}"

    LogInfo "  Reading the file \"${CUR_FILE_NAME}\", the field separator is \"${CUR_FIELD_SEPARATOR}\" "
    TEMP_LIST="${TEMP_LIST} $( cat "${CUR_FILE_NAME}"  | ${SED} -e "s/\r//g" -e "s/[ \t]/ /g"  -e "s/^[[:space:]]*//g"  |  ${EGREP} -v  "^$|^#" | cut -f1 -d "${CUR_FIELD_SEPARATOR}"  )"
  done
  TEMP_LIST="$( echo ${TEMP_LIST} )"

  if [ ${DO_NOT_SORT_HOSTLIST}  = ${__TRUE} ] ; then
    LIST_OF_HOSTS_TO_PROCESS="$( echo "${TEMP_LIST}" "${INCLUDE_HOSTS}" )"
  else
    LIST_OF_HOSTS_TO_PROCESS="$( echo "${TEMP_LIST}" "${INCLUDE_HOSTS}" | sort | uniq )"
  fi

# remove empty lines  
  LIST_OF_HOSTS_TO_PROCESS="$( echo "${LIST_OF_HOSTS_TO_PROCESS}" | ${EGREP} -v "^$|^[ ]*$" )"
  
  if [ "${TEMP_LIST}"x = ""x ] ; then
    NO_OF_HOSTS=0
    die 11 "There are ${NO_OF_HOSTS} hosts to process"
  else
    NO_OF_HOSTS="$( echo "${LIST_OF_HOSTS_TO_PROCESS}" | tr "\t" " " | tr -s " " | tr " " "\n"  | wc -l | tr -d " " )"
  fi
  
  LogMsg "There are ${NO_OF_HOSTS} hosts to process"
  LogMsg ""

  while true ; do
    AskUser "Okay (y/N, list<return> to list all hosts to process; q<return> or CTRL-C to exit)?"
    if [ $? -eq ${__FALSE} ] ; then
      if [  "${USER_INPUT}"x = "list"x ] ; then
        LogMsg "The hosts to process are:"
        LogMsg "-" "${LIST_OF_HOSTS_TO_PROCESS}"
      else
        __FORCE=${__FALSE}
        LogMsg "-"
        die 10 "Script aborted by the user"
      fi
    else
      break
    fi
  done

  HOST_PROCESSING_STARTED=${__TRUE}

  if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
    BackupFileIfNecessary "${OUTPUTFILE}"
    set +o noclobber
    if [ ${__OVERWRITE_MODE} = ${__TRUE} ] ; then
      echo >"${OUTPUTFILE}" || die 15 "Can not write to the output file \"${OUTPUTFILE}\" "
    fi
  fi

  if [ ${SCP_WITH_FORWARD_AGENT_ENABLED} = ${__TRUE} ] ; then
    LogDebugMsg "Creating the wrapper script for enabling agent forwarding for scp ..."
    echo "${ENABLE_FORWARD_AGENT_FOR_SCP_CODE}" >"${SSH_WRAPPER_FOR_SCP}" && chmod 755 "${SSH_WRAPPER_FOR_SCP}"
    if [ $? -ne 0 ] ; then
      die 48 "Can not create the wrapper for ssh: ${SSH_WRAPPER_FOR_SCP}"
    else
      __LIST_OF_TMP_FILES="${__LIST_OF_TMP_FILES} ${SSH_WRAPPER_FOR_SCP}"
    fi
  fi

  if [ ${DO_NOT_COPY_FILE} = ${__FALSE} ] ; then
    LogInfo "Setting the read permissions for the script \"${SCRIPTFILE}\" ..."
    chmod +r "${SCRIPTFILE}" || \
      LogWarning "Error $? calling \"chmod +r\" for the file \"${SCRIPTFILE}\" "
  fi

  if [ "${SSH_KEYFILE}"x != ""x ] ; then
     SSH_KEY_PARM="-i ${SSH_KEYFILE}"
  else
     SSH_KEY_PARM=""
  fi

  if [ "${SCP_KEYFILE}"x != ""x ] ; then
     SCP_KEY_PARM="-i ${SCP_KEYFILE}"
  else
     SCP_KEY_PARM=""
  fi

  PROCESSING_STARTED=${__TRUE}

  typeset -i COUNT=0

  if [ ${CLEAN_KNOWN_HOSTS} = ${__TRUE} -o ${DELETE_KNOWN_HOSTS} = ${__TRUE} ] ; then
    LogMsg "Cleanup or delete known_hosts is enabled - creating a backup of the existing known_hosts file \"${KNOWN_HOSTS_FILE}\" in \"${KNOWN_HOSTS_FILE_BACKUP}\" ..."
    cp "${KNOWN_HOSTS_FILE}" "${KNOWN_HOSTS_FILE_BACKUP}"
    if [ $? -ne 0 ] ; then
      LogError "Error creating the backup -- disabling cleanup known_hosts and deleting the known_hosts now"
      CLEAN_KNOWN_HOSTS=${__FALSE}
      DELETE_KNOWN_HOSTS=${__FALSE}
    else
      KNOWN_HOST_FILE_EDITED=${__TRUE}
    
      if [ ${DELETE_KNOWN_HOSTS} = ${__TRUE} ] ; then
        LogMsg "Now deleting all entries from the known hosts file \"${KNOWN_HOSTS_FILE}\" ..."
        CUR_OUTPUT="$( echo >"${KNOWN_HOSTS_FILE}" 2>&1 )"
        if [ $? -ne 0 ] ; then
          LogMsg "-" "${CUR_OUTPUT}"
          LogError "Error removing all entries from the file \"${KNOWN_HOSTS_FILE}\" "
        fi
      fi
    fi
    
  fi
  
  LogMsg "Starting processing ..."

  if [ ${EXECUTE_PARALLEL} = ${__TRUE} ] ; then
:
    STOP_STARTING=${__FALSE}

    if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
      TMP_OUTPUT_DIR="${__TEMPDIR}/${__SCRIPTNAME}.$$.TEMPDIR"
      mkdir -p "${TMP_OUTPUT_DIR}" || die 55 "Can not create the temporary output directory \"${TMP_OUTPUT_DIR}\" "
      LogMsg "The directory for the temporary output files is \"${TMP_OUTPUT_DIR}\" "
    fi

    PROCS=""
    BACKGROUND_PIDS=""
    typeset -i NO_OF_PROCS_STARTED=0
    typeset -i OVERALL_START_TIME=0

    typeset -i MINUTES
    typeset -i SECONDS
    typeset -i HOURS

    for THIS_HOST in ${LIST_OF_HOSTS_TO_PROCESS} ; do

      retrieve_ssh_and_scp_user "${THIS_HOST}"
      host_on_the_exclude_list "${CUR_HOST}"
      if [ $? -eq ${__TRUE} ] ; then
        LogMsg "++++ The host \"${CUR_HOST}\" is on the exclude list. Ignoring this host."
        continue
      fi

      NO_OF_RUNNING_PIDS=$( GetNumberOfRunningProcesses ${BACKGROUND_PIDS} )

      LogMsg "  Number of running processes are: ${NO_OF_RUNNING_PIDS}"

      if [ "${MAX_NO_OF_BACKGROUND_PROCESSES}"x != "-1"x ] ; then
        typeset -i START_WAIT_TIME=0
        while [ ${NO_OF_RUNNING_PIDS} -ge ${MAX_NO_OF_BACKGROUND_PROCESSES} ] ; do
          if [ "${START_PROC_TIMEOUT_IN_SEC}"x != "-1"x ] ; then
            if [ ${START_WAIT_TIME} -gt ${START_PROC_TIMEOUT_IN_SEC} ] ; then
              LogWarning "Maximum startup time (${START_PROC_TIMEOUT_IN_SEC} seconds) reached - will NOT start the processes for the other hosts!"
              INVALID_HOSTS_LIST="${INVALID_HOSTS_LIST} ${LIST_OF_HOSTS_TO_PROCESS#*${CUR_HOST}}"

              HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}
$( echo "${LIST_OF_HOSTS_TO_PROCESS#*${CUR_HOST}}" | tr " " "\n" | sed "s/$/ maximum number of background processes reached/g" )
"
              STOP_STARTING=${__TRUE}
              break
            fi
          fi
          LogMsg "  Maximum number of background processes (${MAX_NO_OF_BACKGROUND_PROCESSES}) reached."

          if [ "${START_PROC_TIMEOUT_IN_SEC}"x != "-1"x ] ; then
            (( REMAINING_WAIT_TIME = START_PROC_TIMEOUT_IN_SEC - START_WAIT_TIME ))
            LogMsg "Waiting for ${START_PROC_WAIT_INTERVALL_IN_SEC} second(s) now (total wait time until now: ${START_WAIT_TIME} seconds; max. timeout is ${START_PROC_TIMEOUT_IN_SEC} seconds ; remaining wait time is ${REMAINING_WAIT_TIME} seconds) ..."
          else
            LogMsg "Waiting for ${START_PROC_WAIT_INTERVALL_IN_SEC} second(s) now (total wait time until now: ${START_WAIT_TIME} seconds)"
          fi

          sleep ${START_PROC_WAIT_INTERVALL_IN_SEC}
          (( START_WAIT_TIME = START_WAIT_TIME +  START_PROC_WAIT_INTERVALL_IN_SEC ))
          (( OVERALL_START_TIME = OVERALL_START_TIME + START_PROC_WAIT_INTERVALL_IN_SEC ))

          LogMsg "  Resuming starting further processes ..."
          NO_OF_RUNNING_PIDS=$( GetNumberOfRunningProcesses ${BACKGROUND_PIDS} )

        done
        [ ${STOP_STARTING} = ${__TRUE} ] && break
      fi

      (( COUNT = COUNT + 1 ))
      LogMsg  "  ---- Processing \"${CUR_HOST}\" (ssh user is \"${CUR_SSH_USER}\") ... ( ${COUNT} from ${NO_OF_HOSTS}; ${NO_OF_PROCS_STARTED} already started) "

      if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
        CUR_OUTPUTFILE="${TMP_OUTPUT_DIR}/${CUR_HOST}.log"
        echo >"${CUR_OUTPUTFILE}" ; THISRC=$?
        if [ ${THISRC} -ne 0 ] ; then
          LogError "Can not write to the logfile \"${CUR_OUTPUTFILE}\" -- skipping the host \"${CUR_HOST}\" "
          INVALID_HOSTS_LIST="${INVALID_HOSTS_LIST} ${CUR_HOST}"

          HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}          
${CUR_HOST} # can not write the logfile \"${CUR_OUTPUTFILE}\""

          continue
        fi
      else
        CUR_OUTPUTFILE="${OUTPUTFILE}.${CUR_HOST}"
        BackupFileIfNecessary "${CUR_OUTPUTFILE}"
        if [ ${__OVERWRITE_MODE} = ${__TRUE} ] ; then
          echo >"${CUR_OUTPUTFILE}" ; THISRC=$?
        else
          touch "${CUR_OUTPUTFILE}" ; THISRC=$?
        fi
        if [ ${THISRC} -ne 0 ] ; then
          LogError "Can not write to the logfile \"${CUR_OUTPUTFILE}\" -- skipping the host \"${CUR_HOST}\" "
          INVALID_HOSTS_LIST="${INVALID_HOSTS_LIST} ${CUR_HOST}"

          HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}          
${CUR_HOST} # can not write the logfile \"${CUR_OUTPUTFILE}\""

          continue
        fi
      fi

      get_curhost_interface "${CUR_HOST}"
      if [ ${CLEAN_KNOWN_HOSTS} = ${__TRUE} ] ; then
        
        CUR_HOST_IP="$( dig ${CUR_NAMESERVER} "${CUR_HOST}" +short 2>/dev/null )"
        if [ "${CUR_HOST_INTERFACE}"x != ""x ] ; then
          Remove_host_from_known_hosts_file "${CUR_HOST_INTERFACE}" 
          [ $? -eq ${__FALSE} ] && die 80 "Error removing the host from the known_hosts file"
        else
          Remove_host_from_known_hosts_file "${CUR_HOST}"
          [ $? -eq ${__FALSE} ] && die 80 "Error removing the host from the known_hosts file"
        fi
      fi

      CUR_SSH_COMMAND=$( evaluate_template "ssh" )
      CUR_SCP_COMMAND=$( evaluate_template "scp" )

#          "${PREFIX}" "${SCP_BINARY}" ${SCP_OPTIONS} ${SCP_KEY_PARM} "${SCRIPTFILE}" "${CUR_SCP_USER}@${CUR_HOST_INTERFACE}:${TARGET_COMMAND}" && \
#          "${PREFIX}" "${SSH_BINARY}" ${SSH_OPTIONS} ${SSH_KEY_PARM} -l "${CUR_SSH_USER}" "${CUR_HOST_INTERFACE}" ${SHELL_TO_USE} ${TARGET_COMMAND} ; \

#          "${PREFIX}" "${SSH_BINARY}" ${SSH_OPTIONS} ${SSH_KEY_PARM} -l "${CUR_SSH_USER}" "${CUR_HOST_INTERFACE}" ${SHELL_TO_USE} ${TARGET_COMMAND}  ; \

      if [ ${DO_NOT_COPY_FILE} = ${__FALSE} ] ; then

        [ ${PRINT_CMD} = ${__TRUE} ] && LogMsg "The scp command is: ${CUR_SCP_COMMAND}"
        [ ${PRINT_CMD} = ${__TRUE} ] && LogMsg "The ssh command is: ${CUR_SSH_COMMAND}"
        
        ( [ ${ADD_COMMENTS} = ${__TRUE} ] && echo "# ### ---- Log of the script \"${SCRIPTFILE}\" executed on host \"${CUR_HOST}\" as user \"${CUR_SSH_USER}\" at $( date ) --- start ---"  ; \
            echo "*** Executing ${CUR_SCP_COMMAND} " ; \
            echo "" ; \
            ${PREFIX} ${CUR_SCP_COMMAND} && \
            echo "### ${CUR_HOST} # scp RC=$?" ; \
            echo "" ; \
            echo "*** Executing ${CUR_SSH_COMMAND}: " ; \
            echo "" ; \
            ${PREFIX} ${CUR_SSH_COMMAND} ; \
            echo "### ${CUR_HOST} # ssh RC=$?" ; \
            echo "" ; \
          [ ${ADD_COMMENTS} = ${__TRUE} ] && echo "# ### ---- Log of the script executed on host \"${CUR_HOST}\" as user \"${CUR_SSH_USER}\" at $( date ) --- end ---"  ) >>"${CUR_OUTPUTFILE}" 2>&1 &
      else
        [ ${PRINT_CMD} = ${__TRUE} ] && LogMsg "The ssh command is: ${CUR_SSH_COMMAND}"

        ( [ ${ADD_COMMENTS} = ${__TRUE} ] && echo "# ### ---- Log of the command \"${SCRIPTFILE}\" executed on host \"${CUR_HOST}\" as user \"${CUR_SSH_USER}\" at $( date ) --- start ---"  ; \
            echo "*** Executing ${CUR_SSH_COMMAND}: " ; \
            echo "" ; \
            ${PREFIX} ${CUR_SSH_COMMAND} ; \
            echo "### ${CUR_HOST} # ssh RC=$?" ; \
            echo "" ; \
          [ ${ADD_COMMENTS} = ${__TRUE} ] && echo "# ### ---- Log of the command executed on host \"${CUR_HOST}\" as user \"${CUR_SSH_USER}\" at $( date ) --- end ---"  ) >>"${CUR_OUTPUTFILE}" 2>&1 &
      fi

      (( NO_OF_PROCS_STARTED = NO_OF_PROCS_STARTED + 1 ))

      [ "${PROCS}"x = ""x ] && PROCS="${CUR_HOST}#${!}#${CUR_OUTPUTFILE}" || PROCS="${CUR_HOST}#${!}#${CUR_OUTPUTFILE};${PROCS}"
      LogInfo "  command started via ssh on ${CUR_HOST}; the process PID=$! started at $( date )"
      [ "${BACKGROUND_PIDS}"x = ""x ] && BACKGROUND_PIDS="$!" || BACKGROUND_PIDS="${BACKGROUND_PIDS} $!"

    done

    (( SECONDS = OVERALL_START_TIME % 60 ))
    (( MINUTES = OVERALL_START_TIME / 60 ))
    if [ ${MINUTES} -gt 59 ] ; then
      (( HOURS = MINUTES / 60 ))
      (( MINUTES = MINUTES % 60 ))
    else
      HOURS=0
    fi

    LogMsg "The loop to start the ${NO_OF_PROCS_STARTED} background processes ended at $( date ), the runtime is $( printf "%d:%.2d:%.2d" ${HOURS} ${MINUTES} ${SECONDS} )."

    LogInfo "Starting the wait loop with PROCS=\"$PROCS\" "

# now wait for the ssh processes to finish
#
    LogMsg ""
    LogMsg "Starting the loop to wait for the background processes at $( date ) ..."
    LogMsg "  Waiting up to ${MAX_RUN_WAIT_TIME_IN_SEC} seconds for the background processes to finish ..."

    typeset -i RUN_WAIT_TIME=0
    typeset PROC_LOG_FILES=""

    while true ; do

      if [ "${MAX_RUN_WAIT_TIME_IN_SEC}"x != "-1"x ] ; then
        [ ${RUN_WAIT_TIME} -ge ${MAX_RUN_WAIT_TIME_IN_SEC} ] && break
      fi

      [ "${PROCS}"x = ""x ] && break

      LogInfo "  PROCS loop starts here ..."
      STILL_RUNNING_PROCS=""
      NO_OF_STILL_RUNNING_PROCS=0

      NO_OF_RUNNING_PIDS=$( GetNumberOfRunningProcesses ${BACKGROUND_PIDS} )

      case ${NO_OF_RUNNING_PIDS} in
        0 ) LogInfo "All processes finished at loop start." ;;
        1 ) LogInfo "There is still ${NO_OF_RUNNING_PIDS} process running at loop start:" ;;
        * ) LogInfo "There are still ${NO_OF_RUNNING_PIDS} processes running at loop start:" ;;
      esac

      while [ "${PROCS}"x != ""x ]; do
        CUR_PROC_LINE="${PROCS%%;*}"
        PROCS="${PROCS#*;}"
        [ "${PROCS}"x = "${CUR_PROC_LINE}"x  -o "${PROCS}"x = ";"x ] && PROCS=""

        CUR_HOST="${CUR_PROC_LINE%%#*}"
        CUR_OUTPUT_FILE="${CUR_PROC_LINE##*#}"
        CUR_PID=${CUR_PROC_LINE#*#} ; CUR_PID=${CUR_PID%%#*}

        LogInfo "    PROCS: \"${PROCS}\" "
        LogInfo "    CUR_PROC_LINE: \"${CUR_PROC_LINE}\" "
        LogInfo "    CUR_OUTPUT_FILE: \"${CUR_OUTPUT_FILE}\" "
        LogInfo "    CUR_HOST: \"${CUR_HOST}\" "
        LogInfo "    CUR_PID: \"${CUR_PID}\" "

        PS_P_OUTPUT="$( ps -p ${CUR_PID} 2>&1 )"
        if [ $? -eq 0 ] ; then
          [ "${STILL_RUNNING_PROCS}"x = ""x ] && STILL_RUNNING_PROCS="${CUR_PROC_LINE}" || STILL_RUNNING_PROCS="${STILL_RUNNING_PROCS};${CUR_PROC_LINE}"
          LogMsg "    Process \"${CUR_PID}\" for ${CUR_HOST} is still running"
          (( NO_OF_STILL_RUNNING_PROCS = NO_OF_STILL_RUNNING_PROCS + 1 ))
          continue
        else
          LogMsg "    Process \"${CUR_PID}\" for ${CUR_HOST} finished"
          PROC_LOG_FILES="${PROC_LOG_FILES} ${CUR_OUTPUT_FILE}"
        fi

      done

      PROCS="${STILL_RUNNING_PROCS}"
      if [ "${PROCS}"x != ""x ] ; then
        [ ${NO_OF_STILL_RUNNING_PROCS} = 1 ] && \
          LogMsg "  ${NO_OF_STILL_RUNNING_PROCS} background process (from ${NO_OF_PROCS_STARTED}) is still running" || \
          LogMsg "  ${NO_OF_STILL_RUNNING_PROCS} background processes (from ${NO_OF_PROCS_STARTED}) are still running"
        if [ "${MAX_RUN_WAIT_TIME_IN_SEC}x" != "-1"x ] ; then
          (( REMAINING_WAIT_TIME = MAX_RUN_WAIT_TIME_IN_SEC - RUN_WAIT_TIME ))

          LogMsg "  Waiting for ${RUN_WAIT_INTERVALL_IN_SEC} second(s) now (total wait time until now: ${RUN_WAIT_TIME} seconds; max. timeout is ${MAX_RUN_WAIT_TIME_IN_SEC} seconds ; remaining wait time is ${REMAINING_WAIT_TIME} seconds) ..."
        else
          LogMsg "  Waiting for ${RUN_WAIT_INTERVALL_IN_SEC} second(s) now (total wait time until now: ${RUN_WAIT_TIME} seconds)"
        fi

        sleep ${RUN_WAIT_INTERVALL_IN_SEC}
        (( RUN_WAIT_TIME = RUN_WAIT_TIME + RUN_WAIT_INTERVALL_IN_SEC ))
      fi
    done

    (( SECONDS = RUN_WAIT_TIME % 60 ))
    (( MINUTES = RUN_WAIT_TIME / 60 ))
    if [ ${MINUTES} -gt 59 ] ; then
      (( HOURS = MINUTES / 60 ))
      (( MINUTES = MINUTES % 60 ))
    else
      HOURS=0
    fi

    LogMsg "The loop to wait for the background processes ended at $( date ), the runtime is $( printf "%d:%.2d:%.2d" ${HOURS} ${MINUTES} ${SECONDS} )."
    LogMsg ""

    if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
      LogMsg "Collecting the result logs ..."

      for CUR_LOG_FILE in ${PROC_LOG_FILES} ; do
        LogMsg "  Processing \"${CUR_LOG_FILE}\" ..."

        if [ -r "${CUR_LOG_FILE}" ] ; then

#
# check for scp errors
#
          CUR_LINE="$( grep "scp RC=" "${CUR_LOG_FILE}" 2>/dev/null )"
          if [[ ${CUR_LINE} != "" && ${CUR_LINE} != *RC=0* ]] ; then          
            CUR_SSH_ERROR_MESSAGE="$( grep "ssh:" "${CUR_LOG_FILE}" | tr -d "\r" | head -1  )"
            CUR_HOST="$( echo "${CUR_LINE}" | cut   -f2 -d " " )"
            CUR_RC="$( echo "${CUR_LINE}" | cut -f4- -d " " )"
            HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}
${CUR_HOST} # ${CUR_SSH_ERROR_MESSAGE} # ${CUR_RC}"
          else
#
# check for ssh errors
#
            CUR_LINE="$( grep "ssh RC=" "${CUR_LOG_FILE}" 2>/dev/null )"
            if [[ ${CUR_LINE} != "" && ${CUR_LINE} != *RC=0* ]] ; then
              CUR_SSH_ERROR_MESSAGE="$( grep "ssh:" "${CUR_LOG_FILE}" | tr -d "\r" | tail -1 )"
              CUR_HOST="$( echo "${CUR_LINE}" | cut -f2 -d " " )"
              CUR_RC="$( echo "${CUR_LINE}" | cut -f4- -d " " )"
              HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}
${CUR_HOST} # ${CUR_SSH_ERROR_MESSAGE} # ${CUR_RC}" 
            fi
          fi

          executeCommand cat "${CUR_LOG_FILE}" >>"${OUTPUTFILE}"
        else
          LogError "Logfile \"${CUR_LOG_FILE}\" not found or not readable"
        fi
      done
    fi

  else
  
# --------- execute the script sequential

    typeset -i COUNT=0

    HOSTS_IGNORED_ON_USER_REQUEST=""
    HOSTS_PROCESSED=""

    HOSTS_FAILED=""
    
    for THIS_HOST in ${LIST_OF_HOSTS_TO_PROCESS} ; do

      if [ ${COUNT} != 0 -a "${WAIT_TIME_BETWEEN_THE_SSH_CMDS}"x != ""x ] ; then
        LogMsg "Waiting ${WAIT_TIME_BETWEEN_THE_SSH_CMDS} seconds now ..."
        sleep ${WAIT_TIME_BETWEEN_THE_SSH_CMDS}
      fi

      retrieve_ssh_and_scp_user "${THIS_HOST}"

      host_on_the_exclude_list "${CUR_HOST}"
      if [ $? -eq ${__TRUE} ] ; then
        LogMsg "++++ The host \"${CUR_HOST}\" is on the exclude list. Ignoring this host."
        continue
      fi

      [ "${PREFIX}"x != ""x ] && ADD_MSG="(running in dry run mode)" || ADD_MSG=""
      if [ ${SINGLE_STEP} = ${__TRUE} ] ; then
         LogMsg "-" "Press <return> to continue with the host \"${CUR_HOST}\" ${ADD_MSG}"

         push ${__USER_RESPONSE_IS}
         __USER_RESPONSE_IS=""
         AskUser "(<s><return> to skip this host, <g><return> to end single step mode, or <q><return> to end the processing) >> "
         pop __USER_RESPONSE_IS

         if [ "${USER_INPUT}"x = "s"x ] ; then
           LogMsg "Skipping the host \"${CUR_HOST}\" ..."
           HOSTS_IGNORED_ON_USER_REQUEST="${HOSTS_IGNORED_ON_USER_REQUEST} ${CUR_HOST}"
           continue
         elif [ "${USER_INPUT}"x = "g"x ] ; then
           LogMsg "Deactivating single step mode."
           SINGLE_STEP=${__FALSE}
         elif [ "${USER_INPUT}"x = "q"x ] ; then
           LogMsg "-"
           LogMsg "Script aborted by the user"
           break
         else
           LogMsg "-"
         fi
       fi

      (( COUNT = COUNT + 1 ))
      HOSTS_PROCESSED="${HOSTS_PROCESSED} ${CUR_HOST}"

      LogMsg "-"
      LogMsg  "---- Processing \"${CUR_HOST}\" (ssh user is \"${CUR_SSH_USER}\", scp user is \"${CUR_SCP_USER}\")  ... ( ${COUNT} from ${NO_OF_HOSTS}) "

      if [ ${UNIQUE_LOGFILES} = ${__FALSE} ] ; then
        CUR_OUTPUTFILE="${OUTPUTFILE}"
      else
        CUR_OUTPUTFILE="${OUTPUTFILE}.${CUR_HOST}"
        BackupFileIfNecessary "${CUR_OUTPUTFILE}"
        if [ ${__OVERWRITE_MODE} = ${__TRUE} ] ; then
          echo >"${CUR_OUTPUTFILE}" ; THISRC=$?
        else
          touch "${CUR_OUTPUTFILE}" ; THISRC=$?
        fi
        if [ ${THISRC} -ne 0 ] ; then
          LogError "Can not write to the logfile \"${CUR_OUTPUTFILE}\" -- skipping the host \"${CUR_HOST}\" "
          INVALID_HOSTS_LIST="${INVALID_HOSTS_LIST} ${CUR_HOST}"

          HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}          
${CUR_HOST} # can not write the logfile \"${CUR_OUTPUTFILE}\""

          continue
        fi
      fi

      get_curhost_interface "${CUR_HOST}"

      if [ ${CLEAN_KNOWN_HOSTS} = ${__TRUE} ] ; then
  
        CUR_HOST_IP="$( dig ${CUR_NAMESERVER} "${CUR_HOST}" +short 2>/dev/null )"
        if [ "${CUR_HOST_INTERFACE}"x != ""x ] ; then
          Remove_host_from_known_hosts_file "${CUR_HOST_INTERFACE}" 
          [ $? -eq ${__FALSE} ] && die 80 "Error removing the host from the known_hosts file"
        else
          Remove_host_from_known_hosts_file "${CUR_HOST}"
          [ $? -eq ${__FALSE} ] && die 80 "Error removing the host from the known_hosts file"
        fi

      fi

      CUR_SSH_COMMAND="$( evaluate_template "ssh" )"
      CUR_SCP_COMMAND="$( evaluate_template "scp" )"

      if [ ${DO_NOT_COPY_FILE} = ${__FALSE} ] ; then
#        executeCommand "${PREFIX}" "${SCP_BINARY}" "${SCP_OPTIONS}" "${SCP_KEY_PARM}" "${SCRIPTFILE}" "${CUR_SCP_USER}@${CUR_HOST_INTERFACE}:${TARGET_COMMAND}"

        [ ${PRINT_CMD} = ${__TRUE} ] && LogMsg "The scp command is: ${PREFIX} ${TIMEOUT_PREFIX} ${CUR_SCP_COMMAND}"
    
        CUR_OUTPUT="$( ${PREFIX} ${TIMEOUT_PREFIX} ${CUR_SCP_COMMAND} 2>&1 )"
        TEMPRC=$?

        echo "${CUR_OUTPUT}" >>"${CUR_OUTPUTFILE}"

        if [ ${DO_NOT_LOG_SSH_COMMANDS_IN_LOGFILE} = ${__TRUE} ] ; then
          echo "${CUR_OUTPUT}" 
        else
          LogMsg "-" "${CUR_OUTPUT}" 
        fi

        if [ ${TEMPRC} -ne 0 ] ; then
          LogError "Error copying the script to the host \"${CUR_HOST}\" - could not execute the script on that host"
          INVALID_HOSTS_LIST="${INVALID_HOSTS_LIST} ${CUR_HOST}"
          
          HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}          
${CUR_HOST} # can not copy the script to the host using scp"

          continue
        fi
      fi

      if [ ${ADD_COMMENTS} = ${__TRUE} ] ; then
        echo "# ### ---- Log of the script \"${SCRIPTFILE}\" executed on the host \"${CUR_HOST}\" --- start ---" >>"${CUR_OUTPUTFILE}"
      fi

      [ ${PRINT_CMD} = ${__TRUE} ] && LogMsg "The ssh command is: ${PREFIX} ${TIMEOUT_PREFIX} ${CUR_SSH_COMMAND} "

      CUR_OUTPUT="$( ${PREFIX} ${TIMEOUT_PREFIX} ${CUR_SSH_COMMAND}  2>&1 )"
      TEMPRC=$?
      echo "${CUR_OUTPUT}" >>"${CUR_OUTPUTFILE}"
      
      if [ ${DO_NOT_LOG_SSH_COMMANDS_IN_LOGFILE} = ${__TRUE} ] ; then
        echo "${CUR_OUTPUT}" 
      else
        LogMsg "-" "${CUR_OUTPUT}" 
      fi
      
      if [ ${TEMPRC} -ne 0 ] ; then
        LogWarning "The RC of the ssh command is ${TEMPRC}"
        HOSTS_WITH_RC_NOT_ZERO="${HOSTS_WITH_RC_NOT_ZERO} ${CUR_HOST}"

        HOSTS_WITH_ERRORS="${HOSTS_WITH_ERRORS}          
${CUR_HOST} # the script on the host ended with RC=${TEMPRC}"

      fi

      if [ ${ADD_COMMENTS} = ${__TRUE} ] ; then
        echo "# ### ---- Log of the script \"${SCRIPTFILE}\" executed on the host \"${CUR_HOST}\" --- end ---" >>"${CUR_OUTPUTFILE}"
        echo "" >>"${CUR_OUTPUTFILE}"
      fi

    done
  fi

  die ${__MAINRC}

exit

# -----------------------------------------------------------------------------

