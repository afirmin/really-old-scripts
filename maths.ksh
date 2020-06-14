#!/usr/bin/ksh

usage () {
print "
UX: maths: ERROR: invalid syntax.
usage:	maths y + z	(addition)
	maths y - z	(subtraction)
	maths y / z	(division)
	maths y x z	(multiplication)

"
}

if [[ $# -lt 3 || $# -gt 3 ]]
then
	usage
	exit 1
fi

# if [[ $3 -gt 0 || $3 -lt 0 ]]
# then
# 	:
# else
# 	print "
# Cannot use 0 !!!"
# 	usage
# 	exit 1
# fi


print $1 $2 $3 | awk '{
        fred=0
        if ( $2 == "+" ) {
                fred = $1 + $3
                print fred
                break
        }
        if ( $2 == "-" ) {
                fred = $1 - $3
                print fred
                break
        }
        if ( $2 == "/" ) {
                fred = $1 / $3
                print fred
                break
        }
        if ( $2 == "x" ) {
                fred = $1 * $3
                print fred
                break
        }
        print ""
        print "Invalid Operator"
	exit 1
}'

if [[ $? -gt 0 ]]
then
	usage
	return 1
fi

