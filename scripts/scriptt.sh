#!/usr/bin/ksh
#
# ---------------------------------------------------------------------
# ****  Note: The main code starts after the line containing "# main:" ****
#             The main code for your script should start after "# main - your code"
#
# Additional jump targets:
#
#   #main          main code
#   #mit           init main function
#   #svd           set variable defaults
#   #uds           user defined sub routines
#   #auh           add. usage help
#   #udf           user defined functions
#   #udp           user defined parameter
#
# ---------------------------------------------------------------------
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
# Copyright 2006-2019 Bernd Schemmer  All rights reserved.
# Use is subject to license terms.
#
# Notes:
#
# - use "scriptt.sh {-v} {-v} {-v} -h" to get the usage help
#
# - replace "scriptt.sh" with the name of your script
# - change the parts marked with "???" and "??" to your need
#
# - use "scriptt.sh -H 2>scriptt.sh.doc" to get the documentation
#
# - use "scriptt.sh -X 2>scriptt.sh.examples.doc" to get some usage
#   examples for the script
#
# - use "scriptt.sh -D SyntaxHelp 2>scriptt.sh.syntaxhelp.doc" to
#   print usage examples for the functions defined in the template
#
# - this is a Kornshell script - it may not function correctly in other shells
# - the script was written and tested with ksh88 but should also work in ksh93
#   The script should also work in bash -- but that is not completly tested
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
##EXAMPLE## # Note: The variable __CREATE_DUMP can also be set with the debug parameter -D create_dump, e.g.
##EXAMPLE##
##EXAMPLE##    ${__SCRIPTNAME} -D create_dump=/var/tmp/debug 
##EXAMPLE##

# other usage examples (in another format because of the special handling of the parameter -X )

__OTHER_USAGE_EXAMPLES='

# use logger instead of echo to print the messages

  LOGMSG_FUNCTION="logger -s -p user.info ./scriptt.sh" ./scriptt.sh

# Use -D setvar:varname=varvalue to set the value for one or more variables

    ./scriptt.sh -D setvar:NEWVAR=5

#  use -D setvar:varname=varvalue to init the environment, print the internal variables and end the script

    ./scriptt.sh -D setvar:__PRINT_INTERNAL_VARIABLES=0

# use -D setvar:varname to enable debug infos for the parameter handling

    ./scriptt.sh -D setvar:__PRINT_ARGUMENTS=0 [your_script_parameter]

# to temporary disable the house keeping at script end use

    ./scriptt.sh -D setvar:__NO_CLEANUP=0

# Note: to disable only parts of the house keeping use one of the variables:
#       __NO_EXIT_ROUTINES  __NO_TEMPFILES_DELETE __NO_TEMPMOUNTS_UMOUNT
#       __NO_TEMPDIR_DELETE  __NO_FINISH_ROUTINES __CLEANUP_ON_ERROR
#       __NO_KILL_PROCS
#

# Use -D tracefunc=x to trace the function GetSeconds

    ./scriptt.sh -D tracefunc=GetSeconds

 # Use -D tracefunc=x to trace the functions GetSeconds and CreateTemporaryFiles

    ./scriptt.sh -D tracefunc=GetSeconds,CreateTemporaryFiles

 # Use -D tracefunc=x to trace the functions GetSeconds, CreateTemporaryFiles, and SetEnvironment

    ./scriptt.sh -D tracefunc="GetSeconds CreateTemporaryFiles SetEnvironment"

 # Use -D debugcode=x to add some debug code to each function, e.g. to print the function name and parameter for each function executed use:

    ./scriptt.sh -D debugcode="  eval echo Entering the subroutine \${__FUNCTION} Parameter are \\\"\$*\\\"  ... >/dev/tty "


 # Use -D debugcode=x to call a debug shell on every function start (note: use "kill -9 $$" while in the debug shell to end the script)

   ./scriptt.sh  -D debugcode="  eval echo Entering the subroutine \${__FUNCTION} Parameter are \\\"\$*\\\"  ... >/dev/tty ; DebugShell "

 # Use -D debugcode=x to call a debug shell for every call of the function LogInfo (note: use "kill -9 $$" while in the debug shell to end the script)

   ./scriptt.sh  -D debugcode="  eval echo Entering the subroutine \${__FUNCTION} Parameter are \\\"\$*\\\"  ... >/dev/tty ; [ \${__FUNCTION} = LogInfo  ] && DebugShell "

 # use -D debugcode=x to enable tracing (set -x) for the function GetSeconds only

   ./scriptt.sh  -D debugcode="  eval echo Entering the subroutine \${__FUNCTION} Parameter are \\\"\$*\\\"  ... >/dev/tty ; [ \${__FUNCTION} = GetSeconds  ] && set -x"

 # for more complicated code you should use an include file , e.g.

   ls -l debugcode
   -rwxr-xr-x. 1 xtrnaw7 xtrnaw7 325 31. Okt 19:34 debugcode

   cat debugcode
   echo "Entering the subroutine ${__FUNCTION} Parameter are \"$*\"  ... " >/dev/tty ;
   if [ ${__FUNCTION} = GetSeconds  ] ; then
      echo "Enabling trace for GetSconds:" >/dev/tty
      set -x
   elif [ ${__FUNCTION} = CreateTemporaryFiles ] ; then
     echo "Calling DebugShell from CreateTemporyFiles ..." >/dev/tty
     DebugShell
   fi

   ./scriptt.sh  -D debugcode=". $PWD/debugcode"

 # Notes

 Use the parameter -D debugcode=x with care! And do NOT use code that writes
 to STDOUT - all output  must go to another file handle, e.g STDERR or /dev/tty!
 Use either -D debugcode=x or -D tracefunc=f1 -- but not both

