#!/usr/bin/ksh

usage() {

print "
UX: tgrep: ERROR: invalid syntax.
usage:  tgrep  text-string [ directory ]
"
exit 1

}


dir_marker=0
current_dir=$(pwd)

# Check the correct number of parameters have been passed...

if [[ $# -lt 1 || $# -gt 2 ]]
then
	usage
fi

# The first parameter will definitely be the search string, 
# no way of really verifying it so set it...

search_string=$1

if [[ $# -eq 2 ]]
then
	file_dir=$2
	dir_marker=1
else
	file_dir=$(pwd)
fi

# Now we need to see if the second parameter is a directory...

if [[ -d $file_dir ]]
then
	:
else
	print "Directory does not exist."
	usage	
fi

if [[ $dir_marker -eq 1 ]]
then
	grep $search_string $(file $file_dir/* | egrep "script|text" | awk '{print $1}'| sed -e 's/://g')
else
	grep $search_string $(file * | egrep "script|text" | awk '{print $1}'| sed -e 's/://g')
fi
