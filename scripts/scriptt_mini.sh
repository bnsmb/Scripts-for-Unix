#!/bin/ksh
#
# code to restart the script automatically via sudo if not executed by the root user
#
if [ 0 = 1 ] ; then
  SUDO="${SUDO:=sudo}"
  [[ "$0"x != /* ]]  && __THIS_SCRIPT="${PWD}/$0" || __THIS_SCRIPT="$0"
#
# "id -u"  does not work like expected in Solaris prior to version 11
#
  if [[ $( id ) != uid=0*\(root\)* ]] ; then

    echo "$0 was started by the user $( id ) "
    echo "${__THIS_SCRIPT} will be restarted via \"${SUDO}\" ..."
    exec ${SUDO} ${__THIS_SCRIPT} $@ 
    THISRC=$?
# 
# this code should never be executed
#
    echo "$0 -- RC=${THISRC} -- something went terrible wrong " >&2
    exit ${THISRC}
  else
    echo "$0 was started by the user $( id ) "  
  fi
fi

### Simple kornshell script template for Linux, Solaris, AIX and other 
### Unix Operating systems
###
### Replace the parts marked with "???" with your code / descriptions
### and add your code after the line marked with "main:"
###
### Do NOT use variable or function names beginning with two underscores "__" 
### - these variables and functions are used internal by the runtime system.
###
### To use the debugging features of the template you should use 
### functions where ever possible
###
### This script template works with ksh88 and ksh93
###

#
# Notes: 
#
#        Only lines beginning with "#h#" are printed if the script is called 
#        with the parameter  -h
#        If the parameter -v is also used the meaning of -h and --help is equal
#
#        Lines beginning with "#H#" or "#h#" are printed if the script is called 
#        with the parameter  --help
#        Lines beginning with "#U#" are also printed if the script is called
#        with the parameter "-h -v" 
#        Lines beginning with "#V#" are also printed if the script is called
#        with the parameter "-h -v -v" 
#        Lines beginning with "#T#" are also printed if the script is called
#        with the parameter "-h -v -v -v"
#
#        Lines beginning with #h#, #H#, or #U# can be mixed and will be printed in the given order
#        Lines beginning with #T# or #V# will be printed separate
#

# ----------------------------------------------------------------------
# internal variable with the list of supported environment variables
#
# format:
#
# name # type # comment
#
# type and comment are optional
#
# sample line:
# PREFIX                     # string   # prefix used in dry-run-mode
#
ADDITIONAL_ENV_VARIABLES="
"

# Script Usage
# ----------------------------------------------------------------------
#H# <scriptname>
#H#
#H# Function: ???
#H# 
#h# Usage:    <scriptname> [-h|--help] [-v|--verbose] [-v:fn|--verbose:fn] [-q|--quiet] [-f|--force] [-o|--overwrite] [-y|--yes] [-n|--no]
#h#               [-l|--logfile [filename[:n]|:n] [-d{:dryrun_prefix}|--dryrun{:dryrun_prefix}] [-D|--debugshell] [-t fn|--tracefunc fn] [-L]
#h#               [-T|--tee] [-V|--version] [--var name=value] [--appendlog] [--nologrotate] [--noSTDOUTlog] [--print_runtime_vars]
#h#               [--nocleanup] [--nobackups] [--disable_tty_check] [--norcm] [--no_appl_params] [--no_appl_file]
#h#
#H# Parameter:
#H#   -h - print the script usage; use \"-h\" and \"-v\" one or more times to print more help text
#H#        
#H#   -v - verbose mode; use \"-v\" \"-v\" to also print the runtime system messages 
#H#        (or set the environment variables VERBOSE to 0 and VERBOSE_LEVEL to the level)
#H#   -v:fn
#H#        enable verbose mode for the function \"fn\"; use the comma \",\" to separate multiple functions
#H#        or use the parameter more than once. The format \"-v fn\" is NOT supported for this parameter.
#U#        Note that this only works for functions using the code from the function \"function_template\"
#U#        Also note that the script will create an alias for return if this parameter is used
#H#   -q - quiet mode (or set the environment variable QUIET to 0)
#H#   -f - force execution (or set the environment variable FORCE to 0 )
#H#   -o - enable overwrite mode (or set the environment variable OVERWRITE to 0 )
#H#   -y - answer yes to all questions
#H#   -n - answer no to all questions
#H#   -l - logfile to use; use \"-l none\" or \"-l -\" to not use a logfile at all
#H#        the default logfile is /var/tmp/${SCRIPTNAME}.log
#H#        also supported is the format \"-l:filename\"
#H#        The build-in logrotate will keep ${NO_OF_LOGFILES_TO_KEEP} versions of the log file
#H#        Use the prefix \":n\" for the filename to change the number of logfiles to keep
#H#        Use the syntax \"-l :n\" or \"-l default:n\" to use the default logfile and only change the number of logfiles to keep 
#U#        Alternative:  
#U#          Set the environment variable NO_OF_LOGFILES_TO_KEEP to change this value either before
#U#          starting the script or using the parameter \"--var NO_OF_LOGFILES_TO_KEEP=n\"
#H#   -d - dryrun mode, default dryrun_prefix is: \"${DEFAULT_DRYRUN_PREFIX} \"
#H#        Use the parameter \"-d:<dryrun_prefix>\" or the syntax
#H#        \"PREFIX=<new dryrun_prefix> ${REAL_SCRIPTNAME}\" 
#H#        to change the dryrun prefix
#H#        The script will run in dryrun mode if the environment variable PREFIX
#H#        is set. To disable that behaviour use the parameter \"+d\"
#H#        If the parameter \"-d\" is used without a value and there are other
#H#        parameter following that do NOT start with a hyphen (-) use the format \"-d - [other_parameter]\"
#H#        $( [ ${DRYRUN_MODE_DISABLED} = ${__TRUE} ] && echo "Note: dryrun mode is not supported in this script" ) 
#H#        
#H#   -D - start a debug shell and continue the script afterwards
#H#        Note that the debug shell will be executed while processing the parameter; the parameter can be used
#H#        multiple times
#H#        
#H#   -t - trace the function fn; the parameter can be used multiple times.
#H#        also supported is the format \"-t:fn[,...,fn#]\"
#H#        This functionality does not work for a few internal functions used by the runtime system.
#H#   -L - list all defined functions and end the script
#H#   -T - copy STDOUT and STDERR to the file /var/tmp/${SCRIPTNAME}.$$.tee.log 
#H#        using tee; set the environment variable __TEE_OUTPUT_FILE before 
#H#        calling the script to change the file used for the output of tee
#H#        Note that you can NOT set the variable __TEE_OUTPUT_FILE using the parameter \"--var var=value\"
#H#   -V - print the script version and exit; use \"-v -V\" to print the 
#H#        template version also
#H#   --var 
#H#      - set the variable \"name\" to the value \"value\"
#H#        also supported is the format \"--var:<varname>=<value>\"
#H#   --appendlog
#H#      - append the messages to the logfile (default: overwrite an existing logfile)
#H#        This parameter also sets \"--nologrotate\"
#H#   --nologrotate
#H#      - do not create a backup of an existing logfile
#H#   --noSTDOUTlog
#H#      - do not write STDOUT/STDERR to a file if /dev/tty is not a a device
#H#   --nocleanup
#H#      - do no house keeping at script end
#H#   --nobackups
#H#      - do not create backups
#H#   --disable_tty_check
#H#      - disable the check if we do have a tty
#H#   --print_runtime_vars
#H#      - print the runtime variables defined and exit the script
#H#   --norcm
#H#        do not read any data from the RCM
#H#   --no_appl_params
#H#        do not read the APPL_PARAMS entries from the RCM
#H#   --no_appl_file
#H#        do not read APPL_FILE entries from the RCM
#H#
#H#
#H#
#U# Parameter that toggle a switch from true to false or vice versa can
#U# be used with the plus sign (+) instead of minus (-) to invert the usage, e.g.
#U# 
#U# The parameter \"-v\" enables the verbose mode; the parameter \"+v\" disables the verbose mode.
#U# The parameter \"--quiet\" enables the quiet mode; the parameter \"++quiet\" disables the quiet mode.
#U#
#U# All parameter are processed in the given order, e.g.
#U#
#U#  <scriptname> -v +v
#U#    -> verbose mode is now off
#U#
#U#  <scriptname> +v -v
#U#    -> verbose mode is now on
#U#
#U# Parameter are evaluated after the evaluation of environment variables, e.g
#U#
#U# VERBOSE=0  <scriptname>
#U#     -> verbose mode is now on
#U#
#U# VERBOSE=0  <scriptname> +v
#U#     -> verbose mode is now off
#U#
#U# 
#U# To disable one or more of the house keeping tasks you might set some variables
#U# either before starting the script or via the parameter \"--var name=value\"
#U# 
#U# The defined variables are
#U# 
#U#  NO_EXIT_ROUTINES=0       # do not execute the exit routines if set to 0
#U#  NO_TEMPFILES_DELETE=0    # do not delete temporary files if set to 0
#U#  NO_TEMPDIR_DELETE=0      # do not delete temporary directories if set to 0
#U#  NO_FINISH_ROUTINES=0     # do not execute the finish routines if set to 0
#U#  NO_UMOUNT_MOUNTPOINTS=0  # do not umount temporary mount points if set to 0
#U#  NO_KILL_PROCS=0          # do not kill the processes if set to 0
#U#  
### Predefined Return codes:
###
###   2     Invalid parameter found
### 200     Script aborted for unknown reason; EXIST signal received
### 201	    Script aborted for unknown reason, QUIT signal received
### 202     This script must be executed by root only
### 203     internal error
### 250     ${SCRIPTNAME} aborted by CTRL-C
### 253     Can not create backups of the log files
### 254     ${SCRIPTNAME} aborted by the user
###
### ---------------------------------

### for start/stop scripts : 
### 
### # LSB Style tags (remove the initial "### " to activate)
### #
### #
### ### BEGIN INIT INFO
### # Provides: foo
### # Required-Start: bar
### # Default-Start: 2 3 4 5
### # Default-Stop: 0 1 6
### # Description: Foo init script
### ### END INIT INFO

### chkconfig tags for start/stop scripts (remove the initial ### to activate)
###
### For example: # chkconfig: 2345 20 80
###
### # chkconfig: <startlevellist> <startpriority> <endpriority>
### # description: <multi-line description of service>
###
### see man chkconfig for other supported tags

### Note: The format of the entries for the history list should be
### 
###       #V#   <date> v<version> <comment>
#V#
#V# History:  
#V#   01.05.2022 v1.0.0 /bs
#V#     initial release
#V#
#T# ----------------------------------------------------------------------
#T#

#T# History of the script template 
#T#
#T#   28.04.2016 v1.0.0 /bs
#T#     initial release
#T#
#T#   ...
#T#
#T#   08.11.2017 v2.0.0 /bs
#T#     initial public release
#T#
#T#   24.11.2017 v2.1.0 /bs
#T#     added the parameter -T (use tee to save the script output)
#T#     added the function KillProcess
#T#     the script now supports a timeout for each pid to kill at script end
#T#       (see the comments for the function KillProcess)
#T#     the cleanup function now supports parameter for the exit routines
#T#     the cleanup function now supports parameter for the finish routines
#T#     added the variable INSIDE_CLEANUP_ROUTINE
#T#     added the variable INSIDE_FINISH_ROUTINE
#T#     the parameter -t and the DebugShell aliase for tracing now support
#T#       the variable ${.sh.func} if running in ksh93
#T#     the parameter -t and the DebugShell aliase for tracing now add the statements 
#T#       typeset __FUNCTION=<function_name> ; ${__DEBUG_CODE};
#T#     to a function if neccessary and "typeset -f" is supported by the shell used
#T#     added the variable ${ENABLE_DEBUG}; if ${ENABLE_DEBUG} is not ${__TRUE} the DebugShell
#T#       and the parameter -D are disabled
#T#     added the variable ${USAGE_HELP}
#T#     added the function show_extended_usage_help
#T#     added the parameter -L / --listfunctions
#T#     Read_APPL_PARAMS_entries rewritten using an array for the RCM entries
#T#
#T#   07.12.2017 v2.1.1 /bs
#T#     the aliase use now only one line
#T#     LogRotate now aborts the script if it can not create backups of the
#T#       existing log file
#T#
#T#   10.12.2017 v2.2.0 /bs
#T#     added the parameter --var, the parameter --var is disabled if the variable
#T#       ${ENABLE_DEBUG} is not ${__TRUE}
#T#
#T#   19.01.2018 v2.2.1 /bs
#T#     the script now uses /var/tmp/${SCRIPTNAME}.$$.STDOUT_STDERR if it can not
#T#     write to the file /var/tmp/${SCRIPTNAME}.STDOUT_STDERR
#T#
#T#   29.01.2018 v2.2.2 /bs
#T#     the script now uses /var/tmp/${SCRIPTNAME}.log.$$ if it can not
#T#     write to the file /var/tmp/${SCRIPTNAME}.log
#T#     the script now uses /var/tmp/${SCRIPTNAME}.STDOUT_STDERR.$$ if it can not
#T#     write to the file /var/tmp/${SCRIPTNAME}.STDOUT_STDERR
#T#
#T#   09.02.2018 v2.2.3 /bs
#T#     added the parameter --appendlog
#T#     added the parameter --noSTDOUTlog
#T#
#T#   10.02.2018 v2.2.4 /bs
#T#     added the parameter --nologrotate
#T#
#T#   14.02.2018 v2.2.5 /bs
#T#     the script now converts the logfile name to a fully qualified name
#T#     in the previous version the script created additional empty logfiles - fixed
#T#
#T#   01.04.2018 v3.0.0 /bs
#T#     the parameter --var can now be used in this format also: --var:<var>=<value>
#T#     the parameter --tracefunc can now be used in this format also: --tracefunc:fn[..,fn]
#T#     the parameter --logfile can now be used in this format also: --logfile:<logfile>
#T#     the script now prints also the template version if the parameter -v and -V are used
#T#     the script now prints also the template history if the parameter "-h -v -v" are used
#T#     the version of the script and the version of the template are now dynamically 
#T#       retrieved from the source code of the script while executing the script
#T#     the parameter "-d" overwrote the value of the environment variable PREFIX -- fixed
#T#     added more details to the usage help for the parameter \"-h\"
#T#     added the DebugShell function editfunc
#T#     added the DebugShell function savefunc
#T#     added the DebugShell function restorefunc
#T#     added the DebugShell function clearsavedfunc
#T#     added the DebugShell function savedfuncs
#T#     added the DebugShell function viewsavedfunc
#T#     the function DebugShell now prints the return code of every executed command
#T#     the function DebugShell did not handle "." commands with errors correct - fixed
#T#     set_debug now preserves existing debug definitions if the parameter starts with a "+"
#T#     the output of the DebugShell alias vi#T#   25.07.2018 v3.0.1 /bsew_debug is now more human readable
#T#     the parameter --appendlog now also sets --nologrotate
#T#
#T#   25.07.2018 v3.1.0 /bs
#T#     added the parameter --nocleanup
#T#     added the variables
#T#       NO_EXIT_ROUTINES     # do not execute the exit routines if set to 0
#T#       NO_TEMPFILES_DELETE  # do not delete temporary files if set to 0
#T#       NO_TEMPDIR_DELETE    # do not delete temporary directories if set to 0
#T#       NO_FINISH_ROUTINES   # do not execute the finish routines if set to 0
#T#       NO_KILL_PROCS        # do not kill the processes if set to 0
#T#     renamed the variable KSH_VERSION to __KSH_VERSION because KSH_VERSION is a 
#T#       readonly variable in mksh
#T#
#T#   16.08.2018 v3.2.0 /bs
#T#     the default parameter processing now stops if the parameter "--" is found
#T#     added code to umount temporary mount points at script end
#T#     added the variable
#T#       NO_UMOUNT_MOUNTPOINTS # do not umount temporary mount points at script end
#T#     the cleanup function for the house keeping now does nothing in dry-run mode 
#T#     added the function switch_to_background to switch the process with the 
#T#       script into the background; 
#T#       this functionwas tested in Linux (RHEL), Solaris 10, AIX, and MacOS
#T#
#T#   03.11.2018 v3.2.1 /bs
#T#     corrected a minor bug in the cleanup function
#T#     switch_to_background disabled in the DebugShell
#T#     added the variable DEBUG_SHELL_CALLED
#T#     script called the finish functions twice -- fixed
#T#     the script now also evaluates ${..} in help text marked with #U# 
#T#         (-> printed with -h -v)
#T#     corrected some spelling errors
#T#
#T#   16.11.2018 v3.2.2 /bs
#T#     added the variable SYSTEMD_IS_USED 
#T#     added the alias __getparameter to process parameter with values
#T#
#T#   25.12.2018 v3.2.2 /bs
#T#     LogMsg return ${__TRUE} if the message was not written - fixed
#T#     LogInfo, LogWarning, and LogError now also support the special parameter "-"
#T#       to suppress the date prefix in the message
#T#     Added the variable __SHELL
#T#     Added the function BackupFile
#T#
#T#   14.01.2019 v3.3.0 /bs
#T#     corrected some code using the special variable LINENO because
#T#       the old code did not work on all ksh versions from Solaris 11
#T#     alias __ignoretraps deleted -- that code is not supported by all ksh versions
#T#     added the variable CUR_OS_VERSION
#T#
#T#   26.03.2019 v3.4.0 /bs
#T#     added the function LogMoreInfo
#T#
#T#   19.07.2019 v3.5.0 /bs
#T#     added the parameter --disable_tty_check
#T#     the script now uses a logfile in /tmp if it can not create a logfile in /var/tmp
#T#       if it can also not create a logfile in /tmp no logfile is used
#T#     DEBUG_SHELL_CALLED was not set to ${__TRUE} in DebugShell -- fixed
#T#
#T#   29.08.2019 vß3.6.0 /bs
#T#     the variable FILES_TO_REMOVE was overwritten in the function DebugShell -- fixed
#T#     added the function create_lock_file
#T#  
#T#   25.10.2019 v3.6.1 /bs
#T#     the script now only prints a small usage help if the parameter -h is used
#T#     (use --help to get the long usage help like before)
#T#
#T#   21.11.2019 v3.6.2 /bs
#T#     added the global variables 
#T#       RUNNING_ON_A_VIRTUAL_MACHINE 
#T#       THIS_IS_A_VMWARE_MACHINE 
#T#       SYSTEM_PRODUCT_NAME 
#T#       SYSTEM_PRODUCT_VENDOR
#T#       HPYERVISOR_VENDOR
#T#
#T#   05.02.2020 v3.6.3 /bs
#T#     the function get_fqn did not work due to a missing assignment for the variable READLINK -- fixed
#T#     the error messages printed if the script can not write to the logfile are now print to STDERR instead of STDOUT
#T#
#T#   13.02.2020 v3.6.4 /bs
#T#      added the variables STARTTIME_IN_SECONDS amd STARTTIME_IN_HUMAN_READABLE_FORMAT
#T#      added the variables  ENDTIME_IN_SECONDS, and ENDTIME_IN_HUMAN_READABLE_FORMAT
#T#      added the variables  RUNTIME_IN_SECONDS, and RUNTIME_IN_HUMAN_READABLE_FORMAT
#T#      the script now prints the start time, the runtime in seconds and in human readable format, and the return code at script end
#T#
#T#   28.02.2020 v3.6.5 /bs
#T#      added the parameter -o / --overwrite
#T#      added the parameter --nobackups
#T#      added the function read_file_section
#T#      the definition for the variable CUR_SHELL ("$( head -1 "${REAL_SCRIPTNAME}" | cut -f1 -d " " | cut -c3- )" ) got lost -- fixed
#T#
#T#   28.02.2020 v3.6.6 /bs
#T#      create_lock_file improved
#T#
#T#   19.03.2020 v3.6.7 /bs
#T#      removed not neccessary code to check if the log file is writable
#T#
#T#   20.05.2020 v3.6.8 /bs
#T#      switch_to_background did not work in Solaris -- fixed
#T#      switch_to_background now ends with an error if running in an unknown OS
#T#
#T#   29.06.2020 v3.6.9 /bs
#T#      added the variables STDIN_IS_TTY, STDOUT_IS_TTY, STDERR_IS_TTY
#T#      added the variables STDIN_DEVICE, STDOUT_DEVICE, STDERR_DEVICE
#T#      added the variable RUNNING_IN_A_CONSOLE_SESSION
#T#      added the variable STDOUT_IS_A_PIPE
#T#      added the variable STDIN_IS_A_PIPE
#T#      added the variable PARENT_PROCECSS_EXECUTABLE
#T#
#T#   04.07.2020 v3.7.0 /bs
#T#      corrected the code to detect the binary to use for readlink (variable READLINK) again
#T#
#T#   06.07.2020 v3.7.1 /bs
#T#     the new code from 3.6.9 did not work correct if /tmp was mounted with the option noexec -- fixed
#T#
#T#   06.07.2020 v3.7.2 /bs
#T#     code to get STDIN_DEVICE and STDOUT_DEVICE rewritten
#T#
#T#   06.01.2021 v3.8.0 /bs
#T#     the global settings wiill now be printed with LogRuntimeInfo
#T#     changed the code to process the parameter -d
#T#     added support for the dummy parameter "-"
#T#
#T#   14.03.2021 v3.8.1 /bs
#T#     get_fqn now returns the original dir/filename if the directory/file does not exist
#T#
#T#   21.03.2021 v3.8.2 /bs
#T#     the script now prints a hint if the equal sign (=) is used in an unknown parameter
#T#
#T#   25.04.2021 v3.8.3 /bs
#T#     the function show_extended_usage_help (executed if the parameter "-v -h" are used) now
#T#       prints more details for the supported environment variables
#T#     the variables TMPFILE1 and TMPFILE2 were only filled if running under Linux -- fixed
#T#     the variable SED was not defined -- fixed
#T#
#T#   28.04.2021 v3.8.4 /bs
#T#     the code to remove the default temporary files ${TMPFILE1} and ${TMPFILE2} was removed -- fixed
#T#     added the variable NO_OF_LOGFILES_TO_KEEP to define the number of old logfiles to keep
#T#
#T#   18.07.2021 v3.8.5 /bs
#T#     added the function gettime_in_seconds
#T#     added the function runcmd_with_timeout
#T#     the cleanup function will now do the cleanup in this order
#T#       execute all cleanup_functions // kill procs // delete files // umount mount points // delete directories  / execute all finish_functions
#T#     added the parameter --print_runtime_vars
#T#     all cp, mv, and rm commands used are now prefixed with a slash "\" to ignore aliase
#T#
#T#   22.02.2022 v3.8.6 /bs
#T#     removed the not set variable ${THISSCRIPT} from the string in the function LogMsg
#T#
#T#   23.03.2022 v3.8.7 /bs
#T#     added the variable PRINT_COMMAND_TO_EXECUTE : If this variable is true ExecuteCommandAndLog will print all commands before executing them
#T#     minor cosmetic changes only
#T#     The function BackupFile now use the name of the file to backup also for the backup file if the parameter for the backup file name is missing
#T#     added the function convert_variable_to_boolean
#T#     added the function is_variable_true
#T#
#T#   22.04.2022 v3.9.0 /bs
#T#     fixed some typos and errors in the messages
#T#     fixed some minor errors
#T#     added support to enable the verbose mode for specific functions only (parameter "-v:fn")
#T#     lines starting with #h#, #H#, and #U#  can now be mixed in the comments
#T#     the number of log files to keep can now be defined by the prefix ":n" for the value of the parameter "-l"
#T#     to use the default log file and only change the number of logfiles to keep the parameter "-l :n" can be used
#T#     the function gettime_in_seconds now uses "date +%s" if perl is not working
#T#     the alias set_debug in the DebugShell now preserves the value of the variable __DEBUG_CODE 
#T#
#T#   30.04.2022 v3.9.1 /bs
#T#     get_fqn did not use the variable READLINK for the executable readlink -- fixed
#T#
#T#   01.09.2022 v3.9.2 /bs
#T#     the script now uses the parameter "-o comm=" from the command ps to get the shell execuing the script
#T#
#T#   29.05.2023 v3.10.0 /bs
#T#     added the parameter --norcm, --no_appl_params, and --no_appl_file
#T# 

#T#   03.02.2024 v3.11.0 /bs
#T#     "grep -E" is not supported by the grep from Solaris 10 -- fixed
#T#     use gsed instead of sed when available (necessary for Solaris 10)
#T#
# ----------------------------------------------------------------------
#
#
# use "grep -E" instead of "egrep" if supported (this is OS independent)
#
echo test | grep -E test 2>/dev/null >/dev/null && EGREP="grep -E " || EGREP="egrep"


# read the template version from the source file
#
__TEMPLATE_VERSION="$(  grep "^#T#" $0 | grep " v[0-9]" | tail -1 | awk '{ print $3};' )"
: ${__TEMPLATE_VERSION:=can not find the template version -- please check the source code of $0}

# read the script version from the source file
#
SCRIPT_VERSION="$( grep "^#V#" $0 | grep " v[0-9]" | tail -1 | awk '{ print $3};' )"
: ${SCRIPT_VERSION:=can not find the script version -- please check the source code of $0}

# hardcoded script / template versions (not used anymore)
#

# __TEMPLATE_VERSION="3.0.0"

# SCRIPT_VERSION="1.0.0"


# USAGE_HELP contains additional text that is written by the script if 
# executed with the parameter -h
#
USAGE_HELP=""

# enviroment variables used by the script
#
# format:
# name # type # comment
#
# type and comment are optional
#
ENV_VARIABLES="#
PREFIX                     # string   # prefix used in dry-run-mode
__DEBUG_CODE               # string   # debug code for the functions
__TEE_OUTPUT_FILE          # filename # log file used for  --tee
USE_ONLY_KSH88_FEATURES    # boolean  #
DISABLE_TTY_CHECK          # boolean  # paramaeter disable_tty_check
BREAK_ALLOWED              # string   # 0 / 1 / DebugShell
EDITOR                     # filename # editor to use
PAGER                      # filename # pager to use
LOGFILE                    # filename # log file
NO_OF_LOGFILES_TO_KEEP     # integer  # number of log files to keep
NOHUP_STDOUT_STDERR_FILE   # filename # log file used in the function switch_to_background
#
FORCE                      # boolean  # parameter --force
QUIET                      # boolean  # parameter --quiet
VERBOSE                    # boolean  # parameter --verbose
VERBOSE_LEVEL              # boolean  # 
OVERWRITE                  # boolean  # parameter --overwrite
#
# environment variables for the RCM methods
#
RCM_SERVICE                # string   # used only in the RCM methods
RCM_FUNCTION               # string   # used only in the RCM methods
RCM_USERID                 # string   # used only in the RCM methods
RCM_PASSWORD               # string   # used only in the RCM methods

${ADDITIONAL_ENV_VARIABLES}
"

# define constants
#
__TRUE=0
__FALSE=1

__TRUE_FALSE[0]="true"
__TRUE_FALSE[1]="false"

# dryrun mode disabled?
# To enable dryrun mode set DRYRUN_MODE_DISABLED to ${__FALSE}
#
# dryrun mode only works if you prefix all commands that change something whith ${PREFIX}!
#
DRYRUN_MODE_DISABLED=${__TRUE}
#DRYRUN_MODE_DISABLED=${__FALSE}

# dryrun prefix (parameter -d)   
#
DEFAULT_DRYRUN_PREFIX="echo "

# : ${PREFIX:=${DEFAULT_DRYRUN_PREFIX} }
: ${PREFIX:=}


# DebugShell will do nothing, and the parameter -D and --var are not usable if ENABLE_DEBUG is ${__FALSE} 
#
ENABLE_DEBUG=${__TRUE}
#ENABLE_DEBUG=${__FALSE}

# variable for debugging
#
# use "eval ... >&2" for your debug code and use STDERR for all output!
#
# e.g. 
#
#   __DEBUG_CODE="eval echo \*\*\*  Starting the function \$0, parameter are: \'\$*\'>&2" ./scriptt_mini.sh
#
if [ ${ENABLE_DEBUG} = ${__TRUE} ] ; then
: ${__DEBUG_CODE:=}
else
  __DEBUG_CODE=""
fi
__USER_DEBUG_CODE="${__DEBUG_CODE}"


[[ "${__USER_DEBUG_CODE}" != *\;[[:space:]]* ]] &&__USER_DEBUG_CODE="${__USER_DEBUG_CODE} ;"

__CODE_TO_ENABLE_VERBOSE_MODE=""

# list of functions with enabled debug code
#
__FUNCTIONS_WITH_DEBUG_CODE=""

# list of functions with enabled verbose mode
#
__FUNCTIONS_IN_VERBOSE_MODE=""

# list of saved functions
#
__LIST_OF_SAVED_FUNCTIONS=""

# set this variable to ${__TRUE} to change the default to "tty check is disabled"
#

DISABLE_TTY_CHECK=${DISABLE_TTY_CHECK:=${__FALSE}}

RUNNING_IN_TERMINAL_SESSION=${__TRUE}

# check tty
#
if [ ${DISABLE_TTY_CHECK} = ${__FALSE} ] ; then
  tty -s && RUNNING_IN_TERMINAL_SESSION=${__TRUE} || RUNNING_IN_TERMINAL_SESSION=${__FALSE}
fi


# disable the tty check if the parameter --disable_tty_check is used
#
# Note: The parameter ++disable_tty_check is not supported
#
if [[  \ $*\  == *\ --disable_tty_check\ * ]] ; then
  RUNNING_IN_TERMINAL_SESSION=${__TRUE}
  DISABLE_TTY_CHECK=${__TRUE}
fi

# file for STDOUT and STDERR if the parameter -t/--tee is used
#
: ${__TEE_OUTPUT_FILE:=/var/tmp/${0##*/}.$$.tee.log}

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
# check for the parameter -q / --quiet
#
if [[ \ $*\  == *\ -q* || \ $*\  == *\ --quiet\ * ]] ; then
  QUIET=${__TRUE}