'
# -----------------------------------------------------------------------------
####
#### scriptt.sh - ??? script description ???
####
#### Author: Bernd Schemmer (Bernd.Schemmer@gmx.de)
####
#### Version: see variable ${__SCRIPT_VERSION} below
####          (see variable ${__SCRIPT_TEMPLATE_VERSION} for the template version used)
####
#### Supported OS: Solaris, Linux, AIX and other Unix flavours
####
####
#### Description
#### -----------
####
#### ???
####
#### Note: The current version of the script template can be found here:
####
####       http://bnsmb.de/solaris/scriptt.html
####
##C#
##C# Configuration file
##C# ------------------
##C#
##C# This script supports a configuration file called <scriptname>.conf.
##C# The configuration file is searched at script start in the working 
##C# directory, the home directory of the user executing this script
##C# and in /etc (in this order).
##C#
##C# The configuration file is read before the parameter are processed.
##C#
##C# To override the default config file search set the variable
##C# CONFIG_FILE to the name of the config file to use.
##C#
##C# e.g. CONFIG_FILE=/var/myconfigfile ./scriptt.sh
##C#
##C# To disable the use of a config file use
##C#
##C#     CONFIG_FILE=none ./scriptt.sh
##C#
##C# See the value for the variable __CONFIG_PARAMETER in the script
##C# for the possible values in the config file.
##C#
##C# To create a new config file use the parameter "-C"
##C#
####
#### Predefined parameter
#### --------------------
####
#### see the subroutines ShowShortUsage and ShowUsage
####
####
##T# Troubleshooting support
##T# -----------------------
##T#
##T# To disable all debugging features (all debug parameter to call a "shell"
##T# and the DebugShell) set the variable __ENABLE_DEBUG to ${__FALSE}
##T#
##T# Per default CTRL-C calls the DebugShell 
##T# 
##T# The DebugShell is in principle a loop to read input from the user and 
##T# then execute that input via eval. DebugShell knows some internal aliase -
##T# everything else is interpreted as an OS or script command to execute.
##T# 
##T# The online help for the DebugShell is:
##T#
##T# *** Debug Shell called via CTRL-C ***
##T# 
##T#  ------------------------------------------------------------------------------- 
##T# scriptt.sh - debug shell (called via CTRL-C) - enter a command to execute ("exit" to leave the shell)
##T#   defined aliase: functions = list all defined functions, vars [help|var_list] = print global variables, 
##T#                   quit = exit the script, abort = abort the script with kill -9, use help for a short usage help
##T#                   cont = continue script execution
##T# >> help
##T# 
##T# Enter either an defined alias or an OS command to execute
##T# 
##T# Defined aliase are:
##T# 
##T# functions                     - print all defined functions
##T# func f1 [...f#]               - view the source code for the functions f1 to f# 
##T#                                 (supported by this shell: yes)
##T# 
##T# add_debug_code f1 [...f#]     - add debug code to functions f1 to f#; use all for f1 to add
##T#                                 debug code to all functions
##T#                                 (supported by this shell: yes)
##T#                       
##T# view_debug                    - view the current debug code
##T# set_debug f1 [...f#]          - enable tracing for the functions f1 to f#
##T#                                 Note: The existing trace definitions will be overwritten!
##T# clear_debug                   - disable tracing for all functions
##T# 
##T# vars help                     - print defined variable lists
##T# vars var_list                 - print the variable from the variable list 'var_list'
##T# vars all                      - print all variables
##T# 
##T# verbose                       - toggle the verbose switch (current value is: 1, __VERBOSE_LEVEL is 0)
##T# break                         - toggle the break switch (current value is: 0)
##T# 
##T# exit                          - exit the shell
##T# quit                          - exit the script
##T# abort                         - exit the script with 'kill -9'
##T# cont                          - continue the script execution
##T# 
##T# Everthing else is interpreted as an OS command
##T#
##T# Note: The alias "cont" is only available if DebugShell is called in the CTRL-C signal handller.
##T'
##T# 
##T#  ------------------------------------------------------------------------------- 
##T# scriptt.sh - debug shell (called via CTRL-C) - enter a command to execute ("exit" to leave the shell)
##T#   defined aliase: functions = list all defined functions, vars [help|var_list] = print global variables, 
##T#                   quit = exit the script, abort = abort the script with kill -9, use help for short usage help
##T#                   cont = continue script execution
##T# >> vars help
##T# 
##T# Known variable lists are:
##T# 
##T#       all               - print all variables used
##T# 
##T#       application       - print application variables
##T#       used_env          - print environment variables used
##T#       log               - print variables for the logfile handling
##T#       defaults          - print variables with DEFAULT_* values
##T#       config            - print variables for the config file processing
##T#       house_keeping     - print variables for the housekeeping processing
##T#       signalhandler     - print variables for the signal handler
##T#       dump              - print variables for the dump processing
##T#       script            - print variables with the script name, directory, etc
##T#       debug             - print variables for the debug functions
##T#       parameter         - print variables for the parameter
##T#       requirements      - print variables for the script requirements
##T#       runtime           - print various runtime variables
##T#       os_env            - print variables for the OS environment
##T#       internal          - print all internal variables execept these variables
##T#                             __LONG_USAGE_HELP __SHORT_USAGE_HELP 
##T#                             __OTHER_USAGE_EXAMPLES __CONFIG_PARAMETER
##T# 
##T# 
##T#  ------------------------------------------------------------------------------- 
##T# scriptt.sh - debug shell (called via CTRL-C) - enter a command to execute ("exit" to leave the shell)
##T#   defined aliase: functions = list all defined functions, vars [help|var_list] = print global variables, 
##T#                    quit = exit the script, abort = abort the script with kill -9, use help for short usage help
##T#                    cont = continue script execution
##T# >> 
##T#
##T# Use
##T#
##T#   __CREATE_DUMP=<anyvalue|directory> <yourscript>
##T#
##T# to create a dump of the environment variables on program exit.
##T#
##T# e.g
##T#
##T#  __CREATE_DUMP=1 ./scriptt.sh
##T#
##T# will create a dump of the environment variables in the files
##T#
##T#   /tmp/scriptt.sh.envvars.$$
##T#   /tmp/scriptt.sh.exported_envvars.$$
##T#
##T# before the script ends
##T#
##T#  __CREATE_DUMP=/var/tmp/debug ./scriptt.sh
##T#
##T# will create a dump of the environment variables in the files
##T#
##T#   /var/tmp/debug/scriptt.sh.envvars.$$
##T#   /var/tmp/debug/scriptt.sh.exported_envvars.$$
##T#
##T# before the script ends (the target directory must already exist).
##T#
##T# Note that the dump files will always be created in case of a syntax
##T# error. To set the directory for these files use either
##T#
##T#   export __DUMPDIR=/var/tmp/debug
##T#   ./scriptt.sh
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
##T#   /var/debug/scriptt.sh.envvars.$$
##T#   /var/debug/scriptt.sh.exported_envvars.$$
##T#
##T#   CreateDump /var/debug pass2.
##T#
##T# will create the files
##T#
##T#   /var/debug/scriptt.sh.envvars.pass2.$$
##T#   /var/debug/scriptt.sh.exported_envvars.pass2.$$
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
#### In addition there are some debug parameters that can be used to
#### search and fix errors in the script -- see the output of
####
####    script.sh -D help
####
#### for the list of known debug switches.
####
#### -----------------------------------------------------------------------------
#### Note: Use
####
####    ./scriptt.sh -D SyntaxHelp 2>./scriptt.sh.syntaxhelp
####
####    to get some syntax examples for the functions defined in the template.
####
#### -----------------------------------------------------------------------------
####
#### User defined signal handler
#### ---------------------------
####
#### You can define various SIGNAL handlers to process signals received
#### by the script.
####
#### All SIGNAL handlers can use these variables:
####
#### __TRAP_SIGNAL -- the catched trap signal (this variable is NOT
####                  reset when the signal handler ended)
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
####   Thanks to Arno Teunisse for some usage examples for scriptt.sh
####
##v# History:
##v# --------
##v#   ??.??.2017 v1.0.0 /bs
##v#     initial release
##v#
####
##V# script template History
##V# -----------------------
##V#   1.22.0 08.06.2006 /bs  (BigAdmin Version 1)
##V#      public release; starting history for the script template
##V#
##V#   1.22.1 12.06.2006 /bs
##V#      added true/false to CheckYNParameter and ConvertToYesNo
##V#
##V#   1.22.2. 21.06.2006 /bs
##V#      added the parameter -V
##V#      added the use of environment variables
##V#      added the variable __NO_TIME_STAMPS
##V#      added the variable __NO_HEADERS
##V#      corrected a bug in the function executeCommandAndLogSTDERR
##V#      added missing return commands
##V#
##V#   1.22.3 24.06.2006 /bs
##V#      added the function StartStop_LogAll_to_logfile
##V#      added the variable __USE_TTY (used in AskUser)
##V#      corrected a typo (dev/nul instead of /dev/null)
##V#
##V#   1.22.4 06.07.2006 /bs
##V#      corrected a bug in the parameter error handling routine
##V#
##V#   1.22.5 27.07.2006 /bs
##V#      corrected some minor bugs
##V#
##V#   1.22.6 09.08.2006 /bs
##V#      corrected some minor bugs
##V#
##V#   1.22.7 17.08.2006 /bs
##V#      add the CheckParameterCount function
##V#      added the parameter -T
##V#      added long parameter support (e.g --help)
##V#
##V#   1.22.8 07.09.2006 /bs
##V#      added code to save the env variable LANG and set it temporary to C
##V#
##V#   1.22.9 20.09.2006 /bs
##V#      corrected code to save the env variable LANG and set it temporary to C
##V#
##V#   1.22.10 21.09.2006 /bs
##V#      cleanup comments
##V#      the number of temporary files created automatically is now variable
##V#        (see the variable __NO_OF_TEMPFILES)
##V#      added code to install the trap handler in all functions
##V#
##V#   1.22.11 19.10.2006 /bs
##V#      corrected a minor bug in AskUser (/c was not interpreted by echo)
##V#      corrected a bug in the handling of the parameter -S (-S was ignored)
##V#
##V#   1.22.12 31.10.2006 /bs
##V#      added the variable __REQUIRED_ZONE
##V#
##V#   1.22.13 13.11.2006 /bs
##V#      the template now uses TMP or TEMP if set for the temporary files
##V#
##V#   1.22.14 14.11.2006 /bs
##V#      corrected a bug in the function AskUser (the default was y not n)
##V#
##V#   1.22.15 21.11.2006 /bs
##V#      added initial support for other Operating Systems
##V#
##V#   1.22.16 05.07.2007 /bs
##V#      enhanced initial support for other Operating Systems
##V#      Support for other OS is still not fully tested!
##V#
##V#   1.22.17 06.07.2007 /bs
##V#      added the global variable __TRAP_SIGNAL
##V#
##V#   1.22.18 01.08.2007 /bs
##V#      __OS_VERSION and __OS_RELEASE were not set - corrected
##V#
##V#   1.22.19 04.08.2007 /bs
##V#      wrong function used to print "__TRAP_SIGNAL is \"${__TRAP_SIGNAL}\"" - fixed
##V#
##V#   1.22.20 12.09.2007 /bs
##V#      the script now checks the ksh version if running on Solaris
##V#      made some changes for compatibility with ksh93
##V#
##V#   1.22.21 18.09.2007 /bs (BigAdmin Version 2)
##V#      added the variable __FINISHROUTINES
##V#      changed __REQUIRED_ZONE to __REQUIRED_ZONES
##V#      added the variable __KSH_VERSION
##V#      reworked the trap handling
##V#
##V#   1.22.22 23.09.2007 /bs
##V#      added the signal handling for SIGUSR1 and SIGUSR2 (variables __SIGUSR1_FUNC and __SIGUSR2_FUNC)
##V#      added user defined function for the signals HUP, BREAK, TERM, QUIT, EXIT, USR1 and USR2
##V#      added the variables __WARNING_PREFIX, __ERROR_PREFIX,  __INFO_PREFIX, and __RUNTIME_INFO_PREFIX
##V#      the parameter -T or --tee can now be on any position in the parameters
##V#      the default output file if called with -T or --tee is now
##V#        /var/tmp/${0##*/}.$$.tee.log
##V#
##V#   1.22.23 25.09.2007 /bs
##V#      added the environment variables __INFO_PREFIX, __WARNING_PREFIX,
##V#      __ERROR_PREFIX, and __RUNTIME_INFO_PREFIX
##V#      added the environment variable __DEBUG_HISTFILE
##V#      reworked the function to print the usage help :
##V#      use "-h -v" to view the extented usage help and use "-h -v -v" to
##V#          view the environment variables used also
##V#
##V#   1.22.24 05.10.2007 /bs
##V#      another minor fix for ksh93 compatibility
##V#
##V#   1.22.25 08.10.2007 /bs
##V#      only spelling errors corrected
##V#
##V#   1.22.26 19.11.2007 /bs
##V#      only spelling errors corrected
##V#
##V#   1.22.27 29.12.2007 /bs
##V#      improved the code to create the lockfile (thanks to wpollock for the info; see credits above)
##V#      improved the code to create the temporary files (thanks to wpollock for the info; see credits above)
##V#      added the function rand (thanks to wpollock for the info; see credits above)
##V#      the script now uses the directory name saved in the variable $TMPDIR for temporary files
##V#      if it's defined
##V#      now the umask used for creating temporary files can be changed (via variable __TEMPFILE_UMASK)
##V#
##V#   1.22.28 12.01.2008 /bs
##V#      corrected a syntax error in the show usage routine
##V#      added the function PrintWithTimestamp (see credits above)
##V#
##V#   1.22.29 31.01.2008 /bs
##V#      there was a bug in the new code to remove the lockfile which prevented
##V#      the script from removing the lockfile at program end
##V#      if the lockfile already exist the script printed not the correct error
##V#      message
##V#
##V#   1.22.30 28.02.2008 /bs
##V#      Info update: executeCommandAndLog does NOT return the RC of the executed
##V#      command if a logfile is defined
##V#      added inital support for CYGWIN
##V#      (tested with CYGWIN_NT-5.1 v..1.5.20(0.156/4/2)
##V#      Most of the internal functions are NOT tested yet in CYGWIN
##V#      GetCurrentUID now supports UIDs greater than 254; the function now prints the UID to STDOUT
##V#      Corrected bug in GetUserName (only a workaround, not the solution)
##V#      now using printf in the AskUserRoutine
##V#
##V#   1.22.30 28.02.2008 /bs
##V#     The lockfile is now also deleted if the script crashes because of a syntax error or something like this
##V#
##V#   1.22.31 18.03.2008 /bs
##V#     added the version number to the start and end messages
##V#     an existing config file is now removed (and not read) if the script is called with -C to create a config file
##V#
##V#   1.22.32 04.04.2008 /bs
##V#     minor changes for zone support
##V#
##V#   1.22.33 12.02.2009 /bs
##V#     disabled the usage of prtdiag due to the fact that prtdiag on newer Sun machines needs a long time to run
##V#     (-> __MACHINE_SUBTYPE is now always empty for Solaris machines)
##V#     added the variable __CONFIG_FILE_FOUND; this variable contains the name of the config file
##V#     read if a config file was found
##V#     added the variable __CONFIG_FILE_VERSION
##V#
##V#   1.22.34 28.02.2009 /bs
##V#     added code to check for the max. line no for the debug handler
##V#     (an array in ksh88 can only handle up to 4096 entries)
##V#     added the variable __PIDFILE
##V#
##V#  1.22.35 06.04.2009 /bs
##V#     added the variables
##V#       __NO_CLEANUP
##V#       __NO_EXIT_ROUTINES
##V#       __NO_TEMPFILES_DELETE
##V#       __NO_TEMPMOUNTS_UMOUNT
##V#       __NO_TEMPDIR_DELETE
##V#       __NO_FINISH_ROUTINES
##V#       __CLEANUP_ON_ERROR
##V#       CONFIG_FILE
##V#
##V#  1.22.36 11.04.2009 /bs
##V#     corrected a cosmetic error in the messages (wrong: ${TEMPFILE#} correct: ${__TEMPFILE#})
##V#
##V#  1.22.37 08.07.2011 /bs
##V#     corrected a minor error with the QUIET parameter
##V#     added code to dump the environment (env var __CREATE_DUMP, function CreateDump )
##V#     implemented work around for missing function whence in bash
##V#     added the function LogIfNotVerbose
##V#
##V#  1.22.38 22.07.2011 /bs
##V#     added code to make the trap handling also work in bash
##V#     added a sample user defined trap handler (function USER_SIGNAL_HANDLER)
##V#     added the function SetHousekeeping to enabe or disable house keeping
##V#     scriptt.sh did not write all messages to the logfile if a relative filename was used - fixed
##V#     added more help text for "-v -v -v -h"
##V#     now user defined signal handler can have arguments
##V#     the RBAC feature (__USE_RBAC) did not work as expected - fixed
##V#     added new scriptt testsuite for testing the script template on other OS and/or shells
##V#     added the function SaveEnvironmentVariables
##V#
##V#  1.22.39 24.07.2011 /bs
##V#     __INIT_FUNCTION now enabled for cygwin also
##V#     __SHELL did not work in all Unixes - fixed
##V#     __OS_FULLNAME is now also set in Solaris and Linux
##V#
##V#  1.22.40 25.07.2011 /bs
##V#     added some code for ksh93 (functions: substr)
##V#     Note: set __USE_ONLY_KSH88_FEATURES to ${__TRUE} to suppress using the ksh93 features
##V#     The default action for the signal handler USR1 is now "Create an env dump in /var/tmp"
##V#     The filenames for the dumps are
##V#
##V#      /var/tmp/<scriptname>.envvars.dump_no_<no>_<PID>
##V#      /var/tmp/<scriptname>.exported_envvars.dump_no_<no>_<PID>
##V#
##V#     where <no> is a sequential number, <PID> is the PID of the process with the script,
##V#     and <scriptname> is the name of the script without the path.
##V#
##V#  1.22.41 26.09.2011 /bs
##V#     added the parameter -X
##V#     disabled some ksh93 code because "ksh -x -n" using ksh88 does not like it
##V#
##V#  1.22.42 05.10.2011 /bs
##V#     added the function PrintDotToSTDOUT
##V#
##V#  1.22.43 15.10.2011 /bs
##V#     added support for disabling the config file feature with CONFIG_FILE=none ./scriptt.sh
##V#     corrected a minor bug in SaveEnvironmentVariables
##V#     corrected a bug in the function SaveEnvironmentVariables
##V#     corrected a bug in getting the value for the variable ${__ABSOLUTE_SCRIPTDIR}
##V#
##V#  1.22.44 22.04.2012 /bs
##V#     The script now uses nawk only if available (if not awk is used)
##V#     variables are now supported in the usage examples (prefixed with ##EXAMPLE##)
##V#     add a line with the current date and time to variable dumps, e.g.
##V#
##V#         ### /var/tmp/scriptt.sh.exported_envvars.dump_no_0_20074 - exported environment variable dump created on Sun Apr 22 11:35:38 CEST 2012
##V#
##V#         ### /var/tmp/scriptt.sh.envvars.dump_no_0_20074 - environment variable dump created on Sun Apr 22 11:35:38 CEST 2012
##V#
##V#     added experimental interactive mode to the signal handler for USR2
##V#     replaced /usr/bin/echo with printf
##V#     added the variable LOGMSG_FUNCTION
##V#
##V#  1.22.45 07.06.2012 /bs
##V#     added code to check if the symbolic link for the lockfile already exists before creating
##V#     the lock file
##V#
##V#  1.22.46 27.04.2013 /bs
##V#     executeCommandAndLog rewritten using coprocesses (see also credits)
##V#     Info update: executeCommandAndLog does now return the RC of the executed
##V#                  command even if a logfile is defined
##V#
##V# -------------------------------------------------------------------
##V#
##V#  2.0.0.0 17.05.2013 /bs
##V#     added the variable __GENERAL_SIGNAL_FUNCTION: This variable
##V#       contains the name of a function that is called for all SIGNALs
##V#       before the special SIGNAL handler is called
##V#     removed the Debug Handler for single step execution (due to the
##V#       length of the template it is not useful anymore; use the
##V#       version 1.x of scriptt.sh if you still need the Debug Handler)
##V#     function executeCommandAndLogSTDERR rewritten
##V#     removed the function CheckParameterCount
##V#     use lsb_release in Linux to retrieve OS infos if available
##V#     minor fixes for code and comments
##V#     replaced PrintWithTimeStamp with code that does not use awk
##V#     isNumber replaced with code that does not use sed
##V#
##V#  2.0.0.1 06.08.2013 /bs
##V#     added the variable __MACHINE_SUB_CLASS. Possible values
##V#     for sun4v machines: either "GuestLDom" or "PrimaryLDom"
##V#
##V#  2.0.0.2 01.09.2013 /bs
##V#     added the variables __SYSCMDS and __SYSCMDS_FILE
##V#
##V#  2.0.0.3 16.12.2013 /bs
##V#     now the Log-* functions return ${__TRUE} if a message is printed
##V#     and ${__FALSE} if not
##V#
##V#  2.0.0.4 01.01.2014 /bs
##V#     the alias __settrap is renamed to settraps (with leading s)
##V#     two new aliase are defined: __ignoretraps and __unsettraps
##V#     whence function for non-ksh compatible shells rewritten
##V#       without using ksh
##V#     the switch -D is now used to toggle debug switches
##V#       known debug switches:
##V#        help  -- print the usage help for -D
##V#         msg  -- log debug messages to /tmp/<scriptname>.<pid>.debug
##V#       trace  -- activate tracing to the file /tmp/<scriptname>.<pid>.trace
##V#     AskUser now accepts also "yes" and "no"
##V#     function IsFunctionDefined rewritten
##V#     now __LOGON_USERID and __USERID are equal to $LOGNAME until I
##V#     find a working solution (the code in the previous version
##V#       did not work if STDIN is not a tty)
##V#
##V#   2.0.0.5 08.01.2014 /bs
##V#     added the function executeFunctionIfDefined
##V#
##V#   2.0.0.6 27.01.2014 /bs
##V#     added the function PrintLine
##V#     added the functions GetSeconds, GetMinutes, ConvertMinutesToHours,
##V#       and GetTimeStamp
##V#     added the debug options fn_to_stderr, fn_to_tty, and fn_to_handle9
##V#     max. return value for a function is 255 and therefor the functions
##V#       for the stack and the functions pos and lastpos now abort the
##V#       script if a value greater than 255 should be returned
##V#     added the variables __SHEBANG, __SCRIPT_SHELL, and __SCRIPT_SHELL_OPTIONS
##V#     added the function DebugShell
##V#     AskUser now has a hidden shell; use "shell<return>" to call the DebugShell
##V#       set __DEBUG_SHELL_IN_ASKUSER to ${__FALSE} to disable the DebugShell
##V#       in AskUser
##V#     added the function ConvertDateToEpoc
##V#
##V#   2.0.0.7 27.04.2014 /bs
##V#     AskUser now saves the last input in the variable LAST_USER_INPUT, to enter
##V#       this value again use "#last"
##V#     Version parameter (-V) usage enhanced:  use "-v -v  -V" to print also the version
##V#       history; use "-v -v -v -V" to also print the template version history.
##V#
##V#   2.1.0.0 02.11.2014 /bs
##V#     Added the parameter "-D SyntaxHelp" to print syntax usage examples for the template
##V#     Added the parameter "-D debugcode='x' "
##V#     Added the parameter "-D tracefunc=f1"
##V#     Added the parameter "-D setvar:name=value"
##V#     Added more usage information for the template
##V#
##V#   2.1.0.1 04.11.2014 /bs
##V#     Added the parameter variable__DEBUG_PREFIX
##V#     Added the function LogDebugMsg
##V#     Added the parameter "-D listfunc"
##V#     Added the parameter "-D fn_to_device=filename"
##V#     corrected a minor bug in the parameter handling for the parameter "-D"
##V#
##V#   2.1.0.2 06.11.2014 /bs
##V#     Added the parameter "-D create_dump=d"
##V#     the function rand now uses nawk in Solaris and awk in all other OS
##V#
##V#   2.1.0.2 08.11.2014 /bs
##V#     corrected a bug in code for the parameter "-D fn_to_device=filename"
##V#     added ${__FUNCTION_EXIT} to some of the functions
##V#
##V#   2.1.0.3 12.12.2014 /bs
##V#     added the variable ${__BACKUP_FILE} to BackupFileIfNecessary
##V#
##V#   2.1.0.4 25.12.2014 /bs
##V#      __SCRIPTDIR was wrong if the script was called with the name only
##V#
##V#   2.1.0.5 08.05.2015 /bs
##V#      LogRuntimeInfo did not work in the default ksh from Solaris 11 --fixed
##V#
##V#   2.1.0.6 08.07.2015 /bs
##V#     Added the parameter "-D debug"
##V#
##V#   2.1.0.7 25.07.2015 /bs
##V#      added the parameter "-D dryrun". To use dryrun in your code
##V#        add the prefix "${PREFIX}" to every external command executed
##V#        by your script
##V#      added the parameter "-D list_rc" to list all return codes used in the script
##V#        (only works if you only use "die" to end the script)
##V#
##V#   2.1.0.8 09.09.2015 /bs
##V#      added the variable __SETOPTS and the alias __TRACE_ACTIVE
##V#
##V#   2.1.0.9 26.10.2015 /bs
##V#     added the keyword printargs to the parameter -D
##V#     BackupFileIfNecessary now supports rotating backups, e.g.
##V#        file.0, file.1, file.3, ...
##V#     To use that feature the new format of the parameter for the
##V#     function is:
##V#
##V#        BackupFileIfNeccessary [file{,no_of_backups}] [...]
##V#
##V#     In the default configuration the script now creates a new log
##V#     file for each execution of the script and retains up to
##V#     10 backups of the log file.
##V#     To overwrite the number of backups use the following syntax for
##V#     the parameter -l:
##V#
##V#        -l logfile,[no_of_backups_of_the_logfile]
##V#
##V#     The default number of backups for the log file is configured in the variable
##V#     MAX_NO_OF_LOGFILES
##V#
##V#   2.1.0.10 16.11.2015 /bs
##V#     replaced code incompatible with some ksh versions
##V#
##V#   2.1.0.11 26.11.2015 /bs
##V#     moved initialisation of __SCRIPTNAME, __SCRIPTDIR, and
##V#     __REAL_SCRIPTDIR to the beginnning of the script
##V#     automatic umount of mount points via __LIST_OF_TMP_MOUNTS did not work anymore - fixed
##V#     some cosmetic changes
##V#
##V#   2.2.0.0 09.01.2016 /bs
##V#     the function GetKeystroke did not process the parameter - fixed
##V#     GetKeystroke did not check for CTRL-C - fixed
##V#     the function GetKeystroke now supports the parameter [lower|upper] to convert the user input
##V#       to lowercase or uppercase; the real user input is still available in the global variable RAW_USER_INPUT
##V#     the script now prints the actions that would have been done in the cleanup routine if __NO_CLEANUP is set
##V#     added the parameter "-D nocleanup" (shortcut for "-D setvar:__NO_CLEANUP=0")
##V#     added the parameter "-D cleanup[=type]" to enable/disable the house keeping
##V#     die() will now again end the script even if -f was used
##V#     includeScript now checks the syntax of an include script
##V#     added the function tryIncludeScript
##V#     added the parameter "-D showdefaults"
##V#     added the parameter "-D tracemain"
##V#     corrected some errors in the messages written by the script
##V#     reworked the comments in the script
##V#     added the variable __START_DIR_REAL
##V#
##V#   2.2.0.1 17.01.2016 /bs
##V#     the content of the environment variable __DEBUG_CODE was not used -- fixed
##V#     adding -f to the rm and mv commands in BackupFileIfNecessary
##V#     __BACKUP_FILE was not always set to the correct value in BackupFileIfNecessary - fixed
##V#    now BackupFileIfNecessary returns ${__FALSE} if one or more backups failed
##V#
##V#   2.2.0.2 24.10.2016 /bs
##V#     SDTERR in DebugShell was not redirected to /dev/tty -- fixed
##V#     DebugShell returns now immediately if not running in an interactive session
##V#
##V#   2.3.0.0 10.11.2017 /bs scriptt.sh
##V#     added the variable __RUNNING_IN_TERMINAL_SESSION 
##V#     added the function print_runtime_variables
##V#     enhanced the function DebugShell
##V#     default user defined trap handler for CTRL-C is now DebugShell
##V#       edit the line 
##V#         __SIGNAL_SIGINT_FUNCTION="DebugShell" 
##V#       to change this behaviour
##V#       or use   ./scriptt.sh -D setvar:__SIGNAL_SIGINT_FUNCTION=""
##V#     if the script is called with redirected STDIN and without the parameter -q
##V#       all output for STDOUT and STDERR is now redirected to the file
##V#       /var/tmp/${0##*/}.STDOUT_STDERRR.$$
##V#     removed the variables SCRIPT_USER and SCRIPT_USER_MSG
##V#     added the variables __PROCS_TO_KILL and __PROCS_KILL_TIMEOUT to
##V#       define processes that should be stopped at script end
##V#     the debug switch "-D tracefunc" can now be used more then one time 
##V#     the debug switches "-D tracefunc" and "-D debug" can be used at the same time
##V#     the debug switch "-D tracefunc" now supports the variable ${.sh.func} if running in ksh93
##V#     added the debug switch "-D DebugShell" to call the DebugShell while processing the parameter
##V#     fixed a typo: renamed __ingoretraps to __ignoretraps
##V#     the function f() to check the ksh version is now deleted after it is used
##V#     "typeset -f" replaced with "typeset +f" where applicable
##V#     the default value for the debug switch "-D cleanup" is now "all"
##V#     added the variable __TYPESET_F_SUPPORTED; this variable is set to "yes" if "typeset -f function"
##V#       can be used to print the statements of a function in the used shell
##V#     the debug switch "-D tracefunc" and the aliase for tracing in DebugShell now add the statements
##V#       typeset __FUNCTION=<function_name> ; ${__DEBUG_CODE};
##V#     to a function if neccessary, and "typeset -f" is supported by the shell used
##V#     the cleanup function now supports parameter for the exit routines
##V#     the cleanup function now supports parameter for the finish routines
##V#     added the variable __INSIDE_EXIT_ROUTINE
##V#     added the variable __INSIDE_FINISH_ROUTINE
##V#     added the variable __ENABLE_DEBUG (if __ENABLE_DEBUG is not ${__TRUE} all debugging features are
##V#       disabled)
##V#
##V#   2.3.0.1 03.12.2017 /bs scriptt.sh
##V#     there was typo in the code for "func "*  in the DebugShell - fixed
##V#
##V#   2.3.1.0 11.01.2019 /bs scriptt.sh
##V#     alias __ignoretraps deleted -- the trap commands in that alias are
##V#       not supported by all ksh versions
##V#     CreateLockFile : replace "2>/dev/null" with "2>>/dev/null" 
##V#       because some ksh versions use "set -C" also for devices
##V#     alias __unsettraps rewritten to work on more ksh versions
##V#
##V#   2.3.2.0 21.07.2019 /bs scriptt.sh
##V#     added the debug switch "-D disable_tty_check"
##V#     the use of "-" to suppress the date string in messages is now also supported by the functions
##V#       LogOnly
##V#       LogInfo
##V#       LogWarning
##V#       LogError
##V#       LogIfNotVerbose
##V#       LogRuntimeInfo
##V#     added the function switch_to_background 
##V#     in Linux the script now sets the variable _SYSTEMD_IS_USED
##V#     added the variable __DEBUG_SHELL_CALLED
##V#     default for __RBAC_BINARY in all OS except Solaris is now $( which sudo )
##V#
##V#

# -----------------------------------------------------------------------------
#### ##### constants
####
#### __TRUE - true (0)
#### __FALSE - false (1)
####
####
typeset -r __TRUE=0
typeset -r __FALSE=1

# ----------------------------------------------------------------------
# __ENABLE_DEBUG : enable or disable the debugging features
#
__ENABLE_DEBUG=${__TRUE}
#__ENABLE_DEBUG=${__FALSE}

# ----------------------------------------------------------------------
#
# redirect STDOUT and STDERR of the script and all commands executed by
# the script to a file if called in an session without tty
#
# use  ">&3" to print a message to the original STDOUT; 
# use  ">&4" to print amessage to the original STDERR
#
__DISABLE_TTY_CHECK="${__DISABLE_TTY_CHECK:=${__FALSE}}"
__RUNNING_IN_TERMINAL_SESSION=${__TRUE} 

if [[  \ $*\  == *\ -D\ disable_tty_check\ * ]] ; then
  __DISABLE_TTY_CHECK=${__TRUE}
fi
  
if [ ${__DISABLE_TTY_CHECK} = ${__FALSE} ] ; then
  if  ! tty -s  ; then
    __RUNNING_IN_TERMINAL_SESSION=${__FALSE}

    if [[ " $* " != *\ --quiet\ * && " $* " != *\ -q\ * ]]  ; then
      __STDOUT_FILE="/var/tmp/${0##*/}.STDOUT_STDERRR.$$"
      echo "${SCRIPTNAME} -- Running in a detached session ... STDOUT/STDERR will be in ${__STDOUT_FILE}" >&2
 
      exec 3>&1
      exec 4>&2
      exec 1>>"${__STDOUT_FILE}"  2>&1
    fi
  fi
fi


#### ----------------
#### Version variables
####
#### __SCRIPT_VERSION - the version of your script
####
####
typeset  -r __SCRIPT_VERSION="v1.0.0"
####

#### __SCRIPT_TEMPLATE_VERSION - version of the script template
####
typeset -r __SCRIPT_TEMPLATE_VERSION="$( grep "^##V#" $0 | grep bs | grep scriptt.sh | tail -1 | awk '{  print $2" "$3" "$4 }' )"
####

#### __SCRIPTNAME - name of the script without the path
####
typeset -r __SCRIPTNAME="${0##*/}"

#### __SCRIPTDIR - path of the script (as entered by the user!)
####
__SCRIPTDIR="${0%/*}"
[ "${__SCRIPTDIR}"x = "$__SCRIPTNAME{}"x ] && __SCRIPTDIR=""

#### __REAL_SCRIPTDIR - path of the script (real path, maybe a link)
####
__REAL_SCRIPTDIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )


