#!/usr/bin/ksh
#
/usr/local/bin/ndd_settings
print "==============================="
print "Setting hme0 to 100 full-duplex"
print "==============================="
ndd -set /dev/hme instance 0
ndd -set /dev/hme adv_100fdx_cap 1
ndd -set /dev/hme adv_100hdx_cap 0
ndd -set /dev/hme adv_10fdx_cap 0
ndd -set /dev/hme adv_10hdx_cap 0
ndd -set /dev/hme adv_autoneg_cap 0
print ""
print "==============================="
print "Set hme0 to 100 full-duplex"
print "==============================="
print ""
print "Waiting for card reset to complete..."
print ""
sleep 10
/usr/local/bin/ndd_settings
