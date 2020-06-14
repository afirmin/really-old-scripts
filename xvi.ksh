#!/usr/bin/ksh
#
##################################################################################################
#
# Name:		xvi
#
# Description:	An X based version of vi.
#		Somply makes a call to start an xterm window and runs the command vi.
#		Pretty colours changable by editing -bg and -fg.
#
# Parameters:	1.  Name of the file to be edited.
#
# Author:	Anthony Firmin, FCCL
#
# Date:		11/6/02
#
#
##################################################################################################

export DISPLAY=166.1.100.58:0

/usr/openwin/bin/xterm -geom 132x56 -sb -sl 2048 -title xvi -bg wheat -fg black -cr red -e vi $1 &
