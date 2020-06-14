#!/bin/sh

mt -f /dev/rmt/0 rew

usr/sbin/ufsdump 0fu /dev/rmt/0n /
usr/sbin/ufsdump 0fu /dev/rmt/0n /var
usr/sbin/ufsdump 0fu /dev/rmt/0n /export/home

mt -f /dev/rmt/0 rewoffl

date