fi
  
# -----------------------------------------------------------------------------
#### __KSH_VERSION - ksh version (either 88 or 93)
####   If the script is not executed by ksh the shell is compatible to
###    ksh version ${__KSH_VERSION}
####
__KSH_VERSION=88 ; f() { typeset __KSH_VERSION=93 ; } ; f ;

# check if "typeset -f" is supported
#
typeset -f f | grep __KSH_VERSION >/dev/null && TYPESET_F_SUPPORTED="yes" || TYPESET_F_SUPPORTED="no"

unset -f f

# check if $0 in a function defined with "function f { ... }" is the function name
#
function f {
  echo $0
}

[ "$( f )"x = "f"x ] && TRACE_FEATURE_SUPPORTED="yes" || TRACE_FEATURE_SUPPORTED="no"

unset -f f

# use ksh93 features?
#
if [ "${__KSH_VERSION}"x = "93"x ] ; then
  USE_ONLY_KSH88_FEATURES=${USE_ONLY_KSH88_FEATURES:=${__FALSE}}
else
  USE_ONLY_KSH88_FEATURES=${USE_ONLY_KSH88_FEATURES:=${__TRUE}}
fi

# alias to install the trap handler
#

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

alias __settraps="
  trap 'signal_hup_handler    \${LINENO}' 1 ;\
  trap 'signal_break_handler  \${LINENO}' 2 ;\
  trap 'signal_quit_handler   \${LINENO}' 3 ;\
  trap 'signal_exit_handler   \${LINENO}' 15 ;\
  trap 'signal_usr1_handler   \${LINENO}' USR1 ;\
  trap 'signal_usr2_handler   \${LINENO}' USR2  ;\
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

__FUNCTION_INIT="eval __settraps"

# variables used for the logfile handling
#
# the log functions save all messages in the variable LOG_MESSAGE_CACHE until the logfile to use is known
#
LOGFILE_FOUND=${__FALSE}
LOG_MESSAGE_CACHE=""

# variables for the function create_lock_file
#
# these two variables are set by the function create_lock_file
#
WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS="0"
PID_OF_PROCESS_HOLDING_THE_LOCKFILE=""

# default values for the parameter of the function create_lock_file
#
DEFAULT_LOCK_FILE="/tmp/${0##*/}_is_running"
DEFAULT_LOCK_FILE_WAIT_TIME=120
DEFAULT_STEP_COUNT=10

# variables for the trap handler
#
# The INSIDE_* variables are set to ${__TRUE} while the handler is active and 
# then back to ${__FALSE} after the handler is done
#
INSIDE_DIE=${__FALSE}
INSIDE_DEBUG_SHELL=${__FALSE}
INSIDE_CLEANUP_ROUTINE=${__FALSE}
INSIDE_FINISH_ROUTINE=${__FALSE}
#
INSIDE_USR1_HANDLER=${__FALSE}
INSIDE_USR2_HANDLER=${__FALSE}
INSIDE_BREAK_HANDLER=${__FALSE}
INSIDE_HUP_HANDLER=${__FALSE}
INSIDE_EXIT_HANDLER=${__FALSE}
INSIDE_QUIT_HANDLER=${__FALSE}

# the variable DEBUG_SHELL_CALLED is set to TRUE everytime the function DebugShell is executed
#
DEBUG_SHELL_CALLED=${__FALSE}

# set the variable PRINT_COMMAND_TO_EXECUTE to ${__TRUE} to print all commands executed by the function
# executeCommandAndLog
#
PRINT_COMMAND_TO_EXECUTE=${__FALSE}

# set BREAK_ALLOWED to ${__FALSE} to disable CTRL-C, to ${__TRUE} to abort the script with CTRL-C
# and to "DebugShell" to call the DebugShell if the CTRL-C signal is catched
#
BREAK_ALLOWED="${BREAK_ALLOWED:=DebugShell}"
# BREAK_ALLOWED=${__FALSE}
# BREAK_ALLOWED=${__TRUE}

# current hostname
#
CUR_HOST="$( hostname )"
CUR_SHORT_HOST="${CUR_HOST%%.*}"

CUR_OS="$( uname -s )"

CUR_OS_VERSION="$( uname -r )"

# script name and directory
#
typeset -r SCRIPTNAME="${0##*/}"
typeset SCRIPTDIR="${0%/*}"
if [ "${SCRIPTNAME}"x = "${SCRIPTDIR}"x ] ; then
  SCRIPTDIR="$( whence ${SCRIPTNAME} )"
  SCRIPTDIR="${SCRIPTDIR%/*}"
fi  
REAL_SCRIPTDIR="$( cd -P ${SCRIPTDIR} ; pwd )"
REAL_SCRIPTNAME="${REAL_SCRIPTDIR}/${SCRIPTNAME}"

CUR_SHELL="$( head -1 "${REAL_SCRIPTNAME}" | cut -f1 -d " " | cut -c3- )"

WORKING_DIR="$( pwd )"

LOGDIR="/var/tmp"

DEFAULT_LOGFILE="${LOGFILE:=${LOGDIR}/${SCRIPTNAME}.log}"
LOGFILE="${DEFAULT_LOGFILE}"

#
# number of  old logfiles to keep
#
NO_OF_LOGFILES_TO_KEEP=${NO_OF_LOGFILES_TO_KEEP:=10}

# use either vim, vi or nano as editor if no default editor is set
#
: ${EDITOR:=$( which vim 2>/dev/null )}
: ${EDITOR:=$( which vi 2>/dev/null )}
: ${EDITOR:=$( which nano 2>/dev/null )}

# use less or more as pager if no default pager is set
#
: ${PAGER:=$( which less 2>/dev/null )}
: ${PAGER:=$( which more 2>/dev/null )}

SYSTEMD_IS_USED=${__FALSE}

READLINK=""

#
# if either STDIN, STDOUT, or STDERR goes to a real tty
# device this variable will be true
#
# So this is not really a bullet proof solution!
#
RUNNING_IN_A_CONSOLE_SESSION="unknown"

STDOUT_IS_A_PIPE="unknown"
STDIN_IS_A_PIPE="unknown"

[ -t 0 ] &&  STDIN_IS_TTY=${__TRUE} ||  STDIN_IS_TTY=${__FALSE}
[ -t 1 ] && STDOUT_IS_TTY=${__TRUE} || STDOUT_IS_TTY=${__FALSE}
[ -t 2 ] && STDERR_IS_TTY=${__TRUE} || STDERR_IS_TTY=${__FALSE}
 
STDIN_DEVICE="unknown"
STDOUT_DEVICE="unknown"
STDERR_DEVICE="unknown"

PARENT_PROCECSS_EXECUTABLE=""

TMPFILE1="/var/tmp/${SCRIPTNAME}.1.$$"
TMPFILE2="/var/tmp/${SCRIPTNAME}.2.$$"

case "${CUR_OS}" in

  CYGWIN* )
    set +o noclobber

# Note: The variable __SHELL_FIELD is not used anymore
    __SHELL_FIELD=9
    AWK="awk"
    ;;

  Linux )
# Note: The variable __SHELL_FIELD is not used anymore
    __SHELL_FIELD=8  
    ID="id"
    AWK="awk"
    TAR="tar"
    SED="sed"
    ps -p 1 | grep systemd >/dev/null && SYSTEMD_IS_USED=${__TRUE} || SYSTEMD_IS_USED=${__FALSE}

    READLINK="$( which readlink 2>/dev/null )"

    [ -p /proc/$$/fd/1 ] && STDOUT_IS_A_PIPE=${__TRUE} || STDOUT_IS_A_PIPE=${__FALSE}
    [ -p /proc/$$/fd/0 ] &&  STDIN_IS_A_PIPE=${__TRUE} ||  STDIN_IS_A_PIPE=${__FALSE}


