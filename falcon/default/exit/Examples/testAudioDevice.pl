#!/usr/bin/perl
# $Id$
#
# WEB INTERFACE and Controll application for an headless squeezelite
# installation.
#
# Best used with Squeezelite-R2 
# (https://github.com/marcoc1712/squeezelite/releases)
#
# Copyright 2016 Marco Curti, marcoc1712 at gmail dot com.
# Please visit www.marcoc1712.it
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
################################################################################

use strict;
use warnings;

use JSON::PP;

my %commandHash=();
my $cmd= \%commandHash;

##########################################################
#
# Insert here the command to use for your AudioDevice, i.e.
#
###########################################################

$cmd->{'front:CARD=NVidia_1,DEV=0'} = 'cat /proc/asound/NVidia_1/codec#0';
$cmd->{'hw:CARD=NVidia_1,DEV=0'} = 'cat /proc/asound/NVidia_1/codec#0';
$cmd->{'front:CARD=I82801AAICH,DEV=0'} = 'cat /proc/asound/I82801AAICH/codec97#0/ac97#0-0';
$cmd->{'hw:CARD=I82801AAICH,DEV=0'} = 'cat /proc/asound/I82801AAICH/codec97#0/ac97#0-0';
$cmd->{'hw:CARD=Intel,DEV=0'} = 'cat /proc/asound/card0/codec#0';
$cmd->{'front:CARD=X20,DEV=0'} = 'cat /proc/asound/J20/stream0';
$cmd->{'hw:CARD=J20,DEV=0'} = 'cat /proc/asound/J20/stream0';
$cmd->{'hw:CARD=io2,DEV=0'} = 'cat /proc/asound/io2/stream0';
$cmd->{'iec958:CARD=io2,DEV=0'} = 'cat /proc/asound/io2/stream0';

#... and so on.

#############################################################
#
# You could even rewrite _getTestCommand
#
#############################################################

sub _getTestCommand{

	my $audioDevice = shift;

	if ($cmd->{$audioDevice}){ 

		return $cmd->{$audioDevice};
	}
	return undef;
}
################################################################################

# the return MUST be in form of an hash with three elements:
#
# 'status'  = values "ok", "ERROR", "WARNING". Any other is "INFO".
# 'message' = status message displayed to the user, MUST be a valid UTF_8 string,
#             please avoid special and control characters.
# 'data'		= ARRAY of valid UTF_8 string containing the command result, 
#             contents is validated only by the application.
#
# any other element is discharged.
#
# here the PROTOTYPE:

my @data=();
my $out={};
$out->{'status'}='ok';
$out->{'message'}="";
$out->{'data'}=\@data;

#tobe converted in JSON format and printed out.

#look for the command to be executed;
if (!scalar @ARGV == 1) {

	$out->{'status'}='ERROR';
	$out->{'message'}="Missing audio device";
	
	printJSON($out);
	exit 0;
	
}
my $audiodevice = $ARGV[0];
my $command = _getTestCommand($audiodevice);

if (!$command) {
	
	$out->{'status'}='WARNING';
	$out->{'message'}="Unable to find valid test command for device: $audiodevice";
	
	#push @data, "WARNING: Unable to find test command for device: $audiodevice";
	
	printJSON($out);
	exit 0;

}
#execute the command
my @rows = `$command 2>&1`;

#result validation and return.
validateResult(\@rows);

sub validateResult{
	my $result = shift;

	if (! $result || (scalar @$result == 0)){
		$out->{'status'}="WARNING";
		$out->{'message'}="$command returned no info";
			
		printJSON($out);
		exit 0;
	}
	$out->{'data'}=$result;
	printJSON($out);
	exit 1;
}

###############################################################################
# This code should be in a library, please do not modify it.
###############################################################################

sub trim {
	my ($val) = shift;

  	if (defined $val) {

    	$val =~ s/^\s+//; # strip white space from the beginning
    	$val =~ s/\s+$//; # strip white space from the end
    }
	if (($val =~ /^\"/) && ($val =~ /\"+$/)) {#"
	
		$val =~ s/^\"+//; # strip "  from the beginning
    	$val =~ s/\"+$//; # strip "  from the end 
	}
	if (($val =~ /^\'/) && ($val =~ /\'+$/)) {#'
	
		$val =~ s/^\'+//; # strip '  from the beginning
    	$val =~ s/\'+$//; # strip '  from the end
	}
    
    return $val;         
}

sub printJSON{
	my $in = shift;
	print  encode_json $in;
}
1;

