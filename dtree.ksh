#!/bin/ksh

# set -x

if [[ $# -eq 1 ]]
then
	dir=$1
else
	dir=`pwd`
fi

if [[ ! -d $dir ]]
then
	print "Invalid directory - please enter a valid directory"
	exit
fi

findtype="-type d"
echo "Tree for directory $dir and its files:"

echo "
$dir"

find $dir $findtype -print |
tr / \\001 | sort -f | tr \\001 / |
sed -e s@\^$dir@@ -e /\^$/d -e 's@[^/]*/@------>@g'

# sed -e s@\^$dir@@ -e /\^$/d -e 's@[^/]*/@ "	@g'
