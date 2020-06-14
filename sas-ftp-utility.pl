#!/usr/bin/perl
#
#=====================================================================================
# Name:         	SAS FTP Utility.pl
#=====================================================================================
# Author:       	Anthony Firmin
#=====================================================================================
# Date:         	15/2/02
#=====================================================================================
# Description:  	V.1.0
# 			The purpose of this utility is to transfer SAS code files from
#			the PC to the Zantos server to be run at a predetermined time
#			chosen by the user.
#			The first window to be displayed allows the user to select the
#			SAS batch method which determines the name of the file on the
#			server which in itself is run at a time dependant on the file
#			name.  When the method has been selected it is displayed at
#			the top of the window.
#			The user then chooses the SAS code file to be transfered via a 
#			FileSelect module and this is then displayed at the top of the
#			main screen.
#			The user can then chose transfer the file to the server which
#			uses the Net::FTP module.
#
#=====================================================================================
# Change History:	V.n.n	Name		Date			
#			
#
#
#=====================================================================================
######################################################################################
################################## MODULES ###########################################
######################################################################################

use warnings;
use strict;
use Tk;
use Tk::FileSelect;
use Net::FTP;
use File::Copy;

######################################################################################
############################### END OF MODULES #######################################
######################################################################################

######################################################################################
############################# VARIABLES & ARRAYS #####################################
######################################################################################

#  These variables need to be changed depending on the user!!!

my $username = "afirmin";
my $password = "dogbert02";
my $start = '/export/home/afirmin';

###############################################################

# static variables...

my $local_file = "";
my $transfer_file = "";
my $temp_file = "";
my $svr_file = "";
my $status = "No Batch Method selected\n";
my $message = "No SAS Code File entered\n";
my @files = (	'One-off overnight run', 
		'Daytime runs', 
		'Weekly Sunday night run',
		'Weekly Monday night run',
		'Weekly Tuesday night run',
		'Weekly Wednesday night run',
		'Weekly Thursday night run',
);

######################################################################################
######################## END OF VARIABLES & ARRAYS ###################################
######################################################################################

######################################################################################
########################## MAIN WINDOW PROCESSING ####################################
######################################################################################

my $mw = MainWindow->new or die 'Cannot create main window';
$mw->geometry("500x400+100+100");
$mw->title('SAS File Transfer Utility V.1.0');

# insert widgets into $mw

my $label1 = $mw->Label(-textvariable => \$status);
my $label2 = $mw->Label(-textvariable => \$message);
my $enter = $mw->Label(-text => 'Select the Batch Method');

my $lb = $mw->Listbox(	-height => '7', 
			-width => '30', 
			-selectmode => 'browse');
$lb->insert('end', @files);

my $show = $mw->Button(		-text => 'Select Batch Method', 
				-command => [\&display]);
my $select = $mw->Button(	-text => 'Select SAS Code File', 
				-command => [\&select]);
my $transfer = $mw->Button(	-text => 'Transfer the Code File', 
				-command => [\&transfer]);
my $exit = $mw->Button(		-text => 'Exit', 
				-command => [$mw => 'destroy']);

$label1->pack;
$label2->pack;
$enter->pack;
$lb->pack;
$show->pack(qw/-expand yes/);
$select->pack(qw/-expand yes/);
$transfer->pack(qw/-expand yes/);
$exit->pack(qw/-expand yes -pady 10/);

# main part of the program

MainLoop;

######################################################################################
##################### END OF MAIN WINDOW PROCESSING ##################################
######################################################################################

######################################################################################
############################### SUBROUTINES ##########################################
######################################################################################
#
# Display the options for the SAS batch method and allow the user to select the 
# method...
#
sub display {
	my @selections = $lb->curselection;
	$status = "Chosen SAS batch method: \n\n";
	foreach (@selections) {
		$svr_file = $lb->get($_);
		$status .= $svr_file . "\n";
	}
	$lb->selectionClear(0, 'end');
	if ( $svr_file eq "One-off overnight run" ) {
		$svr_file = "sas.file";
	}
	if ( $svr_file eq "Daytime runs" ) {
		$svr_file = "sas.day";
	}
	if ( $svr_file eq "Weekly Sunday night run" ) {
		$svr_file = "sas.mon";
	}
	if ( $svr_file eq "Weekly Monday night run" ) {
		$svr_file = "sas.tue";
	}
	if ( $svr_file eq "Weekly Tuesday night run" ) {
		$svr_file = "sas.wed";
	}
	if ( $svr_file eq "Weekly Wednesday night run" ) {
		$svr_file = "sas.thu";
	}
	if ( $svr_file eq "Weekly Thursday night run" ) {
		$svr_file = "sas.fri";
	}
}

######################################################################################
#
# Display the select SAS code "FileSelect" window and allow user to select a file...
#
sub select {
	my $fselect = $mw->FileSelect(-directory => $start);
	$fselect->geometry("700x500");	
	$local_file = $fselect->Show;
	if ( $local_file eq "" ) {
		$message = qq{No file entered\n};	
	} else {
		$message = qq{You chose '$local_file'\n};
	}
}

######################################################################################
#
# Having made the selections, transfer the file to the server using "Net::FTP"...
#
sub transfer {

	my $tl = $mw->Toplevel;

#
# The following two lines are commented out, if there is a problem transferring
# files to the server, uncomment these lines save the file and re-run the utility.
# the output will appear in the MS-DOS window.
#
#	print "\nTransferring... $local_file\n";
#	print "\nTo remote file... $svr_file\n";

	if ( $svr_file eq "" )
	{
		die $tl->Button(-height => '10',
				-width => '40',
				-background => "red",
				-text => 'You need to select a batch method', 
				-command => sub {$tl->destroy})->pack;
	}	

	if ( $local_file eq "" )
	{
		die $tl->Button(-height => '10',
				-width => '40',
				-background => "red",
				-text => 'You need to select a SAS Code file', 
				-command => sub {$tl->destroy})->pack;
	}	


	my $ftp = Net::FTP->new("zantos")
		or die $tl->Button(	-height => '7',
					-width => '30',
					-background => "red",
					-text => 'FTP Cannot connect', 
					-command => sub {$tl->destroy})->pack;

	$ftp->login($username, $password)
		or die $tl->Button(	-height => '7',
					-width => '30',
					-background => "red",
					-text => 'FTP Cannot login', 
					-command => sub {$tl->destroy})->pack;

	$ftp->put($local_file, $svr_file)
		or die $tl->Button(	-height => '7',
					-width => '30',
					-background => "red",
					-text => 'FTP Cannot Transfer Files', 
					-command => sub {$tl->destroy})->pack;

	$ftp->quit()
		or die $tl->Button(	-height => '7',
					-width => '30',
					-background => "red",
					-text => 'FTP Cannot quit', 
					-command => sub {$tl->destroy})->pack;

	$tl->title('Success!!');
	$tl->geometry("200x50-400-300");
	$tl->Button(	-height => '7',
			-width => '30',
			-background => "aquamarine",
			-text => 'File transfered successfully', 
			-command => sub {$tl->destroy})->pack;

}

######################################################################################
############################ END OFSUBROUTINES #######################################
######################################################################################