#
# a workaround is neccessary to get the device/file used for STDOUT and STDIN in some circumstances
#        
    echo "( ls -l /proc/$$/fd/0 2>/dev/null || echo unknown  ; ls -l /proc/$$/fd/1 2>/dev/null || echo unknown ) >${TMPFILE1}"  >"${TMPFILE2}"
    if [ $? -eq 0 ] ; then
      chmod 755 "${TMPFILE2}"
      ksh -c "${TMPFILE2}" 2>/dev/null
      if [ $? -eq 0 -a -r "${TMPFILE1}" ] ; then
        STDIN_DEVICE="$(  head -1 "${TMPFILE1}" 2>/dev/null | awk '{ print $NF }' )"
        STDOUT_DEVICE="$( tail -1 "${TMPFILE1}" 2>/dev/null | awk '{ print $NF }' )"
      fi      
      \rm -f "${TMPFILE1}" "${TMPFILE2}"  2>/dev/null
    fi

    STDERR_DEVICE="$( ls -l /proc/$$/fd/2 | awk '{ print $NF }' )"
    
    [[ ${STDIN_DEVICE} == /dev/tty* ]] &&  RUNNING_IN_A_CONSOLE_SESSION=${__TRUE} ||  RUNNING_IN_A_CONSOLE_SESSION=${__FALSE}

    [[ ${STDIN_DEVICE} == /dev/pts/* || ${STDIN_DEVICE} == /dev/tty* ]] &&  STDIN_IS_TTY=${__TRUE} ||  STDIN_IS_TTY=${__FALSE}
    
    [[ ${STDOUT_DEVICE} == /dev/pts/* || ${STDOUT_DEVICE} == /dev/tty* ]] && STDOUT_IS_TTY=${__TRUE} || STDOUT_IS_TTY=${__FALSE}
    [[ ${STDOUT_DEVICE} == /dev/tty* ]] &&  RUNNING_IN_A_CONSOLE_SESSION=${__TRUE} 

    [[ ${STDERR_DEVICE} == /dev/pts/* || ${STDERR_DEVICE} == /dev/tty* ]] && STDERR_IS_TTY=${__TRUE} || STDERR_IS_TTY=${__FALSE}
    [[ ${STDERR_DEVICE} == /dev/tty* ]] &&  RUNNING_IN_A_CONSOLE_SESSION=${__TRUE} 

    PARENT_PROCECSS_EXECUTABLE="$( readlink -f /proc/$(ps -o ppid:1= -p $$)/exe )"
    ;;
      
  SunOS )
# Note: The variable __SHELL_FIELD is not used anymore
    __SHELL_FIELD=9
    if [ "${CUR_OS_VERSION}"x != "5.11"x ] ; then
      AWK="nawk"
     
      ID="/usr/xpg4/bin/id"

      SED="$( whence gsed )"
      [ "${SED}"x = ""x -a -x "/opt/csw/bin/gsed" ] && SED="/opt/csw/bin/gsed"
      [ "${SED}"x = ""x -a -x "/usr/xpg4/bin/sed" ] && SED="/usr/xpg4/bin/sed"
      [ "${SED}"x = ""x ] && SED="$( whence sed )"

      TAR="$( whence gsed )"
      [ "${TAR}"x = ""x -a -x "/opt/csw/bin/gtar" ] && SED="/opt/csw/bin/gtar"
      [ "${TAR}"x = ""x -a -x "/usr/sfw/bin/gtar" ] && SED="/usr/sfw/bin/gtar"
      [ "${TAR}"x = ""x -a -x "/usr/xpg4/bin/star" ] && SED="/usr/xpg4/bin/gtar"
      [ "${TAR}"x = ""x ] && SED="$( whence tar )"
      
    else
      ID="id"
      AWK="awk"
      TAR="tar"
      SED="sed"
    fi
 
    READLINK="$( whence readlink )" || \
      [ -x /opt/csw/gnu/readlink ] && READLINK="/opt/csw/gnu/readlink"

    RUNNING_IN_A_CONSOLE_SESSION=${__FALSE} 

    [ -p /proc/$$/fd/1 ] && STDOUT_IS_A_PIPE=${__TRUE} || STDOUT_IS_A_PIPE=${__FALSE}
    [ -p /proc/$$/fd/0 ]  && STDIN_IS_A_PIPE=${__TRUE}  || STDIN_IS_A_PIPE=${__FALSE}

    CUR_MAJOR_DEV="$( ls -ld /proc/$$/fd/0 | awk '{ print $5 }' )"    
    [ "${CUR_MAJOR_DEV}"x = "0,"x ] && RUNNING_IN_A_CONSOLE_SESSION=${__TRUE} 

    CUR_MAJOR_DEV="$( ls -ld /proc/$$/fd/1 | awk '{ print $5 }' )"    
    [ "${CUR_MAJOR_DEV}"x = "0,"x ] && RUNNING_IN_A_CONSOLE_SESSION=${__TRUE} 
 
    CUR_MAJOR_DEV="$( ls -ld /proc/$$/fd/2 | awk '{ print $5 }' )"    
    [ "${CUR_MAJOR_DEV}"x = "0,"x ] && RUNNING_IN_A_CONSOLE_SESSION=${__TRUE} 
    ;;

  AIX )
# Note: The variable __SHELL_FIELD is not used anymore
    __SHELL_FIELD=9
    AWK="awk"
    ID="id"
    TAR="tar" 
    SED="sed"
    ;;

  Darwin )
# Note: The variable __SHELL_FIELD is not used anymore
    __SHELL_FIELD=8
    AWK="awk"
    ID="id"
    TAR="tar"    
    SED="sed"
    ;;

  * )
# Note: The variable __SHELL_FIELD is not used anymore
    __SHELL_FIELD=8
    AWK="awk"
    ID="id"
    TAR="tar"    
    SED="sed"
    ;;

esac


#### __SHELL - name of the current shell executing this script
####

# old code:
# __SHELL="$( ps -f -p $$ | grep -v PID | tr -s " " | cut -f${__SHELL_FIELD} -d " " )"

__SHELL="$( ps  -p $$ -o comm= )"

__SHELL=${__SHELL##*/}

: ${__SHELL:=ksh}

CUR_USER_ID="$( ${ID} -u )"
CUR_USER_NAME="$( ${ID} -un )"

CUR_GROUP_ID="$( ${ID} -g )"
CUR_GROUP_NAME="$( ${ID} -gn )"

# parameter -f
#
: ${FORCE:=${__FALSE}}

# parameter -q
#
: ${QUIET:=${__FALSE}}

# parameter -v
#
: ${VERBOSE:=${__FALSE}}

# VERBOSE_LEVEL is increased by one for every -v found in the parameter
#
: ${VERBOSE_LEVEL:=0}

# parameter -o
#
: ${OVERWRITE:=${__FALSE}}


# parameter -L
#
LIST_FUNCTIONS_AND_EXIT=${__FALSE}

# parameter --nologrotate
#
ROTATE_LOG=${__TRUE}

# for Logrotating once each month for scripts running each day use
#
# [ $( date "+%d" ) = 1 ] && ROTATE_LOG=${__TRUE} || ROTATE_LOG=${__FALSE}

# for Logrotating once a week (1 = monday) for scripts running each day use
#
# [ $( date "+%u" ) = 1 ] && ROTATE_LOG=${__TRUE} || ROTATE_LOG=${__FALSE}

# parameter --nocleanup
#
NO_CLEANUP=${__FALSE}

# parameter --nobackups
#
NO_BACKUPS=${__FALSE}

# parameter --appendlog
#
APPEND_LOG=${__FALSE}

# parameter --noSTDOUTlog
#
LOG_STDOUT=${__TRUE}

# parameter -y and -n (used in the function AskUser)
#
# answer all questions with Yes (if "y") or No (if "n") else ask the user
#
__USER_RESPONSE_IS=""

# user input in the function AskUser
#
USER_INPUT=""
LAST_USER_INPUT=""

# do not print the user input in the function AskUser
#
__NOECHO=${__FALSE}

# use /dev/tty instead of STDIN and STDOUT in the function AskUser
#
__USE_TTY=${__FALSE}

# stty settings (used in die to reset the stty settings if neccessary)
#
__STTY_SETTINGS=""

# allow a debug shell in the function AskUser
#
__DEBUG_SHELL_IN_ASKUSER=${__TRUE}

# variables for the house keeping
#
# directories to remove at script end
#
DIRS_TO_REMOVE=""

# files to remove at script end
#
#FILES_TO_REMOVE=""
FILES_TO_REMOVE="${TMPFILE1} ${TMPFILE2}"

# processes to kill at script end
#
PROCS_TO_KILL=""

# timeout in seconds to wait after "kill" before issueing a "kill -9" for a 
# still running process, use -1 for the KILL_PROC_TIMEOUT to disable "kill -9"
#
KILL_PROC_TIMEOUT=0

# cleanup functions to execute at script end
# Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
# blanks or tabs in the parameter are NOT allowed
#
CLEANUP_FUNCTIONS=""

# mount points to umount at script end
#
MOUNTS_TO_UMOUNT=""

# finish functions to execute at script end
# Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
# blanks or tabs in the parameter are NOT allowed
#
FINISH_FUNCTIONS=""

# ----------------------------------------------------------------------
# variable for print_runtime_variables
#
# format:
#
#  #msg  - message to print (replacing "_" with " "; 
#          do NOT use blanks in the lines starting with #)
#  else	 - variablename, print the name and value
#
RUNTIME_VARIABLES="
#
#constants
__TRUE
__FALSE
#
#signal_handling:
BREAK_ALLOWED
INSIDE_DIE
INSIDE_DEBUG_SHELL
INSIDE_CLEANUP_ROUTINE
INSIDE_FINISH_ROUTINE
INSIDE_USR1_HANDLER
INSIDE_USR2_HANDLER
INSIDE_BREAK_HANDLER
INSIDE_HUP_HANDLER
INSIDE_EXIT_HANDLER
INSIDE_QUIT_HANDLER
DEBUG_SHELL_CALLED

#Parameter:
ALL_PARAMETER
NOT_USED_PARAMETER
FORCE
QUIET
VERBOSE
VERBOSE_LEVEL
OVERWRITE
USAGE_HELP
LIST_FUNCTIONS_AND_EXIT
APPEND_LOG
LOG_STDOUT
NO_BACKUPS
__USER_RESPONSE_IS
DISABLE_TTY_CHECK

#Hostname_variables:
CUR_HOST
CUR_SHORT_HOST
CUR_OS
CUR_OS_VERSION

#Scriptname_and_directory:
SCRIPTNAME
SCRIPTDIR
REAL_SCRIPTDIR
REAL_SCRIPTNAME

#Current_environment:
CUR_SHELL
EDITOR
PAGER
WORKING_DIR
LOGFILE
LOGFILE_FOUND
LOG_MESSAGE_CACHE
ROTATE_LOG
RUNNING_IN_TERMINAL_SESSION
__KSH_VERSION
USE_ONLY_KSH88_FEATURES
TYPESET_F_SUPPORTED
TRACE_FEATURE_SUPPORTED
AWK
ID
__PPID
NOHUP_STDOUT_STDERR_FILE
__SHELL
RUNNING_IN_A_CONSOLE_SESSION
SYSTEMD_IS_USED
STDERR_DEVICE
STDERR_IS_TTY
STDIN_DEVICE
STDIN_IS_A_PIPE
STDIN_IS_TTY
STDOUT_DEVICE
STDOUT_IS_A_PIPE
STDOUT_IS_TTY


#Hardware_related_variables
#
RUNNING_ON_A_VIRTUAL_MACHINE
HPYERVISOR_VENDOR
SYSTEM_PRODUCT_NAME
SYSTEM_PRODUCT_VENDOR

#Variables_for_the_function_AskUser:
USER_INPUT
LAST_USER_INPUT
__NOECHO
__USE_TTY
__STTY_SETTINGS
__DEBUG_SHELL_IN_ASKUSER
__USER_RESPONSE_IS

#User_and_group:
CUR_USER_ID
CUR_USER_NAME
CUR_GROUP_ID
CUR_GROUP_NAME

#RCM_variables:
RCM_SERVICE
RCM_FUNCTION
RCM_HOSTID
RCM_HOSTID_FILE
RCM_DBQUERY
RCM_DBGET_FILE
RCM_USERID
RCM_PASSWORD

#Housekeeping:
CLEANUP_FUNCTIONS
FILES_TO_REMOVE
DIRS_TO_REMOVE
PROCS_TO_KILL
KILL_PROC_TIMEOUT
FINISH_FUNCTIONS
MOUNTS_TO_UMOUNT
NO_CLEANUP
NO_EXIT_ROUTINES
NO_TEMPFILES_DELETE
NO_TEMPDIR_DELETE
NO_FINISH_ROUTINES
NO_KILL_PROCS
NO_UMOUNT_MOUNTPOINTS

#Debugging
__DEBUG_CODE
__USER_DEBUG_CODE
__FUNCTION_INIT
DEFAULT_DRYRUN_PREFIX
PREFIX
ENABLE_DEBUG
__TEE_OUTPUT_FILE
__LIST_OF_SAVED_FUNCTIONS
FUNCTIONS_TO_TRACE
__FUNCTIONS_WITH_DEBUG_CODE
__FUNCTIONS_IN_VERBOSE_MODE
"



# ----------------------------------------------------------------------

### start of comments and variables for RCM environments
###
### ignore the comments and variables in this section if not using RCM
#
# Variables set by make_appls.pl from the RCM methods:
# 
# export RCM_SERVICE=Oracle
# export RCM_FUNCTION=clt_sw.11.2.0.4
# epxort RCM_IVERSION=11.2.0.4
# export RCM_ISERVER=dbkpinst1.rze.de.db.com
# export RCM_IPATH=/usr/sys/inst.images/Linux/Oracle/rdbms11g
#

# values for the function Read_APPL_PARAMS_entries and Retrieve_file_from_Jamaica
#
RCM_SERVICE="${RCM_SERVICE:=}"
RCM_FUNCTION="${RCM_FUNCTION:=}"

RCM_HOSTID_FILE="/var/db/var/hostid"
RCM_HOSTID="$( cat "${RCM_HOSTID_FILE}" 2>/dev/null )"

RCM_DBQUERY="/usr/db/RCM/Utility/dbquery"
RCM_DBGET_FILE="/usr/db/RCM/Utility/dbgetfile"

RCM_USERID="${RCM_USERID:=}"
RCM_PASSWORD="${RCM_PASSWORD:=}"

FOUND_APPL_PARAM_ENTRY_KEYS=""
typeset RCM_APPL_PARAMS_KEY
typeset RCM_APPL_PARAMS_VAL
RCM_APPL_PARAMS_KEY[0]=0

# default value for the parameter --no_appl_params / ++no_appl_params
#
READ_APPL_PARAMS=${__FALSE}

# default value for the parameter --no_appl_file / ++no_appl_file
#
READ_APPL_FILE=${__FALSE}

###  end of comments and variables for RCM environments

# ----------------------------------------------------------------------
# add variables for print_runtime_variables
#
# format:
#
#  #msg  - message to print (replacing "_" with " ")
#  else	 - variablename, print the name and value
#
APPLICATION_VARIABLES="
"

# ----------------------------------------------------------------------

[ -r /sys/class/dmi/id/product_name ] && SYSTEM_PRODUCT_NAME="$( < /sys/class/dmi/id/product_name )" || SYSTEM_PRODUCT_NAME=""
[ -r /sys/class/dmi/id/sys_vendor ] && SYSTEM_PRODUCT_VENDOR="$( < /sys/class/dmi/id/sys_vendor )" || SYSTEM_PRODUCT_VENDOR=""

if [[ ${SYSTEM_PRODUCT_NAME} == VMware* || ${SYSTEM_PRODUCT_VENDOR} == VMware* ]] ; then

    HPYERVISOR_VENDOR="VMware"
    RUNNING_ON_A_VIRTUAL_MACHINE=${__TRUE}
    THIS_IS_A_VMWARE_MACHINE=${__TRUE}

elif [[ ${SYSTEM_PRODUCT_NAME} == VirtualBox* || ${SYSTEM_PRODUCT_VENDOR} == innotek* ]] ; then

    HPYERVISOR_VENDOR="VirtualBox"
    RUNNING_ON_A_VIRTUAL_MACHINE=${__TRUE}
    THIS_IS_A_VMWARE_MACHINE=${__FALSE}

elif [[ ${SYSTEM_PRODUCT_VENDOR} == QEMU* ]] ; then

    HPYERVISOR_VENDOR="qemu"
    RUNNING_ON_A_VIRTUAL_MACHINE=${__TRUE}
    THIS_IS_A_VMWARE_MACHINE=${__FALSE}

else
    HPYERVISOR_VENDOR=""
    RUNNING_ON_A_VIRTUAL_MACHINE=${__FALSE}
    THIS_IS_A_VMWARE_MACHINE=${__FALSE}
fi

# ----------------------------------------------------------------------
# internal functions
#

# ----------------------------------------------------------------------
# RotateLog
#
# create up to n backups of one or more files
#
# usage: RotateLog [file1 [... [file#]]]
#
# returns: ${__TRUE} - a new backup was created
#
# The number of log files to keep are read from the variable 
# CUR_NO_OF_LOGFILES_TO_KEEP
#
function RotateLog {
  typeset __FUNCTION="RotateLog"
  ${__DEBUG_CODE} 
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}
  typeset THIS_LOGFILES="${LOGFILE}"
  typeset THIS_LOGFILE=""
  typeset i=0
  typeset CUR_NO_OF_LOGFILES_TO_KEEP=10
  
  if ! isNumber ${NO_OF_LOGFILES_TO_KEEP} ; then
    LogError "The value of the variable \"NO_OF_LOGFILES_TO_KEEP\" is not numeric: \"${NO_OF_LOGFILES_TO_KEEP}\" - using the hardcoded value now (${CUR_NO_OF_LOGFILES_TO_KEEP}) "
  else
    CUR_NO_OF_LOGFILES_TO_KEEP=${NO_OF_LOGFILES_TO_KEEP}  
  fi
  
  [ $# -ne 0 ] && THIS_LOGFILES="$*"
  if [ "${THIS_LOGFILES}"x != ""x ] ; then
    i=${CUR_NO_OF_LOGFILES_TO_KEEP}

    for THIS_LOGFILE in "${THIS_LOGFILES}" ; do

      (( i = i - 1 ))
      while [ $i -ge 0 ] ; do
       (( i = i - 1 ))
    
        if [ -r "${THIS_LOGFILE}.${i}" ] ; then
          \mv -f "${THIS_LOGFILE}.${i}" "${THIS_LOGFILE}.$(( i + 1 ))" || THISRC=${__FALSE}
        fi
      done
      if [ -r "${THIS_LOGFILE}" ] ; then
        \mv -f "${THIS_LOGFILE}" "${THIS_LOGFILE}.0"  || THISRC=${__FALSE}
      fi
    done
  fi

  return ${THISRC}
}


# ----------------------------------------------------------------------
# general functions
#


# ----------------------------------------------------------------------
# LogMsg
#
# write a message to STDOUT and to the log file if the variable QUIET is not ${__TRUE}
#
# usage: LogMsg [msg1] [...] [msg#]
#
# returns: ${__TRUE} - the message was written
#
# notes:
#
# - the messages will be stored in the variable LOG_MESSAGE_CACHE until the log file name is fixed
# - LogMsg calls the function RotateLog if neccessary
#
function LogMsg {
  typeset __FUNCTION="LogMsg"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  
  [[ ${QUIET} = ${__TRUE} ]] && return ${__FALSE}

  typeset THISMSG=""
  typeset TEMPVAR="${LOGFILE}"

  if [ ${LOGFILE_FOUND}x = ${__TRUE}x -a "${LOGFILE}"x != ""x ] ; then 
    if [ ${ROTATE_LOG}x = ${__TRUE}x  ] ; then
      ROTATE_LOG=${__FALSE}
      RotateLog 
      if [ $? -ne 0 ] ; then
        LOGFILE=""
        LogError "Existing logfile(s) are:"
        LogMsg "-" "$( ls -l "${TEMPVAR}"* )"
        die 253 "Can not create backups of the log files"
      fi
    fi
    if [ ${APPEND_LOG}x = ${__FALSE}x ] ; then
      echo >"${LOGFILE}"
      APPEND_LOG=${__TRUE}
    fi
  fi
 
  if [ "$1"x = "-"x ] ; then
    shift
    THISMSG="$*"
  else
    THISMSG="[$( date +"%d.%m.%Y %H:%M" )] $*"
  fi
  
  echo "${THISMSG}"  

# make sure all messages go to the correct log file if the parameter -l is used
#
  if [ "${LOGFILE}"x != ""x ] ; then
    if [ ${LOGFILE_FOUND}x = ${__TRUE}x ] ; then
      if [ "${LOG_MESSAGE_CACHE}"x != ""x ] ; then
        echo "${LOG_MESSAGE_CACHE}" >>"${LOGFILE}"
        LOG_MESSAGE_CACHE=""
      fi  
      [ "${LOGFILE}"x != ""x ] && echo "${THISMSG}" >>"${LOGFILE}"
    else
      LOG_MESSAGE_CACHE="${LOG_MESSAGE_CACHE}
${THISMSG}"
    fi
  fi
}

# ----------------------------------------------------------------------
# LogOnly
#
# write a message only to the log file if the variable QUIET is not ${__TRUE}
#
# usage: LogOnly [msg1] [...] [msg#]
#
# returns: ${__TRUE} - the message was written
#
# note: the message is written using the function LogMsg
#
function LogOnly {
  typeset __FUNCTION="LogOnly"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
	
  LogMsg "$*" >/dev/null  

  return $?
}

# ----------------------------------------------------------------------
# LogInfo
#
# write an INFO: message to STDERR and the logfile if the variable VERBOSE is ${__TRUE}
# and if the variable QUIET is not ${__TRUE}
#
# usage: LogInfo [msg1] [...] [msg#]
#
# returns: ${__TRUE} - the message was written
#
# note: the message is written using the function LogMsg
#
function LogInfo {
  typeset __FUNCTION="LogInfo"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__FALSE}
  
  if [ ${VERBOSE} = ${__TRUE} ] ; then
    if [ "$1"x = "-"x ] ; then	
      shift
      LogMsg "-" "INFO: $*" >&2
      THISRC=$?
    else
      LogMsg "INFO: $*" >&2
      THISRC=$?
    fi
  fi

  return ${THISRC}
}

# ----------------------------------------------------------------------
# LogMoreInfo
#
# write an INFO: message to STDERR and the logfile if the variable VERBOSE is ${__TRUE}
# and if the variable QUIET is not ${__TRUE}
#
# usage: LogMoreInfo {loglevel} [msg1] [...] [msg#]
#
# returns: ${__TRUE} - the message was written
#
# default for "loglevel" is "1" (-> print the message if the parameter -v is used at least two times)
#
# note: the message is written using the function LogMsg
#
function LogMoreInfo {
  typeset __FUNCTION="LogMoreInfo"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset CUR_LEVEL=""
  
  if [[ $1 == [0-9]* ]] ; then
    CUR_LEVEL="$1"
    shift
  else
    CUR_LEVEL="1"
  fi
    
  [ ${VERBOSE_LEVEL} -gt ${CUR_LEVEL} ] && LogMsg "INFO: $*" >&2

  return $?
}


# ----------------------------------------------------------------------
# LogRuntimeInfo
#
# internal sub routine for info messages from the runtime system
#
# returns: ${__TRUE} - message printed
#          ${__FALSE} - message not printed
#
function LogRuntimeInfo {
  typeset __FUNCTION="LogRuntimeInfo"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__FALSE}

  if [ ${VERBOSE_LEVEL} -gt 1 ] ; then
    LogInfo "$*"
    THISRC=$?
  fi

  return ${THISRC}
}

# ----------------------------------------------------------------------
# LogError
#
# write an ERROR: message to STDERR and the logfile if the variable QUIET is not ${__TRUE}
#
# usage: LogError [msg1] [...] [msg#]
#
# returns: ${__TRUE} - the message was written
#
# note: the message is written using the function LogMsg
#
function LogError {
  typeset __FUNCTION="LogError"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}

  if [ "$1"x = "-"x ] ; then	
    shift
    LogMsg "-" "ERROR: $*" >&2
    THISRC=$?
  else
    LogMsg "ERROR: $*" >&2
    THISRC=$?
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# LogWarning
#
# write an WARNING: message to STDOUT and the logfile if the variable QUIET is not ${__TRUE}
#
# usage: LogWarning [msg1] [...] [msg#]
#
# returns: ${__TRUE} - the message was written
#
# note: the message is written using the function LogMsg
#
function LogWarning  {
  typeset __FUNCTION="LogWarning"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}

  if [ "$1"x = "-"x ] ; then	
    shift
    LogMsg "-" "WARNING: $*" >&2
    THISRC=$?
  else
    LogMsg "WARNING: $*" >&2
    THISRC=$?
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# __activate_logfile
#
# activate the logfile 
# set the semaphor for LogMsg to flush all messages to the logfile
#
# usage: __activate_logfile
#
# returns: ${__TRUE} - logfile activated
#          ${__FALSE} - error creating the log file
#
function __activate_logfile  {
  typeset __FUNCTION="__activate_logfile"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}
  typeset OLOGFILE=""
  typeset TEMPVAR=""

#
# check for "-l :n"
#
  [[ ${LOGFILE} == :* ]] && LOGFILE="${DEFAULT_LOGFILE}${LOGFILE}" && LogInfo "The expanded value for the parameter \"-l\" is  \"${LOGFILE}\""
  [[ ${LOGFILE} == default:* ]] && LOGFILE="${DEFAULT_LOGFILE}:${LOGFILE##*:}" && LogInfo "The expanded value for the parameter \"-l\" is  \"${LOGFILE}\""
  
  if [ "${LOGFILE}"x != ""x  ] ; then
#
# check for "-l filename:n"
#    
    TEMPVAR="${LOGFILE##*:}"
    LOGFILE="${LOGFILE%:*}"
    if [ "${LOGFILE}"x != "${TEMPVAR}"x ] ; then
      if isNumber ${TEMPVAR} ; then
        LogInfo "The number of log files to keep found in the parameter is ${TEMPVAR}"
        LogInfo "The logfile found in the  parameter is \"${LOGFILE}\" "
        NO_OF_LOGFILES_TO_KEEP=${TEMPVAR}
      else
        LogError "The value for the number of logfiles to keep in the parameter \"${TEMPVAR}\" is not a number"
      fi
    fi
    
    LogMsg "### The logfile used is ${LOGFILE}"

    if [ ${LOGFILE_PARAMETER_FOUND} = ${__TRUE} ] ; then
      LOGDIR="$( cd $( dirname "${LOGFILE}" ) ; pwd )"
      LOGFILE="${LOGDIR}/$( basename "${LOGFILE}" )"
    fi

    LOGFILE_FOUND=${__TRUE}
  
    OLOGFILE="${LOGFILE}"
    touch "${LOGFILE}" 2>/dev/null >/dev/null 
    if [ $? -ne 0 ] ; then
      OLOGFILE="${LOGFILE}"
      LOGFILE="${LOGFILE}.$$"
      LogError "Can not write to the file ${OLOGFILE} - now using the log file ${LOGFILE}"
      THISRC=${__FALSE}
    else
      [ ! -s "${LOGFILE}" ] && \rm "${LOGFILE}"
    fi
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# curtimestamp
#
# write the current date and time to STDOUT in a format that can be 
# used for filenames
#
# usage: curtimestamp
#
# returns: nothing
#
function curtimestamp {
  typeset __FUNCTION="curtimestamp"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
	
  date "+%Y.%m.%d.%H_%M_%S_%s" 

  return $?
}
  
# ----------------------------------------------------------------------
# executeCommandAndLog
#
# execute a command and write STDERR and STDOUT also to the logfile
#
# usage: executeCommandAndLog command parameter
#
# returns: the RC of the executed command (even if a logfile is used!)
#
function executeCommandAndLog {
  typeset __FUNCTION="executeCommandAndLog"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
	
  set +e
  typeset THISRC=0

  if [ ${PRINT_COMMAND_TO_EXECUTE}x  = ${__TRUE}x ] ;  then
    LogMsg "### Executing \"$@\" "
  else
    LogInfo "### Executing \"$@\" " || LogOnly "### Executing \"$@\" "
  fi
  
  if [ "${LOGFILE}"x != ""x -a -f "${LOGFILE}" ] ; then
    # The following trick is from
    # http://www.unix.com/unix-dummies-questions-answers/13018-exit-status-command-pipe-line.html#post47559
    exec 5>&1
    tee -a "${LOGFILE}" >&5 |&
    exec >&p
    eval "$*" 2>&1
    THISRC=$?
    exec >&- >&5
    wait

    LogInfo "### The RC is ${THISRC}" || LogOnly  "### The RC is ${THISRC}"

  else
    eval "$@"
    THISRC=$?
  fi

  return ${THISRC}
}


#### --------------------------------------
#### KillProcess
####
#### Kill one or more processes
####
#### usage: KillProcess pid [...pid]
####
#### returns: ${__TRUE} -- all processes killed
####          ${__FALSE} -- at least one process not killed
#### 
#### notes:
####  The format for pid is "pid[:timeout_in_seconds]"
####
####  timeout_in_seconds is the time to wait after kill before a "kill -9"
####  is issued if the process is still running; use "pid:-1" to disable
####  the "kill -9" for a process
####  Default timeout for all PIDs is KILL_PROC_TIMEOUT
####
function KillProcess {
  typeset __FUNCTION="KillProcess"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  
  typeset THISRC=${__TRUE}
  
  typeset CUR_PID=""
  typeset CUR_KILL_PROC_TIMEOUT=""
  typeset PROCS_TO_KILL="$*"
  
  for CUR_PID in ${PROCS_TO_KILL} ; do

    if [[ ${CUR_PID} == *:* ]] ; then
      CUR_KILL_PROC_TIMEOUT="${CUR_PID#*:}"
      CUR_PID="${CUR_PID%:*}"
    else
      CUR_KILL_PROC_TIMEOUT="${KILL_PROC_TIMEOUT}"
    fi
  
    LogRuntimeInfo "Killing the process ${CUR_PID} (Timeout is ${CUR_KILL_PROC_TIMEOUT} seconds) ..."
    ps -p ${CUR_PID} >/dev/null
    if [ $? -eq 0 ] ; then
      LogRuntimeInfo "$( ps -fp ${CUR_PID} ) "
      kill ${CUR_PID}
      if [  ${CUR_KILL_PROC_TIMEOUT} != -1 ] ; then
        if [  ${CUR_KILL_PROC_TIMEOUT} != 0 ] ; then
          LogRuntimeInfo "Waiting up to ${CUR_KILL_PROC_TIMEOUT} second(s) ..."
          i=0
          while [ $i -lt ${CUR_KILL_PROC_TIMEOUT} ] ; do
            sleep 1
            ps -p ${CUR_PID} 2>/dev/null >/dev/null || break
            (( i = i + 1 ))
          done
        fi
        
        ps -p ${CUR_PID} 2>/dev/null >/dev/null
        if [ $? -eq 0 ] ; then
          LogRuntimeInfo "Process ${CUR_PID} is still alive after kill - now using \"kill -9\" ..."
          kill -9 ${CUR_PID}
          ps -p ${CUR_PID} 2>/dev/null >/dev/null
          if [ $? -eq 0 ] ; then
            LogError "The process ${CUR_PID} is still alive after \"kill -9\" "
            THISRC=${__FALSE}
          else
            LogRuntimeInfo "Process ${CUR_PID} killed with \"kill -9\" "                  
          fi
        else
          LogRuntimeInfo "Process ${CUR_PID} killed"
        fi
      else
#
# kill -9 is disabled for this PID
#
        ps -p ${CUR_PID} 2>/dev/null >/dev/null
        if [ $? -eq 0 ] ; then
          LogRuntimeInfo "Process \"${CUR_PID}\" is still alive after kill (\"kill -9\" is disabled)."
          THISRC=${__FALSE}       
        else
          LogRuntimeInfo "Process \"${CUR_PID}\" killed"
        fi
      fi
    else
      LogRuntimeInfo "Process ${CUR_PID} is not runninng"
    fi
  done

  return ${THISRC}
}

