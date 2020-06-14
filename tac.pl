#!/usr/bin/perl
#	tac - cat in reverse

$filenumber = @ARGV;
$mycount = 0;

until ( $mycount == $filenumber ) {

	$filename = $ARGV[$mycount];

	unless (open(MYFILE, $filename)) {
		die ("cannot open input file $filename\n");
	}

	@input = <MYFILE>;

	$length = @input;

	until ( $length == 0 ) {
		$length--;
		if ( $filenumber > 1 ) {
			print ("$filename: @input[$length]");
		}else{
			print (@input[$length]);
		}
	}

	$mycount++;

}