#### __SHORT_DESC - short description (for help texts, etc)
####   Change to your need
####
typeset -r __SHORT_DESC="??? short description ???"

#### __LONG_USAGE_HELP - Additional help if the script is called with
####   the parameter "-v -h"
####
####   Note: To use variables in the help text use the variable name without
####         an escape character, eg. ${OS_VERSION}
####
#
# examples:
#
#      -D    - debug switch
#              current value: ${__DEBUG_SWITCHES}
#              use "-D help" to list the known debug switches
#              Long format: --debug / ++debug
#      -a|+a - turn colors on/off; current value: $( ConvertToYesNo "${__USE_COLORS}" )
#              Long format: --color / ++color
#

__LONG_USAGE_HELP='
      [??? add additional parameter here ???]

'

#### __SHORT_USAGE_HELP - Additional help if the script is called with the parameter "-h"
####
####   Note: To use variables in the help text use the variable name without an escape
####         character, eg. ${OS_VERSION}
####
# Note: PADSTR is set by the function to print the usage help; the variable will be replaced
#       with the correct value in the function to print the usage help
#
__SHORT_USAGE_HELP='
         ${PADSTR} [??? add additional parameter here ???]


  Use the parameter \"-v -h [-v]\" to view the detailed online help; use the parameter \"-X\" to view some usage examples.

  see also http://bnsmb.de/solaris/scriptt.html

'

#### ----------------
####
##R# Predefined return codes:
##R# ------------------------
##R#
##R#    0 - ok, no error
##R#    1 - show usage and exit
##R#    2 - invalid parameter found
##R#
##R#    3 - 209 These returncodes can be used by the application code
##R#
##R#  210 - 254 reserved for the runtime system
##R#
##R#  228 - There is an error in an include script
##R#  229 - Script aborted by the user
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
# The variable __USED_ENVIRONMENT_VARIABLES is used in the function ShowUsage and print_runtime_variables
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
#### __NO_KILL_PROCS
#### __PROCS_KILL_TIMEOUT
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
#### __DISABLE_TTY_CHECK
#### CONFIG_FILE
"
####

#
# binaries and scripts used in this script:
#
# awk basename cat cp cpio cut date dd dirname egrep expr find grep id
# ln ls nawk pwd perl
# reboot rm sed sh tee touch tty umount uname who zonename
#
# /usr/bin/pfexec
# /usr/ucb/whoami or $( whence whoami )
# /usr/openwin/bin/resize or $( whence resize )
#
# AIX: oslevel
#
# Linux: lsb_release
#
# -----------------------------------------------------------------------------
# variables for the trap handler

__FUNCTION="main"


# supported signals
#

# general signals
#
#  Number	KSH name	Comments
#  0	    EXIT	    This number does not correspond to a real signal, but the corresponding trap is executed before script termination.
#  1	    HUP	        hangup
#  2	    INT	        The interrupt signal typically is generated using the DEL or the ^C key
#  3	    QUIT	    The quit signal is typically generated using the ^[ key. It is used like the INT signal but explicitly requests a core dump.
#  9	    KILL	    cannot be caught or ignored
#  10	    BUS	        bus error
#  11	    SEGV	    segmentation violation
#  13	    PIPE	    generated if there is a pipeline without reader to terminate the writing process(es)
#  15	    TERM	    generated to terminate the process gracefully
#  -	    DEBUG	    KSH93 only: This is no signal, but the corresponding trap code is executed before each statement of the script.
#
# signals in Solaris
#  16	    USR1	    user defined signal 1, this value is different in other Unix OS!
#  17	    USR2	    user defined signal 2, this value is different in other Unix OS!
#
#  24       SIGTSTP		stop a running process (like CTRL-Z)
#  25       SIGCONT		continue a stopped process in the background
#
# signals in Linux
#  16	    USR1	    user defined signal 1, this value is different in other Unix OS!
#  17	    USR2	    user defined signal 2, this value is different in other Unix OS!
#
#  20       SIGTSTP		stop a running process (like CTRL-Z)
#  18       SIGCONT		continue a stopped process in the background
#
# signals in AIX
#  30	    USR1	    user defined signal 1, this value is different in other Unix OS!
#  31	    USR2	    user defined signal 2, this value is different in other Unix OS!
#
#  18       SIGTSTP		stop a running process (like CTRL-Z)
#  19       SIGCONT		continue a stopped process in the background
#
# signals in MacOS (Darwin)
#  30	    USR1	    user defined signal 1, this value is different in other Unix OS!
#  31	    USR2	    user defined signal 2, this value is different in other Unix OS!
#
#  18       SIGTSTP		stop a running process (like CTRL-Z)
#  19       SIGCONT		continue a stopped process in the background
#
# 

#
# Note: The usage of the variable LINENO is different in the various ksh versions
#

# alias to install the trap handler
#
alias __settraps="
  trap 'GENERAL_SIGNAL_HANDLER SIGHUP    \${LINENO} \${__FUNCTION}' 1 ;\
  trap 'GENERAL_SIGNAL_HANDLER SIGINT    \${LINENO} \${__FUNCTION}' 2 ;\
  trap 'GENERAL_SIGNAL_HANDLER SIGQUIT   \${LINENO} \${__FUNCTION}' 3 ;\
  trap 'GENERAL_SIGNAL_HANDLER SIGTERM   \${LINENO} \${__FUNCTION}' 15 ;\
  trap 'GENERAL_SIGNAL_HANDLER SIGUSR1   \${LINENO} \${__FUNCTION}' USR1 ;\
  trap 'GENERAL_SIGNAL_HANDLER SIGUSR2   \${LINENO} \${__FUNCTION}' USR2 ;\
"


# alias to reset all traps to the defaults
#
alias __unsettraps="
  trap - 1 ;\
  trap - 2 ;\
  trap - 3 ;\
  trap - 15 ;\
  trap - USR1 ;\
  trap - USR2 ;\
"

# -----------------------------------------------------------------------------

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
#### __KSH_VERSION - ksh version (either 88 or 93)
####   If the script is not executed by ksh the shell is compatible to
###    ksh version ${__KSH_VERSION}
####
__KSH_VERSION=88 ; f() { typeset __KSH_VERSION=93 ; } ; f ;

### check if "typeset -f" is supported
###
typeset -f f | grep __KSH_VERSION >/dev/null && __TYPESET_F_SUPPORTED="yes" || __TYPESET_F_SUPPORTED="no"

unset -f f

# use ksh93 features?
#
if [ "${__USE_ONLY_KSH88_FEATURES}"x = ""x ] ; then
  [ "${__KSH_VERSION}"x = "93"x ] &&  __USE_ONLY_KSH88_FEATURES=${__FALSE} || __USE_ONLY_KSH88_FEATURES=${__TRUE}
fi

#### __OS - Operating system (e.g. SunOS)
####
__OS="$( uname -s )"

# -----------------------------------------------------------------------------
#### __SETOPTS - active set options at script start
####
__SETOPTS=$-

# -----------------------------------------------------------------------------
#### __TRACE_ACTIVE - alias, write ${__TRUE} to stdout  if "set -x" is active else ${__FALSE}
####
alias __TRACE_ACTIVE='[[ $- == *x* ]] && echo ${__TRUE} || echo ${__FALSE}'

# ----------------------------------------------------------------------
# read the hash tag (shebang) of the script
#
#### __SHEBANG - shebang of the script
#### __SCRIPT_SHELL - shell in the shebang of the script
#### __SCRIPT_SHELL_OPTIONS - shell options in the shebang of the script
####
####
__SHEBANG="$( head -1 $0 )"
if [[ ${__SHEBANG} == \#!* ]] ; then
  __SCRIPT_SHELL="${__SHEBANG#*!}"
  __SCRIPT_SHELL="${__SCRIPT_SHELL% *}"
  __SCRIPT_SHELL_OPTIONS="${__SHEBANG#* }"
  [ "${__SCRIPT_SHELL_OPTIONS}"x = "${__SHEBANG}"x ] && __SCRIPT_SHELL_OPTIONS=""
else
  __SCRIPT_SHELL=""
  __SCRIPT_SHELL_OPTIONS=""
fi

# -----------------------------------------------------------------------------
# specific settings for the various operating systems
#
#
case ${__OS} in
  CYGWIN* )
    set +o noclobber
    __SHELL_FIELD=9
    __AWK="awk"
    ;;

  SunOS | AIX )
    __SHELL_FIELD=9
    __AWK="nawk"
    ( $__AWK '{}' ) < /dev/null 2>&0 || __AWK="awk"
    ;;

  * )
    __SHELL_FIELD=8
    __AWK="awk"
    ;;

esac

AWK="${__AWK}"


# -----------------------------------------------------------------------------
# specific settings for various shells
#

#### __SHELL - name of the current shell executing this script
####
__SHELL="$( ps -f -p $$ | grep -v PID | tr -s " " | cut -f${__SHELL_FIELD} -d " " )"
__SHELL=${__SHELL##*/}

: ${__SHELL:=ksh}

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
  typeset __FUNCTION="whence"; ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=1

  if typeset +f $1 1>/dev/null ; then
    echo $1 ; THISRC=0
  elif alias $1 2>/dev/null 1>/dev/null  ; then
    echo $1 ; THISRC=0
  else
    which $1 2>/dev/null ; THISRC=$?
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
####
#### __DEBUG_SHELL_IN_ASKUSER - enable or disable the debug shell in AskUser
####
__DEBUG_SHELL_IN_ASKUSER=${__TRUE}

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
####   default is /usr/bin/pfexec
####
####   Note: You can also set this environment variable before starting the script
####
case ${__OS} in
  SunOS )
: ${__RBAC_BINARY:=/usr/bin/pfexec}
  ;;
  
  * )
: ${__RBAC_BINARY:=$(which sudo)}
  ;;
esac
  
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
# all output into a file using tee

if [ "${__PPID}"x = ""x ] ; then
  __PPID=$PPID ; export __PPID
  if [[ \ $*\  == *\ -T* || \ $*\  == *\ --tee\ * ]] ; then
    echo "Saving STDOUT and STDERR to \"${__TEE_OUTPUT_FILE}\" ..."
    exec  $0 $@ 2>&1 | tee -a "${__TEE_OUTPUT_FILE}"
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
  [[ \ $*\  == *\ -v\ * ]] && echo "RBAC USED --now using \"${__RBAC_BINARY}\" to execute \"$0 $*\" " >&2
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
if [ ${__ENABLE_DEBUG} = ${__TRUE} ] ; then
  : __DEBUG_CODE="${__DEBUG_CODE:=}"
else
  __DEBUG_CODE=""
fi

#### __FUNCTIONS_TO_TRACE - functions for which trace (set -x) is enable
####
__FUNCTIONS_TO_TRACE=""

#### __FUNCTION_INIT - code executed at start of every sub routine
####   (see the hints for __DEBUG_CODE)
####   Default init code : install the trap handlers
####
__FUNCTION_INIT="eval __settraps"

#### __FUNCTION_EXIT - code executed at end of every sub routine
####   (see the hints for __DEBUG_CODE)
####   Default exit code : ""
####
__FUNCTION_EXIT=""

#### variables for debugging
####
#### __NO_CLEANUP - do not call the cleanup routine at all at script end if ${__TRUE}
####
: ${__NO_CLEANUP:=${__FALSE}}

#### __NO_EXIT_ROUTINES  - do not execute the exit routines if ${__TRUE}
####
: ${__NO_EXIT_ROUTINES:=${__FALSE}}

#### __NO_KILL_PROCS - do not kill the processes at script end if ${__TRUE}
####
: ${__NO_KILL_PROCS:=${__FALSE}}

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

#J# #svd  set variable defaults

__CONFIG_PARAMETER="__CONFIG_FILE_VERSION=\"${__SCRIPT_VERSION}\"
"'

#### BACKUP_EXTENSION - extension for backup files
####
  DEFAULT_BACKUP_EXTENSION=".$$.backup"


#### MAX_NO_OF_LOGFILES - number of backups for the log file
####
#### Default: create up to 10 backups of the log file
####
  DEFAULT_MAX_NO_OF_LOGFILES=10


# ??? example variables for the configuration file - change to your need

# ??? example config data -- start -- delete if not used!
#

# master server with the directories to synchronize
#
# overwritten by the parameter -m
  DEFAULT_MASTER_SERVER="sol9.isbs.de"

# server with the rsync daemon. This is either the master server or
# localhost
#
# overwritten by the parameter -s
  DEFAULT_RSYNC_SERVER="localhost"

# ??? example config data -- end -- delete if not used!


# only change the following variables if you know what you are doing #

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

#### default for the parameter -D dryrun
####  DEFAULT_PREFIX=""

# no further internal variables defined yet
#
# Note you can redefine any variable that is initialized before calling
# ReadConfigFile here!
'
# end of config parameters

#J# #auh  add. usage help


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
: __VERBOSE_LEVEL=${__VERBOSE_LEVEL:=0}

#### __RT_VERBOSE_LEVEL - level of -v for runtime messages (def.: 1)
####
####   e.g. 1 = -v -v is necessary to print info messages of the runtime system
####        2 = -v -v -v is necessary to print info messages of the runtime system
####
####   Note: You can also set this environment variable before starting the script
####
: __RT_VERBOSE_LEVEL=${__RT_VERBOSE_LEVEL:=1}

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


#### __DEBUG_SHELL_CALLED - the variableis set to TRUE everytime the function DebugShell is executed
####   The script will NOT set the variable back to ${__FALSE} - that must be done by your code if neccessary
####
__DEBUG_SHELL_CALLED=${__FALSE}

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
####   number of automatically created tempfiles that are deleted at script end
####   (def. 2)
####   Note: The variable names for the tempfiles are __TEMPFILE1, __TEMPFILE2, etc.
####
__NO_OF_TEMPFILES=2

#### __TEMPFILE_UMASK
####   umask for creating temporary files (def.: 177)
####
__TEMPFILE_UMASK=177

#### __LIST_OF_TMP_MOUNTS - list of mounts that should be umounted at script end
####
__LIST_OF_TMP_MOUNTS=""

#### __LIST_OF_TMP_DIRS - list of directories that should be removed at script end
####
__LIST_OF_TMP_DIRS=""

#### __LIST_OF_TMP_FILES - list of files that should be removed at script end
####
__LIST_OF_TMP_FILES=""

#### __SYSCMDS - list of commands execute via one of the execute... functions
###
__SYSCMDS=""

#### __SYSCMDS_FILE - write the list of executed commands via the execute.. functions to
####   this file at script and
####
__SYSCMDS_FILE=""

#### __EXITROUTINES - list of routines that should be executed before the script ends
####   Note: These routines are called *before* temporary files, temporary
####         directories, and temporary mounts are removed
####         Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
####         blanks or tabs in the parameter are NOT allowed
####
__EXITROUTINES=""

####  __INSIDE_EXIT_ROUTINE is set to ${__TRUE} before calling a exit routine
####
__INSIDE_EXIT_ROUTINE=${__FALSE}

#### __FINISHROUTINES - list of routines that should be executed before the script ends
####   Note: These routines are called *after* temporary files, temporary
####         directories, and temporary mounts are removed
####         Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
####         blanks or tabs in the parameter are NOT allowed
####
__FINISHROUTINES=""

####  __INSIDE_FINISH_ROUTINE is set to ${__TRUE} before calling a finish routine
####
__INSIDE_FINISH_ROUTINE=${__FALSE}

#### __PROCS_TO_KILL - list of proceesses to kill at script end
####   Note: The processes are killed after the functions from __EXITROUTINES are executed
####         To change the timeout after the "kill" command before issueing a "kill -9" 
####         for a specific process use "pid:timeout_in_seconds"; to disable "kill -9" 
####         for a specific process use "pid:-1"
####
__PROCS_TO_KILL=""

#### __PROCS_KILL_TIMEOUT - timeout in seconds to wait after the command "kill PID"  
####   in the function cleanup. If the PID is then still running it will be killed with 
####   the command "kill -9 PID"
####   Use "-1" to disable the "kill -9" for all PIDs
####
__PROCS_KILL_TIMEOUT=${__PROCS_KILL_TIMEOUT:=0}

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
if [ ${__USER_BREAK_ALLOWED}x = ${__TRUE}x ] ; then
  __SIGNAL_SIGINT_FUNCTION="DebugShell"
else
  __SIGNAL_SIGINT_FUNCTION=""
fi

#### __IN_BREAK_HANDLER - this variable is true if we are in the signal handler for CTLR-C
####
__IN_BREAK_HANDLER=${__FALSE}

#### __CONTINUE_SCRIPT_EXECUTION can be set by the CTRL-C handler to temporary disable CTRL-C
####   The signal handler will reset the variable to ${__FALSE} again
####
__CONTINUE_SCRIPT_EXECUTION=${__FALSE}

#### __IN_DEBUG_SHELL is set to ${__TRUE} if the function DebugShell is active
####
__IN_DEBUG_SHELL=${__FALSE}

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

#### __DEBUG_PREFIX - prefix for debug messages printed with LogDebugMsg
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

#### __PRINT_LIST_OF_WARNINGS_MSGS - print the list of warning messages at script end (def.: false)
####   Note: Do not change this variable direct -- change __PRINT_SUMMARIES instead
####
__PRINT_LIST_OF_WARNINGS_MSGS=${__FALSE}

#### __PRINT_LIST_OF_ERROR_MSGS - print the list of error messages at script end (def.: false)
####   Note: Do not change this variable direct -- change __PRINT_SUMMARIES instead
####
__PRINT_LIST_OF_ERROR_MSGS=${__FALSE}

#### __PRINT_SUMMARIES - print error/warning msg summaries at script end
####
####   print error and/or warning message summaries at script end
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
# variable lists for the function print_runtime_variables
#
__PRT_VAR_LISTS="
__PRT_APPLICATION_VARIABLES
__PRT_USED_ENVIRONMENT_VARIABLES
__PRT_LOG_VAR_LIST
__PRT_DEFAULT_VAR_LIST
__PRT_CONFIG_VAR_LIST
__PRT_HOUSEKEEPING_VAR_LIST
__PRT_SIGNALHANDLER_VAR_LIST
__PRT_DUMP_VAR_LIST
__PRT_SCRIPT_VAR_LIST
__PRT_DEBUG_VAR_LIST
__PRT_PARAMETER_VAR_LIST
__PRT_SCRIPT_REQUIREMENT_VAR_LIST
__PRT_RUNTIME_VAR_LIST
__PRT_OS_ENVIRONMENT_VAR_LIST
__PRT_INTERNAL_VARIABLES
"

__PRT_INTERNAL_VARIABLES="
#All_internal_variables:
$( set | grep "^__" | cut -f1 -d"=" | egrep -v "__LONG_USAGE_HELP|__SHORT_USAGE_HELP|__OTHER_USAGE_EXAMPLES|__CONFIG_PARAMETER" )
"

__PRT_USED_ENVIRONMENT_VARIABLES="
#Environment_variables_used_by_the_script: 
$( echo "${__USED_ENVIRONMENT_VARIABLES}" | cut -c6- )
"

__PRT_LOG_VAR_LIST="
#Logging_variables:
__DEF_LOGFILE
__LOGFILE
__DEBUG_PREFIX
__INFO_PREFIX
__WARNING_PREFIX
__ERROR_PREFIX
__RUNTIME_INFO_PREFIX
__NO_TIME_STAMPS
__NO_HEADERS
__NOECHO
__USE_TTY
__NO_OF_WARNINGS
__LIST_OF_WARNINGS
__NO_OF_ERRORS
__LIST_OF_ERRORS
"

__PRT_CONFIG_VAR_LIST="
#configfile_variables:
CONFIG_FILE
__CONFIG_PARAMETER
__CONFIG_FILE_FOUND
__CONFIG_FILE
"