# ---------------------------------------
# BackupFile
#
# create a backup of a file if it exists
#
# usage: BackupFile sourcefile [backupfile] [backupfile_extension]
#
# returns:  ${__TRUE} - backup created or original file does not exist
#           ${__FALSE} - error creating the backup
#
# Note: No backup will be created if the varaible ${NO_BACKUPS} is ${__TRUE}
#
function BackupFile {
  typeset __FUNCTION="BackupFile"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  	
  typeset THISRC=${__TRUE}

  typeset CUR_TIME="$( date +%Y.%m.%d-%H:%M:%S.%s )"
  typeset BACKUP_FILE=""
  typeset BACKUP_EXT=""
  typeset CUR_OUTPUT=""
  
  if [ ${NO_BACKUPS} -eq ${__TRUE} ] ; then
    LogInfo "Backups are disabled via parameter \"--no-backup\" -- will not create a backup of the file \"$1\" "
  else
    if [ $# -eq 3 ] ; then
      BACKUP_EXT="$3"
      shift
    else
      BACKUP_EXT="$$.${CUR_TIME}"
    fi

    if [ $# -eq 2 ] ; then
      BACKUP_FILE="$2"
    else
      BACKUP_FILE="$1"
    fi
    
    if [ -f "$1" ] ; then
      LogMsg "Creating a backup of the file \"$1\" in \"${BACKUP_FILE}.${BACKUP_EXT}\" ..."
      CUR_OUTPUT="$( \cp -p "$1" "${BACKUP_FILE}.${BACKUP_EXT}" 2>&1 )" 
      if [ $? -ne 0 ] ; then 
        LogMsg "-" "${CUR_OUTPUT}"
        THISRC=${__FALSE}
      fi      
    fi
  fi
  return ${THISRC}
}
  

# ----------------------------------------------------------------------
# __evaluate_fn
#
# Evaluate the parameter fn of the various DebugShell aliase
#
# Usage: executed by DebugShell - do not call this function in your code!
#
# returns: write the evaluated string to STDOUT
#
function __evaluate_fn {

  typeset CUR_FN=""
  typeset THIS_FN=""
  typeset NEW_FN=""
  typeset REAL_FN=""
 
## for debugging only
#
#  "printf" "The parameter are: \"$*\" \n" >&2

  
  typeset DEFINED_FUNCTIONS=" $("typeset" +f ) "
  set -f
  
  for CUR_FN in $* ; do
    case ${CUR_FN} in 
      *\** | *\?* )
       for THIS_FN in ${DEFINED_FUNCTIONS} ; do
         [[ " ${THIS_FN} " == *\ ${CUR_FN}\ * ]] && NEW_FN="${NEW_FN} ${THIS_FN} "
       done
       ;;
      
      all )
        NEW_FN="${NEW_FN} ${DEFINED_FUNCTIONS} "
        ;;
        
      * )
        NEW_FN="${NEW_FN} ${CUR_FN} "
        ;;
    esac
  done

  for CUR_FN in  ${NEW_FN} ; do
    [[ ${REAL_FN} == *\ ${CUR_FN}\ * ]] && continue
    REAL_FN="${REAL_FN} ${CUR_FN}"
  done
  
  echo "${REAL_FN}"
}
  
# ----------------------------------------------------------------------
# __DebugShell
#
# Open a simple debug shell
#
# Usage: executed by DebugShell - do not call this function in your code!
#
# returns: ${__TRUE}
#
# Input is always read from /dev/tty; output always goes to /dev/tty
# so DebugShell is only allowed if STDIN is a tty.
#
function __DebugShell {
  typeset __FUNCTION="__DebugShell"

  [ ${ENABLE_DEBUG}x != ${__TRUE}x ] && return 0
  
  [ ${INSIDE_DEBUG_SHELL}x = ${__TRUE}x ] && return 0
  INSIDE_DEBUG_SHELL=${__TRUE}

  if [ ${RUNNING_IN_TERMINAL_SESSION} != ${__TRUE} ] ; then
    LogError "DebugShell can only be used in interactive sessions"
    INSIDE_DEBUG_SHELL=${__FALSE}
    return ${__FALSE}
  fi

  DEBUG_SHELL_CALLED=${__TRUE}

  __settraps
  
  "typeset" THISRC=${__TRUE}
  "typeset" CMD_PARAMETER=""
  "typeset" FUNCTION_LIST=""
  "typeset" CUR_STATEMENT=""
  "typeset" CUR_VALUE=""
  "typeset" ADD_CODE=""

  "typeset" FUNC_SAVE_VAR=""
  "typeset" FUNC_SAVE_CONTENT=""
  
  "typeset" USER_INPUT=""
  "typeset" USER_INPUT1=""
  "typeset" CUR_CMD=""
  "typeset" CUR_FUNCTION_CODE=""
  "typeset" HASHCODE1=""
  "typeset" HASHCODE2=""
  
  "typeset" __TMP__STTY_SETTINGS="$( stty -g )"
            
  "typeset" TMP_FILE1="/tmp/${SCRIPTNAME}.DebugShell.$$.1.tmp"
  "typeset" TMP_FILE2="/tmp/${SCRIPTNAME}.DebugShell.$$.2.tmp"
  FILES_TO_REMOVE="${FILES_TO_REMOVE} ${TMP_FILE1} ${TMP_FILE2}"
 
  [ -r "${TMP_FILE1}" ] && \rm "${TMP_FILE1}"
  [ -r "${TMP_FILE2}" ] && \rm "${TMP_FILE2}"
#  ${USER_INPUT%% *}
  
  stty echo
  while "true" ; do
    "printf" "\n ------------------------------------------------------------------------------- \n"
    "printf" "${SCRIPTNAME} - debug shell - enter a command to execute (\"exit\" to leave the shell)\n"
    "printf" "Current environment: ksh version: ${__KSH_VERSION} | change function code supported: ${TYPESET_F_SUPPORTED} | tracing feature using \$0 supported: ${TRACE_FEATURE_SUPPORTED}\n"
    "printf" ">> "
    set -f
    "read" USER_INPUT
    set +f

    CMD_PARAMETER="${USER_INPUT#* }"
    [ "${CMD_PARAMETER}"x = "${USER_INPUT}"x ] && CMD_PARAMETER=""
    CUR_CMD="${USER_INPUT%% *}"

    case "${USER_INPUT}" in
    
      "help" )
         "printf" "
vars                      - print the runtime variable values

functions | funcs         - list all defined functions 
functions fn | funcs fn   - list functions matching the regex fn

func fn                   - view the source code for the function fn (supported by this shell: ${TYPESET_F_SUPPORTED})
savedfuncs                - list the saved functions (supported by this shell: ${TYPESET_F_SUPPORTED})
editfunc fn               - edit the source code for the function fn (supported by this shell: ${TYPESET_F_SUPPORTED})
savefunc fn               - save the source code of the function fn (supported by this shell: ${TYPESET_F_SUPPORTED})
viewsavedfunc fn          - view the source code of the saved function fn (supported by this shell: ${TYPESET_F_SUPPORTED})
restorefunc fn            - restore the source code of the function fn (supported by this shell: ${TYPESET_F_SUPPORTED})
clearsavedfunc fn         - delete the saved source code of the function fn (supported by this shell: ${TYPESET_F_SUPPORTED})

verbose                   - toggle the verbose switch (Current value: ${VERBOSE})

view_debug                - view the current trace settings 
clear_debug               - clear the tracing for all functions
set_debug fn              - enable tracing for the functions fn; use \"+fn\" to preserve existing settings
add_debug_code fn         - enable debug code for the functions fn (supported by this shell: ${TYPESET_F_SUPPORTED})

exit                      - exit the debug shell
quit                      - end the script using die
abort                     - abort the script using kill -9

!<code>                   - execute the instructions \"<code>\"
<code>                    - execute the instructions using \"eval <code>\"

Notes:

\"fn\" can be one or more function names or regex; use \"functions fn\" to test the value of \"fn\"

"        ;;

      "exit" )
        "break";
        ;;

      "quit" )
        INSIDE_DEBUG_SHELL=${__FALSE}
        die 254 "${SCRIPTNAME} aborted by the user"
        ;;

      "abort" )
        LogMsg "${SCRIPTNAME} aborted with \"kill -9\" by the user"
        INSIDE_DEBUG_SHELL=${__FALSE}
        "kill" -9 $$
        ;;

      "verbose" )
        [ ${VERBOSE} = ${__TRUE} ] && VERBOSE=${__FALSE} || VERBOSE=${__TRUE}
        "printf" "The verbose switch is now ${__TRUE_FALSE[${VERBOSE}]} \n"
        ;;

      "vars" | "variables" )
        print_runtime_variables 
        ;;

      "savedfuncs" )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi
         if [ "${__LIST_OF_SAVED_FUNCTIONS}"x = ""x ] ; then
            "printf" "There are no saved functions\n"
         else
            "printf"  "Saved functions are: \n${__LIST_OF_SAVED_FUNCTIONS} \n"
         fi
         continue
         ;;
      
      "savefunc "* | "saveFunc "* )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi
         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"

         for CUR_VALUE in ${FUNCTION_LIST} ; do
         
           CUR_FUNCTION_CODE="$( "typeset" -f "${CUR_VALUE}" 2>/dev/null )"
           if [ $? -ne 0 ] ; then
             "printf" "The function ${CUR_VALUE} is not defined\n"
             continue
           fi
           
           FUNC_SAVE_VAR="__FUNCTION_${CUR_VALUE}"
           eval FUNC_SAVE_CONTENT="\$${FUNC_SAVE_VAR}"
           if [ "${FUNC_SAVE_CONTENT}"x != ""x ] ; then
             "printf" "The function ${CUR_VALUE} is already saved\n"
             continue
           fi

           "printf" "Saving the current code for the function ${CUR_VALUE} ...\n"
           eval ${FUNC_SAVE_VAR}="\${CUR_FUNCTION_CODE}"
           __LIST_OF_SAVED_FUNCTIONS="${__LIST_OF_SAVED_FUNCTIONS} ${CUR_VALUE} "
         done      
         ;;

      "restorefunc "* | "restfunc "* | "restFunc "* )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi

         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
         
         for CUR_VALUE in ${FUNCTION_LIST} ; do
           FUNC_SAVE_VAR="__FUNCTION_${CUR_VALUE}"
           eval FUNC_SAVE_CONTENT="\$${FUNC_SAVE_VAR}"
           if [ "${FUNC_SAVE_CONTENT}"x = ""x ] ; then
             "printf" "There is no saved code for the function ${CUR_VALUE}\n"
             continue
             continue
           fi

           "printf" "Restoring the code for the function ${CUR_VALUE} ...\n"

           "echo" "${FUNC_SAVE_CONTENT}" >"${TMP_FILE1}"
            eval . "${TMP_FILE1}"
         done
         ;;

      "viewsavedfunc "* | "viewsavedFunc "*)
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi

         if [ "${PAGER}"x = ""x ] ; then
           "printf" "No valid editor found (set the variable PAGER before calling this script)\n"
           continue
         fi

         if [ ! -x "${PAGER}" ] ; then
           "printf" "${PAGER} not found or not executable (check the variable PAGER)\n"
           continue
         fi

         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
         
         for CUR_VALUE in ${FUNCTION_LIST} ; do
           FUNC_SAVE_VAR="__FUNCTION_${CUR_VALUE}"
           eval FUNC_SAVE_CONTENT="\$${FUNC_SAVE_VAR}"
           if [ "${FUNC_SAVE_CONTENT}"x = ""x ] ; then
             "printf" "There is no saved code for the function ${CUR_VALUE}\n"
             continue
           fi

           "printf" "Viewing the code for the saved function ${CUR_VALUE} ...\n"

           "echo" "${FUNC_SAVE_CONTENT}" >"${TMP_FILE1}"
           ${PAGER} "${TMP_FILE1}"
         done
         ;;

      "clearsavedfunc "* | "clearsavedFunc "* )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi

         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
         
         for CUR_VALUE in ${FUNCTION_LIST} ; do
           FUNC_SAVE_VAR="__FUNCTION_${CUR_VALUE}"
           eval FUNC_SAVE_CONTENT="\$${FUNC_SAVE_VAR}"
           if [ "${FUNC_SAVE_CONTENT}"x = ""x ] ; then
             "printf" "There is no saved code for the function ${CUR_VALUE}\n"
             continue
           fi
           "printf" "Deleting the saved code for the function ${CUR_VALUE} ...\n"
           __LIST_OF_SAVED_FUNCTIONS=" ${__LIST_OF_SAVED_FUNCTIONS% ${CUR_VALUE} *} ${__LIST_OF_SAVED_FUNCTIONS#* ${CUR_VALUE} }"
           unset FUNC_SAVE_VAR

         done           
         ;;


      "editfunc "* | "editFunc "* )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi

         if [ "${EDITOR}"x = ""x ] ; then
           "printf" "No valid editor found (set the variable EDITOR before calling this script)\n"
           continue
         fi

         if [ ! -x "${EDITOR}" ] ; then
           "printf" "${EDITOR} not found or not executable (check the variable EDITOR)\n"
           continue
         fi

         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
         
         for CUR_VALUE in ${FUNCTION_LIST} ; do
           USER_INPUT1=""
           
           FUNC_SAVE_VAR="__TMP_FUNCTION_${CUR_VALUE}"
           eval CUR_FUNCTION_CODE="\$${FUNC_SAVE_VAR}"
           [ "${CUR_FUNCTION_CODE}"x = ""x ] && CUR_FUNCTION_CODE="$( "typeset" -f "${CUR_VALUE}" 2>/dev/null )"

           if [ "${CUR_FUNCTION_CODE}"x = ""x ] ; then
             "printf" "The function \"${CUR_VALUE}\" is not defined\n"
             "printf" "Create a new function \"${CUR_VALUE}\" (y/N)? " 
             "read" USER_INPUT1
             if [ "${USER_INPUT1}"x = "y"x ] ; then
               CUR_FUNCTION_CODE="$( typeset -f function_template | sed "s/function_template/${CUR_VALUE}/g" )"
             else
               "printf" "New function \"${CUR_VALUE}\" not created.\n"
               "continue"
             fi
             
           else
             CUR_FUNCTION_CODE="# delete the existing function defintion 
unset -f ${CUR_VALUE}

${CUR_FUNCTION_CODE}
"
           fi
           "echo" "${CUR_FUNCTION_CODE}" >"${TMP_FILE1}"

           HASHCODE1="$( cksum "${TMP_FILE1}" 2>/dev/null | cut -f1 -d " "  )"
           [ "${HASHCODE1}"x = ""x ] && HASHCODE1="$( <"${TMP_FILE1}" )"

           while true ; do
             ${EDITOR} "${TMP_FILE1}"

             HASHCODE2="$( cksum "${TMP_FILE1}" 2>/dev/null | cut -f1 -d " "  )"
             [ "${HASHCODE2}"x = ""x ] && HASHCODE2="$( <"${TMP_FILE1}" )"

             if [ "${HASHCODE1}"x = "${HASHCODE2}"x -a "${USER_INPUT1}"x = ""x  ] ; then
               "printf" "No changes found in the edited source code.\n"
               break
             else               
               "printf" "Checking the new source code for \"${CUR_VALUE}\" using the shell ${CUR_SHELL} now ...\n"
               ${CUR_SHELL} -x -n "${TMP_FILE1}"
               if [ $? -ne 0 ] ; then
                 "printf" "Syntax Errors found in the new source code for \"${CUR_VALUE}\" - edit again (Y/n)? "
                 "read" USER_INPUT1
                 [ "${USER_INPUT1}"x != "n"x ] && continue
                  "printf" "New source code for \"${CUR_VALUE}\" ignored\n"
                 break
               fi                 
               "printf" "Enabling the new source code for \"${CUR_VALUE}\" now ...\n"
               . "${TMP_FILE1}"

               eval  ${FUNC_SAVE_VAR}="\$( typeset -f  ${CUR_VALUE} )"
               break
             fi
           done
         done
         ;;

      "func "* | "viewfunc "* | "viewFunc "* )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi
         
         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
         
         for CUR_VALUE in ${FUNCTION_LIST} ; do

           FUNC_SAVE_VAR="__TMP_FUNCTION_${CUR_VALUE}"
           eval CUR_FUNCTION_CODE="\$${FUNC_SAVE_VAR}"
           [ "${CUR_FUNCTION_CODE}"x = ""x ] && CUR_FUNCTION_CODE="$( "typeset" -f "${CUR_VALUE}" 2>/dev/null )"

           "typeset" +f "${CUR_VALUE}" 2>/dev/null 1>/dev/null
           if [ $? -ne 0 ] ; then
             "printf" "The function ${CUR_VALUE} is not defined\n\n"
             "continue"
           else
             "printf" "${CUR_FUNCTION_CODE}\n"      
           fi
         done
         ;;

      "functions" | "func" | "funcs" )
        "typeset" +f | grep -v "^__"

        ;;

      "functions "* | "func "* | "funcs "* )
        "printf" "$( __evaluate_fn "${CMD_PARAMETER}" )\n"
        ;;
         
      "add_debug_code"* )
         if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
           "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
           continue
         fi
         
         FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
         
         for CUR_VALUE in ${FUNCTION_LIST} ; do
           "typeset" +f "${CUR_VALUE}" 2>/dev/null 1>/dev/null
           if [ $? -ne 0 ] ; then
             "printf" "The function ${CUR_VALUE} is not defined\n"
             "continue"
           fi

           if [[ $( "typeset" -f "${CUR_VALUE}" 2>&1 ) == *\$\{__DEBUG_CODE\}* ]] ; then
             "printf" "The function ${CUR_VALUE} is already debug enabled\n"
             "continue"
           fi
           "printf" "Adding debug code to the function ${CUR_VALUE} ...\n"   
            if [ ${USE_ONLY_KSH88_FEATURES} = 0 ] ; then
              ADD_CODE=" typeset __FUNCTION=${CUR_VALUE}; "
            else
              ADD_CODE="  "
            fi
            eval "$( typeset -f  "${CUR_VALUE}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	                    
          done
          ;;

      view_debug | viewdebug )
        if [ "${TRACE_FEATURE_SUPPORTED}"x != "yes"x ] ; then
          "printf" "Warning: The tracing features using \$0 are not supported by this shell\n"
        fi
        
        if [ "${__FUNCTIONS_WITH_DEBUG_CODE}"x != ""x ] ; then
          "printf" "Debug code is currently enabled for these functions: \n${__FUNCTIONS_WITH_DEBUG_CODE}\n"
          [ ${VERBOSE} = ${__TRUE} ] && "printf" "The current debug code for all functions (\$__DEBUG_CODE) is:\n${__DEBUG_CODE}\n" 
        else
          "printf" "Debug code is currently enabled for no function\n"
        fi        
        ;;

      clear_debug | cleardebug )
        if [ "${TRACE_FEATURE_SUPPORTED}"x != "yes"x ] ; then
          "printf" "Warning: The tracing features using \$0 are not supported by this shell\n"
        fi
        "printf" "Clearing the debug code now ...\n"
        __DEBUG_CODE="${__USER_DEBUG_CODE} ${__CODE_TO_ENABLE_VERBOSE_MODE}"
        __FUNCTIONS_WITH_DEBUG_CODE=""
        ;;
          
      "debug "* | "set_debug "* | "setdebug "* )
        if [ "${TRACE_FEATURE_SUPPORTED}"x != "yes"x ] ; then
          "printf" "Warning: The tracing features using \$0 are not supported by this shell\n"
        fi

        if [ "${CMD_PARAMETER}"x != ""x ] ; then
          "printf" "Enabling debug code for the function(s) \"${CMD_PARAMETER}\" now\n"
          CUR_STATEMENT="[ 0 = 1 "

          if [ "${__KSH_VERSION}"x = "93"x -a ${USE_ONLY_KSH88_FEATURES} = ${__FALSE} ] ; then
            CUR_STATEMENT="__FUNCTION=\"\${.sh.fun}\" ; ${CUR_STATEMENT}"
          fi

          if [[ ${CMD_PARAMETER} == +* ]] ; then
