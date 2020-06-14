#!/bin/sh
# ---------------------------------------------------------------------------
# Script    : family
# Author    : Sir Anthony Barnsley MBE
# Date      : Jun 1993
# Desc      : Produce complete process list for specified process
# Calls     :
# Called by : Command Line
# Version   : 1.0
# Amendments: 
# ---------------------------------------------------------------------------

# Validate Usage
# ie. Ensure pid is provided, it is numeric, and is not 1.

   if [ $# -ne 1 -o "`expr \"$1\" : \"\([0-9]*\)\"`" != "$1" ]
   then
      echo "\nUsage :  $0 pid\n"
      exit 1
   elif [ $1 = 1 ]
   then
      echo "\nProcess id 1 is the init process.\n"
      exit 1
   fi

# Set Variables

   family=/tmp/family$$
   procs=/tmp/procs$$
   PID=$1
   PPID=$PID
   CHILD=$PID

# Put process list in file, to avoid repeated ps's, and clear file
# to contain process list

   ps -ef >$family
   >$procs

# Get parent processes down to init ( 1 ), and all child processes.
# It is quicker to use ps -p$PID than repeated greps for parents.
# However, we need to use grep to obtain any child processes.

# Store relevant line from ps into variable $line.  If $line is then empty,
# there is no such process.  If $line is over 80 characters long ( >1 line )
# there are multiple children, so issue warning, and abandon further search.

   until [ $PPID = 1 ]
   do
      line=`ps -fp$PPID | fgrep -v UID`
      if [ "${line}" ]
      then
         PPID=`echo $line | cut -d" " -f3`
         if [ `expr $PPID : '.*'` -gt 5 ]
         then
            PPID=`echo $line | cut -c14-18`
         fi
      else
         PPID=1
         continue
      fi
      echo $line >>$procs
   done

# Get child processes
# Use a check variable $CHECK to stop once the final child is found.

   CHECK="0"
   while [ $CHECK != $CHILD ]
   do
      CHECK=$CHILD
      line=`egrep "^.............. ?$CHILD" $family`
      if [ "${line}" ]
      then
         if [ `echo $line | wc -c` -gt 200 ]
         then
            echo "\nProcess $CHILD has many children. \c"
            echo " Please be more specific.\n"
            continue
         else
            CHILD=`echo $line | cut -d" " -f2`
            echo $line >>$procs
         fi
      fi
   done

# Check whether any such processes exist, ie has file procs been created ?

   if [ ! -s $procs ]
   then
      echo "\n$PID :  No such process.\n"
      exit 1
   fi

# Sort output file into numeric order

   sort -o $family +1n -2 $procs

# When the ps lines have been put into the temporary file, the tabulation is
# lost, so use awk to sort it.  Also, the PPID column runs into the C column
# on ps output, so separate these.

   awk '
      BEGIN { printf("\n    UID    PID  PPID   STIME   TTY    TIME COMMAND\n")}
      {
      if ( length($3) > 5 )
         { fields = 7
           printf("%-8s %5d %5d  %8s %-4s %6s ", \
           $1, $2, substr($3,1,5), $4, $5, $6 ) }
      else
         { fields = 8
           printf("%-8s %5d %5d  %8s %-4s %6s ", \
           $1, $2, $3, $5, $6, $7 ) }
      for ( i = fields; i<= NF; i++ )
        { printf $i" " }
      printf "\n" 
      }
      END { printf "\n" }' $family

# Cleanup

   rm -f $family $proc