__PRT_HOUSEKEEPING_VAR_LIST="
#Housekeeping_variables:
__NO_CLEANUP
__NO_EXIT_ROUTINES
__NO_KILL_PROCS
__NO_TEMPFILES_DELETE
__NO_TEMPMOUNTS_UMOUNT
__NO_TEMPDIR_DELETE
__NO_FINISH_ROUTINES
__CLEANUP_ON_ERROR
__EXITROUTINES
__FINISHROUTINES
__LIST_OF_TMP_MOUNTS
__LIST_OF_TMP_DIRS
__LIST_OF_TMP_FILES
__PROCS_TO_KILL
__PROCS_KILL_TIMEOUT
__SYSCMDS
__SYSCMDS_FILE
__PRINT_LIST_OF_WARNINGS_MSGS
__PRINT_LIST_OF_ERROR_MSGS
__PRINT_SUMMARIES
"

__PRT_SIGNALHANDLER_VAR_LIST="
#SignalHandler_variables:
__GENERAL_SIGNAL_FUNCTION
__SIGNAL_SIGUSR1_FUNCTION
__SIGNAL_SIGUSR2_FUNCTION
__SIGNAL_SIGHUP_FUNCTION
__SIGNAL_SIGINT_FUNCTION
__SIGNAL_SIGQUIT_FUNCTION
__SIGNAL_SIGTERM_FUNCTION
__TRAP_SIGNAL
INTERRUPTED_FUNCTION
__REBOOT_REQUIRED
__REBOOT_PARAMETER
"

__PRT_DUMP_VAR_LIST="
#Dump_variables:
__CREATE_DUMP
__DUMPDIR
__DUMP_ALREADY_CREATED
"

__PRT_SCRIPT_VAR_LIST="
#Script_variables:
__SCRIPTNAME
__SCRIPTDIR
__REAL_SCRIPTDIR
__SCRIPT_VERSION
__SCRIPT_TEMPLATE_VERSION
__KSH_VERSION
__USE_ONLY_KSH88_FEATURES
__RUNNING_IN_TERMINAL_SESSION
__SHEBANG
__SCRIPT_SHELL
__SCRIPT_SHELL_OPTIONS
__SHELL
__SHELL_FIELD
"

__PRT_DEBUG_VAR_LIST="
#Debug_variables:
__ENABLE_DEBUG
__DEBUG_CODE
__FUNCTION_INIT
__FUNCTION_EXIT
__DEBUG_LOGFILE
__TRACE_LOGFILE
__LOG_DEBUG_MESSAGES
__DEBUG_SHELL_IN_ASKUSER
__ACTIVATE_TRACE
__TRACE_ACTIVE
__TYPESET_F_SUPPORTED
"

__PRT_PARAMETER_VAR_LIST="
#Parameter_values:
__SETOPTS
__USE_RBAC
__RBAC_BINARY
__TEE_OUTPUT_FILE
__NO_HEADERS
__QUIET_MODE
__VERBOSE_MODE
__VERBOSE_LEVEL
__RT_VERBOSE_LEVEL
__FORCE
__USE_COLORS
__OVERWRITE_MODE
__PRINT_SUMMARIES
__NEW_LOGFILE
"
__PRT_SCRIPT_REQUIREMENT_VAR_LIST="
#Script_requirements
__MUST_BE_ROOT
__REQUIRED_USERID
__REQUIRED_ZONES
__ONLY_ONCE
__REQUIRED_OS
__REQUIRED_OS_VERSION
__REQUIRED_MACHINE_PLATFORM
__REQUIRED_MACHINE_CLASS
__REQUIRED_MACHINE_ARC
"

__PRT_RUNTIME_VAR_LIST="
#runtime_variables
__TEMPDIR
__NO_OF_TEMPFILES
__TEMPFILE_UMASK
__STACK_POINTER
__STTY_SETTINGS
__INCLUDE_SCRIPT_RUNNING
__PIDFILE
__LOCKFILE
__LOCKFILE_CREATED
__START_TIME_IN_SECONDS
"

__PRT_OS_ENVIRONMENT_VAR_LIST="
#OS_environment
__HOSTNAME
__NODENAME
__OS_FULLNAME
__MACHINE_SUB_CLASS
__ZONENAME
__OS_VERSION
__OS_RELEASE
__MACHINE_CLASS
__MACHINE_SUB_CLASS
__MACHINE_PLATFORM
__MACHINE_SUBTYPE
__MACHINE_ARC
__RUNLEVEL
__SAVE_LANG
__START_DIR
__START_DIR_REAL
__LOGIN_USERID
__USERID
"

# -----------------------------------------------------------------------------
# init the global variables
#

#### ##### defined variables that should not be changed
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

#### __CONFIG_FILE - name of the default config file
####   (use ReadConfigFile to read the config file;
####   use WriteConfigFile to write it)
####   use none to disable the config file feature
####
__CONFIG_FILE="${__SCRIPTNAME%.*}.conf"

#### __PIDFILE - save the pid of the script in a file if this variable is defined
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


# only used in Linux:
#
_SYSTEMD_IS_USED=${__FALSE}

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
#
# code disabled because prtdiag takes to much time on newer SPARC machines 
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
        ps -p 1 | grep systemd >/dev/null && __SYSTEMD_IS_USED=${__TRUE} || __SYSTEMD_IS_USED=${__FALSE}
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


    * )
       __ZONENAME=""
       __MACHINE_PLATFORM=""
       __MACHINE_CLASS=""
       __MACHINE_PLATFORM=""
       __MACHINE_SUBTYPE=""
       __MACHINE_ARC=""
       __RUNLEVEL="?"
       ;;

esac

#### __START_DIR - working directory when starting the script (may be a symbolic link)
####
__START_DIR="$( pwd )"


#### __START_DIR_REAL - working directory when starting the script (symbolic links resolved)
####
__START_DIR_REAL="$( pwd -P )"


#### __LOGFILE - fully qualified name of the logfile used
####   use the parameter -l to change the logfile
####
##   in Solaris /tmp is mounted on a RAM disk so we check if /var/tmp
##   exists first
##
if [ -d /var/tmp ] ; then
  __DEF_LOGFILE="/var/tmp/${__SCRIPTNAME%.*}.log"
else
  __DEF_LOGFILE="/tmp/${__SCRIPTNAME%.*}.log"
fi

__LOGFILE="${__DEF_LOGFILE}"


#### LOGMSG_FUNCTION - function to write log messages to STDOUT or STDERR
####   default: use "echo " to write in log functions
####
: ${LOGMSG_FUNCTION:=echo}


# __GLOBAL_OUTPUT_REDIRECTION
#   status variable used by StartStop_LogAll_to_logfile
#
__GLOBAL_OUTPUT_REDIRECTION=""


# lock file (used if ${__ONLY_ONCE} is ${__TRUE})
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