# preserve existing settings          
            "printf" "Current settings for debug code (${__FUNCTIONS_WITH_DEBUG_CODE}) are preserved.\n"
            FUNCTION_LIST="${__FUNCTIONS_WITH_DEBUG_CODE} $( __evaluate_fn "${CMD_PARAMETER#*+}" )"
          else
# overwrite existing settings          
            "printf" "Current settings for debug code are overwritten.\n"
            FUNCTION_LIST="$( __evaluate_fn "${CMD_PARAMETER}" )"
          fi

          __FUNCTIONS_WITH_DEBUG_CODE=""
          for CUR_VALUE in ${FUNCTION_LIST} ; do
            [[ ${CUR_VALUE} == +* ]] && CUR_VALUE="${CUR_VALUE#*+}"
            
            if [[ ${__FUNCTIONS_WITH_DEBUG_CODE} == *\ ${CUR_VALUE}\ * ]] ; then
              "printf" "Debug code is already enabled for the function ${CUR_VALUE}\n"
              continue
            fi

            "printf" "Enabling debug code for the function \"${CUR_VALUE}\" ...\n"
            __FUNCTIONS_WITH_DEBUG_CODE="${__FUNCTIONS_WITH_DEBUG_CODE} ${CUR_VALUE} "
            CUR_STATEMENT="${CUR_STATEMENT} -o \"\$0\"x = \"${CUR_VALUE}\"x -o \"\${__FUNCTION}\"x = \"${CUR_VALUE}\"x "

            if ! "typeset" +f "${CUR_VALUE}" >/dev/null ; then
              "printf" "WARNING: The function \"${CUR_VALUE}\" is not defined\n"
               continue
            fi
 
            if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
              "printf" "\"typeset -f\" required for \"${CUR_CMD}\" is NOT supported by this shell\n"
               continue
            fi

            if [[ $( "typeset" -f "${CUR_VALUE}" 2>&1 ) != *\$\{__DEBUG_CODE\}* ]] ; then
              "printf" "Adding debug code to the function ${CUR_VALUE} ...\n"           
              ADD_CODE=" typeset __FUNCTION=${CUR_VALUE}; "
              eval "$( typeset -f  "${CUR_VALUE}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	                    
            fi
          done
          CUR_STATEMENT="eval ${CUR_STATEMENT} ] && printf \"\n*** Enabling trace for the function \${__FUNCTION:=\$0} ...\n\" >&2 && set -x "
          __DEBUG_CODE="${__USER_DEBUG_CODE} ${CUR_STATEMENT} ; ${__CODE_TO_ENABLE_VERBOSE_MODE}" 

        else
          "printf" " ${USER_INPUT}: Parameter missing\n"
        fi 
        ;;

      "" )
        :
        ;;

      * )
        if [ "${USER_INPUT}"x = "."x -o "${USER_INPUT}"x = "!."x ] ; then
            "printf" "\".\" without parameter is useless\n"
            continue          
        elif [ "${USER_INPUT}"x = "function"x ] ; then
          continue
        fi
        
        if [[ ${USER_INPUT} = .\ * || ${USER_INPUT} = !.\ * ]] ; then
          eval "CUR_FUNCTION_CODE=${CMD_PARAMETER}"
          if [ "${CUR_FUNCTION_CODE}"x != "${CMD_PARAMETER}"x ] ; then
            "printf" "File to source in is \"${CUR_FUNCTION_CODE}\" \n"
          fi
          
          if [ ! -r "${CUR_FUNCTION_CODE}" ] ; then
            "printf" "The file \"${CUR_FUNCTION_CODE}\" does not exist or is not readable\n"
            continue
          fi    
          "printf" "Checking the file \"${CUR_FUNCTION_CODE}\" for errors using the shell ${CUR_SHELL} ...\n"
          ${CUR_SHELL} -x -n "${CUR_FUNCTION_CODE}"
          if [ $? -ne 0 ] ; then
            "printf" "There is a syntax error in the file \"${CUR_FUNCTION_CODE}\" \n"
            continue
          fi
        fi

        if [[ ${USER_INPUT} = !* ]] ; then
          "printf" "Executing now \"${USER_INPUT#*!}\" ...\n"
          ${USER_INPUT#*!}
        else
          "printf" "Executing now \"eval ${USER_INPUT}\" ...\n"
          "eval" ${USER_INPUT}
        fi
        "printf" "\n---------\nRC is $?\n"    
        ;;
    esac
  done </dev/tty >/dev/tty 2>&1

  [ "${__TMP__STTY_SETTINGS}"x != ""x ] &&  stty ${__TMP__STTY_SETTINGS}

  INSIDE_DEBUG_SHELL=${__FALSE}

  "return" ${THISRC}
}

