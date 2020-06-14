#!/usr/bin/ksh
print ""
print "Network Driver Configuration..."
print "==============================="
print ""
#
print "link status is...     (1 up, 0 down)"
ndd -get /dev/hme link_status
print "link speed is...     (1 100, 0 10)"
ndd -get /dev/hme link_speed
print "link mode is...     (1 full, 0 half)"
ndd -get /dev/hme link_mode
print ""