#### __LOGIN_USERID - ID of the user opening the session
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
      LogHeader "No config file (\"${THIS_CONFIG}\") found (use -C to create a default config file)"
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
#### return the number of stack elements
####
#### usage: NoOfStackElements; var=$?
####
#### returns: number of elements on the stack
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####
function NoOfStackElements {
  typeset __FUNCTION="NoOfStackElements";  ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  [ ${__STACK_POINTER} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  typeset THISRC=${__STACK_POINTER}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### FlushStack
####
#### flush the stack
####
#### usage: FlushStack
####
#### returns: number of elements on the stack before flushing it
####
#### Note: NoOfStackElements, FlushStack, push and pop use only one global stack!
####       In the current implementation the stack routines only support
####       up to 255 Stack elements
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
####       In the current implementation the stack routines only support
####       up to 255 Stack elements
####
function push {
  typeset __FUNCTION="push";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

  while [ $# -ne 0 ] ; do
   (( __STACK_POINTER=__STACK_POINTER+1 ))
    __STACK[${__STACK_POINTER}]="$1"
    shift
  done

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
####       In the current implementation the stack routines only support
####       up to 255 Stack elements
####
function pop {
  typeset __FUNCTION="pop";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

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
  return ${THISRC}
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
####       In the current implementation the stack routines only support
####       up to 255 Stack elements
####
function push_and_set {
  typeset __FUNCTION="push_and_set";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

  if [ $# -ne 0 ] ; then
    typeset VARNAME="$1"
    eval push \$${VARNAME}

    shift
    eval ${VARNAME}="\"$*\""
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  case $1 in
   "y" | "Y" | "yes" | "YES" | "Yes" | "true"  | "True"  | "TRUE"  | 0 ) echo "y" ;;
   "n" | "N" | "no"  | "NO"  | "No"  | "false" | "False" | "FALSE" | 1 ) echo "n" ;;
   * ) echo "?" ;;
  esac

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  eval "[ \$$1 -eq ${__TRUE} ] && $1=${__FALSE} || $1=${__TRUE} "

  ${__FUNCTION_EXIT}
  return ${THISRC}
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

  tty -s

  typeset THISRC=$?

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
  typeset THISRC=0

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
  return ${THISRC}
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

  [ ${THISRC} -gt 255 ] && die 234 "The return value ${THISRC} is greater than 255 in function \"${__FUNCTION}\""

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

  [ ${THISRC} -gt 255 ] && die 234 "The return value ${THISRC} is greater than 255 in function \"${__FUNCTION}\""

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
#  typeset TESTVAR="$(echo "$1" | sed 's/[0-9]*//g' )"
#  [ "${TESTVAR}"x = ""x ] && return ${__TRUE} || return ${__FALSE}

  [[ $1 == +([0-9]) ]] && THISRC=${__TRUE} || THISRC=${__FALSE}

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
  typeset THISRC=0

  typeset -i16 HEXVAR
  HEXVAR="$1"
  echo ${HEXVAR##*#}

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  typeset -i8 OCTVAR
  OCTVAR="$1"
  echo ${OCTVAR##*#}

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  typeset -i2 BINVAR
  BINVAR="$1"
  echo ${BINVAR##*#}

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  typeset -u testvar="$1"

  if [ "$2"x != ""x ] ; then
    eval $2=\"${testvar}\"
  else
    echo "${testvar}"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  typeset -l testvar="$1"

  if [ "$2"x != ""x ] ; then
    eval $2=\"${testvar}\"
  else
    echo "${testvar}"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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

    THISRC=4

    ${__FUNCTION_EXIT}
    return ${THISRC}
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

  if [ ${PRINT_EXECUTED_COMMAND}x = ${__TRUE}x ] ; then
    LogMsg "Executing \"$@\" "
  else
    LogRuntimeInfo "Executing \"$@\" "
  fi
  
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
  typeset THISRC=${__FALSE}

  [ "$( id | sed 's/uid=\([0-9]*\)(.*/\1/' )" = 0 ] && THISRC=${__TRUE} || THISRC=${__FALSE}

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
      UID="$( id | sed 's/uid=\([0-9]*\)(.*/\1/' )"
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
  typeset THISRC=0

  echo "$(id | sed 's/uid=\([0-9]*\)(.*/\1/')"

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  [ "$1"x != ""x ] &&  __USERNAME=$( grep ":x:$1:" /etc/passwd | cut -d: -f1 )  || __USERNAME=""

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  [ "$1"x != ""x ] &&  __USER_ID=$( grep "^$1:" /etc/passwd | cut -d: -f3 ) || __USER_ID=""

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset __FUNCTION="PrintWithTimestamp";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset COMMAND="$*"
  typeset THISRC=0

  LogInfo "Executing \"${COMMAND}\" ..."

  ${COMMAND} | while IFS= read -r line; do
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line";
  done

  ${__FUNCTION_EXIT}
  return ${THISRC}
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

  typeset THISMSG=""
  
  if [ "$1"x = "-"x ] ; then
    shift
    THISMSG="$*"
  elif [ "${__NO_TIME_STAMPS}"x = "${__TRUE}"x ] ; then
    THISMSG="$*"
  else
    THISMSG="[$(date +"%d.%m.%Y %H:%M:%S")] $*"
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

  typeset THISMSG=""

  if [ "$1"x = "-"x ] ; then	
    shift
    THISMSG="$*"
  else
    THISMSG="[$(date +"%d.%m.%Y %H:%M:%S")] $*"
  fi

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
# Do NOT use "$*" !!!  
    LogMsg $*
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
      if [ "$1"x = "-"x ] ; then	
        shift
        LogMsg "-" "${__INFO_PREFIX} $*" >&2
        THISRC=$?
      else
        LogMsg "${__INFO_PREFIX} $*" >&2
        THISRC=$?
      fi
    fi
  fi

  [ ${THISRC} = 1 -a "${__DEBUG_LOGFILE}"x != ""x  ] && echo "${THIS_TIMESTAMP}${__INFO_PREFIX}$*" 2>/dev/null  >>"${__DEBUG_LOGFILE}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# internal sub routine for info messages from the runtime system
#
# returns: ${__TRUE} - message printed
#          ${__FALSE} - message not printed
#
function LogRuntimeInfo {
  typeset __FUNCTION="LogRuntimeInfo";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=${__FALSE}

  push ${__INFO_PREFIX}
  __INFO_PREFIX="${__RUNTIME_INFO_PREFIX}"
  LogInfo "${__RT_VERBOSE_LEVEL}" $*
  THISRC=$?
  pop __INFO_PREFIX

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# internal sub routine for header messages
#
# returns: ${__TRUE} - message printed
#          ${__FALSE} - message not printed
#
function LogHeader {
  typeset __FUNCTION="LogHeader";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
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

  if [ "$1"x = "-"x ] ; then	
    shift
    LogMsg "-" "${__WARNING_PREFIX}$*" >&2
    THISRC=$?
  else
    LogMsg "${__WARNING_PREFIX}$*" >&2
    THISRC=$?
  fi
  
  THISRC=$?
  (( __NO_OF_WARNINGS = __NO_OF_WARNINGS +1 ))
  __LIST_OF_WARNINGS="${__LIST_OF_WARNINGS}
${__WARNING_PREFIX}$*"

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

  if [ ${__LOG_DEBUG_MESSAGES} = ${__TRUE} ] ; then
    LogMsg "${__DEBUG_PREFIX}$*" >&2
    THISRC=$?
  fi

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

    if [ "$1"x = "-"x ] ; then	
      shift
      LogMsg "-" "${__ERROR_PREFIX}$*" >&3
      THISRC=$?
    else
      LogMsg "${__ERROR_PREFIX}$*" >&3
      THISRC=$?
    fi
    
  else
    if [ "$1"x = "-"x ] ; then	
      shift
      LogMsg "-" "${__ERROR_PREFIX}$*" >&2
      THISRC=$?
    else
      LogMsg "${__ERROR_PREFIX}$*" >&2
      THISRC=$?
    fi

  fi

  (( __NO_OF_ERRORS=__NO_OF_ERRORS + 1 ))
  __LIST_OF_ERRORS="${__LIST_OF_ERRORS}
${__ERROR_PREFIX}$*"

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
#### returns: ${__TRUE} - done;
####          ${__FALSE} - error creating a backup of the file ${__BACKUP_FILE_ERROR}
####
#### The function returns after the first error; no backups will be created for the remaining files in the parameter
####
#### If successfull ${__BACKUP_FILE} contains the name(s) of the backup file(s).
#### If no backup was created ${__BACKUP_FILE} is empty
####
function BackupFileIfNecessary {
  typeset __FUNCTION="BackupFileIfNecessary";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  typeset FILES_TO_BACKUP="$*"
  typeset CURFILE=""
  typeset CUR_BKP_FILE=""
  typeset NO_OF_BACKUPS=:
  typeset -i i=
  typeset -i j=
  typeset THISRC=${__TRUE}

  __BACKUP_FILE_ERROR=""
  __BACKUP_FILE=""

  if [ ${__OVERWRITE_MODE} -eq ${__FALSE} ] ; then
    for CURFILE in ${FILES_TO_BACKUP} ; do

      __BACKUP_FILE_ERROR=""

      NO_OF_BACKUPS="${CURFILE#*,}"
      CURFILE="${CURFILE%,*}"

      if [ ! -f "${CURFILE}" ] ; then
        LogRuntimeInfo "\"${CURFILE}\" does not exit - no backup must be created."
        continue
      fi

      if [ "${CURFILE}"x = "${NO_OF_BACKUPS}"x ] ; then
# only one backup version requested
#
        CUR_BKP_FILE="${CURFILE}${BACKUP_EXTENSION:=.$$}"
        LogMsg "Creating a backup of \"${CURFILE}\" in \"${CUR_BKP_FILE}\" ..."
        cp -f "${CURFILE}" "${CUR_BKP_FILE}"
        THISRC=$?
        if [ ${THISRC} -ne 0 ] ; then
          LogError "Error creating the backup of the file \"${CURFILE}\""
          __BACKUP_FILE_ERROR="${CURFILE}"
          break
        else
          __BACKUP_FILE="${__BACKUP_FILE} ${CUR_BKP_FILE}"
        fi
      elif ! isNumber ${NO_OF_BACKUPS}  ; then
# invalid usage
        LogError "Backup file ${CURFILE}: Specified backup count (${NO_OF_BACKUPS}) is not a number, creating only one backup"
        BackupFileIfNecessary "${CURFILE}"
        THISRC=$?
      elif [ ${NO_OF_BACKUPS} = 0 ] ; then
        LogRuntimeInfo "The backup count for ${CURFILE} is 0 - no backup must be created."
        continue
      else
        i="${NO_OF_BACKUPS}"
        CUR_BKP_FILE="${CURFILE}"

        LogRuntimeInfo "Creating up to ${NO_OF_BACKUPS} backups of the file \"${CURFILE}\" ..."

        (( i = i - 1 ))
        if [ -r "${CUR_BKP_FILE}.${i}" ] ; then
          LogRuntimeInfo "  Removing the old backup file \"${CUR_BKP_FILE}.${i}\" "
          rm -f "${CUR_BKP_FILE}.${i}" || THISRC=${__FALSE}
        fi

        while [ $i -ge 1 ] ; do
          (( j = i - 1 ))
          if [ -r "${CUR_BKP_FILE}.${j}" ] ; then
            LogRuntimeInfo "  Renaming \"${CUR_BKP_FILE}.${j}\" to \"${CUR_BKP_FILE}.${i}\" ..."
            rm -f "${CUR_BKP_FILE}.${i}" 2>/dev/null
            mv -f "${CUR_BKP_FILE}.${j}" "${CUR_BKP_FILE}.${i}" || THISRC=${__FALSE}
          fi
          (( i = i - 1 ))

        done

        LogRuntimeInfo "  Copying \"${CUR_BKP_FILE}\" to \"${CUR_BKP_FILE}.${i}\" ..."
        cp -f "${CURFILE}" "${CUR_BKP_FILE}.${i}"
        THISRC=$?
        if [ ${THISRC} -ne 0 ] ; then
          LogError "Error creating the backup of the file \"${CURFILE}\""
          __BACKUP_FILE_ERROR="${CURFILE}"
          break
        fi
        __BACKUP_FILE="${__BACKUP_FILE} ${CUR_BKP_FILE}.${i}"
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
        cd "$1" && find . -depth -print | cpio -pdum "$2"
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
####
function DebugShell {
  [ ${__ENABLE_DEBUG} != ${__TRUE} ] && return 0
  
  [ "${__IN_DEBUG_SHELL}"x = "${__TRUE}"x ] && return 0

  __DEBUG_SHELL_CALLED=${__TRUE}

  "typeset" THISRC=${__TRUE}

  "typeset" CONT_DESC0=" "
  "typeset" CONT_DESC1=""
  "typeset" CONT_DESC2=""
  
  "typeset" CUR_STATEMENT=""
  "typeset" CUR_VAR=""
  "typeset" CUR_VALUE=""
  "typeset" ADD_CODE=""
  
  if [ "${__RUNNING_IN_TERMINAL_SESSION}"x != "${__TRUE}"x ] ; then
    LogError "DebugShell can only be used in an interactive session"
    __IN_DEBUG_SHELL=${__FALSE}
    THISRC=${__FALSE}
  else
    __IN_DEBUG_SHELL=${__TRUE}   
     
    if [ "${__IN_BREAK_HANDLER}"x = "${__TRUE}"x ] ; then
      CONT_DESC0=" (called via CTRL-C) " 
      CONT_DESC1="cont = continue script execution"
      CONT_DESC2="cont                          - continue the script execution"
      "printf" "*** Debug Shell called via CTRL-C ***\n"
    fi
      
    "typeset" USER_INPUT=""
    "typeset" CMD_PARAMETER=""
    
#    echo "USER_INPUT=\"${USER_INPUT}\""
#    echo "CMD_PARAMETER=\"${CMD_PARAMETER}\" "
    
    while "true" ; do
      "printf" "\n ------------------------------------------------------------------------------- \n"
      "printf" "${__SCRIPTNAME} - debug shell${CONT_DESC0}- enter a command to execute (\"exit\" to leave the shell)\n"
      "printf" "  defined aliase: functions = list all defined functions, vars [help|var_list] = print global variables, \n"
      "printf" "                  quit = exit the script, abort = abort the script with kill -9, use help for short usage help\n"
      "printf" "                  ${CONT_DESC1}\n"
      
      "printf" ">> "
      "read" USER_INPUT
      CMD_PARAMETER="${USER_INPUT#* }"

      case "${USER_INPUT}" in

        "help" | "help "* )

           if [ "${CMD_PARAMETER}"x = "var"x -o "${CMD_PARAMETER}"x = "vars"x ] ; then
             print_runtime_variables help           
           else
             "printf" "
Enter either an defined alias or an OS command to execute

Defined aliase are:

functions                     - print all defined functions
func f1 [...f#]               - view the source code for the functions f1 to f# 
                                (supported by this shell: ${__TYPESET_F_SUPPORTED})

add_debug_code f1 [...f#]     - add debug code to the functions f1 to f#; use all for f1 to add
                                debug code to all functions
                                (supported by this shell: ${__TYPESET_F_SUPPORTED})
                      
view_debug                    - view the current debug code
set_debug f1 [...f#]          - enable tracing for the functions f1 to f#
                                Note: The existing trace definitions will be overwritten!
clear_debug                   - disable tracing for all functions

vars help                     - print defined variable lists
vars var_list                 - print the variable from the variable list 'var_list'
vars all                      - print all variables

verbose                       - toggle the verbose switch (current value is: ${__VERBOSE_MODE}, __VERBOSE_LEVEL is ${__VERBOSE_LEVEL})
break                         - toggle the break switch (current value is: ${__USER_BREAK_ALLOWED})

exit                          - exit the shell
quit                          - exit the script
abort                         - exit the script with 'kill -9'
${CONT_DESC2}

Everthing else is interpreted as an OS command

"
           fi
           ;;

        "cont" | "continue" )
           if [ "${__IN_BREAK_HANDLER}"x = "${__TRUE}"x ] ; then
             __CONTINUE_SCRIPT_EXECUTION=${__TRUE}
             "break"
           else
             "printf" "\"cont\" is only supported in CTRL-C handler"
           fi
           ;;

        "exit" )
          "break";
          ;;

        "quit" )
          die 254 "${SCRIPTNAME} aborted by the user"
          ;;

        "abort" )
          LogMsg "${SCRIPTNAME} aborted with \"kill -9\" by the user"
          "kill" -9 $$
          ;;


        "verbose" )
          "printf" "Toggling the verbose mode now ...\n"
          InvertSwitch __VERBOSE_MODE
          "printf" "The verbose mode is now ${__VERBOSE_MODE}\n"
          ;;

        "break" )
          "printf" "Toggling the break mode now ...\n"
          InvertSwitch __USER_BREAK_ALLOWED
          "printf" "The break mode is now ${__USER_BREAK_ALLOWED}\n"
          ;;
           
        "view_debug" )
          "printf" "The current debug code for all functions (__DEBUG_CODE) is:\n${__DEBUG_CODE}\n"
          ;;

        "add_debug_code"* )
          if [ "${CMD_PARAMETER}"x = "all"x ] ; then
            CMD_PARAMETER="$( "typeset" +f )"
          fi
        
          for CUR_PARM in ${CMD_PARAMETER} ; do
            "typeset" +f "${CUR_PARM}" 2>/dev/null 1>/dev/null
            if [ $? -ne 0 ] ; then
              "printf" "The function ${CUR_PARM} is not defined\n"
              "continue"
            fi
            "typeset" -f "${CUR_PARM}" | grep \__DEBUG_CODE >/dev/null
            if [ $? -eq 0 ] ; then
              "printf" "The function ${CUR_PARM} is already debug enabled\n"
              "continue"
            fi
            "printf" "Adding debug code to the function ${CUR_PARM} ...\n"   

            ADD_CODE=" typeset __FUNCTION=${CUR_PARM}; "
            eval "$( typeset -f  "${CUR_PARM}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	                    
          done
          ;;

        clear_debug )
          "printf" "Clearing the debug code now ...\n"
          __DEBUG_CODE=""
          ;;
          
        debug* | set_debug* )
          if [ "${CMD_PARAMETER}"x != ""x ] ; then
            "printf" "Enabling debug code for the functions \"${CMD_PARAMETER}\" now"

            CUR_STATEMENT="[ 0 = 1 "
            for CUR_VALUE in ${CMD_PARAMETER} ; do
              CUR_STATEMENT="${CUR_STATEMENT} -o \"\${__FUNCTION}\"x = \"${CUR_VALUE}\"x "

              if ! "typeset" +f "${CUR_VALUE}" >/dev/null ; then
                "printf" "The function \"${CUR_VALUE}\" is not defined\n"
                 continue
              fi
 
              if [ "${__TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
                "printf" "\"typeset -f\" required for \"func\" is NOT supported by this shell"
                continue
              fi
      
              if [[ $( "typeset" -f "${CUR_VALUE}" 2>&1 ) != *\$\{__DEBUG_CODE\}* ]] ; then
                "printf" "Adding debug code to the function ${CUR_VALUE} ...\n"           
                ADD_CODE=" typeset __FUNCTION=${CUR_PARM}; "
                eval "$( typeset -f  "${CUR_PARM}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	                                    
              fi   
            done
            CUR_STATEMENT="eval ${CUR_STATEMENT} ] && printf \"\n*** Enabling trace for the function \${__FUNCTION} ...\n\" >&2 && set -x "
            __DEBUG_CODE="${CUR_STATEMENT}"
          else
            "printf" " ${USER_INPUT}: Parameter missing"
          fi 
          ;;

        "vars" | "variables" )
          print_runtime_variables all >"/dev/tty"
          ;;

        "vars"* | "variables"* )
          print_runtime_variables ${CMD_PARAMETER} >"/dev/tty"
          ;;
        
        "functions"  | "funcs" )
          "typeset" +f  
          ;;

        "func "* )
          if [ "${__TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
            "printf" "\"typeset -f\" required for \"func\" is NOT supported by this shell"
            continue
          fi

          for CUR_VALUE in ${CMD_PARAMETER} ; do
            "typeset" +f "${CUR_VALUE}" # 2>/dev/null 1>/dev/ull
            if [ $? -ne 0 ] ; then
              "printf" "Function ${CUR_VALUE} is not defined. Use \"func\" to view all defined functions.\n"
            else
              "typeset" -f "${CUR_VALUE}" 
            fi
          done
          ;;

        "" )
          :
          ;;

        * )
          "eval" ${USER_INPUT}
          ;;
        
      esac
    done </dev/tty >/dev/tty 2>&1
  fi

  __IN_DEBUG_SHELL=${__FALSE}

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
#### "shell" opens the DebugShell; set __DEBUG_SHELL_IN_ASKUSER to ${__FALSE}
#### to disable the DebugShell in AskUser
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
#### Usage: GetKeystroke [upper|lower] "message"
####
#### returns: 0
####          USER_INPUT contains the user input (converted to uppercase or lowercase if requested)
####          RAW_USER_INPUT contains unconverted user input
####
#### Sample key codes in RAW_USER_INPUT :
####
####  $'\E'     ESC
####   $'\r'    RETURN or CTRL-M
####
####  $'\f'     CTRL-L
####  $'\a'     CTRL-G
####  $'\b'     CTRL-H
####  $'\t'     TAB or CTRL-I
####  $'\x01'   CTRL-A
####  $'\x02'   CTRL-B
####  $'\x03'   CTRL-C
####  $'\x04'   CTRL-E
####  $'\x05'   CTRL-F
####  $'\x06'   CTRL-G
####  $'\x0b'   CTRL-K
####  $'\x0e'   CTRL-N
####  $'\x0f'   CTRL-O
####  $'\x10'   CTRL-P
####  ...
####  $'\x15'   CTRL-U
####  ...
####  $'\x1a'   CTRL-Z
####  $'\E[5~'  PageUp
####  $'\E[6~'  PageDown
####  $'\E[B'   CursorDown
####  $'\E[A'   CursorUp
####  $'\E[D'   CursorLeft
####  $'\E[C'   CursorRight
####  $'\EOH'   Home
####  $'\EOF'   End
####  $'\E[2~'  Insert
####  $'\E[3~'  Delete
####
####  $'\E[4~'  End (Numblock)
####  $'\E[1~'  Home (Numblock)
####  $'\E[E'   5 (Numblock, NumOff)
####
function GetKeystroke {
  typeset __FUNCTION="GetKeystroke";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

  typeset TO_UPPER=${__FALSE}
  typeset TO_LOWER=${__FALSE}

  if [ "$1"x = "upper"x ] ; then
    TO_UPPER=${__TRUE}
    typeset -u TMPVAR=""
    shift
  elif [ "$1"x = "lower"x ] ; then
    TO_LOWER=${__TRUE}
    typeset -l TMPVAR=""
    shift
  else
    typeset TMPVAR=""
  fi

  [ $# -ne 0 ] && PrintLine "$*"

  __STTY_SETTINGS="$( stty -g )"

  stty -echo raw
  RAW_USER_INPUT=$( dd count=1 2> /dev/null )

  stty ${__STTY_SETTINGS}
  __STTY_SETTINGS=""

  if [ "${RAW_USER_INPUT}" = $'\x03' -a ${__USER_BREAK_ALLOWED} == ${__TRUE} ] ; then
    LogMsg "-"
    die 252 "Script aborted by the user via signal BREAK (CTRL-C)"
  fi

#  trap 2 3

# convert the input to lowercase or uppercase if requested
#
  TMPVAR="${RAW_USER_INPUT}"

# and set the result variable
#
  USER_INPUT="${TMPVAR}"

# if typeset -l / -u does not work this code could be used:
#
#  if [ ${TO_UPPER} -eq ${__TRUE} ] ; then
#    USER_INPUT="$( echo "${RAW_USER_INPUT}" | tr "a-z" "A-Z" )"
#  elif [ ${TO_LOWER} -eq ${__TRUE} ] ; then
#    USER_INPUT="$( echo "${RAW_USER_INPUT}" | tr "A-Z" "a-z" )"
#  else
#    USER_INPUT="${RAW_USER_INPUT}"
#  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

  if [ ${__REBOOT_REQUIRED} -eq 0 ] ; then
    LogMsg "The changes made to the system require a reboot"

    AskUser "Do you want to reboot now (y/n, default is NO)?"
    if [ $? -eq ${__TRUE} ] ; then
      LogMsg "Rebooting now ..."
      echo "???" reboot ${__REBOOT_PARAMETER}
    fi
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
####     - prints a script end message and the program return code
#### and
####     - and ends the program or reboots the machine if requested
####
####
function die {
  typeset __FUNCTION="die";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}

  __unsettraps

  [ "${__TRAP_SIGNAL}"x != ""x ] &&  LogRuntimeInfo "__TRAP_SIGNAL is \"${__TRAP_SIGNAL}\""

  typeset THISRC=$1
  [ $# -ne 0 ] && shift

  if [ "$*"x != ""x ] ; then
    [ ${THISRC} = 0 ] && LogMsg "$*" || LogError "$*"
  fi

  if [ "${__NO_CLEANUP}"x != ${__TRUE}x  ] ; then
    cleanup
  else
    LogMsg "die(): __NO_CLEANUP set -- skipping the cleanup at script end at all"
    LogMsg "die(): Debug Info: Defined processes to kill are: ${__PROCS_TO_KILL:=none}"
    LogMsg "die(): Debug Info: Defined temporary files are: ${__LIST_OF_TMP_FILES:=none}"
    LogMsg "die(): Debug Info: Defined exit routines are: ${__EXITROUTINES:=none}"
    LogMsg "die(): Debug Info: Defined temporary mount points are: ${__LIST_OF_TMP_MOUNTS:=none}"
    LogMsg "die(): Debug Info: Defined temporary directories are: ${__LIST_OF_TMP_DIRS:=none}"
    LogMsg "die(): Debug Info: Defined finish routines are: ${__FINISHROUTINES:=none}"

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

  __END_TIME_IN_SECONDS="$( GetSeconds )"

  LogHeader "${__SCRIPTNAME} ${__SCRIPT_VERSION} started at ${__START_TIME} and ended at ${__END_TIME}."

  if [ "${__END_TIME_IN_SECONDS}"x != ""x -a  "${__START_TIME_IN_SECONDS}"x != ""x ] ; then
    (( __RUNTIME_IN_SECONDS = __END_TIME_IN_SECONDS - __START_TIME_IN_SECONDS ))
    (( __RUNTIME_IN_MINUTES = __RUNTIME_IN_SECONDS / 60 ))
    (( __RUNTIME_IN_SECONDS = __RUNTIME_IN_SECONDS % 60 ))

    LogHeader "The time used for the script is ${__RUNTIME_IN_MINUTES} minutes and ${__RUNTIME_IN_SECONDS} seconds."
  fi

  LogHeader "The RC is ${THISRC}."

  __EXIT_VIA_DIE=${__TRUE}

  if [ "${__GLOBAL_OUTPUT_REDIRECTION}"x != ""x ]  ; then
    StartStop_LogAll_to_logfile "stop"
  fi

  RemoveLockFile

  RebootIfNecessary

  ${__FUNCTION_EXIT}
  exit ${THISRC}
}



#### ---------------------------------------
#### tryIncludeScript
####
#### include a script via . [scriptname] if it exists and is error free
####
#### usage: tryIncludeScript [scriptname]
####
#### returns: $? after including the script if the script was executed else 0
####
#### Ouptut variables:
####
#### __INCLUDE_SCRIPT_CHECK_OUTPUT=<output of the script check>
####
#### __INCLUDE_SCRIPT_RC - result code; known values:
####
####    0  - script found, checked, and executed
####    1  - script not found
####    2  - script has syntax errors
####    3  - tryIncludeScript called without parameter
####
####
#### notes:
####
####    first check the variable  __INCLUDE_SCRIPT_RC then the return code!
####
function tryIncludeScript {
  typeset __FUNCTION="tryIncludeScript";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0
  typeset THIS_OUTPUT=""

  typeset INCLUDE_FILE="$1"
  [ $# -ne 0 ] && shift

  typeset THIS_SHELL="${__SHELL}"
  [ "${THIS_SHELL}"x = ""x ] && THIS_SHELL="${__SCRIPT_SHELL}}"

# use the bash variable SHELL if set
#
  [ "${THIS_SHELL}"x = ""x ] && THIS_SHELL="${SHELL}"

# no shell variable set -- use ksh
#
  [ "${THIS_SHELL}"x = ""x ] && THIS_SHELL="ksh"

  if [ "${INCLUDE_FILE}"x != ""x ] ; then

    LogRuntimeInfo "Including the script \"${INCLUDE_FILE}\" ..."

    [[ ${INCLUDE_FILE} != */* ]] && INCLUDE_FILE="./${INCLUDE_FILE}"

    if [ ! -r "${INCLUDE_FILE}" ] ; then
      __INCLUDE_SCRIPT_RC=1
    else

# check the script syntax
      THIS_OUTPUT="$( ${THIS_SHELL} -n  "${INCLUDE_FILE}" 2>&1 )"
      if [ $? -ne 0 ] ; then
        __INCLUDE_SCRIPT_RC=2
        __INCLUDE_SCRIPT_CHECK_OUTPUT="${THIS_OUTPUT}"
      else
        __INCLUDE_SCRIPT_RC=0

# set the variable for the TRAP handlers
        __INCLUDE_SCRIPT_RUNNING="${INCLUDE_FILE}"

# include the script
        . ${INCLUDE_FILE} $*
        THISRC=$?

# reset the variable for the TRAP handlers
        __INCLUDE_SCRIPT_RUNNING=""
      fi
    fi
  else
     __INCLUDE_SCRIPT_RC=3
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### ---------------------------------------
#### includeScript
####
#### include a script via . [scriptname]
####
#### usage: includeScript [scriptname]
####
#### returns: $? after including the script if the script was executed
####
#### notes:
####
#### includeScript aborts the script via die() if the include file
#### does not exist or has syntax errors
####
function includeScript {
  typeset __FUNCTION="includeScript";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

  if [ $# -ne 0 ] ; then
    tryIncludeScript $*
    THISRC=$?

    case ${__INCLUDE_SCRIPT_RC} in

      0 )
        :  # script found, checked, and executed
        ;;

      1 )
        die 247 "Include script \"$1\" not found"
        ;;

      2 )
        LogError "Errors found in the include file \"$1\" are:"
        LogMsg "-" "${__INCLUDE_SCRIPT_CHECK_OUTPUT}"
        die 228 "There is an error in an include script"
        ;;

      * )
        die 240 "internal error: TryIncludeScript signaled error ${__INCLUDE_SCRIPT_RC}"
        ;;
    esac
  else
    die 240 "internal error: IncludeScript called without parameter"
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
      LogRuntimeInfo "The function \"${THIS_FUNCTION}\" is defined; now calling with \"${THIS_FUNCTION} $@\" ..."
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

  typeset THISRC=${__FALSE}

  if [ "${RANDOM}"x != ""x ] ; then
    echo ${RANDOM}
    THISRC=${__TRUE}
  elif whence ${AWK} >/dev/null ; then
    ${AWK} 'BEGIN { srand(); printf "%d\n", (rand() * 10^8); }'
    THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=250

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
  return ${THISRC}
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
  typeset THISRC

# for compatibilty reasons the old code can still be activated if necessary
  typeset __USE_OLD_CODE=${__FALSE}

  typeset LN_RC=""

  LogRuntimeInfo "Trying to create the lock semaphore \"${__LOCKFILE}\" ..."
  if [ ${__USE_OLD_CODE} = ${__TRUE} ] ; then
# old code using ln
    ln -s  "$0" "${__LOCKFILE}" 2>>/dev/null
    LN_RC=$?
  else
    __INSIDE_CREATE_LOCKFILE=${__TRUE}

# improved code from wpollock (see credits)
    if [ -f "${__LOCKFILE}" ] ; then
      LN_RC=1
    else
      set -C  # or: set -o noclobber
      : > "${__LOCKFILE}" 2>>/dev/null
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
  elif [ ${__LOCKFILE_CREATED} -eq ${__TRUE} ] ; then
    LogRuntimeInfo "Removing the lock semaphore ..."

    rm "${__LOCKFILE}" 1>/dev/null 2>/dev/null
    [ $? -eq 0 ] && THISRC=0
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
  typeset RAND=""
  
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

      echo >"${CURFILE}" || return $?
    else
# improved code from wpollock (see credits)
      set -C  # turn on noclobber shell option

      while : ; do
        eval __TEMPFILE${i}="${__TEMPDIR}/${__SCRIPTNAME}.$$._${RANDOM}_.TEMP${i}"
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
#
# house keeping at script end
#
# usage: [called by the runtime system]
#
# returns: 0
#
# notes:
#  execution order is
#    - write executed commands to ${__SYSCMDS_FILE} if requested
#    - call exit routines from ${__EXITROUTINES}
#    - kill all processes from ${__PROCS_TO_KILL}
#    - remove files from ${__LIST_OF_TMP_FILES}
#    - umount mount points ${__LIST_OF_TMP_MOUNTS}
#    - remove directories ${__LIST_OF_TMP_DIRS}
#    - call finish routines from ${__FINISHROUTINES}
#
function cleanup {
  typeset __FUNCTION="cleanup";    ${__FUNCTION_INIT} ; ${__DEBUG_CODE}
  typeset THISRC=0

  typeset EXIT_ROUTINE=
  typeset OLDPWD="$( pwd )"
  typeset CUR_PID=""
  typeset CUR_KILL_PROC_TIMEOUT=""
  typeset i=0
  typeset ROUTINE_PARAMETER=""
    
  cd /tmp

# write __SYSCMDS
  if [ "${__SYSCMDS_FILE}"x != ""x -a "${__SYSCMDS}"x != ""x ] ; then
    LogRuntimeInfo "Writing the list of executed commands to the file \"${__SYSCMDS_FILE}\" ..."
    echo "
# ---------------------------------------------------------------------
# [$(date +"%d.%m.%Y %H:%M:%S")] ${__SCRIPTNAME} ${__SCRIPT_VERSION} started at ${__START_TIME}
# OS commands executed in this run:
${__SYSCMDS}
# ---------------------------------------------------------------------
" >>"${__SYSCMDS_FILE}"
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

        ROUTINE_PARAMETER="${EXIT_ROUTINE#*:}"
        EXIT_ROUTINE="${EXIT_ROUTINE%%:*}"
        [ "${EXIT_ROUTINE}"x = "${ROUTINE_PARAMETER}"x ] && ROUTINE_PARAMETER="" || ROUTINE_PARAMETER="$( IFS=: ; printf "%s " ${ROUTINE_PARAMETER}  )"

        typeset +f | grep "^${EXIT_ROUTINE}" >/dev/null
        if [ $? -eq 0 ] ; then
        LogRuntimeInfo "Now calling the exit routine \"${EXIT_ROUTINE}\" (Parameter are: \"${ROUTINE_PARAMETER}\") ..."
        __INSIDE_EXIT_ROUTINE=${__TRUE}
        eval ${EXIT_ROUTINE} ${ROUTINE_PARAMETER}
        __INSIDE_EXIT_ROUTINE=${__FALSE}
      else
        LogError "Exit routine \"${EXIT_ROUTINE}\" is NOT defined!"
      fi
      done
    fi
  else
    LogRuntimeInfo " __NO_EXIT_ROUTINES is set -- skipping executing the exit routines"
    LogMsg "Debug Info: Defined exit routines are: ${__EXITROUTINES:=none}"
  fi

# kill still running processes
#
  if [ "${__NO_KILL_PROCS}"x != "${__TRUE}"x  ] ; then
    LogRuntimeInfo "Killing the processes \"${__PROCS_TO_KILL}\" ..."

    for CUR_PID in ${__PROCS_TO_KILL} ; do

      if [[ ${CUR_PID} == *:* ]] ; then
        CUR_KILL_PROC_TIMEOUT="${CUR_PID#*:}"
        CUR_PID=${CUR_PID%:*}
      else
        CUR_KILL_PROC_TIMEOUT=${__PROCS_KILL_TIMEOUT}
      fi

      LogRuntimeInfo "Killing the process ${CUR_PID} (Timeout is ${CUR_KILL_PROC_TIMEOUT} seconds) ..."
      ps -p ${CUR_PID} >/dev/null
      if [ $? -eq 0 ] ; then
        kill ${CUR_PID}
        
        if [  ${CUR_KILL_PROC_TIMEOUT} != -1 ] ; then
          if [  ${CUR_KILL_PROC_TIMEOUT} != 0 ] ; then
            LogRuntimeInfo "Waiting up to ${CUR_KILL_PROC_TIMEOUT} second(s) ..."
            i=0
            while [ $i -lt ${CUR_KILL_PROC_TIMEOUT} ] ; do
              sleep 1
              ps -p ${CUR_PID} >/dev/null || break
              (( i = i + 1 ))
            done
          fi
          ps -p ${CUR_PID} >/dev/null
          if [ $? -eq 0 ] ; then
            LogRuntimeInfo "Process ${CUR_PID} is still alive after kill - now using kill -9 ..."
            kill -9 ${CUR_PID}
            ps -p ${CUR_PID} >/dev/null
            if [ $? -eq 0 ] ; then
              LogError "The process ${CUR_PID} is still alive after kill -9"
            else
              LogRuntimeInfo "Process ${CUR_PID} killed with kill -9"                  
            fi
          else
            LogRuntimeInfo "Process ${CUR_PID} killed"
          fi
        else
#
# kill -9 is disabled for this PID
#
          ps -p ${CUR_PID} >/dev/null
          if [ $? -eq 0 ] ; then
            LogRuntimeInfo "Process \"${CUR_PID}\" is still alive after kill (kill -9 is disabled)."
            THISRC=${__FALSE}       
          else
            LogRuntimeInfo "Process \"${CUR_PID}\" killed"
          fi
        fi
      else
        LogRuntimeInfo "Process ${CUR_PID} is not runninng"
      fi
    done
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
    LogRuntimeInfo " __NO_TEMPFILES_DELETE is set -- skipping removing temporary files"
    LogMsg "Debug Info: Defined exit routines are: ${__EXITROUTINES:=none}"
  fi


# remove temporary mounts
  if [ "${__NO_TEMPMOUNTS_UMOUNT}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Removing temporary mounts ..."
    typeset CURENTRY
    for CURENTRY in ${__LIST_OF_TMP_MOUNTS} ; do
      mount | ${AWK} '{ print $3 };' | grep "^${CURENTRY}$" 1>/dev/null 2>/dev/null
      if [ $? -eq 0 ] ; then
        LogRuntimeInfo "Umounting \"${CURENTRY}\" ..."
        umount "${CURENTRY}"
        [ $? -ne 0 ] && LogWarning "Error umounting \"${CURENTRY}\" "
      fi
    done
  else
    LogRuntimeInfo " __NO_TEMPMOUNTS_UMOUNT is set -- skipping umounting temporary mounts"
    LogMsg "Debug Info: Defined temporary mount points are: ${__LIST_OF_TMP_MOUNTS:=none}"
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
    LogRuntimeInfo " __NO_TEMPDIR_DELETE is set -- skipping removing temporary directories"
    LogMsg "Debug Info: Defined temporary directories are: ${__LIST_OF_TMP_DIRS:=none}"
  fi

# call the defined finish routines
  if [ "${__NO_FINISH_ROUTINES}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Executing the finish routines \"${__FINISHROUTINES}\" ..."
    if [ "${__FINISHROUTINES}"x !=  ""x ] ; then
      for FINISH_ROUTINE in ${__FINISHROUTINES} ; do

        ROUTINE_PARAMETER="${FINISH_ROUTINE#*:}"
        FINISH_ROUTINE="${FINISH_ROUTINE%%:*}"
        [ "${FINISH_ROUTINE}"x = "${ROUTINE_PARAMETER}"x ] && ROUTINE_PARAMETER="" || ROUTINE_PARAMETER="$( IFS=: ; printf "%s " ${ROUTINE_PARAMETER}  )"

        typeset +f | grep "^${FINISH_ROUTINE}" >/dev/null
        if [ $? -eq 0 ] ; then
          LogRuntimeInfo "Now calling the finish routine \"${FINISH_ROUTINE}\"  (Parameter are: \"${ROUTINE_PARAMETER}\") ..."
          __INSIDE_FINISH_ROUTINE=${__TRUE}
          eval ${FINISH_ROUTINE} ${ROUTINE_PARAMETER}
         __INSIDE_FINISH_ROUTINE=${__FALSE}
        else
          LogError "Finish routine \"${FINISH_ROUTINE}\" is NOT defined!"
        fi
      done
    fi
  else
    LogRuntimeInfo " __NO_FINISH_ROUTINES is set -- skipping executing the finish routines"
    LogMsg "Debug Info: Defined finish routines are: ${__FINISHROUTINES:=none}"
  fi

  [ -d "${OLDPWD}" ] && cd "${OLDPWD}"

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
#### IsFunctionDefined
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

  [ $# -eq 1 ] && typeset +f $1 >/dev/null && THISRC=${__TRUE}

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
  [ "${__TRAP_SIGNAL}"x = "SIGINT"x ] &&  __IN_BREAK_HANDLER=${__TRUE}
  
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
        [ "${__TRAP_SIGNAL}"x = "SIGINT"x ] &&  __IN_BREAK_HANDLER=${__FALSE}
        "return"
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

          if [ ${__USER_BREAK_ALLOWED} -eq ${__TRUE} -a ${__CONTINUE_SCRIPT_EXECUTION} = ${__FALSE} ] ; then
            LogMsg "-"
            [ "${__TRAP_SIGNAL}"x = "SIGINT"x ] &&  __IN_BREAK_HANDLER=${__FALSE}
            die 252 "Script aborted by the user via signal BREAK (CTRL-C)"
          else
            LogRuntimeInfo "Break signal (CTRL-C) received and ignored (Break is disabled)"
          fi
          __CONTINUE_SCRIPT_EXECUTION=${__FALSE}
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
            DebugShell
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
              LogMsg "__CLEANUP_ON_ERROR set -- calling the function die anyway"
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

  [ "${__TRAP_SIGNAL}"x = "SIGINT"x ] &&  __IN_BREAK_HANDLER=${__FALSE}

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
  echo >"${__LOGFILE}"

  if [ "${__DEBUG_LOGFILE}"x != ""x ] ; then
    echo 2>/dev/null >"${__DEBUG_LOGFILE}"
  fi

  __START_TIME="$( date )"
  LogHeader "${__SCRIPTNAME} ${__SCRIPT_VERSION} started at ${__START_TIME}."

  LogInfo "Script template used is \"${__SCRIPT_TEMPLATE_VERSION}\" ."

  __WRITE_CONFIG_AND_EXIT=${__FALSE}

# init the variables
  eval "${__CONFIG_PARAMETER}"

# __ENABLE_DEBUG can not be changed with a config file
#
  push ${__ENABLE_DEBUG}

  if [[ ! \ $*\  == *\ -C* ]]  ; then
# read the config file
    [ "${CONFIG_FILE}"x != ""x ] && LogInfo "User defined config file is \"${CONFIG_FILE}\" "
    ReadConfigFile "${CONFIG_FILE}"
  fi
  pop __ENABLE_DEBUG

  if [ ${__ENABLE_DEBUG} != ${__TRUE} ] ; then
    __DEBUG_CODE=""
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
  typeset THISRC=0

  typeset NO_OF_BACKUPS=

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
      __INSIDE_CREATE_LOCKFILE=${__FALSE}
      die 250
    fi

# remove the lock file at script end
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

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0
  typeset PADSTR="$( echo ${__SCRIPTNAME} | sed "s/./ /g" )"

  eval "__SHORT_USAGE_HELP=\"${__SHORT_USAGE_HELP}\""

cat <<EOT
  ${__SCRIPTNAME} ${__SCRIPT_VERSION} - ${__SHORT_DESC}

  Usage: ${__SCRIPTNAME} [-v|+v] [-q|+q] [-h] [-l logfile|+l] [-y|+y] [-n|+n]
         ${PADSTR} [-D debugswitch] [-a|+a] [-O|+O] [-f|+f] [-C] [-H] [-X] [-S n] [-V] [-T]
${__SHORT_USAGE_HELP}

EOT

  ${__FUNCTION_EXIT}
  return ${THISRC}
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
  typeset THISRC=0

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
      -D    - debug switch
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
              use "-v -V" to print also the template version
              use "-v -v -V" to print also the version history
              use "-v -v -v -V" to also print the template version history
      -T    - append STDOUT and STDERR to the file "${__TEE_OUTPUT_FILE}"
              Long format: --tee
${__LONG_USAGE_HELP}

  Use  "-D create_documentation" to create all available documentation for the script.

EOT

  if [ ${__VERBOSE_LEVEL} -gt 1 ] ; then
    typeset __ENVVARS=$( IFS="#" ; printf "%s " ${__USED_ENVIRONMENT_VARIABLES}  )
    cat <<EOT
  Use "-D SyntaxHelp" to print usage examples for the functions defined in the
  template to STDERR.

  Environment variables that are used if set before calling this script (0 = TRUE, 1 = FALSE):

EOT

    for __CURVAR in ${__ENVVARS} ; do
      echo "  ${__CURVAR} (Current value: \"$( eval echo \$${__CURVAR} )\")"
    done
  fi

  [ ${__VERBOSE_LEVEL} -gt 2 ] && egrep "^##[CRT]#" "${__SCRIPTNAME}" | cut -c5- 1>&2


  ${__FUNCTION_EXIT}
  return ${THISRC}
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
      LogRuntimeInfo "Enabling cleanup at script end"
      __NO_CLEANUP=${__FALSE}
      __NO_EXIT_ROUTINES=${__FALSE}
      __NO_TEMPFILES_DELETE=${__FALSE}
      __NO_TEMPMOUNTS_UMOUNT=${__FALSE}
      __NO_TEMPDIR_DELETE=${__FALSE}
      __NO_FINISH_ROUTINES=${__FALSE}
      __NO_KILL_PROCS=${__FALSE}
     ;;

    ${__FALSE} | "none" )
      LogRuntimeInfo "Disabling cleanup at script end"
      __NO_CLEANUP=${__TRUE}
      __NO_EXIT_ROUTINES=${__TRUE}
      __NO_TEMPFILES_DELETE=${__TRUE}
      __NO_TEMPMOUNTS_UMOUNT=${__TRUE}
      __NO_TEMPDIR_DELETE=${__TRUE}
      __NO_FINISH_ROUTINES=${__TRUE}
      __NO_KILL_PROCS=${__TRUE}
      ;;

    "nodelete" )
      LogRuntimeInfo "Disabling deleting of temporary files at script end"
      __NO_CLEANUP=${__FALSE}
      __NO_EXIT_ROUTINES=${__FALSE}
      __NO_TEMPFILES_DELETE=${__TRUE}
      __NO_TEMPMOUNTS_UMOUNT=${__FALSE}
      __NO_TEMPDIR_DELETE=${__TRUE}
      __NO_FINISH_ROUTINES=${__FALSE}
      __NO_KILL_PROCS=${__FALSE}
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

#J# #uds user defined subroutines
# ??? add user defined subroutines here


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
#### ConvertDateToEpoc
####
#### convert a date into epoc time
####
#### usage: ConvertDateToEpoc [day month year hours minutes seconds] {diff}
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####           The epoc time is printed to STDOUT
####
function ConvertDateToEpoc {
  typeset __FUNCTION="GetTimeStamp";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__TRUE}

  typeset DIFF=$7
  typeset DIFF=${DIFF:=0}
  typeset PERL_PROG="

$day=$1 ;
$month=$2 ;
$year=$3 ;
$hour=$4-$7 ;
$minute=$5 ;
$seconds=$6

  use Time::Local;
  print timelocal($second,$minute,$hour,$day,$month-1,$year);
"
  echo "${PERL_PROG}" | perl

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### GetTimeStamp
####
#### get the current time stamp in the format dd:mm:yyyy hh:mm
####
#### usage: GetTimeStamp
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####           The timestamp is printed to STDOUT
####
function GetTimeStamp {
  typeset __FUNCTION="GetTimeStamp";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__TRUE}
  date +"%d.%m.%Y %H:%M"

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### GetSeconds
####
#### get the seconds since 1970-01-01 00:00:00 UTC
####
#### usage: GetSeconds
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####           The seconds are printed to STDOUT
####
function GetSeconds {
  typeset __FUNCTION="GetSeconds";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  perl -e 'print int(time)' 2>/dev/null
  THISRC=$?

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### GetMinutes
####
#### get the minutes since 1970-01-01 00:00:00 UTC
####
#### usage: GetMinutes
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####           The minutes are printed to STDOUT
####
function GetMinutes {
  typeset __FUNCTION="GetMinutes";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  typeset m1="$( GetSeconds  )"
  if [ $? -eq 0 ] ; then
    typeset m2
    (( m2 = m1 / 60  ))
    echo $m2
    THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### ConvertMinutesToHours
####
#### convert a number of minutes in hh:mm
####
#### usage: ConvertMinutesToHours
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####           The result is printed to STDOUT
####
function ConvertMinutesToHours {
  typeset __FUNCTION="ConvertMinutesToHours";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__FALSE}

  if [ $# = 1 ] ; then
    isNumber $1
    if [ $? -eq ${__TRUE} ] ; then
      typeset -Z2 h
      typeset -Z2 m
      (( h = $1 / 60 ))
      (( m = $1 % 60 ))
      echo "$h:$m"
      THISRC=${__TRUE}
    fi
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
          NEW_OUTPUT="$( set | egrep "$i" )"
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
#### usage: PrintLine [n] {c} {msg}
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
#### default for c is "-"
####
function PrintLine {
  typeset __FUNCTION="PrintLine";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}


# init the return code
  typeset THISRC=${__FALSE}
  typeset n
  typeset c
  typeset m

  if [ $# -ge 1 ] ; then
    n=$1
    c=$2
    c=${c:=-}
    m=$3
    eval printf \'%0.1s\' "$c"\{1..$n\}
    printf $m
    typeset THISRC=${__TRUE}
  fi

  ${__FUNCTION_EXIT}
  return ${THISRC}
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

  grep "die " "${SCRIPTFILE}" | egrep -v "^#|grep|function die|__MAINRC|DIE" | while read line ; do

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
  typeset ADD_CODE=""
  
  typeset DEBUG_PARAMETER_OKAY=${__FALSE}

  typeset NEW_LOG_DEBUG_MESSAGES=""

  push_and_set  __LOG_DEBUG_MESSAGES ${__TRUE}

  case ${CUR_DEBUG_SWITCH} in

# this is an internal switch -- do not use as parameter!
#
    "enable_debug" )
        if [ ${__ENABLE_DEBUG} = ${__TRUE} -a ${PARAMETER_PROCESSING_DONE} = ${__TRUE} ] ; then
          DEBUG_PARAMETER_OKAY=${__TRUE}

          CUR_STATEMENT="[ 0 = 1 "

          for CUR_VALUE in ${__FUNCTIONS_TO_TRACE} ; do
            LogDebugMsg "Enabling trace (set -x) for the function \"${CUR_VALUE}\" ..."

            CUR_STATEMENT="${CUR_STATEMENT} -o \"\${__FUNCTION}\"x = \"${CUR_VALUE}\"x "

            if ! typeset +f "${CUR_VALUE}" >/dev/null ; then
              LogDebugMsg "Warning: The function \"${CUR_VALUE}\" is not yet defined"
              continue
		    fi

            [ "${__TYPESET_F_SUPPORTED}"x != "yes"x ] && continue
          
            if [[ $( typeset -f "${CUR_VALUE}" 2>&1 ) != *\$\{__DEBUG_CODE\}* ]] ; then
              LogDebugMsg "Adding debug code to the function \"${CUR_VALUE}\" ..."  
              ADD_CODE=" typeset __FUNCTION=${CUR_VLAUE}; "
              eval "$( typeset -f  "${CUR_VALUE}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	
            else
              LogDebugMsg "\"${CUR_VALUE}\" already contains debug code."      
            fi
          done

          if [ "${__KSH_VERSION}"x = "93"x -a ${__USE_ONLY_KSH88_FEATURES} = ${__FALSE} ] ; then
            CUR_STATEMENT="__FUNCTION=\"\${.sh.fun}\" ; ${CUR_STATEMENT}"
          fi
        
          CUR_STATEMENT="eval ${CUR_STATEMENT} ] && printf \"\n*** Enabling trace for the function \${__FUNCTION} ...\n\" >&2 && set -x "

          LogDebugMsg "Adding the debug code \"${CUR_STATEMENT}\" to all functions."

          if [ "${__DEBUG_CODE}"x != ""x ] ; then
            if [[ "${__DEBUG_CODE}" == *\; ]] ; then
              __DEBUG_CODE="${__DEBUG_CODE}  ${CUR_STATEMENT}"
            else
              __DEBUG_CODE="${__DEBUG_CODE} ; ${CUR_STATEMENT}"
            fi
          else
            __DEBUG_CODE="${CUR_STATEMENT}"
          fi
    
          if [ "${__TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
            LogDebugMsg "Warning: \"typeset -f\" is NOT supported by this shell - can not check or add the debug code to the functions"
          fi     
        fi
        ;;

    
    "help" )
       cat <<EOT
Known debug switches (for -D / --debug):

  help          -- show this usage and exit
  create_documentation
                -- create the script documentation
  list_rc       -- list return codes used by this script
                   Works only if you only use "die" to end the script
  msg           -- log debug messages to the file ${__DEBUG_LOGFILE}
                   This parameter should be the first parameter.
  trace         -- activate tracing to the file ${__TRACE_LOGFILE}
  tracemain     -- trace the main function
  fn_to_stderr  -- print the function names to STDERR
  fn_to_tty     -- print the function names to /dev/tty
  fn_to_handle9 -- print the function names to the file handle 9
  fn_to_device=filename
                -- print the function names to the file "filename"
  debugcode="x" -- execute the debug code "x" at every function start
                   CAUTION: The debug code should NOT write to 
                            STDOUT - use STDERR instead
  printargs     -- print the script arguments
  tracefunc=f1[,...,f#]
                -- enable tracing for the functions f1 to f#
  debug[=cmd]   -- exeucte the command "cmd" or call a very simple cmd loop
  DebugShell    -- start the DebugShell
  setvar:name=value
                -- set the variable "name" to "value"
  listfunc      -- list all functions defined and exit
  showdefaults  -- show the default variable values
  create_dump=dirname
                -- enable environment dumps; target directory is dirname
  SyntaxHelp    -- print syntax usage examples for the functions in the template
                   and exit
  dryrun        -- dry run only, do not execute commands
  dryrun=prefix -- dry run only, add the prefix "prefix" to all commands

  nocleanup     -- disable the house keeping at script end
  cleanup[=type]
                -- disable or enable the house keeping at script end; "type" can be
                     all - enable all house keeping (this is the default)
                     none - disable all house keeping 
                     nodelete - disable only removing of temporary files and directories
  disable_tty_check 
               -- disable the tty check and always assume we do have a tty

EOT

        if [ ${__VERBOSE_MODE} != ${__FALSE} ] ; then
          cat <<EOT

To disable only some of the house keeping routines use

  -D setvar:__NO_CLEANUP=0
  -D setvar:__NO_EXIT_ROUTINES=0
  -D setvar:__NO_TEMPFILES_DELETE=0
  -D setvar:__NO_TEMPMOUNTS_UMOUNT=0
  -D setvar:__NO_TEMPDIR_DELETE=0
  -D setvar:__NO_FINISH_ROUTINES=0
  -D setvar:__NO_KILL_PROCS=0

EOT

        fi

        DEBUG_PARAMETER_OKAY=${__TRUE}
        die 0
        ;;

# this parameter is processed before the general parameter handling
# -> process & ignore the parameter in this function
#
    showdefaults )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        ;;

# this parameter is processed before the general parameter handling
# -> process & ignore the parameter in this function
#
    tracemain )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        ;;

    cleanup | cleanup=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        CUR_VALUE="${CUR_DEBUG_SWITCH#*=}"
        case ${CUR_VALUE} in
          "all" | "cleanup" | "" )
            SetHousekeeping "all"
            LogDebugMsg "*** housekeeping is enabled now "
            ;;

          "nodelete" )
            SetHousekeeping "nodelete"
            LogDebugMsg "*** housekeeping is partially disabled now - will not delete temporary files or directories"
            ;;

          "none" )
            SetHousekeeping "none"
            LogDebugMsg "*** housekeeping is disabled now "
            ;;

          * )
            LogWarning "*** Invalid value for the parameter -D cleanup found: \"${CUR_VALUE}\" - the parameter will be ignored"
            ;;
        esac
        ;;


    nocleanup )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        __NO_CLEANUP=${__TRUE}
        LogDebugMsg "*** housekeeping is disabled now "
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
        ;;

    dryrun=* )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        PREFIX="${CUR_DEBUG_SWITCH#*=}"
        LogDebugMsg "*** dryrun mode -- the command prefix is \"${PREFIX}\" "
        ;;

    dryrun )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        PREFIX="/usr/bin/echo "
        LogDebugMsg "*** dryrun mode -- the command prefix is \"${PREFIX}\" "
        ;;

    nodryrun )
        DEBUG_PARAMETER_OKAY=${__TRUE}
        if [ "${PREFIX}"x != ""x ] ; then
          LogDebugMsg "*** dryrun mode turned off"
        fi
        PREFIX=""
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
        if [ ${__ENABLE_DEBUG} != ${__TRUE} ] ; then
          LogDebugMsg "The parameter debugcode is disabled."
        else
          DEBUG_PARAMETER_OKAY=${__TRUE}


          CUR_STATEMENT="${CUR_DEBUG_SWITCH#*=}"
          LogDebugMsg "Adding the debug code \"${CUR_STATEMENT}\" to all functions."
          __DEBUG_CODE="${__DEBUG_CODE}
${CUR_STATEMENT}
"      
        fi
        ;;

    debug* )
        if [ ${__ENABLE_DEBUG} != ${__TRUE} ] ; then
          LogDebugMsg "The parameter debug is disabled."
        else
          DEBUG_PARAMETER_OKAY=${__TRUE}
          CUR_STATEMENT="${CUR_DEBUG_SWITCH#*=}"
          if [ "${CUR_STATEMENT}"x != ""x  -a "${CUR_STATEMENT}"x != "debug"x ] ; then
            LogDebugMsg "Executing \"${CUR_STATEMENT}\" ..."
            ${CUR_STATEMENT}
          else
            LogDebugMsg "Starting debug environment ..."
            set +e
            while true ; do
              printf "Enter a command to execute [quiet to continue the script; exit to end the script]\n>> "
              read USER_INPUT
              if [ "${USER_INPUT}"x = "quiet"x  ] ; then
                break
              elif [ "${USER_INPUT}"x = "exit"x  ] ; then
                die 229
              fi
              eval ${USER_INPUT}
            done
          fi
        fi
        ;;

    DebugShell )
        if [ ${__ENABLE_DEBUG} != ${__TRUE} ] ; then
          LogDebugMsg "The parameter DebugShell is disabled."
        else
          DEBUG_PARAMETER_OKAY=${__TRUE}
          DebugShell
        fi
        ;;
        
    setvar:* )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        CUR_STATEMENT="${CUR_DEBUG_SWITCH#*:}"
        CUR_VALUE="${CUR_STATEMENT#*=}"
        CUR_VAR="${CUR_STATEMENT%%=*}"
        LogDebugMsg "Setting the variable \"${CUR_VAR}\" to \"${CUR_VALUE}\" "
        
        push ${__ENABLE_DEBUG}
        eval ${CUR_VAR}=\"${CUR_VALUE}\"
        pop __ENABLE_DEBUG
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

        NEW_LOG_DEBUG_MESSAGES=${__TRUE}
        LogDebugMsg "Debug messages enabled; the output goes into the file \"${__DEBUG_LOGFILE}\"."
        ;;

    "nomsg" )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        __LOG_DEBUG_MESSAGES=${__FALSE}
        LogDebugMsg "Debug messages disabled"
        ;;

    "trace" )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        __ACTIVATE_TRACE=${__TRUE}
        LogDebugMsg "Tracing enabled; the output goes to the file \"${__TRACE_LOGFILE}\". "
        LogDebugMsg "WARNING: All output to STDERR now goes into the file \"${__TRACE_LOGFILE}\"; use \">&3\" to print to real STDERR."
        exec 3>&2
        exec 2>"${__TRACE_LOGFILE}"
        typeset -ft $( typeset +f )
        set -x
        PS4='LineNo: $LINENO (sec: $SECONDS): >> '
        ;;

    "notrace" )
        DEBUG_PARAMETER_OKAY=${__TRUE}

        __ACTIVATE_TRACE=${__FALSE}
        LogDebugMsg "Tracing disabled"
        ;;

     "disable_tty_check" )
        DEBUG_PARAMETER_OKAY=${__TRUE}
#        __DISABLE_TTY_CHECK=${__TRUE}
        LogDebugMsg "tty check disabled"
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
        typeset +f
        die 0
        ;;

      tracefunc=* )
        if [ ${__ENABLE_DEBUG} != ${__TRUE} ] ; then
          LogDebugMsg "The parameter tracefunc is disabled."
        else      
          DEBUG_PARAMETER_OKAY=${__TRUE}

          CUR_VAR="${CUR_DEBUG_SWITCH#*=}"
          __FUNCTIONS_TO_TRACE="${__FUNCTIONS_TO_TRACE} ${CUR_VAR}"
        fi   
        ;;

      * )
#        DEBUG_PARAMETER_OKAY=${__TRUE}

        die 235 "Invalid debug switch found: \"${CUR_DEBUG_SWITCH}\" -- use \"-d help\" to list the known debug switches"
        ;;

    esac
  fi

  pop __LOG_DEBUG_MESSAGES
  [ "${NEW_LOG_DEBUG_MESSAGES}"x != ""x ] && __LOG_DEBUG_MESSAGES=${NEW_LOG_DEBUG_MESSAGES}

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

#### --------------------------------------
#### print_runtime_variables
####
#### print some usage examples for the functions defined in the template to STDOUT
####
#### usage: print_runtime_variables
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function print_runtime_variables {
  typeset __FUNCTION="print_runtime_variables";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}
	
  typeset THISRC=${__TRUE}

  typeset CUR_VAR_LIST=""
  typeset CUR_VAR_LIST_NAME=""

  typeset CUR_LIST=""
  typeset VARIABLE_LIST=""
  
  typeset CUR_VAR=""
  typeset CUR_VALUE=""
  typeset CUR_MSG=""
  
  for CUR_VAR_LIST_NAME in $* ; do
  
    case ${CUR_VAR_LIST_NAME} in

      help )
        printf "
Known variable lists for the alias \"vars\" are:

      all               - print all variables used

      application       - print application variables
      used_env          - print environment variables used
      log               - print variables for the logfile handling
      defaults          - print variables with DEFAULT_* values
      config            - print variables for the config file processing
      house_keeping     - print variables for the housekeeping processing
      signalhandler     - print variables for the signal handler
      dump              - print variables for the dump processing
      script            - print variables with the script name, directory, etc
      debug             - print variables for the debug functions
      parameter         - print variables for the parameter
      requirements      - print variables for the script requirements
      runtime           - print various runtime variables
      os_env            - print variables for the OS environment
      internal          - print all internal variables execept these variables
                            __LONG_USAGE_HELP __SHORT_USAGE_HELP 
                            __OTHER_USAGE_EXAMPLES __CONFIG_PARAMETER

"

        CUR_VAR_LIST=""
        break
        ;;

      all )
        CUR_VAR_LIST="${__PRT_VAR_LISTS}"
        ;;

      internal )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_INTERNAL_VARIABLES"
        ;;
      
      application )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_APPLICATION_VARIABLES"
        ;;
        
      used_env )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_USED_ENVIRONMENT_VARIABLES"
        ;;

      log )   
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_LOG_VAR_LIST"
        ;;

      defaults )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_DEFAULT_VAR_LIST"
        ;;

      config )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_CONFIG_VAR_LIST"
        ;;

      house_keeping )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_HOUSEKEEPING_VAR_LIST"
        ;;

      signalhandler )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_SIGNALHANDLER_VAR_LIST"
        ;;

      dump )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_DUMP_VAR_LIST"
        ;;

      script )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_SCRIPT_VAR_LIST"
        ;;

      debug )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_DEBUG_VAR_LIST"
        ;;

      parameter )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_PARAMETER_VAR_LIST"
        ;;

      requirements )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_SCRIPT_REQUIREMENT_VAR_LIST"
        ;;

      runtime )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_RUNTIME_VAR_LIST"
        ;;

      os_env )
        CUR_VAR_LIST="${CUR_VAR_LIST} __PRT_OS_ENVIRONMENT_VAR_LIST"
        ;;

      * ) 
        printf "Unknown parameter for ${__FUNCTION} found: ${CUR_VAR_LIST_NAME}\n"
        printf "(use \"vars help\" to list all known parameter)\n"
        ;;
    esac
  done

  for CUR_LIST in ${CUR_VAR_LIST} ; do
    VARIABLE_LIST="${VARIABLE_LIST} $( eval echo \$${CUR_LIST} )"
  done
  
  for CUR_VAR in ${VARIABLE_LIST} ; do
    if [[ ${CUR_VAR} == \#* ]] ; then
      CUR_MSG="*** $( echo "${CUR_VAR#*#}" | tr "_" " ")"
    else
      eval CUR_VALUE="\$${CUR_VAR}"
      CUR_MSG="  ${CUR_VAR}: \"${CUR_VALUE}\" "
    fi
    "printf" "${CUR_MSG}\n" 
  done

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### --------------------------------------
#### PrintScriptEnv
####
#### print a short list of the environment
####
#### usage: PrintScriptEnv
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function PrintScriptEnv {
  typeset __FUNCTION="PrintScriptEnv";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

# init the return code
  typeset THISRC=${__TRUE}

# -----------------------------------------------------------------------------
# print script environment
  
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
  LogMsg "The script Shebang is \"${__SHEBANG}\""
  LogMsg "The shell in the Shebang is \"${__SCRIPT_SHELL}\" "
  LogMsg "The shell options in the Shebang are \"${__SCRIPT_SHELL_OPTIONS}\" "
  LogMsg "----------------------------------------------------------------------"
  LogMsg ""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}

# -----------------------------------------------------------------------------
# functions:
#

# ??? insert additional functions here

# You can remove the function SyntaxHelp

#### --------------------------------------
#### SyntaxHelp
####
#### print some usage examples for the functions defined in the template to STDOUT
####
#### usage: SyntaxHelp
####
#### returns:  ${__TRUE} - ok
####           ${__FALSE} - error
####
####
function SyntaxHelp {
  typeset __FUNCTION="SyntaxHelp";   ${__FUNCTION_INIT} ;
  ${__DEBUG_CODE}

  typeset THISRC=${__TRUE}

  LogMsg "Writing the syntax help to STDERR ..."

  cat <<-\END_OF_EXAMPLES >&2
#
# =============================================================================
# Syntax Usage examples for some of the functions in scriptt.sh
# =============================================================================
#
# Note: you can delete the function "SyntaxHelp" in your script if applicable
#
# -----------------------------------------------------------------------------
# General hints
#

Use

  scriptt.sh -H 2>./scriptt.doc

to create the documentation for scriptt.sh including the infos for all public
variables and functions that can be used.

Use the function "YourRoutine" as template for new functions.

Use the function "USER_SIGNAL_HANDLER" as template for new signal handler.

Use the format

  function [function_name] { ... }

to define new functions to be compatible with ksh88 and ksh93.

Be aware that the return code for a function is an integer value between 0 and 255

Define all local variables in functions using

  typeset [varname][=value]

Do NOT define new variables beginning with two underscore "__"!

To source in another script you should only use the function

  includeScript

instead of ". <includefile>"

# -----------------------------------------------------------------------------
# sample code for using the house keeping routines
#

# create a temporary mount point or directory

    mkdir "${TMPDIR}" && __LIST_OF_TMP_DIRS="${__LIST_OF_TMP_DIRS} ${TMPDIR}" || LogError "Error creating the directory \"${TMPDIR}\" "

# create a temporary file

    touch "${TMPFILE}" && __LIST_OF_TMP_FILES="${__LIST_OF_TMP_FILES} ${TMPFILE}" || LogError "Error creating the file \"${TMPFILE}\" "

# add a function to the house keeping (to be executed before files, directories, and mounts are removed)
# Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
# blanks or tabs in the parameter are NOT allowed

    __EXITROUTINES="${__EXITROUTINES} [your_function]"

# or (to be executed after files, directories, and mounts are removed)
# Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
# blanks or tabs in the parameter are NOT allowed

    __FINISHROUTINES="${__FINISHROUTINES} [your_function]"

# -----------------------------------------------------------------------------
# To log a message you may use one of the functions
#
#   LogMsg, LogInfo, LogWarning, LogError,  LogOnly, LogIfNotVerbose
#

# To log a message without timestamp use

    LogMsg "-" "[your message]"

# To Log a message in verbose mode (parameter -v) use

    LogInfo "[your message]"

# or

    LogInfo 0 "[your message]"


# To log a message only in a more verbose mode (parameters -v -v) use

    LogInfo 1 "[your message]"

# To log a message only in a more verbose mode (parameters -v -v -v) use

    LogInfo 2 "[your message]"


# To Print only a dot (or any other character) without a line feed use

    PrintDotToSTDOUT


# To add a timestamp to all messages from a binary or script you can use

    PrintWithTimestamp vmstat 1 5


# use StartStop_LogAll_to_logfile to log STDERR and STDOUT of all running programs to a logfile

   # start logging
   StartStop_LogAll_to_logfile start "/var/tmp/newlogfile"

   # this messages is only written to the logfile
   echo "### Logging started"

   # write a message to STDOUT
   echo "This message goes to STDOUT and not in the log file " >&3

   # do whatever is necessary ... (all output of the commands is only written to the logfile)
   ls
   ls /dfafdsa
   uname -a

   # exeucte a command with "normal" STDOUT and STDERR
   ls /dasff 2>&4 1>&3

   # write a message to STDERR
   echo "This message goes to STDERR and not in the log file " >&4

   # this messages is only written to the logfile
   echo "### Logging will be stopped now"

   # stop logging
   StartStop_LogAll_to_logfile stop

   echo "Logging disabled again."


# To get some input from the user the function AskUser might be used

  AskUser "Start (y/N)?"
  if [ $? -eq ${__TRUE} ] ; then
    echo "User response was yes"
  else
    echo "User response was not yes"
  fi

# or

  AskUser "Your input please:"
  echo "User response is \"${USER_INPUT}\" "


# AskUser supports an internal debug shell; to start the debug shell enter "shell", e.g.

#
[01.11.2014 14:01:05] Using the log file "/var/tmp/scriptt.log"
Start (y/N)? shell

 -------------------------------------------------------------------------------
scriptt.sh - debug shell - enter a command to execute ("exit" to leave the shell)
>>

# The debug shell can be used to view or change global variables in your script.

# use
#   executeCommandAndLog
# to execute other scripts and binaries. This function logs STDOUT and STDERR
# to the logfile. The return code is the returncode of the executed script/binary
# (use executeCommandAndLogSTDERR to only log STDERR)

  executeCommandAndLog "ls ${__SCRIPTNAME}"
  LogMsg "The returncode is $?"

  executeCommandAndLog "ls \dasfdsaf"
  LogMsg "The returncode is $?"


# To work with dynamically defined functions the template implements the functions:
#   IsFunctionDefined
# and
#   executeFunctionIfDefined
# e.g.

  IsFunctionDefined SyntaxHelp
  if [ $? -eq ${__TRUE} ] ; then
    SyntaxHelp
    die 0
  else
    die 232 "Function SyntaxHelp NOT defined."
  fi


# to work with userid and groups you can use the functions
#   UserIs, GetCurrentUID, GetUserName, and GetUID

# to work with dates the template contains the functions
#  GetOtherDate, ConvertDateToEpoc, GetTimeStamp, GetSeconds, GetMinutes, and ConvertMinutesToHours


# Use push and pop to temporary save the contents of a variable:
# (push and pop use a LIFO stack structure; there is only one global stack
#  with up to 255 elements)
#

    VAR1=var1
    VAR2=var2
    VAR3=var3
    echo "Variable VAR1 is \"${VAR1}\", VAR2 is \"${VAR2}\", and VAR3 is \"${VAR3}\" "

    # save the contents of the variables VAR1 and VAR2
    push "${VAR1}" "${VAR2}"

    # save the contents of the variable VAR3 and then set VAR3 to 99
    push_and_set VAR3 99

    # now you can work with the variables VAR1, VAR2, and VAR3
    # ...

    VAR2=88
    VAR1=100

    echo "Variable VAR1 is \"${VAR1}\", VAR2 is \"${VAR2}\", and VAR3 is \"${VAR3}\" "

    # restore the contents of the variables VAR1, VAR2, and VAR3:
    pop VAR3 VAR2 VAR1
    echo "Variable VAR1 is \"${VAR1}\", VAR2 is \"${VAR2}\", and VAR3 is \"${VAR3}\" "


# use CheckInputDevice to check if the script is running in a terminal session
# or for example as cron job
#
   CheckInputDevice
   if [ $? -eq ${__TRUE} ] ; then
     echo "Standard input is a terminal"
   else
     echo "Standard input is NOT a terminal"
   fi

# Use the string manipulation functions
#   substr, replacestr, pos, lastpos, toUppercase, and toLowercase
# to work with strings, e.g.:

# function replacestr
#
  STR="1234567890"
  SUBSTR="456"
  replacestr $STR $SUBSTR  "Arno Teunisse" TT
  [ $? == 0 ] && echo $TT
#  should show in $TT : "123Arno Teunisse7890"

# function pos
#
  STR="Arno Teunisse"
  SUBSTR="o"
  pos $SUBSTR $STR
  [ $? -gt 0 ] && echo $?

# Most of the string functions support an optional parameter for the result string,
# so you can use substr for example either this way
#   variable=$( substr sourceStr pos length )
# or this way
#   substr sourceStr pos length resultVariable
# e.g.

  RESULTVAR=""
  SOURCESTRING=12345abcdefg"
  POS=6
  LENGTH=3

  substr  "${SOURCESTRING}" ${POS} ${LENGTH} "RESULTVAR"
  echo "RESULTVAR is now \"${RESULTVAR}\" "

# is the same as

  RESULTVAR="$( substr  "${SOURCESTRING}" ${POS} ${LENGTH} )"
  echo "RESULTVAR is now \"${RESULTVAR}\" "


# use the convert routines
#   ConvertToOctal, ConvertoBinary, and ConvertToHex
# to convert a value into octal, binary, or hexadecimal format

  DECIMAL_VALUE=23
  LogMsg "${DECIMAL_VALUE} in Octal  is      $( ConvertToOctal ${DECIMAL_VALUE} )"
  LogMsg "${DECIMAL_VALUE} in Binary is      $( ConvertToBinary ${DECIMAL_VALUE} )"
  LogMsg "${DECIMAL_VALUE} in Hexadecimal is $( ConvertToHex ${DECIMAL_VALUE} )"



# -----------------------------------------------------------------------------
# and last some sample code snippets for ksh88 ...
#

# count words in a string
#

# this code returns 5
  noOfWords=$(  set -- This is a Test String ; echo $# )

# this code returns 1
  noOfWords=$(  set -- "This is a Test String"  ; echo $# )

# get the current date & time
# source: http://cfajohnson.com/shell/tuesday-tips/#tt-2004-07-06
#
  eval "$( date "+DATE=%Y-%m-%d
               YEAR=%Y
               MONTH=%m
               DAY=%d
               TIME=%H:%M:%S
               HOUR=%H
               MINUTE=%M
               SECOND=%S
               datestamp=%Y-%m-%d_%H.%M.%S
               DayOfWeek=%a
               MonthAbbrev=%b")"

# replace a character with another character with ksh internals
# -> replace ":" with "#" in the PATH variable
#
  NEW_STRING=$( IFS=: ; printf "%s#" $PATH  )

# read the 1st line of a file
#
  IFS="$( printf "\n" ; )" read LINE1  </etc/hosts

# define some variables for special characters
#
   NL="$( printf "\n" ; )"
   CR="$( printf "\r" ; )"
  TAB="$( printf "\t" ; )"
  ESC="$( printf "\e" ; )"


# define an array (indexing starts at 0!)
  typeset -A array

# fill an array
  for c in red green blue white; do
    array[${#array[@]}]=$c
  done

# print all members of an array
  echo ${array[@]}

# print no of members of an array
  echo ${#array[@]}

# add a member to an array
  array[${#array[@]}]="new value"

# -----------------------------------------------------------------------------
# ... and some sample code snippets for ksh93
#

# define an indexed array (indexing starts at 0!); default arrays in ksh93 are associative arrays!
  typeset -a array

# special characters:
#
# bash and ksh93 specific;
# in other shells, replace the $'\X' with a literal character
#            DEC     OCT   HEX
  NL=$'\n'   ##  10, \012, 0x0a, a literal newline
  CR=$'\r'   ##  13, \015, 0x0d, carriage return
  TAB=$'\t'  ##   9, \011, 0x09, tab
  ESC=$'\e'  ##  27, \033, 0x1b, escape

# replace a character with another character with ksh internals (ksh93 only!)
# -> replace ":" with "#" in the PATH variable
#
  NEW_STRING="${PATH//:/#}"

# sample for loop over 1 to 10
#
  for i in {1..10} ; do
    echo $i
  done

# builtin time formatting in printf in ksh93:
# see http://blog.fpmurphy.com/2008/10/ksh93-date-manipulation.html:

# The ksh93 builtin printf (not printf(1)) includes a %T formatting option.
#
# %T               Treat argument as a date/time string and format it accordingly.
#
# %(dateformat)T   T can be preceded by dateformat, where dateformat is any date format supported
#                  by the date(1) command.




END_OF_EXAMPLES

  ${__FUNCTION_EXIT}
  return ${THISTRC}
}

#J#  #udf  user defined functions

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
  typeset THISRC=0

  LogMsg "***"
  LogMsg "User defined signal handler called"
  LogMsg ""
  LogMsg "Trap signal is \"${__TRAP_SIGNAL}\" "
  LogMsg "Interrupted function: \"${INTERRUPTED_FUNCTION}\", Line No: \"${__LINENO}\" "
  LogMsg "***"

  return ${THISRC}
}


# ----------------------------------------------------------------------
# switch_to_background
#
# function: switch the current process running this script into the background
#
# usage: switch_to_background {no_redirect}
#
# parameter: no_redirect - do not redirect STDOUT and STDERR to a file
#
# returns: ${__TRUE} - ok, the process is running in the background
#          ${__FALSE} - error, can not switch the process into the background
#
function switch_to_background {
  typeset __FUNCTION="switch_to_background"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}

  if [ ${__IN_DEBUG_SHELL}x = ${__TRUE}x ] ; then
    LogError "${__FUNCTION} not allowed in the Debugshell"
    return ${__FALSE}
  fi

  typeset REDIRECT_STDOUT=${__TRUE}
  [ "$1"x = "no_redirect"x ] && REDIRECT_STDOUT=${__FALSE}

  typeset TMPFILE=""
  typeset TMPLOGFILE=""

  typeset SIGTSTP=""
  typeset SIGCONT=""

# the signals used to stop a process and to restart the process in the
# background are different in the various Unix OS
#  
  case ${__OS} in 
  
     Solaris )
       SIGTSTP="24"
       SIGCONT="25"
       ;;

     Linux )
       SIGTSTP="20"
       SIGCONT="18"
       ;;

     AIX )
       SIGTSTP="18"
       SIGCONT="19"
       ;;

     Darwin )
       SIGTSTP="18"
       SIGCONT="19"
       ;;

  esac

  LogMsg "Switching the process for the script \"${SCRIPTNAME}\" with the PID $$ into the background now ..."

# create a duplicate file descriptor for the current STDOUT file descriptor
#
  exec 9>&1

# the file used for STDOUT and STDERR for the background process
# (this is a global variable!)
#

  if [ ${REDIRECT_STDOUT} = ${__TRUE} ] ; then
    NOHUP_STDOUT_STDERR_FILE="${NOHUP_STDOUT_STDERR_FILE:=${PWD}/nohup.out}"

    LogMsg "STDOUT/STDERR now goes to the file \"${NOHUP_STDOUT_STDERR_FILE}\" "
  fi
  
  case ${__OS} in 

    SunOS | Linux | AIX | Darwin )
      if [ ${REDIRECT_STDOUT} = ${__TRUE} ] ; then
        exec 1>"${NOHUP_STDOUT_STDERR_FILE}" 2>&1 </dev/null
      fi
      
      TMPFILE="/tmp/${SCRIPTNAME}.$$.temp.sh"
      TMPLOGFILE="/tmp/${SCRIPTNAME}.$$.temp.log"
      
# use &9 to write messages to the old STDOUT file descriptor
#      echo "Test Redirect, TMPFILE is ${TMPFILE} " >&9

# create a temporary script to switch this process into the background
#      
      echo "
# script to switch the process $$ to the background
#
kill -${SIGTSTP} $$
sleep 1
kill -${SIGCONT} $$
exit 0
"     >"${TMPFILE}" && chmod 755  "${TMPFILE}" && \
          FILES_TO_REMOVE="${FILES_TO_REMOVE} ${TMPFILE} ${TMPLOGFILE}"

      if [ ! -x "${TMPFILE}" ] ; then
        THISRC=${__FALSE}
        LogError "Can not create the temporary file for switching the process into the background"
      else
        "${TMPFILE}" >"${TMPLOGFILE}" 2>&1 &
        sleep 1
        __settraps

        LogMsg "-" >&9
        LogMsg "*** The script \"${SCRIPTNAME}\" (PID is $$) should now run in the background ...
" >&9
      fi
      ;;

    * ) 
      LogError "Can not switch a process into the background in ${__OS}"
      THISRC=${__FALSE}
      ;; 
  esac

  tty -s && RUNNING_IN_TERMINAL_SESSION=${__TRUE} || RUNNING_IN_TERMINAL_SESSION=${__FALSE}

# close the temporary file descriptor again  
  exec 9>&-

  return ${THISRC}
}

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
  echo "In YourRoutine -- "
# -----------------------------------------------------------------------------
# print script environment
  

  [ ${THISRC} -gt 255 ] && die 234 "The return value is greater than 255 in function \"${__FUNCTION}\""

  ${__FUNCTION_EXIT}
  return ${THISRC}
}


#### -----------------------------------------------------------------------------
#### Note: Use
####
####          ./scriptt.sh -D SyntaxHelp 2>./scriptt.sh.syntaxhelp
####
####        to get some syntax examples for the functions defined in the template.
####
#### -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# main:   - init -
#
#J# #mit
#

__START_TIME_IN_SECONDS="$( GetSeconds )"

# trace main routine
#
if [[ \ $*\  == *\ -D\ tracemain\ *  ]] ; then
  set -x
  PS4='LineNo: $LINENO (sec: $SECONDS): >> '
fi

# install trap handler
  __settraps

  trap 'GENERAL_SIGNAL_HANDLER EXIT  ${LINENO} ${__FUNCTION}' exit

# trace also all function defined before this line (!)
#
# typeset -ft $( typeset +f )

  InitScript $*

# define the variable for the DEFAULT_* variables in print_runtime_variables
#
  __PRT_DEFAULT_VAR_LIST="
  #Default_variables:
$( set | grep "^DEFAULT_"  | cut -f1 -d"=" )
"

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
    if [[ \ $*\  == *\ -D\ showdefaults\ *  ]] ; then
      push_and_set __VERBOSE_MODE ${__TRUE}
      push_and_set __VERBOSE_LEVEL ${__RT_VERBOSE_LEVEL}
      LogInfo 0 "Setting variable $P2 to \"$( eval "echo \"\$$P1\"")\" "
      pop __VERBOSE_MODE
      pop __VERBOSE_LEVEL
    fi

    eval "$P2="\"\$$P1\"""
  done

  
# variables used by getopts:
#    OPTIND = index of the current argument
#    OPTARG = current function character
#
  THIS_PARAMETER="$*"

  PARAMETER_PROCESSING_DONE=${__FALSE}
  
  INVALID_PARAMETER_FOUND=${__FALSE}

  __PRINT_USAGE=${__FALSE}
  CUR_SWITCH=""
  OPTARG=""

# ??? add additional switch characters here
#
  [ "${__OS}"x = "Linux"x ] &&  GETOPT_COMPATIBLE="0"

  __GETOPTS="+:ynvqhHD:fl:aOS:CVTX"
  if [ "${__OS}"x = "SunOS"x -a "${__SHELL}"x = "ksh"x ] ; then
    if [ "${__OS_VERSION}"x  = "5.10"x -o  "${__OS_VERSION}"x  = "5.11"x ] ; then
      __GETOPTS="+:y(yes)n(no)v(verbose)q(quiet)h(help)H(doc)D:(debug)f(force)l:(logfile)\
a(color)O(overwrite)S:(summaries)C(writeconfigfile)V(version)T(tee)X(view_examples)"
    fi
  fi

# ??? remove the following line if your ksh implementation does not support long switches 
#
  __GETOPTS="+:y(yes)n(no)v(verbose)q(quiet)h(help)H(doc)D:(debug)f(force)l:(logfile)\
a(color)O(overwrite)S:(summaries)C(writeconfigfile)V(version)T(tee)X(view_examples)"

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
             LogMsg "Writing the script documentation to STDERR ..."

echo " -----------------------------------------------------------------------------------------------------" >&2
echo " ${__SCRIPTNAME} ${__SCRIPT_VERSION} (Scripttemplate: ${__SCRIPT_TEMPLATE_VERSION})  ">&2
echo " Documentation" >&2
echo " -----------------------------------------------------------------------------------------------------" >&2

             grep "^##" "$0" | grep -v "##EXAMPLE##" | cut -c5- 1>&2
             die 0
             ;;

       "X" )
             LogMsg "Writing the script usage examples to STDERR ..."

echo " -----------------------------------------------------------------------------------------------------" >&2
echo " ${__SCRIPTNAME} ${__SCRIPT_VERSION} ">&2
echo " Documentation" - Examples>&2
echo " -----------------------------------------------------------------------------------------------------" >&2

             T=$( grep "^##EXAMPLE##" "$0" | cut -c12- )
       eval T1="\"$T\""
       echo "$T1" 1>&2
       echo "${__OTHER_USAGE_EXAMPLES}" | sed "s/scriptt.sh/${__SCRIPTNAME}/g" 1>&2
             die 0
             ;;

       "V" ) LogMsg "Script version: ${__SCRIPT_VERSION}"
             if [ ${__VERBOSE_MODE} = ${__TRUE} ] ; then
               LogMsg "Script template version: ${__SCRIPT_TEMPLATE_VERSION}"
               if [ "${__CONFIG_FILE_FOUND}"x != ""x ] ; then
                 LogMsg "Script config file: \"${__CONFIG_FILE_FOUND}\""
                 LogMsg "Script config file version : ${__CONFIG_FILE_VERSION}"
               fi
               if [ ${__VERBOSE_LEVEL} -gt 1 ] ; then
                 LogMsg "-"
                 T=$( grep "^##v#" "$0" | cut -c4- )
                 eval T1="\"$T\""
               echo "$T1"
               fi
               if [ ${__VERBOSE_LEVEL} -gt 2 ] ; then
                 LogMsg "-"
                 T=$( grep "^##V#" "$0" | cut -c4- )
#              eval T1="\"$T\""
               echo "$T"
               fi
               __VERBOSE_LEVEL=0
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

#J# #udp user defined parameter

# ??? add additional parameter here


        \? ) [ "${OPTARG}"x = ""x ] && eval OPTARG=\$"$(( $OPTIND -1 ))"
             LogError "Unknown parameter found: \"${OPTARG}\" "
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

  PARAMETER_PROCESSING_DONE=${__TRUE}

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


  if [ ${__LOG_DEBUG_MESSAGES} != ${__TRUE} ] ; then
    rm "${__DEBUG_LOGFILE}" 2>/dev/null 1>/dev/null
    __DEBUG_LOGFILE=""
  else
    echo 2>/dev/null >>"${__DEBUG_LOGFILE}" || \
      die 237 "Can not write to the debug log file \"${__DEBUG_LOGFILE}\" "
  fi

# ??? add parameter checking code here
#
# set INVALID_PARAMETER_FOUND to ${__TRUE} if the script
# should abort due to an invalid parameter
#
#  if [ "${NOT_PROCESSED_PARAMETER}"x != ""x ] ; then
#    LogError "Unknown parameter: \"${NOT_PROCESSED_PARAMETER}\" "
#    INVALID_PARAMETER_FOUND=${__TRUE}
#  fi


# exit the program if there are one or more invalid parameter
#
  if [ ${INVALID_PARAMETER_FOUND} -eq ${__TRUE} ] ; then
    LogError "One or more invalid parameters found"
    ShowShortUsage
    die 2
  fi

# enable "set -x" for all requested functions (--D tracefunc=fn)
#
  if [ "${__FUNCTIONS_TO_TRACE}"x != ""x -a ${__ENABLE_DEBUG} = ${__TRUE} ] ; then
    ProcessDebugSwitch "enable_debug"
  fi

  SetEnvironment

# create the PID file
#
  if [ "${__PIDFILE}"x != ""x ] ; then
    LogRuntimeInfo "Writing the PID $$ to the PID file \"${__PIDFILE}\" ..."
    echo $$>"${__PIDFILE}" && __LIST_OF_TMP_FILES="${__LIST_OF_TMP_FILES} ${__PIDFILE}" || \
      LogWarning "Can not write the PID to the PID file \"${__PIDFILE}\" "
  fi

# restore the language setting
#
  LANG=${__SAVE_LANG}
  export LANG

# -----------------------------------------------------------------------------
# test / debug code -- remove in your script

  LogInfo "Config file version is: \"${__CONFIG_FILE_VERSION}\" "


# print all of the runtime variables
#
  [ ${__PRINT_ALL_VARIABLES}x = ${__TRUE}x ] && print_runtime_variables all

# print all internal variables
#
  [ ${__PRINT_INTERNAL_VARIABLES}x = ${__TRUE}x ] && print_runtime_variables internal

# print the script environment in verbose mode
#
  [ ${__VERBOSE_MODE} = ${__TRUE} ] && PrintScriptEnv

# -----------------------------------------------------------------------------
#J# #main   main:   - main code -


# -----------------------------------------------------------------------------
# ??? add your main code here

  LogMsg "This is only sample code!!!"
  
# Define application variables for print_runtime_variables
#
# __PRT_APPLICATION_VARIABLES="
#Application_variables:
#"
#

# --- variables for the cleanup routine:
#
# add mounts that should be automatically unmounted at script end to this variable
#
#  __LIST_OF_TMP_MOUNTS="${__LIST_OF_TMP_MOUNTS} "

# add directories that should be automatically removed at script end to this variable
#
#  __LIST_OF_TMP_DIRS="${__LIST_OF_TMP_DIRS} "

# add files that should be automatically removed at script end to this variable
#  __LIST_OF_TMP_FILES="${__LIST_OF_TMP_FILES} "

# add functions that should be called automatically at script end
# before removing temporary files, directories, and mounts
# to this variable
# Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
# blanks or tabs in the parameter are NOT allowed
#
#  __EXITROUTINES="${__EXITROUTINES} "

# add functions that should be called automatically at script end
# after removing temporary files, directories, and mounts
# to this variable
# Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
# blanks or tabs in the parameter are NOT allowed
#
#  __FINISHROUTINES="${__FINISHROUTINES} "

# add processes (PID) that should be killed at script end
#
# to change the timeout after kill before issuing a "kill -9" for 
# a specific process use  "pid:timeout_in_seconds"; default timeout is
# ${__PROCS_KILL_TIMEOUT}.
# To disable "kill -9" for a specific process use "pid:-1"
#
#  __PROCS_TO_KILL="${__PROCS_TO_KILL} "


#  . ./scriptt_testsuite.sh


 
# -----------------------------------------------------------------------------

 
# -----------------------------------------------------------------------------
  
  LogMsg "You must add your own code (the PID of this process is $$)  .. press return to continue"
  read USER_INPUT
  
  LogMsg "Standard message"
  LogMsg "-" "Message without date"
  
  LogInfo "Standard info message"
  LogInfo "-"  "Info message without date"
  
  LogWarning "Standard warning messages"
  LogWarning "-"  "Warning Message wihtout date"
  
  LogError "Standard Error Message"
  LogError "-"  "Error message without date"
  
  LogOnly "Standard logonly messages"
  LogOnly  "-"  "Standard logonly messages without date"
  
  LogIfNotVerbose "Standard NOt verbose messages"
  LogIfNotVerbose  "-"  "Standard NOt verbose messages  without date"
  
  
  LogRuntimeInfo "Standard runtime info message"
  LogRuntimeInfo  "-"  "Standard runtime info message without date"
  switch_to_background
  
  while true ; do 
    echo "$$ stil running ">&9
    sleep 2
  done
  
  die ${__MAINRC}

# -----------------------------------------------------------------------------
# this code should never be executed...
#

exit 4

# -----------------------------------------------------------------------------