# ----------------------------------------------------------------------
# DebugShell
#
# this is a wrapper function for __DebugShell
#
# Usage: DebugShell
#
# returns: ${__TRUE}
#
# Input is always read from /dev/tty; output always goes to /dev/tty
# so DebugShell is only allowed if STDIN is a tty.
#
function DebugShell {
  typeset __FUNCTION="DebugShell"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  
  typeset THISRC=${__TRUE}

  while true ; do
    __DebugShell $*
    THISRC=$?
    [ ${INSIDE_DEBUG_SHELL}x = ${__FALSE}x ]  && break
    INSIDE_DEBUG_SHELL=${__FALSE}
  done
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# show_script_usage
#
# write the script usage to STDOUT
#
# usage: show_script_usage
#
# returns: ${__TRUE} - the message was written
#
# note: the function writes all lines from the script that start with
#       "#H#" without the "#H#"
#
function show_script_usage {
  typeset __FUNCTION="show_script_usage"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}
  typeset HELPMSG=""
  
  typeset REGEX=""
  
  if [ ${SHORT_HELP} = ${__TRUE} ]; then
    REGEX="^#h#"
  elif [ ${VERBOSE_LEVEL} -ge 1 ] ; then
#
# print also the verbose usage help if --v used
#
    REGEX="^#H#|^#h#|^#U#"
  else
    REGEX="^#H#|^#h#"
  fi
  
  HELPMSG="$( ${EGREP} "${REGEX}" "${REAL_SCRIPTNAME}" | cut -c4- | sed "s/scriptt_mini.sh/${SCRIPTNAME}/g" )"
   
  eval echo \""${HELPMSG}"\"

  if [ ${SHORT_HELP} = ${__TRUE} ]; then
    echo "
 Use the parameter \"--help\" to print the detailed help message; use the parameter \"--help -v\" to also print the list of supported environment variables"
  fi

  if [ "${USAGE_HELP}"x != ""x ] ; then
    echo "${USAGE_HELP}"
  fi

  if [ "${ENABLE_DEBUG}"x = "${__TRUE}x" ] ; then
    echo "
Current environment: ksh version: ${__KSH_VERSION} | change function code supported: ${TYPESET_F_SUPPORTED} | tracing feature using \$0 supported: ${TRACE_FEATURE_SUPPORTED}
"
  else
    echo "
Note: The parameter -D and --var are disabled
"
  fi
  
# execute the function show_extended_usage_help if defined and the parameter
# -v was found
#
  if [ ${VERBOSE} = ${__TRUE} ] ; then  
    if typeset -f show_extended_usage_help 2>/dev/null  >/dev/null ; then
      show_extended_usage_help
    fi
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# general exit routine
#      

# ----------------------------------------------------------------------
# cleanup
#
# Housekeeping tasks (in this order):
#
#   - execute the cleanup functions
#   - kill temporary processes 
#   - remove temporary files 
#   - umount mount points
#   - remove temporary directories
#   - execute the finish functions
#
# usage: cleanup
#
# returns: 0
#
function cleanup {
  typeset __FUNCTION="cleanup"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset CUR_DIR=""
  typeset CUR_FILE=""
  typeset CUR_PID=""
  typeset CUR_KILL_PROC_TIMEOUT=""
  typeset CUR_FUNC=""
  typeset CUR_DEV0=""
  typeset CUR_DEV1=""
  typeset CUR_MOUNT=""
  typeset CUR_MOUNT1=""
  typeset i=0
  typeset ROUTINE_PARAMETER=""
  
  cd /
  
  LogRuntimeInfo "Housekeeping process started ...." 
  if [ $? -ne 0 -a "${PREFIX}"x != ""x ] ; then
    LogMsg "-"
    LogMsg "*** Housekeeping is starting ..."
  fi
  
  if [ "${CLEANUP_FUNCTIONS}"x != ""x -a "${NO_EXIT_ROUTINES}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Executing the cleanup functions \"${CLEANUP_FUNCTIONS}\" ..."
  
    for CUR_FUNC in ${CLEANUP_FUNCTIONS} ; do

      ROUTINE_PARAMETER="${CUR_FUNC#*:}"
      CUR_FUNC="${CUR_FUNC%%:*}"
      [ "${CUR_FUNC}"x = "${ROUTINE_PARAMETER}"x ] && ROUTINE_PARAMETER="" || ROUTINE_PARAMETER="$( IFS=: ; printf "%s " ${ROUTINE_PARAMETER}  )"
    
      typeset +f "${CUR_FUNC}" 2>/dev/null >/dev/null${CUR_KILL_PROC_TIMEOUT}
      if [ $? -eq 0 ] ; then
        LogRuntimeInfo "Executing the cleanup function \"${CUR_FUNC}\" (Parameter are: \"${ROUTINE_PARAMETER}\") ..."
        INSIDE_CLEANUP_ROUTINE=${__TRUE}
        ${PREFIX} ${CUR_FUNC} ${ROUTINE_PARAMETER}
        INSIDE_CLEANUP_ROUTINE=${__FALSE}
      else
        LogRuntimeInfo "The cleanup function \"${CUR_FUNC}\" is not defined - ignoring this entry"
      fi
    done
  else
    LogRuntimeInfo "No cleanup functions defined or cleanup functions disabled"
  fi

  if [ "${PROCS_TO_KILL}"x != ""x -a "${NO_KILL_PROCS}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Stopping the processes to kill \"${PROCS_TO_KILL}\" ..."
    ${PREFIX} KillProcess ${PROCS_TO_KILL}
  else
    LogRuntimeInfo "No processes to kill defined or process killing disabled"
  fi
  
  if [ "${FILES_TO_REMOVE}"x != ""x -a "${NO_TEMPFILES_DELETE}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Removing the temporary files \"${FILES_TO_REMOVE}\" ..." 
    for CUR_FILE in ${FILES_TO_REMOVE} ; do
      if [ -f "${CUR_FILE}" ] ; then
        LogRuntimeInfo "Removing the file \"${CUR_FILE}\" ..."
        ${PREFIX} \rm -f "${CUR_FILE}"
      else
        LogRuntimeInfo "The file \"${CUR_FILE}\" does not exist."
      fi
    done
  else
    LogRuntimeInfo "No files to delete defined or files deleting disabled"
  fi

  if [ "${MOUNTS_TO_UMOUNT}"x != ""x -a "${NO_UMOUNT_MOUNTPOINTS}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Umounting the mount points to umount \"${MOUNTS_TO_UMOUNT}\" ..."
    for CUR_MOUNT in ${MOUNTS_TO_UMOUNT} ; do
      if [[ ${CUR_MOUNT} != /* ]] ; then
        LogRuntimeInfo "\"${CUR_MOUNT}\" is not a mount point"
        continue
      fi

      if [ ! -d "${CUR_MOUNT}" ] ; then
        LogRuntimeInfo "\"${CUR_MOUNT}\" does not exist"
        continue
      fi

      CUR_MOUNT1="${CUR_MOUNT%/*}" 
      [ "${CUR_MOUNT1}"x = ""x ] && CUR_MOUNT1="/"
      CUR_DEV0="$( df -h ${CUR_MOUNT}  2>/dev/null | tail -1 | awk '{ print $1 };' )"
      CUR_DEV1="$( df -h ${CUR_MOUNT1} 2>/dev/null | tail -1 | awk '{ print $1 };' )"
      if [ "${CUR_DEV1}"x != "${CUR_DEV0}"x ] ; then
        LogRuntimeInfo "Umounting \"${CUR_MOUNT}\" ..."
        ${PREFIX} umount "${CUR_MOUNT}"
      else
        LogRuntimeInfo "\"${CUR_MOUNT}\" is not mounted"
      fi
    done
  else
    LogRuntimeInfo "No mount points to umount configured"
  fi
  
  if [ "${DIRS_TO_REMOVE}"x != ""x -a "${NO_TEMPDIR_DELETE}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Removing the temporary directories \"${DIRS_TO_REMOVE}\" ..."
    for CUR_DIR in ${DIRS_TO_REMOVE} ; do
      if [ -d "${CUR_DIR}" ] ; then
        LogRuntimeInfo "Removing the directory \"${CUR_DIR}\" ..."
        ${PREFIX} \rm -rf "${CUR_DIR}"
      else
        LogRuntimeInfo "The directory \"${CUR_DIR}\" does not exist"
      fi
    done
  else
    LogRuntimeInfo "No directories to remove defined or directory removing disabled"
  fi


  if [ "${FINISH_FUNCTIONS}"x != ""x  -a "${NO_FINISH_ROUTINES}"x != "${__TRUE}"x ] ; then
    LogRuntimeInfo "Executing the finish functions \"${FINISH_FUNCTIONS}\" ..."
    for CUR_FUNC in ${FINISH_FUNCTIONS} ; do

      ROUTINE_PARAMETER="${CUR_FUNC#*:}"
      CUR_FUNC="${CUR_FUNC%%:*}"
      [ "${CUR_FUNC}"x = "${ROUTINE_PARAMETER}"x ] && ROUTINE_PARAMETER="" || ROUTINE_PARAMETER="$( IFS=: ; printf "%s " ${ROUTINE_PARAMETER}  )"

      typeset +f "${CUR_FUNC}" 2>/dev/null >/dev/null
      if [ $? -eq 0 ] ; then
        LogRuntimeInfo "Executing the finish function \"${CUR_FUNC}\" (Parameter are: \"${ROUTINE_PARAMETER}\") ..."
        INSIDE_FINISH_ROUTINE=${__TRUE}
        ${PREFIX} ${CUR_FUNC} ${ROUTINE_PARAMETER}
        INSIDE_FINISH_ROUTINE=${__FALSE}
      else
        LogRuntimeInfo "The finish function \"${CUR_FUNC}\" is not defined - ignoring this entry"
      fi
    done
  else
    LogRuntimeInfo "No finish functions defined or finish functions disabled"
  fi
  
  return 0
}

# ----------------------------------------------------------------------
# die
#
# do the housekeeping and end the script 
#
# usage: die [script_returncode] [end_message]
#
# returns: the function ends the script
#
# default returncode is 0; there is no default for end_message
#
function die {
  typeset __FUNCTION="die"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  __unsettraps

  typeset THISRC=$1
  [ "${THISRC}"x = ""x ] && THISRC=0
  
  INSIDE_DIE=${__TRUE}

  if [ "${__STTY_SETTINGS}"x != ""x ] ; then
    LogRuntimeInfo "Resetting the tty ..."
    stty ${__STTY_SETTINGS}
    __STTY_SETTINGS=""
  fi
  
  if [ ${NO_CLEANUP}x = ${__TRUE}x ] ; then
    LogRuntimeInfo "House keeping is disabled"
  else
    cleanup
  fi
  
  if [ $# -ne 0 ] ; then
    shift
    if [ $# -ne 0 ] ; then
      if [ ${THISRC} = 0 ] ; then
        LogMsg "$*"
      else
        LogError "$*! RC=${THISRC}"
      fi
    fi      
  fi

  if [ "${PREFIX}"x != ""x ] ; then
    LogMsg "-"
    LogMsg "*** Running in dry-run mode -- no changes were done. The dryrun prefix used was \"${PREFIX}\" "
    LogMsg "-"
  fi

  if [ "${LOGFILE}"x != ""x -a -f "${LOGFILE}" ] ; then
    LogMsg "### The logfile used was ${LOGFILE}"
  fi
   
  gettime_in_seconds ENDTIME_IN_SECONDS
  ENDTIME_IN_HUMAN_READABLE_FORMAT="$( date "+%d.%m.%Y %H:%M:%S" )"

  if isNumber ${STARTTIME_IN_SECONDS} -a isNumber ${ENDTIME_IN_SECONDS}  ; then
    (( RUNTIME_IN_SECONDS = ENDTIME_IN_SECONDS - STARTTIME_IN_SECONDS ))
    RUNTIME_IN_HUMAN_READABLE_FORMAT="$( echo ${RUNTIME_IN_SECONDS} | awk '{printf("%d:%02d:%02d:%02d\n",($1/60/60/24),($1/60/60%24),($1/60%60),($1%60))}'  )"
  else
    RUNTIME_IN_SECONDS="?"
    RUNTIME_IN_HUMAN_READABLE_FORMAT=""
  fi

  LogMsg "### The start time was ${STARTTIME_IN_HUMAN_READABLE_FORMAT}, the script runtime is (day:hour:minute:seconds) ${RUNTIME_IN_HUMAN_READABLE_FORMAT} (= ${RUNTIME_IN_SECONDS} seconds)"

  LogMsg "### ${SCRIPTNAME} ended at ${ENDTIME_IN_HUMAN_READABLE_FORMAT} (The PID of this process is $$; the RC is ${THISRC})"

  exit ${THISRC}
}


# ----------------------------------------------------------------------
# signal_exit_handler
#
# signal handler for the signal EXIT
#
# usage: the function is called via the signal only
#
# returns: the function ends the script using the function die
#
function signal_exit_handler {  
  typeset __FUNCTION="signal_exit_handler"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  
  typeset SIGNAL_LINENO=$1
  LogRuntimeInfo "Signal handler for the signal EXIT called"
  
  [ ${INSIDE_EXIT_HANDLER} = ${__TRUE} ] && return
  INSIDE_EXIT_HANDLER=${__TRUE}
  
  if [ ${INSIDE_DIE} = ${__FALSE} ] ; then
    die 200 "Script aborted for unknown reason; EXIT signal received"
  fi  

  INSIDE_EXIT_HANDLER=${__FALSE}
}

# ----------------------------------------------------------------------
# signal_quit_handler
#
# signal handler for the signal QUIT
#
# usage: the function is called via the signal only
#
# returns: 
#
function signal_quit_handler {  
  typeset __FUNCTION="signal_quit_handler"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset SIGNAL_LINENO=$1
  LogRuntimeInfo "Signal handler for the signal QUIT called"
 
  [ ${INSIDE_QUIT_HANDLER} = ${__TRUE} ] && return
  INSIDE_QUIT_HANDLER=${__TRUE}

  if [ ${INSIDE_DIE} = ${__FALSE} ] ; then
    die 201 "Script aborted for unknown reason, QUIT signal received"
  fi  
  
  INSIDE_QUIT_HANDLER=${__FALSE}
}

# ----------------------------------------------------------------------
# signal_usr1_handler
#
# signal handler for the signal USR1
#
# usage: the function is called via the signal only
#
# returns: n/a
#
function signal_usr1_handler {
  typeset __FUNCTION="signal_usr1_handler"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset SIGNAL_LINENO=$1
  LogRuntimeInfo "Signal handler for the signal USR1 called in line ${SIGNAL_LINENO}"

  [ ${INSIDE_USR1_HANDLER} = ${__TRUE} ] && return
  INSIDE_USR1_HANDLER=${__TRUE}

  LogMsg "Signal USR1 received while in line ${SIGNAL_LINENO}" >&2
  DebugShell
  
  INSIDE_USR1_HANDLER=${__FALSE}
}

# ----------------------------------------------------------------------
# signal_usr2_handler
#
# signal handler for the signal USR2
#
# usage: the function is called via the signal only
#
# returns: n/a
#
function signal_usr2_handler {
  typeset __FUNCTION="signal_usr2_handler"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset SIGNAL_LINENO=$1
  LogRuntimeInfo "Signal handler for the signal USR2 called in line ${SIGNAL_LINENO}"

  [ ${INSIDE_USR1_HANDLER} = ${__TRUE} ] && return
  INSIDE_USR2_HANDLER=${__TRUE}

#  LogMsg "Signal USR2 received while in line ${SIGNAL_LINENO}" >&2
#  DebugShell
  
  INSIDE_USR2_HANDLER=${__FALSE}
}


# ----------------------------------------------------------------------
# signal_hup_handler
#
# signal handler for the signal HUP
#
# usage: the function is called via the signal only
#
# returns: n/a
#
function signal_hup_handler {
  typeset __FUNCTION="signal_hup_handler"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset SIGNAL_LINENO=$1
  LogRuntimeInfo "Signal handler for the signal HUP called in line ${SIGNAL_LINENO}"

  [ ${INSIDE_USR1_HANDLER} = ${__TRUE} ] && return
  INSIDE_HUP_HANDLER=${__TRUE}

#  LogMsg "Signal HUP received while in line ${SIGNAL_LINENO}" >&2
#  DebugShell
  
  INSIDE_HUP_HANDLER=${__FALSE}
}

# ----------------------------------------------------------------------
# signal_break_handler
#
# signal handler for the signal break (CTRL-C)
#
# usage: the function is called via the signal only
#
# returns: n/a
#
function signal_break_handler {
  typeset __FUNCTION="signal_break_handler"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset SIGNAL_LINENO=$1
  LogRuntimeInfo "Signal handler for the signal BREAK called in line ${SIGNAL_LINENO}"

  if [ ${INSIDE_BREAK_HANDLER} = ${__TRUE} ] ; then
    INSIDE_BREAK_HANDLER=${__FALSE}
    return
  fi

  LogMsg "Signal BREAK received while in line ${SIGNAL_LINENO}" >&2
  
  INSIDE_BREAK_HANDLER=${__TRUE}
  
  if [ "${BREAK_ALLOWED}"x = "DebugShell"x ] ; then
    if [ ${ENABLE_DEBUG}x = ${__TRUE}x ]  ; then
      LogMsg "*** DebugShell called via CTRL_C"
      DebugShell
    fi
  elif [ ${BREAK_ALLOWED} = ${__FALSE} ] ; then
    LogRuntimeInfo "CTRL-C is disabled for ${SCRIPTNAME}"
  else
    die 250 "${SCRIPTNAME} aborted by CTRL-C"
  fi
  
  INSIDE_BREAK_HANDLER=${__FALSE}
}

# ----------------------------------------------------------------------
#

# ----------------------------------------------------------------------
# print_runtime_variables
#
# print the current values of the runtime variables
#
# usage: print_runtime_variables 
#
# returns: ${__TRUE}
#
function print_runtime_variables {
  typeset __FUNCTION="print_runtime_variables"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
	
  typeset THISRC=${__TRUE}
  typeset CUR_VAR=""
  typeset CUR_VALUE=""
  typeset CUR_MSG=""
  
  for CUR_VAR in ${RUNTIME_VARIABLES} ${APPLICATION_VARIABLES} ; do
    if [[ ${CUR_VAR} == \#* ]] ; then
      CUR_MSG="*** $( echo "${CUR_VAR#*#}" | tr "_" " ")"
    else
      eval CUR_VALUE="\$${CUR_VAR}"
      CUR_MSG="  ${CUR_VAR}: \"${CUR_VALUE}\" "
    fi
    "printf"  "${CUR_MSG}\n" 
  done
  
  return ${THISRC}
}

# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# isNumber
#
# check if a value is an integer
#
# usage: isNumber testValue
#
# returns: ${__TRUE} - testValue is a number else not
#
function isNumber {
  typeset __FUNCTION="isNumber"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
	
  typeset THISRC=${__FALSE}

# old code:
#  typeset TESTVAR="$(echo "$1" | sed 's/[0-9]*//g' )"
#  [ "${TESTVAR}"x = ""x ] && return ${__TRUE} || return ${__FALSE}

  [[ $1 == +([0-9]) ]] && THISRC=${__TRUE} || THISRC=${__FALSE}

  return ${THISRC}
}

# ----------------------------------------------------------------------
# AskUser
#
# Ask the user (or use defaults depending on the parameter -n and -y)
#
# Usage: AskUser "message"
#
# returns: ${__TRUE} - user input is yes
#          ${__FALSE} - user input is no
#          USER_INPUT contains the user input
#
# Notes: "all" is interpreted as yes for this and all other questions
#        "none" is interpreted as no for this and all other questions
#
# If __NOECHO is ${__TRUE} the user input is not written to STDOUT
# __NOECHO is set to ${__FALSE} again in this function
#
# If __USE_TTY is ${__TRUE} the prompt is written to /dev/tty and the
# user input is read from /dev/tty . This is useful if STDOUT is redirected
# to a file.
#
# "shell" opens the DebugShell; set __DEBUG_SHELL_IN_ASKUSER to ${__FALSE}
# to disable the DebugShell in AskUser
#
function AskUser {
  typeset __FUNCTION="AskUser"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
	
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
  return ${THISRC}
}


# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# check_rcm_values
#
# init the variables neccessary for RCM access
#
# usage: check_rcm_values
#
# returns: ${__TRUE} - ok, variables set
#          ${__FALSE} - error initiating the RCm support
#
# This function is only useful in RCM environments!
#
function check_rcm_values {
  typeset __FUNCTION="check_rcm_values"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  typeset THISRC=${__TRUE}

  if [ "${RCM_HOSTID}"x = ""x ] ; then
    LogError "RCM_HOSTID is not set (check the file ${RCM_HOSTID_FILE})"
    THISRC=${__FALSE}
  fi

  if [ "${RCM_SERVICE}"x = ""x ] ; then
    LogError "Variable RCM_SERVICE is not set"
    THISRC=${__FALSE}
  fi

  if [ "${RCM_FUNCTION}"x = ""x ] ; then
    LogError "Variable RCM_FUNCTION is not set"
    THISRC=${__FALSE}
  fi
  
  return ${THISRC}
}

  
# ----------------------------------------------------------------------
# get_rcm_userid
#
# get the userid and password for RCM access from the user
#
# usage: get_rcm_userid
#
# returns: always ${__TRUE}, RCM_USERID and RCM_PASSWORD are set 
#
# note: the RCM_USERID is NOT neccessary for dbquery and dbgetfile
#
# This function is only useful in RCM environments!
#
function get_rcm_userid {
  typeset __FUNCTION="get_rcm_userid"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  typeset THISRC=${__TRUE}
  
  typeset STTY_SETTINGS="$( stty -g )"

  if [ "${RCM_USERID}"x = ""x ] ; then
#    printf "Please enter the RCM userid: " ; read RCM_USERID
    AskUser "Please enter the RCM userid: " ; RCM_USERID="${USER_INPUT}"
  fi
  
  if [ "${RCM_PASSWORD}"x = ""x ] ; then
    __NOECHO=${__TRUE}
    __USE_TTY=${__TRUE}
    AskUser "Please enter the RCM password for ${RCM_USERID}: " ; RCM_PASSWORD="${USER_INPUT}"
    __NOECHO=${__FALSE}
    __USE_TTY=${__FALSE}

#    stty -echo
#    printf "Please enter the RCM password: " ; read RCM_PASSWORD
#    stty ${STTY_SETTINGS}
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# Read_APPL_PARAMS_entries
#
# read the APPL_PARAMS entries for ${RCM_SERVICE}:${RCM_FUNCTION} from the RCM
#
# usage: Read_APPL_PARAMS_entries
#
# returns: ${__TRUE} - APPL_PARAMS read
#          ${__FALSE} - error reading the APPL_PARAMS
#
# The found APPL_PARAMS entries are stored in these variables.
#
# RCM_APPL_PARAMS_KEY[0] - no of entries found
#
# RCM_APPL_PARAMS_KEY[n] - PARAMETER field for the nth entry
# RCM_APPL_PARAMS_VAL[n] - VALUE field for the nth entry
#
# The variable FOUND_APPL_PARAM_ENTRY_KEYS contains all PARAMETER entries
# found in the RCM
#
# This function is only useful in RCM environments!
#
function Read_APPL_PARAMS_entries {
  typeset __FUNCTION="Read_APPL_PARAMS_entries"	
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  typeset THISRC=${__TRUE}

  typeset RCM_INCLUDE_FILE="/usr/db/RCM/Utility/shAPI_env"
   
  typeset DBQUERY_CMD=""
  typeset THIS_KEY=""
  typeset THIS_VALUE=""
  typeset i=0
  
  FOUND_APPL_PARAM_ENTRY_KEYS=""
    
  if [ "${RCM_INCLUDE_FILE}"x != ""x ] ; then
    if [ -r "${RCM_INCLUDE_FILE}" ] ; then
      . "${RCM_INCLUDE_FILE}"
    fi
  fi

  check_rcm_values || THISRC=${__FALSE}
  
  if  [ ! -x "${RCM_DBQUERY}" ] ; then
    LogError "${RCM_DBQUERY} not found or not executable"
    THISRC=${__FALSE}
  fi

  if [ ${THISRC} = ${__TRUE} ] ; then

    THISRC=${__FALSE}

# read the APPL_PARAMS from the RCM
#
    DBQUERY_CMD="${RCM_DBQUERY} --where \"{ hostid => '${RCM_HOSTID}', service => '${RCM_SERVICE}', function => '${RCM_FUNCTION}' }\" \
 --key appl_params_by_hostid_svc_func --fields=parameter,value "

    LogMsg "Executing "
    LogMsg "-"  "${DBQUERY_CMD}"

    eval ${DBQUERY_CMD} | tr -d '"' | sort | while read THIS_KEY THIS_VALUE ; do
      [ "${THIS_KEY}"x = ""x ] && continue
      
      (( i = i + 1 ))
      
      THISRC=${__TRUE}
      LogInfo "Key found: \"${THIS_KEY}\" = \"${THIS_VALUE}\" "

      case ${THIS_KEY} in

        * )
          LogMsg "Found the key \"${THIS_KEY}\" with the value \"${THIS_VALUE}\" "
          RCM_APPL_PARAMS_KEY[$i]="${THIS_KEY}"
          RCM_APPL_PARAMS_VAL[$i]="${THIS_VALUE}"
          FOUND_APPL_PARAM_ENTRY_KEYS="${FOUND_APPL_PARAM_ENTRY_KEYS} ${THIS_KEY}"
          ;;  

      esac
    done

    RCM_APPL_PARAMS_KEY[0]=$i
  fi

  [ ${THISRC} != ${__TRUE} ] && LogMsg "No config found in the RCM"

  return ${THISRC}
}


# ----------------------------------------------------------------------
# Retrieve_file_from_Jamaica
#
# retrieve a file from Jamaica (RCM)
#
# usage: Retrieve_file_from_Jamaica [file_name_in_rcm] {local_file_name}
#
# returns: ${__TRUE} - file retrieved
#          ${__FALSE} - file not found in Jamaica
#
# This function is only useful in RCM environments!
#
function Retrieve_file_from_Jamaica {
  typeset __FUNCTION="Retrieve_file_from_Jamaica"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  typeset THISRC=${__TRUE}

  typeset RCM_FILE="$1"
  typeset TARGET_FILE="$2"
  
  typeset NEW_FILE_CONTENTS=""

  check_rcm_values || THISRC=${__FALSE}
 
  if  [ ! -x "${RCM_DBGET_FILE}" ] ; then
    LogError "${RCM_DBGET_FILE} not found or not executable"
    THISRC=${__FALSE}
  fi

  if [ "${RCM_FILE}"x != ""x -a ${THISRC} = ${__TRUE} ] ; then

    [ "${TARGET_FILE}"x = ""x ] && TARGET_FILE="${RCM_FILE}"
    
    [ -r "${TARGET_FILE}" ] && ${PREFIX} \rm "${TARGET_FILE}" 

    LogMsg "Executing "
    LogMsg "-"  "${RCM_DBGET_FILE} -f ${RCM_HOSTID} ${RCM_SERVICE} ${RCM_FUNCTION} ${RCM_FILE}"

    NEW_FILE_CONTENTS="$( ${RCM_DBGET_FILE} -f ${RCM_HOSTID} ${RCM_SERVICE} ${RCM_FUNCTION} "${RCM_FILE}" 2>/dev/null )"
    if [ "${NEW_FILE_CONTENTS}"x = ""x ] ; then
      LogWarning "${RCM_FILE} NOT found in the RCM"
    else
      LogMsg "Creating the file ${TARGET_FILE} (RCM entry is ${RCM_FILE})...."
      if [ "${PREFIX}"x = ""x ] ; then
        echo "${NEW_FILE_CONTENTS}" >"${TARGET_FILE}" && THISRC=${__TRUE}
      else
        ${PREFIX} echo "${NEW_FILE_CONTENTS} >${TARGET_FILE}" && THISRC=${__TRUE}
      fi
    fi
  fi

  return ${THISRC}
}

# ----------------------------------------------------------------------
# show_extended_usage_help
#
# function: show_extended_usage_help
#
# usage: this function is called in show_script_usage if the 
#        parameter -v and -h are used
#
# returns: ${__TRUE} - 
#          ${__FALSE} - 
#
function show_extended_usage_help {
  typeset __FUNCTION="show_extended_usage_help"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}
 
  typeset CUR_ENTRY=""
  typeset CUR_VAR=""
  typeset CUR_VALUE=""
  typeset CUR_TYPE=""
  typeset CUR_COMMENT=""

  typeset CUR_VAR_L=10
  typeset CUR_VALUE_L=16
  typeset CUR_TYPE_L=5
  typeset CUR_COMMENT_L=10
  
  typeset CUR_PRINTF_FORM=""
  typeset LAST_LINE_EMPTY=${__FALSE}
  
  
# add your code her
#  LogMsg "This function is called if the parameter -v and -h are used"

  if [ "${ENV_VARIABLES}"x != ""x ] ; then
    echo ""
    echo " Supported environment variables are (values for booleans: 0 = TRUE, 1 = FALSE):"
    echo ""
  
    echo "${ENV_VARIABLES}" | while IFS= read -r CUR_ENTRY  ; do
#    echo "${CUR_ENTRY}"
  
      CUR_VAR=""
      CUR_TYPE=""
      CUR_COMMENT=""
      
      CUR_VAR="${CUR_ENTRY%%#*}"
      [ ${#CUR_VAR} -gt ${CUR_VAR_L} ] && CUR_VAR_L=${#CUR_VAR}
      
      CUR_ENTRY="${CUR_ENTRY#*#}" 
      if [ "${CUR_ENTRY}"x != "${CUR_VAR}"x ] ; then
  
        CUR_TYPE="${CUR_ENTRY%%#*}"
        [ ${#CUR_TYPE} -gt ${CUR_TYPE_L} ] && CUR_TYPE_L=${#CUR_TYPE}
  
        CUR_COMMENT="${CUR_ENTRY#*#}"
        if [ "${CUR_TYPE}"x != "${CUR_COMMENT}"x ] ; then
          [ ${#CUR_COMMENT} -gt ${CUR_COMMENT_L} ] && CUR_COMMENT_L=${#CUR_COMMENT}
        fi
      fi
      
      if [ "${CUR_VAR}"x != ""x ] ; then
        eval CUR_VALUE="\$${CUR_VAR}"
        if [ ${#CUR_VALUE} -gt ${CUR_VALUE_L} ] ;then
          (( CUR_VALUE_L = ${#CUR_VALUE} + 2 ))
        fi
      fi
  
#
# ugly but working code .. (this loop is executed in a sub shell)
#
      echo  " %-${CUR_VAR_L}s %-${CUR_TYPE_L}s %-${CUR_VALUE_L}s %-${CUR_COMMENT_L}s" >"${TMPFILE1}"
  
    done
  
#  (( CUR_VALUE_L = CUR_VALUE_L +4 ))
  
#  CUR_PRINTF_FORM="%-${CUR_VAR_L}s %-${CUR_TYPE_L}s %-${CUR_VALUE_L}s %-${CUR_COMMENT_L}s"
  
    CUR_PRINTF_FORM="$( cat "${TMPFILE1}" )"
    
    LogMsg "-" "$( printf "${CUR_PRINTF_FORM}" "Variable" "Type" "Current value" "Comment" )"
  
    echo "${ENV_VARIABLES}" | while IFS= read -r CUR_ENTRY  ; do
     if [[ ${CUR_ENTRY} == \# ]] ; then
       LogMsg "-"
     elif [[ ${CUR_ENTRY} == \#* ]] ; then
       LogMsg "-" "${CUR_ENTRY}"
       continue
     fi
#    echo "${CUR_ENTRY}"
  
      CUR_VAR=""
      CUR_VALUE=""
      CUR_TYPE=""
      CUR_COMMENT=""
  
      CUR_VAR="${CUR_ENTRY%%#*}"
      [ ${#CUR_VAR} -gt ${CUR_VAR_L} ] && CUR_VAR_L=${#CUR_VAR}
      
      CUR_ENTRY="${CUR_ENTRY#*#}" 
      if [ "${CUR_ENTRY}"x != "${CUR_VAR}"x ] ; then
  
        CUR_TYPE="${CUR_ENTRY%%#*}"
        CUR_COMMENT="${CUR_ENTRY#*#}"
        if [ "${CUR_TYPE}"x != "${CUR_COMMENT}"x ] ; then
          [ ${#CUR_COMMENT} -gt ${CUR_COMMENT_L} ] && CUR_COMMENT_L=${#CUR_COMMENT}
        else
          CUR_COMMENT=""
        fi
      fi
  
      if [ "${CUR_VAR}"x != ""x ] ; then
        eval CUR_VALUE="\$${CUR_VAR}"
        CUR_VALUE="\"${CUR_VALUE}\""
      else 
        continue
      fi
  
#
# ugly but working code .. (this loop is executed in a sub shell)
#
   
      LogMsg "-" "$( printf "${CUR_PRINTF_FORM}" "${CUR_VAR# *}" "${CUR_TYPE# *}" "${CUR_VALUE}"  "${CUR_COMMENT# *}" )"
  
    done
  
    LogMsg "-" "
 How to use the variables:
      
 Either define the environment variables before executing the script or use the parameter \"--var name=value\"
  " 
  fi   

# print also the history if the parameter -v is used two times
#
  if [ ${VERBOSE_LEVEL} -ge 2 ] ; then
    grep "^#V#" "${REAL_SCRIPTNAME}" | cut -c4- | sed "s#sync_install_server_directory#${REAL_SCRIPTNAME}#g"
  fi

# print also the template history if the parameter -v is used three times
#
  if [ ${VERBOSE_LEVEL} -ge 3 ] ; then
    grep "^#T#" "${REAL_SCRIPTNAME}" | cut -c4- | sed "s#sync_install_server_directory#${REAL_SCRIPTNAME}#g"
  fi

  VERBOSE_LEVEL=0
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

  if [ ${INSIDE_DEBUG_SHELL}x = ${__TRUE}x ] ; then
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
  case ${CUR_OS} in 
  
     SunOS )
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

  if [ "${SIGTSTP}"x = ""x -o "${SIGCONT}"x = ""x ] ; then
    LogError "${__FUNCTION}: I do not know the signals used for OS \"${CUR_OS}\" "
    THISRC=${__FALSE}
  else

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
    
    case ${CUR_OS} in 
  
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
        LogError "Can not switch a process into the background in ${CUR_OS}"
        THISRC=${__FALSE}
        ;; 
    esac
  
    tty -s && RUNNING_IN_TERMINAL_SESSION=${__TRUE} || RUNNING_IN_TERMINAL_SESSION=${__FALSE}
  
  # close the temporary file descriptor again  
    exec 9>&-

  fi

  return ${THISRC}
}


# ----------------------------------------------------------------------
# create_lock_file
#
# function: create a lock file to avoid that multiple instances of this script are running at the same time
#
# usage: create_lock_file [lockfile] [wait_time] [wait_step_in_seconds]
#
# parameter: 
#   lockfile - fully qualified name of the lock file
#     default: ${DEFAULT_LOCK_FILE}
#
#   wait_time - time in seconds (#S), minutes (#M), or hours (#H) to wait if the lockfile already exist
#     default : ${DEFAULT_LOCK_FILE_WAIT_TIME} 
#
#   wait_step_in_seconds - wait pause in seconds
#     default: ${DEFAULT_STEP_COUNT}
#
# global varables used:
#
# WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS
# PID_OF_PROCESS_HOLDING_THE_LOCKFILE
#
#                 
# returns: 0 -  lock file created without waiting (probably after waiting for ${WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS} seconds)
#          1 -  error creating the lock file
#          2 -  lock file already exists - could not create the lockfile, the variable 
#               ${PID_OF_PROCESS_HOLDING_THE_LOCKFILE} contains the PID of the process holding the lockfile
#          3 -  usage error (invalid parameter, etc)
#          3 -  unknown error
#
function create_lock_file {
  typeset __FUNCTION="create_lock_file"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=0

  typeset LOCKFILE=""
  typeset LOCKFILE_DIR=""
  typeset WAIT_TIME=""
  typeset FACTOR=""
  typeset CUR_WAIT_TIME=""
  typeset WAIT_TIME_IN_SECONDS=""
  typeset WAIT_TIME_MSG=""
  typeset STEP_COUNT=""
  typeset CUR_STEP_COUNT=""
  typeset STEP_COUNT_MSG=""
  typeset STEP_COUNT_IN_SECONDS=""
  
  [ "$1"x != ""x ] && LOCKFILE="$1"    || LOCKFILE="${DEFAULT_LOCK_FILE}"
  [ "$2"x != ""x ] && WAIT_TIME="$2"   || WAIT_TIME="${DEFAULT_LOCK_FILE_WAIT_TIME}"
  [ "$3"x != ""x ] && STEP_COUNT="$3"  || STEP_COUNT="${DEFAULT_STEP_COUNT}"

  
  WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS="0"
  PID_OF_PROCESS_HOLDING_THE_LOCKFILE=""

  LOCKFILE_DIR="${LOCKFILE%/*}"
  [ "${LOCKFILE_DIR}"x  = ""x ] && LOCKFILE_DIR="/"

  if [[ ${LOCKFILE_DIR} != /* ]] ; then
    LogError "The value for the lock file, \"${LOCKFILE_DIR}\", is not an absolute path"
    THISRC=3
  elif [ ! -d "${LOCKFILE_DIR}" ] ; then
    LogError "The directory for the lock file, \"${LOCKFILE_DIR}\" does not exist"
    THISRC=3
  fi

  if [ "${WAIT_TIME}"x = ""x ] ; then
    CUR_WAIT_TIME="0"
    FACTOR=1
    WAIT_TIME_MSG=""
  elif [[ ${WAIT_TIME} == *M || ${WAIT_TIME} == *m ]] ; then
    CUR_WAIT_TIME="${WAIT_TIME%[mM]*}"
    FACTOR=60
    WAIT_TIME_MSG=" ( = ${CUR_WAIT_TIME} minute(s) )"
  elif [[ ${WAIT_TIME} == *H || ${WAIT_TIME} == *h ]] ; then
    CUR_WAIT_TIME="${WAIT_TIME%[hH]*}"
    FACTOR=3600
    WAIT_TIME_MSG=" ( = ${CUR_WAIT_TIME} hour(s) )"
  elif [[ ${WAIT_TIME} == *S || ${WAIT_TIME} == *s ]] ; then
    CUR_WAIT_TIME="${WAIT_TIME%[sS]*}"
    FACTOR=1
    WAIT_TIME_MSG=""
  else
    CUR_WAIT_TIME="${WAIT_TIME}"
    FACTOR=1
    WAIT_TIME_MSG=""
  fi
   
  if ! isNumber ${CUR_WAIT_TIME}  ; then
    LogError "\"${WAIT_TIME}\" is not a valid value for the time wait parameter"
    THISRC=${__FALSE}
  fi
   
  (( WAIT_TIME_IN_SECONDS = CUR_WAIT_TIME * FACTOR ))


  if [ "${STEP_COUNT}"x = ""x ] ; then
    CUR_STEP_COUNT="0"
    FACTOR=1
    STEP_COUNT_MSG=""
  elif [[ ${STEP_COUNT} == *M || ${STEP_COUNT} == *m ]] ; then
    CUR_STEP_COUNT="${STEP_COUNT%[mM]*}"
    FACTOR=60
    STEP_COUNT_MSG=" ( = ${CUR_STEP_COUNT} minute(s) )"
  elif [[ ${STEP_COUNT} == *H || ${STEP_COUNT} == *h ]] ; then
    CUR_STEP_COUNT="${STEP_COUNT%[hH]*}"
    FACTOR=3600
    STEP_COUNT_MSG=" ( = ${CUR_STEP_COUNT} hour(s) )"
  elif [[ ${STEP_COUNT} == *S || ${STEP_COUNT} == *s ]] ; then
    CUR_STEP_COUNT="${STEP_COUNT%[sS]*}"
    FACTOR=1
    STEP_COUNT_MSG=""
  else
    CUR_STEP_COUNT="${STEP_COUNT}"
    FACTOR=1
    STEP_COUNT_MSG=""
  fi
   
  if ! isNumber ${CUR_STEP_COUNT} ] ; then
    LogError "\"${STEP_COUNT}\" is not a valid value for the time wait parameter"
    THISRC=${__FALSE}
  elif [ ${STEP_COUNT} = 0 ] ; then
    LogError "\"${STEP_COUNT}\" is not a valid value for the step count parameter"
    THISRC=${__FALSE}

  fi

  (( STEP_COUNT_IN_SECONDS = CUR_STEP_COUNT * FACTOR ))
    
#
# create the lock file
#
  if [ ${THISRC} = ${__TRUE} ] ; then

    while [ ${WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS} -le ${WAIT_TIME_IN_SECONDS} ] ; do
      if [ -f "${LOCKFILE}" ] ; then
        LN_RC=1
      else
        set -C  # or: set -o noclobber
        : > "${LOCKFILE}" 2>>/dev/null
        LN_RC=$?
      fi

      if [ ${LN_RC} = 0 ] ; then
        LogInfo "Lockfile \"${LOCKFILE}\" created"
        set +C # or: set +o noclobber
        echo $$ >>"${LOCKFILE}"
        
        break
      fi

      if [ "${WAIT_TIME_IN_SECONDS}" != 0 ] ; then
        if [ "${WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS}"x = "0"x  ] ; then
          LogMsg "-"
          LogMsg  "*******************************************************************************"
          LogMsg  "*** Another instance of the script \"${SCRIPTNAME}\" is currently running"
          LogMsg "-"
          
          RUNNING_PID="$( ${EGREP} -v "^#|^$" "${LOCKFILE}" 2>//dev/null )"
          if [ "${RUNNING_PID}"x != ""x ] ; then
            if isNumber ${RUNNING_PID} ; then
              CUR_OUTPUT="$( ps -fp ${RUNNING_PID} 2>&1 )"
              if [ $? -eq 0 ] ; then
                LogMsg "The running process is:"
                LogMsg "-"
                LogMsg "-" "${CUR_OUTPUT}"
                LogMsg "-"
              else
                LogMsg "The PID of the process creating the semaphor was ${RUNNING_PID} (there is no process currently running with that PID)"
              fi
            fi
          fi
          LogMsg "The file \"${LOCKFILE}\" already exists - now waiting for up to ${WAIT_TIME_IN_SECONDS} seconds${WAIT_TIME_MSG} in steps with ${STEP_COUNT_IN_SECONDS} seconds${STEP_COUNT_MSG}..."
        else
          printf "."
        fi
        sleep ${STEP_COUNT}
        (( WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS = WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS + STEP_COUNT_IN_SECONDS ))
      fi
    done      
  fi
  printf "\n"
 
#
# remove the lockfile at script end
#    
  if [ ${THISRC} = ${__TRUE} ] ; then

    if [ ${LN_RC} = 0 ] ; then
      [ ${WAIT_TIME_FOR_THE_LOCKFILE_IN_SECONDS} != 0 ] &&  LogMsg  "*** The other instance of the script ended. Will continue now ..."

      FILES_TO_REMOVE="${FILES_TO_REMOVE} ${LOCKFILE}"
      echo $$ >>"${LOCKFILE}"
    else
      THISRC=${__FALSE}
      LogMsg "-"
      LogError "Another instance of \"${SCRIPTNAME}\" is still running"
      PID_OF_PROCESS_HOLDING_THE_LOCKFILE="$( grep -v "^#" "${LOCKFILE}" )"
      if [ "${PID_OF_PROCESS_HOLDING_THE_LOCKFILE}"x != ""x  ] ; then
        if isNumber ${PID_OF_PROCESS_HOLDING_THE_LOCKFILE} ; then
          CUR_OUTPUT="$( ps -f -p ${PID_OF_PROCESS_HOLDING_THE_LOCKFILE} )" && \
            LogMsg "-" "
${CUR_OUTPUT}
"
        fi    
      fi
      LogMsg "       Either wait until the instance is finished or "
      LogMsg "       remove the file \"${LOCKFILE}\" if there is no other instance running"
      LogMsg "-"
    fi
  fi

  return ${THISRC}
}


# ----------------------------------------------------------------------
# get_fqn
#
# function: get the FQN of a file
#
# usage: get_fqn filename [...[filename#]]
#
# returns: ${__TRUE} - 
#          ${__FALSE} - 
#
# The function writes the FQN or the filename to STDOUT
#
function get_fqn {
  typeset __FUNCTION="get_fqn"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}
  typeset CUR_OUTPUT=""
  
  if [ "${READLINK}"x = ""x ] ; then
    CUR_OUTPUT="$*"
  else
    while [ $# -ne 0 ] ; do
      if [ ! -r $1 -a ! -d $( dirname $1 ) ] ; then
        CUR_OUTPUT="${CUR_OUTPUT} $1"
      else
        [ "${CUR_OUTPUT}"x = ""x ] && CUR_OUTPUT="$( ${READLINK} -f $1 )" || CUR_OUTPUT="${CUR_OUTPUT} $( ${READLINK} -f $1 )"
      fi
      shift 
    done
  fi
  \echo "${CUR_OUTPUT}"      

  return ${THISRC}
}

# ----------------------------------------------------------------------
# read_file_section
#
# function: read the lines of a file between start_regex and end_regex
#
# usage: read_file_section [filename] [start_regex] [end_regex] 
#
# returns: 0  OK, section found and printed to STDOUT 
#          1  OK, section not found in the file
#          2  file not found
#          3  error in one of the regex
#          4  invalid usage
#
# The function searches for sections starting with 
#
# start_regex
#  ...
# end_regex
# 
# The lines matching start_regex and end_regex are part of the output
#
# The output of the sed command used is in the global variable FILE_SECTION_CONTENTS (including
# the lines matching start_regex and end_regex).
# The remaining lines from the file will be in the global variable REMAINING_FILE_CONTENTS
#
# Example usage:
#   read_file_section "${DHCPD_CONFIG_FILE}" "^[ \t]*host[ \t]*${THIS_HOSTID}[ \t]*$" "^[ \t]*}[ \t]*$*"
#   read_file_section "${PXE_DEFAULT_CONFIG_FILE}" "^[ \t]*label[ \t]*${LABEL_FOR_PXE_DEFAULT_BOOT_MENU}[ \t]*$" "^[ \t]*append[ \t]*.*$"
#   read_file_section "${CUR_OUTPUT_FILE}" "^[ \t]*label install[ \t]*$" "^[ \t]*append[ \t]"
#
function read_file_section {
  typeset __FUNCTION="read_file_section"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=4
 
  typeset CUR_FILE="$1"
  typeset START_REGEX="$2"
  typeset END_REGEX="$3"

# init the global variables used
#  
  FILE_SECTION_CONTENTS=""
  REMAINING_FILE_CONTENTS=""
  
  if [ $# -eq 3 ] ; then
    if [ -r "${CUR_FILE}" ] ; then

#    ${SED} -n "/^[ \t]*host schemmer-04/,/^[ \t]*}/p" /var/tmp/dhcpd.conf  ; echo $?
#      FILE_SECTION_CONTENTS="$( ${SED} -n "/^[ \t]*${START_REGEX}/,/^[ \t]*${END_REGEX}[ \t]$/p" "${CUR_FILE}" 2>&1 )"

      FILE_SECTION_CONTENTS="$( ${SED} -n "/${START_REGEX}/,/${END_REGEX}/p" "${CUR_FILE}" 2>&1 )"
      if [ $? -eq 0 ] ; then
        REMAINING_FILE_CONTENTS="$( ${SED} -n "/${START_REGEX}/,/${END_REGEX}/!p" "${CUR_FILE}" 2>&1 )"
        if [ "${FILE_SECTION_CONTENTS}"x != ""x ] ; then
          THISRC=0
        else
          THISRC=1       
        fi
      else
        THISRC=3
      fi
    else
      THISRC=2
    fi
  else
    THISRC=4
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# gettime_in_seconds
#
# function: get the time since 1.1.1970 in seconds
#
# usage: VAR_NAME=$( gettime_in_seconds )
#
#  or  gettime_in_seconds VAR_NAME1 {... VAR_NAME#}
#
# returns: ${__TRUE} - time retrieved
#          ${__FALSE} - error retrieving the time
#
# Note:
#
#  "date +%s" is not supported on all OS
#
function gettime_in_seconds {
  typeset __FUNCTION="gettime_in_seconds"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}
 
  typeset CUR_TIME_IN_SEC=""

  CUR_TIME_IN_SEC="$( perl -e 'print int(time)' 2>/dev/null )"
  if [ $? -ne 0 -o "${CUR_TIME_IN_SEC}"x = ""x ] ; then
    CUR_TIME_IN_SEC="$( date +%s 2>/dev/null )"
    if [ $? -ne 0 -o "${CUR_TIME_IN_SEC}"x = "%s"x ] ; then
      THISRC=${__FALSE}
    fi
  fi

  if [ ${THISRC} = ${__TRUE} ] ; then
    if [ $# -ne 0 ] ; then
       while [ $# -ne 0 ] ; do
         eval "$1=${CUR_TIME_IN_SEC}"
         shift
       done
    else
       echo "${CUR_TIME_IN_SEC}"
    fi
  fi
  
  return ${THISRC}
}

# ----------------------------------------------------------------------
# runcmd_with_timeout
#
# function: run a function or command with timeout
#
# usage: runcmd_with_timeout [timeout_value] [kill_signal] [cmd] [parameter]
#
# returns: 
#
#   the return code of the function is the return code of the program executed but only if the program finished before hitting the timeout.
#   If the program is killed by the timeout function the return code of the function is 249.
#   If the first parameter of the function is invalid the function ends with the return code 248
#
# parameter:
#
#   timeout_value
#     timeout value in seconds, use #m for minutes, #h for hours, or # or (optional) #s for seconds
#
#   kill_signal 
#     use "kill -${kill_signal}" to kill the command when the timeout is reached ("kill -9" is neccessary for example for some shell scripts)
#     default is kill with the standard signal to kill a process (which is 15)
#     kill_signal must be a number
#
#   cmd 
#     command to execute; the command can NOT be a number
#     "cmd" can be an external command or a function in the script
#
#   parameter 
#     parameter for the command to execute
#
# Be carefull with writing messages to STDOUT/STDERR or into the logfile of this script.
#
# Note:
#
# The function does NOT work in AIX
#
# Credits for this function
#    https://stackoverflow.com/questions/24412721/elegant-solution-to-implement-timeout-for-bash-commands-and-functions
#
function runcmd_with_timeout {
  typeset __FUNCTION="runcmd_with_timeout"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}

  typeset TIMEOUT_PARAMETER=""
  typeset CUR_CMD=""
  typeset CUR_VAL=""
  typeset CHILD_PID=""
  typeset CHILD_PID2=""
  typeset TIMEOUT_MSG=""
  typeset FACTOR=""
  typeset KILL_SIGNAL=15
#
# process the parameter
#  
  TIMEOUT_PARAMETER="$1"
  shift
  
  if isNumber $1 ; then
    KILL_SIGNAL=$1
    shift
  fi
  
  CUR_CMD="$@"
  
  if [[ ${TIMEOUT_PARAMETER} == *h ]] ; then
    CUR_VAL="${TIMEOUT_PARAMETER%*h}"
    FACTOR=3600
    TIMEOUT_MSG=" (= ${CUR_VAL} hours(s))"
  elif [[ ${TIMEOUT_PARAMETER} == *m ]] ; then
    CUR_VAL="${TIMEOUT_PARAMETER%*m}"
    FACTOR=60
    TIMEOUT_MSG=" (= ${CUR_VAL} minutes(s))"
  elif [[ ${TIMEOUT_PARAMETER} == *s ]] ; then
    CUR_VAL="${TIMEOUT_PARAMETER%*s}"
    FACTOR=1
    TIMEOUT_MSG=""  
  elif isNumber "${TIMEOUT_PARAMETER}" ; then
    CUR_VAL="${TIMEOUT_PARAMETER}"
    FACTOR=1
    TIMEOUT_MSG=""
  fi
    
  if [ "${FACTOR}"x = ""x ] ; then
    LogError "Internal Error: ${__FUNCTION} called with an invalid parameter for the timeout: \"${TIMEOUT_PARAMETER}\" "
    THISRC=248
  else
    ((  CUR_TIMEOUT = CUR_VAL * FACTOR ))
    
    LogInfo "Using the signal ${KILL_SIGNAL} to kill the command if the timeout is reached"
    LogInfo "Executing now \"${CUR_CMD}\" with a timeout of ${CUR_TIMEOUT} seconds ${TIMEOUT_MSG}"

#
# start a sub shell
#
    ( 
        ${CUR_CMD} &
        CHILD_PID=$!
        LogInfo "The running cmd is: $( ps -f -p ${CHILD_PID} | tail -1  )"
        trap -- "" SIGTERM 
#
# start a background process to kill the command after # seconds
#        
        (                       
          sleep ${CUR_TIMEOUT}
          LogInfo "The process ${CHILD_PID} is still running after ${CUR_TIMEOUT} seconds -- will kill it now using the signal ${KILL_SIGNAL}"
          kill -${KILL_SIGNAL} ${CHILD_PID} 

        ) 1>/dev/null  &     
        CHILD_PID2=$!

#
# now wait for the command to finish
#        
        wait ${CHILD_PID}
#
# store the return code of the command executed in the background
#
        THISRC=$?

        LogInfo "${__FUNCTION} : The return code of the \"wait\" command is ${THISRC}"
#
# kill the background process used to wait and kill if it's still running
#        
        if  ps -p ${CHILD_PID2} >/dev/null ; then
          LogInfo "The temporary process for the timeout functionality (PID =  ${CHILD_PID2}) is still running -- will kill it now"
          kill -9 ${CHILD_PID2}
        else  
          THISRC=249
        fi

#
# exit the sub shell with the return code of the command executed with timoeut
#                
        exit ${THISRC}
    ) 

#
# exit the function runcmd_with_timeout with the return code of the executed command
#
    THISRC=$?
  fi
  
  return ${THISRC}
}


# ----------------------------------------------------------------------
# convert_variable_to_boolean
#
# function: convert the value of a variable to ${__TRUE} or ${__FALSE}
#
# usage: convert_variable_to_boolean VARIABLE_NAME
#        
# returns: ${__TRUE} - variable set to ${__TRUE}
#          ${__FALSE} - variable set to ${__FALSE}
#          100 - variable not changed
#          110 - variable is already ${__TRUE}
#          111 - variable is already ${__FALSE}
#
function convert_variable_to_boolean {
  typeset __FUNCTION="convert_variable_to_boolean"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=100

  typeset CUR_OUTPUT=""
  typeset TEMPRC=""

  typeset VAR_NAME="$1"
  
  typeset CUR_VALUE=""
  typeset NEW_VALUE=""
  
  if [ "${VAR_NAME}"x != ""x ] ; then
    eval "CUR_VALUE=\$${VAR_NAME}"
    LogInfo "${__FUNCTION}: The current value of the variable \"${VAR_NAME}\" is \"${CUR_VALUE}\" "
    
    CUR_VALUE="$( echo "${CUR_VALUE}" | tr "[a-z]"  "[A-Z]" )"
    
    case ${CUR_VALUE} in
      0  )
        THISRC=110
        ;;

      1 )
        THISRC=111
        ;;
        
      TRUE | YES  )
        NEW_VALUE=${__TRUE}
        ;;

      FALSE | NO )        
        NEW_VALUE=${__FALSE}
        ;;

    esac
    
    if [ "${NEW_VALUE}"x != ""x ] ; then
#
# change the variable
#    
      THISRC=${NEW_VALUE}
      eval "${VAR_NAME}=${NEW_VALUE}"

# check the result    
      eval "CUR_VALUE=\$${VAR_NAME}"
      LogInfo "${__FUNCTION}: The current value of the variable \"${VAR_NAME}\" is now \"${CUR_VALUE}\" "
      
    fi
  fi

  return ${THISRC}
}


# ----------------------------------------------------------------------
# is_variable_true
#
# function: check if the value of a variable is true
#
# usage: is_variable_true [var_value]
#
# returns: ${__TRUE} - ok, the variable is set to true
#          ${__FALSE} - the variable is not set to true
#          100 - the value of the variable is not known
#
#
function is_variable_true {
  typeset __FUNCTION="is_variable_true"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

# init the return code of the function
#
  typeset THISRC=${__TRUE}

  LogInfo "*** Function \"${__FUNCTION}\" started"

  case $1 in
    "0" | "yes" | "YES" | "Yes" | "true" | "TRUE" | "True" | ${__TRUE} )
      THISRC=${__TRUE}
      ;;

    "1" | "no" | "No" | "No" | "false" | "FALSE" | "False" | ${__FALSE} )
      THISRC=${__FALSE}
      ;;

     * | "" )
      THISRC=100
      ;;
  esac

  LogInfo "*** Function \"${__FUNCTION}\" ended ; RC = ${THISRC}"

  return ${THISRC}
}


# ----------------------------------------------------------------------
# helper function to restore the return code of the last command for the 
# code for enabling the debug code
#
function __return {
  \return $1
}

# ----------------------------------------------------------------------
# __enable_trace_for_functions
#
# enable trace for functions
#
# Usage: __enable_trace_for_functions
#
# returns: ${__TRUE}
#
function __enable_trace_for_functions {
  typeset __FUNCTION="__enable_trace_for_functions"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  
  typeset THISRC=${__TRUE}
  typeset FUNCTIONS_TO_TRACE="$*"
  typeset CUR_STATEMENT=""
  typeset CUR_VALUE=""
  typeset ADD_CODE=""
  
  if [ "${FUNCTIONS_TO_TRACE}"x != ""x ] ; then
    CUR_STATEMENT="[ 0 = 1 "

    if [ "${__KSH_VERSION}"x = "93"x -a ${USE_ONLY_KSH88_FEATURES} = ${__FALSE} ] ; then
      CUR_STATEMENT="__FUNCTION=\"\${.sh.fun}\" ; ${CUR_STATEMENT}"
    fi

#    __FUNCTIONS_WITH_DEBUG_CODE=""
    FUNCTION_LIST="$( __evaluate_fn "${FUNCTIONS_TO_TRACE}" )"
    for CUR_VALUE in ${FUNCTION_LIST} ; do
      LogMsg "Enabling trace for the function \"${CUR_VALUE}\" ..."

      if [[ ${__FUNCTIONS_WITH_DEBUG_CODE} == *\ ${CUR_VALUE}\ * ]] ; then
        "printf" "Debug code is already enabled for the function ${CUR_VALUE}"
        continue
      fi
    
      CUR_STATEMENT="${CUR_STATEMENT} -o \"\$0\"x = \"${CUR_VALUE}\"x -o \"\${__FUNCTION}\"x = \"${CUR_VALUE}\"x  "

       __FUNCTIONS_WITH_DEBUG_CODE="${__FUNCTIONS_WITH_DEBUG_CODE} ${CUR_VALUE} "

      if ! typeset +f "${CUR_VALUE}" >/dev/null ; then
        LogMsg "The function \"${CUR_VALUE}\" is not defined"
        continue
      fi

      if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
        :
      elif [[ $( typeset -f "${CUR_VALUE}" 2>&1 ) != *\$\{__DEBUG_CODE\}* ]] ; then
        LogMsg "Adding debug code to the function \"${CUR_VALUE}\" ..."           
        ADD_CODE=" typeset __FUNCTION=${CUR_VALUE}; "
        eval "$( typeset -f  "${CUR_VALUE}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	                    
      else
        LogMsg "\"${CUR_VALUE}\" already contains debug code."      
      fi
    done
    CUR_STATEMENT="eval ${CUR_STATEMENT} ] && printf \"\n*** Enabling trace for the function \${__FUNCTION:=\$0} ...\n\" >&2 && set -x "

    if [ "${__DEBUG_CODE}"x != ""x ] ; then
      
      if [[ "${__DEBUG_CODE}" == *\; ]] ; then
        __DEBUG_CODE="${__DEBUG_CODE}    ${CUR_STATEMENT} "
      else
        __DEBUG_CODE="${__DEBUG_CODE}  ; ${CUR_STATEMENT} "
      fi

    else
      __DEBUG_CODE="${CUR_STATEMENT}"
    fi
  
    if [ "${TRACE_FEATURE_SUPPORTED}"x != "yes"x ] ; then
      LogWarning "The tracing features are only supported using the local variable __FUNCTION by this shell"
    fi
  
    if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
      LogWarning "\"typeset -f\" is not supported by this shell - can not check or add the debug code to the functions"
    fi

  fi
  
  return ${THISRC}
}


# ----------------------------------------------------------------------
# __enable_verbose_for_functions
#
# enable verbose mode for functions
#
# Usage: __enable_verbose_for_functions
#
# returns: ${__TRUE}
#
function __enable_verbose_for_functions {
  typeset __FUNCTION="__enable_verbose_for_functions"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}
  
  typeset THISRC=${__TRUE}
  typeset FUNCTIONS_TO_TRACE="$*"
  typeset CUR_STATEMENT=""
  typeset CUR_VALUE=""
  typeset ADD_CODE=""
  
  if [ "${FUNCTIONS_IN_VERBOSE}"x != ""x ] ; then
    CUR_STATEMENT="[ 0 = 1 "

    if [ "${__KSH_VERSION}"x = "93"x -a ${USE_ONLY_KSH88_FEATURES} = ${__FALSE} ] ; then
      CUR_STATEMENT="__FUNCTION=\"\${.sh.fun}\" ; ${CUR_STATEMENT}"
    fi

#    __FUNCTIONS_IN_VERBOSE_MODE=""
    FUNCTION_LIST="$( __evaluate_fn "${FUNCTIONS_TO_TRACE}" )"
    for CUR_VALUE in ${FUNCTION_LIST} ; do
      LogMsg "Enabling verbose mode for the function \"${CUR_VALUE}\" ..."

      if [[ ${__FUNCTIONS_IN_VERBOSE_MODE} == *\ ${CUR_VALUE}\ * ]] ; then
        "printf" "Debug code is already enabled for the function ${CUR_VALUE}"
        continue
      fi
    
      CUR_STATEMENT="${CUR_STATEMENT} -o \"\$0\"x = \"${CUR_VALUE}\"x -o \"\${__FUNCTION}\"x = \"${CUR_VALUE}\"x  "

       __FUNCTIONS_IN_VERBOSE_MODE="${__FUNCTIONS_IN_VERBOSE_MODE} ${CUR_VALUE} "

      if ! typeset +f "${CUR_VALUE}" >/dev/null ; then
        LogMsg "The function \"${CUR_VALUE}\" is not defined"
        continue
      fi

      if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
        :
      elif [[ $( typeset -f "${CUR_VALUE}" 2>&1 ) != *\$\{__DEBUG_CODE\}* ]] ; then
        LogMsg "Adding debug code to the function \"${CUR_VALUE}\" ..."           
        ADD_CODE=" typeset __FUNCTION=${CUR_VALUE}; "
        eval "$( typeset -f  "${CUR_VALUE}" | sed "1 s/{/\{ ${ADD_CODE}\\\$\{__DEBUG_CODE\}\;/" )"	                    
      else
        LogMsg "\"${CUR_VALUE}\" already contains debug code."      
      fi
    done

# __DEBUG_CODE="eval typeset __VERBOSE=\${VERBOSE} ; [[ \${FUNCTIONS_IN_VERBOSE_MODE}  == \${__FUNCTION} ]] && VERBOSE=\${__TRUE} ||  unset __VERBOSE ; ${__DEBUG_CODE} "
        
    CUR_STATEMENT="eval ${CUR_STATEMENT} ] && printf \"\n*** Enabling verbose mode for the function \${__FUNCTION:=\$0} ...\n\" >&2 && eval typeset __VERBOSE=\${VERBOSE} && VERBOSE=\${__TRUE} ||  unset __VERBOSE ; "
    
    __CODE_TO_ENABLE_VERBOSE_MODE="${CUR_STATEMENT}"
    
    if [ "${__DEBUG_CODE}"x != ""x ] ; then
      if [[ "${__DEBUG_CODE}" == *\; ]] ; then
        __DEBUG_CODE="${__DEBUG_CODE}  ${CUR_STATEMENT}  "
      else
        __DEBUG_CODE="${__DEBUG_CODE} ; ${CUR_STATEMENT} "
      fi
    else
      __DEBUG_CODE="${CUR_STATEMENT}"
    fi
  
    if [ "${TRACE_FEATURE_SUPPORTED}"x != "yes"x ] ; then
      LogWarning "Enabling verbose mode is only supported using the local variable __FUNCTION by this shell"
    fi
  
    if [ "${TYPESET_F_SUPPORTED}"x != "yes"x ] ; then
      LogWarning "\"typeset -f\" is not supported by this shell - can not check or add the debug code to the functions"
    fi

  fi
  
  return ${THISRC}
}


# ----------------------------------------------------------------------
# function_template
#
# function: 
#
# usage: 
#
# returns: ${__TRUE} - 
#          ${__FALSE} - 
#
# Notes:
# 
# Using the parameter -v:fn will use the local variable __VERBOSE to store
# the global value of the variable VERBOSE - therefor you should not use that
# variable in your code.
#
# Using the parameter -v:fn will enable an alias for return ; use a leading slash
# to use the real return if neccessary , e.g. 
#
#    \return 5
#
function function_template {
  typeset __FUNCTION="function_template"
  ${__DEBUG_CODE}
  ${__FUNCTION_INIT}

  typeset THISRC=${__TRUE}

  typeset CUR_OUTPUT=""
  typeset TEMPRC=""

# add your code her

#
# use \return ${THISRC} to ignore an alias defined for return
# 
  return ${THISRC}
}

# ----------------------------------------------------------------------
# main code starts here
#

# install the trap handler
#
__settraps

# ----------------------------------------------------------------------
#
# redirect STDOUT and STDERR of the script and all commands executed by
# the script to a file if called in an background session
#
if [ ${RUNNING_IN_TERMINAL_SESSION} = ${__FALSE} -a  ${LOG_STDOUT} = ${__TRUE} ] ; then
  if [[ " $* " = *\ --noSTDOUTlog\ * ]] ; then
    :
  elif [[ " $* " != *\ -q\ * && " $* " != *\ --quiet\ * ]] ; then
    STDOUT_FILE="/var/tmp/${SCRIPTNAME}.STDOUT_STDERR"
    touch "${STDOUT_FILE}" 2>/dev/null
    if [ $? -ne 0 ] ; then
      STDOUT_FILE="/var/tmp/${SCRIPTNAME}.STDOUT_STDERR.$$"
    else
      [ ! -s "${STDOUT_FILE}" ] && \rm "${STDOUT_FILE}"
    fi
    
    RotateLog "${STDOUT_FILE}"
  
    echo "${SCRIPTNAME} -- Running in a detached session ... STDOUT/STDERR will be in ${STDOUT_FILE}" >&2
 
    exec 3>&1
    exec 4>&2
    exec 1>>"${STDOUT_FILE}"  2>&1
  fi
fi

# ----------------------------------------------------------------------

gettime_in_seconds STARTTIME_IN_SECONDS
STARTTIME_IN_HUMAN_READABLE_FORMAT="$( date "+%d.%m.%Y %H:%M:%S" )"

LogMsg "### ${SCRIPTNAME} started at ${STARTTIME_IN_HUMAN_READABLE_FORMAT} (The PID of this process is $$)"


# get the parameter
#
ALL_PARAMETER="$*"

PARAMETER_OKAY=${__TRUE}

SHOW_SCRIPT_USAGE=${__FALSE}

FUNCTIONS_TO_TRACE=""

FUNCTIONS_IN_VERBOSE=""

PRINT_VERSION_AND_EXIT=${__FALSE}

LOGFILE_PARAMETER_FOUND=${__FALSE}

PRINT_RUNTIME_VARIABLES=${__FALSE}

# the alias __getparameter is used for parameter that support values
# and can be used like this "-l logfile" or this "-l:logfile"
#
alias __getparameter='
       CUR_KEY="$1"
       CUR_VALUE="${1#*:}"
       if [ "${CUR_VALUE}"x = "$1"x ] ; then
         CUR_VALUE=""
         if [ "$2"x != ""x ] ; then
           if [[ $2 != -* ]] ; then
             CUR_VALUE="$2"
             shift
           fi
         fi  
       fi'

while [ $# -ne 0 ] ; do
  
  CUR_PARAMETER="$1"
  case $1 in

# dummy help parameter
    - ) 
       :
       ;;

    -h | "" )
       SHORT_HELP=${__TRUE}
       SHOW_SCRIPT_USAGE=${__TRUE}
       ;;

    --help | -H | help |  "" )
       SHORT_HELP=${__FALSE}
       SHOW_SCRIPT_USAGE=${__TRUE}
       ;;

    -V | --version )
       PRINT_VERSION_AND_EXIT=${__TRUE}
       ;;

    +V | ++version )
       PRINT_VERSION_AND_EXIT=${__FALSE}
       ;;

    -v | --verbose )
       (( VERBOSE_LEVEL = VERBOSE_LEVEL+1 ))
       VERBOSE=${__TRUE}
       SHORT_HELP=${__FALSE}
       ;;

    +v | ++verbose )
       VERBOSE=${__FALSE}
       [ ${VERBOSE_LEVEL} -gt 0 ] && (( VERBOSE_LEVEL = VERBOSE_LEVEL-1 )) || VERBOSE_LEVEL=0
       ;;

    -q | --quiet )
       QUIET=${__TRUE}
       ;;

    +q | ++quiet )
       QUIET=${__FALSE}
       ;;

    -f | --force )
       FORCE=${__TRUE}
       ;;

    +f | ++force )
       FORCE=${__FALSE}
       ;;

    -o | --overwrite )
       OVERWRITE=${__TRUE}
       ;;

    +o | ++overwrite )
       OVERWRITE=${__FALSE}
       ;;

    -D | --debugshell )
       if [ ${ENABLE_DEBUG}x != ${__TRUE}x ] ; then
         LogError "DebugShell is disabled."
         PARAMETER_OKAY=${__FALSE}
       else
         DebugShell 
       fi
       ;;


    -d | --dryrun | -d:* | --dryrun:* )
       __getparameter    
       
       if [ "${CUR_VALUE}"x = ""x ] ; then
         PREFIX="${PREFIX:=${DEFAULT_DRYRUN_PREFIX}}"
       else
         LogInfo "Parameter \"${CUR_PARAMETER} ${CUR_VALUE}\" found"
         PREFIX="${CUR_VALUE}"
       fi

       if [ ${DRYRUN_MODE_DISABLED} = ${__TRUE} ] ; then
         LogError "Dryrun Mode is NOT supported"
         PARAMETER_OKAY=${__FALSE}
         PREFIX=""
       fi
       ;;

    +d | ++dryrun )
       if [ ${DRYRUN_MODE_DISABLED} = ${__TRUE} ] ; then
         LogError "Dryrun Mode is NOT supported"
         PARAMETER_OKAY=${__FALSE}
       else
         if [ "${PREFIX}"x != ""x ] ; then
           LogMsg "Disabling the dryrun mode (the dryrun prefix was \"${PREFIX}\")"
         fi
         PREFIX=""
       fi
       ;;

#    -d:* | --dryrun:** )
#       if [ ${DRYRUN_MODE_DISABLED} = ${__TRUE} ] ; then
#         LogError "Dryrun Mode is NOT supported"
#         PARAMETER_OKAY=${__FALSE}
#       else
#         PREFIX="${1#*:}"
#         LogMsg "The dryrun prefix used is: \"${PREFIX}\" "
#       fi
#       ;;

    +y | ++yes | +n | ++no )
       __USER_RESPONSE_IS=""
       ;;
   
    -y | --yes )
       __USER_RESPONSE_IS="y"
       ;;
       
    -n | --no )
       __USER_RESPONSE_IS="n"
       ;;

    --nologrotate )
       ROTATE_LOG=${__FALSE}
       ;;

    ++nologrotate )
       ROTATE_LOG=${__TRUE}
       ;;

    --appendlog )
       APPEND_LOG=${__TRUE}
       ROTATE_LOG=${__FALSE}
       ;;
        
    ++appendlog )
       APPEND_LOG=${__FALSE}
       ROTATE_LOG=${__TRUE}
       ;;

    --noSTDOUTlog )
       LOG_STDOUT=${__FALSE}
       ;;

    ++noSTDOUTlog )
       LOG_STDOUT=${__TRUE}
       ;;
    
    --nocleanup )
      NO_CLEANUP=${__TRUE}
      ;;

    ++nocleanup )
      NO_CLEANUP=${__FALSE}
      ;;

    --nobackups)
      NO_BACKUPS=${__TRUE}
      ;;

    ++nobackups )
      NO_BACKUPS=${__FALSE}
      ;;

    --var | --var:* )
      __getparameter

      if [ "${CUR_VALUE}"x = ""x ] ; then
         LogError "Missing value for --var"
         PARAMETER_OKAY=${__FALSE}
       else
         if [ ${ENABLE_DEBUG}x != ${__TRUE}x ] ; then
           LogError "Parameter \"${CUR_PARAMETER}\" is disabled."
           PARAMETER_OKAY=${__FALSE}
         else
           VAR_NAME="${CUR_VALUE%%=*}"
           VAR_VALUE="${CUR_VALUE#*=}"
           LogMsg "Found ${CUR_PARAMETER} parameter for ${VAR_NAME}=\"${VAR_VALUE}\" "
         
           eval CUR_VALUE="\$${VAR_NAME}"
           LogMsg "Current value of ${VAR_NAME} is: \"${CUR_VALUE}\" "
         
           eval ${VAR_NAME}=\"${VAR_VALUE}\" 

           eval NEW_VALUE="\$${VAR_NAME}"
           LogMsg "New value of ${VAR_NAME} is now: \"${NEW_VALUE}\" "
         fi
       fi
       ;;

    -v:* | --verbose:* )
       __getparameter    
       
       if [ "${CUR_VALUE}"x = ""x ] ; then
         LogError "Missing value for the parameter \"${CUR_PARAMETER}\" "
         PARAMETER_OKAY=${__FALSE}
       elif [ "${CUR_VALUE}"x = "none"x ] ; then
         LogInfo "Disabling verbose mode for all functions"
         FUNCTIONS_IN_VERBOSE=""
       else
         FUNCTIONS_IN_VERBOSE="${FUNCTIONS_IN_VERBOSE} $( echo "${CUR_VALUE}" | tr "," " " )"
       fi
       ;;
         
    -t | --tracefunc | -t:* | --tracefunc:* )
       __getparameter    
       
       if [ "${CUR_VALUE}"x = ""x ] ; then
         LogError "Missing value for the parameter \"${CUR_PARAMETER}\" "
         PARAMETER_OKAY=${__FALSE}
       elif [ "${CUR_VALUE}"x = "none"x ] ; then
         LogInfo "Disabling tracing for all functions"
         FUNCTIONS_TO_TRACE=""
       else
         FUNCTIONS_TO_TRACE="${FUNCTIONS_TO_TRACE} $( echo "${CUR_VALUE}" | tr "," " " )"
       fi
       ;;

    -L | --listfunctions ) 
       LIST_FUNCTIONS_AND_EXIT=${__TRUE}
       ;;

    +L | ++listfunctions ) 
       LIST_FUNCTIONS_AND_EXIT=${__FALSE}
       ;;
       
    -l | --logfile | -l:* | --logfile:* )
       LOGFILE_PARAMETER_FOUND=${__TRUE}
       __getparameter

       if [ "${CUR_VALUE}"x = ""x ] ; then
         LogInfo "Running without a logfile (no value for the parameter \"${CUR_PARAMETER}\" found)"
         LOGFILE=""
       elif [[ ${CUR_VALUE} = -* ]] ; then
         LogInfo "Running without a logfile (no value for the parameter \"${CUR_PARAMETER}\" found)"
         LOGFILE=""
       elif [ "${CUR_VALUE}"x = "none"x ] ; then
         LogInfo "Running without a logfile (the value for the parameter \"${CUR_PARAMETER}\" is \"none\")"
         LOGFILE=""
       else
         LOGFILE="${CUR_VALUE}"
         LogRuntimeInfo "Using the logfile ${LOGFILE}"
       fi
       ;;

    -T | --tee )
       # parameter is already processed - ignore it
       :
       ;;

    --disable_tty_check )
       DISABLE_TTY_CHECK=${__TRUE}
       ;;

    ++disable_tty_check )
       LogWarning "The parameter \"${CUR_PARAMETER}\" is not supported and will be ignored"
#       DISABLE_TTY_CHECK=${__FALSE}
       ;;

    --print_runtime_variables | --print_runtime_vars )
       PRINT_RUNTIME_VARIABLES=${__TRUE}
       ;;

    ++print_runtime_variables | ++print_runtime_vars )
       PRINT_RUNTIME_VARIABLES=${__FALSE}
       ;;

    ++configure )
       CHANGE_CONFIG_PARAMETER=${__FALSE}
       ;;    

    --norcm )
       READ_APPL_PARAMS=${__FALSE}
       READ_APPL_FILE=${__FALSE}
       ;;

    ++norcm )
       READ_APPL_PARAMS=${__TRUE}
       READ_APPL_FILE=${__TRUE}
       ;;
     
    --no_appl_params )
       READ_APPL_PARAMS=${__FALSE}
       ;;

    ++no_appl_params )
       READ_APPL_PARAMS=${__TRUE}
       ;;

    --no_appl_file )
       READ_APPL_FILE=${__FALSE}
       ;;

    ++no_appl_file )
       READ_APPL_FILE=${__TRUE}
       ;;

    -- )
        shift
        break
        ;;

# check for unknown switches
#
    -*=* )
       LogError "Unknown parameter found: ${CUR_PARAMETER}  (wrong separator character? the separator character to use is the colon \":\")"
       PARAMETER_OKAY=${__FALSE}
       ;;

    -* )
       LogError "Unknown parameter found: ${CUR_PARAMETER}"
       PARAMETER_OKAY=${__FALSE}
       ;;


    * ) 
       break
#       LogError "Unknown parameter found: ${CUR_PARAMETER}"
#       PARAMETER_OKAY=${__FALSE}
       ;;
     
  esac
  shift
done

NOT_USED_PARAMETER="$*"
[ $# -ne 0 ] && LogMsg "Not yet used parameter are: \"$*\" "

if [ ${PARAMETER_OKAY} != ${__TRUE} ] ; then
  die 2
fi

if [ ${LIST_FUNCTIONS_AND_EXIT} = ${__TRUE} ] ; then
  LogMsg "Defined functions are :"
  LogMsg "-" "$( typeset +f )"
  die 0
fi

if [ ${PRINT_RUNTIME_VARIABLES} = ${__TRUE} ] ; then
  LogMsg "Defined runtime variables are :"
  print_runtime_variables
  die 0
fi

if [ ${SHOW_SCRIPT_USAGE} = ${__TRUE} ] ; then
  show_script_usage    
  die 0
fi

if [ ${PRINT_VERSION_AND_EXIT} = ${__TRUE}   ] ; then
  LOGFILE=""
  echo "${SCRIPT_VERSION}"
  [ ${VERBOSE} = ${__TRUE} ] && echo "The Script template version is ${__TEMPLATE_VERSION}"
  die 0
fi

if [ "${PREFIX}"x != ""x ] ; then
  LogMsg "-"
  LogMsg "*** Running in dry-run mode -- no changes will be done. The dryrun prefix used is \"${PREFIX}\" "
  LogMsg "-"
fi

# the logfile to use is now fix so activate the logging to the logfile
#
__activate_logfile

# enable trace (set -x) for all requested functions
#
if [ "${FUNCTIONS_TO_TRACE}"x != ""x ] ; then
  __enable_trace_for_functions  "${FUNCTIONS_TO_TRACE}"
fi


# enable verbose mode for all requested functions
#
if [ "${FUNCTIONS_IN_VERBOSE}"x != ""x ] ; then
  __enable_verbose_for_functions  "${FUNCTIONS_IN_VERBOSE}"

#
# define an alias for return to restore the setting for the verbose mode
#
  alias return='eval typeset __RC_\$\$=\$? ; [ "${__VERBOSE}"x != ""x ] && VERBOSE=${__VERBOSE}; eval __return \$__RC_$$; return '

fi
 
  
# ----------------------------------------------------------------------




# ----------------------------------------------------------------------
# main:

# ???
# ----------------------------------------------------------------------
# check if this script is executed by the root user
#
# [ "${CUR_USER_ID}"x != "0"x ] && die 202 "This script must be executed by root only"


# ----------------------------------------------------------------------
# to add variables to the print variable function for DebugShell use
#
# APPLICATION_VARIABLES="${APPLICATION_VARIABLES} "
#
# to define files, directories, or processes to remove at script end 
# or functions to execute at script end use
#
# finish routines that should be executed before the house keeping tasks are done
#   Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
#   blanks or tabs in the parameter are NOT allowed
#
# CLEANUP_FUNCTIONS="${CLEANUP_FUNCTIONS} "
#
# processes that should be killed at script end
#   to change the timeout after kill before issuing a kill -9 for 
#   a process use  pid:timeout
#
# PROCS_TO_KILL="${PROCS_TO_KILL} "
#
# files that should be deleted at script end
#
# FILES_TO_REMOVE="${FILES_TO_REMOVE} "
#
# directories that should be removed at script end
#
# DIRS_TO_REMOVE="${DIRS_TO_REMOVE} "
#
# mount points to umount at script end
#
# MOUNTS_TO_UMOUNT="${MOUNTS_TO_UMOUNT} "
#
# finish routines to executed after all house keeping tasks are done
#   Use "function_name:parameter1[[...]:parameter#] to add parameter for a function
#   blanks or tabs in the parameter are NOT allowed
#
# FINISH_FUNCTIONS="${FINISH_FUNCTIONS} "
#

# ----------------------------------------------------------------------
# init the script return code
#
THISRC=${__TRUE}

#
# ----------------------------------------------------------------------

if [ ${DISABLE_TTY_CHECK} != ${__TRUE} ] ; then
  if [ ${RUNNING_IN_TERMINAL_SESSION} = ${__TRUE} ] ; then
    LogRuntimeInfo "The script is running in a terminal session"
  else
    LogRuntimeInfo "The script is running in a session without terminal"
  fi
else
  LogRuntimeInfo "The tty check is disabled -- the script assumes to run in a terminal session"
fi
LogRuntimeInfo "The name of the shell used is \"${__SHELL}\" "
LogRuntimeInfo "The ksh version of the running shell is ${__KSH_VERSION}"
LogRuntimeInfo "The current hostname is \"${CUR_HOST}\" "
LogRuntimeInfo "The current short hostname is \"${CUR_SHORT_HOST}\" "
LogRuntimeInfo "The current os is \"${CUR_OS}\", the current OS version is \"${CUR_OS_VERSION}\" "
LogRuntimeInfo "The user id executing this script is \"${CUR_USER_NAME}\" (UID is \"${CUR_USER_ID}\") "
LogRuntimeInfo "The group id executing this script is \"${CUR_GROUP_NAME}\" (GID is \"${CUR_GROUP_ID}\") "

LogRuntimeInfo "The real script name is \"${REAL_SCRIPTNAME}\" "
LogRuntimeInfo "The real script directory is \"${REAL_SCRIPTDIR}\" "
LogRuntimeInfo "The working directory is \"${WORKING_DIR}\" "
LogRuntimeInfo "The editor to use is \"${EDITOR}\" "
LogRuntimeInfo "The pager to use is \"${PAGER}\" "

if [ ${RUNNING_ON_A_VIRTUAL_MACHINE} = ${__TRUE} ] ; then
  LogRuntimeInfo "The script is running in a virtual machine"
  LogRuntimeInfo "The hypervisor used is \"${SYSTEM_PRODUCT_NAME}\" "
  LogRuntimeInfo "The vendor of the hypervisor used is \"${HPYERVISOR_VENDOR}\" "
else
  LogRuntimeInfo "The script is running on a physical machine"
fi

LogRuntimeInfo "RUNNING_IN_A_CONSOLE_SESSION is  \"${RUNNING_IN_A_CONSOLE_SESSION}\" "

LogRuntimeInfo "STDOUT_IS_A_PIPE is ${STDOUT_IS_A_PIPE} "
LogRuntimeInfo "STDIN_IS_A_PIPE is ${STDIN_IS_A_PIPE} "
LogRuntimeInfo "STDIN_IS_TTY is  \"${STDIN_IS_TTY}\" "
LogRuntimeInfo "STDOUT_IS_TTY is  \"${STDOUT_IS_TTY}\" "
LogRuntimeInfo "STDERR_IS_TTY is  \"${STDERR_IS_TTY}\" "

LogRuntimeInfo "STDIN is  \"${STDIN_DEVICE}\" "
LogRuntimeInfo "STDOUT is \"${STDOUT_DEVICE}\" "
LogRuntimeInfo "STDERR is \"${STDERR_DEVICE}\" "

# ----------------------------------------------------------------------
# ???



# ----------------------------------------------------------------------
# code to process the RCM entries
#
# Note:
#
# This is only sample code - delete if not used!
#
if [ ${READ_APPL_PARAMS} = ${__TRUE} ] ; then

  LogMsg "Retrieving the RCM entries now ..."

  Read_APPL_PARAMS_entries || die 10 "Error reading the entries from the RCM"

  [ ${RCM_APPL_PARAMS_KEY[0]} = 0 ] &&  die 15 "No RCM entries found"

#
# RCM_APPL_PARAMS_KEY[0] - no of entries found
#
# RCM_APPL_PARAMS_KEY[n] - PARAMETER field for the nth entry
# RCM_APPL_PARAMS_VAL[n] - VALUE field for the nth entry
#
  
  i=0
  while [ $i -lt ${RCM_APPL_PARAMS_KEY[0]} ] ; do
    (( i = i + 1 ))
  
    CUR_KEY="${RCM_APPL_PARAMS_KEY[$i]}"
    CUR_VALUE="${RCM_APPL_PARAMS_VAL[$i]}"
  
    LogMsg "  Processing the entry \"${CUR_KEY} = ${CUR_VALUE}\" ..."
  
    case ${CUR_KEY} in
  
      "#"* )
        LogMsg "Comment entry found: \"${CUR_KEY}\" = \"${CUR_VALUE}\" and ignored"
        ;;
  
      "VAR:"* )
        LogMsg "  --- Variable assignment found in the RCM:"
        VAR_NAME="${CUR_KEY#*:}"
        LogMsg "  --- Current value of ${VAR_NAME} is: \"$( eval echo \$${VAR_NAME} )\" "
        set -x
        eval ${VAR_NAME}="${CUR_VALUE}"
        set +x
        LogMsg "  --- Current value of ${VAR_NAME} is now: \"$( eval echo \$${VAR_NAME} )\" "
        ;;

# 
# ... add code here to process the entries
#
  
      * )
        LogWarning "Unknown RCM APPL_PARAMS entry found: \"${CUR_KEY}\" = \"${CUR_VALUE}\" "
        ;;
    esac
    
  done
  
fi

# ----------------------------------------------------------------------
# read files from APPL_FILE if requested
#
# Note:
#
# This is only sample code - delete if not used!
#
if [ ${READ_APPL_FILE} = ${__TRUE} ] ; then

  LogMsg "Reading the files from Jamaica ...."
  
  Retrieve_file_from_Jamaica "newrelic.yml" "${AGENT_CONFIG_FILE_FROM_JAMAICA}"
  if [ $? -eq ${__FALSE} ] ; then
    LogMsg "No config file found in Jamaica"
  else
    LogMsg "Config file from Jamaica stored in the local file \"${AGENT_CONFIG_FILE_FROM_JAMAICA}\" "
#...
  fi
fi

# ----------------------------------------------------------------------
#


die ${THISRC}

# ----------------------------------------------------------------------
#

