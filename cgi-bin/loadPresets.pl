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
binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib $Bin;
use lib "../falcon/lib";
use lib "../falcon/src";

use Log::Log4perl;
Log::Log4perl->init_once("log.conf");

my $log = Log::Log4perl->get_logger("falcon");
$log->info("started");

use WebInterface::Controller;
use WebInterface::Utils;

my $controller = WebInterface::Controller->new();
my $utils = WebInterface::Utils->new();

my $return=$controller->listPresetsHTML();

print "Content-type: text/html\n\n";

if (!$return ){

    my $error= $controller->getError();
    print $error."\n";
    exit 0;
    
}

# Presets are already in HTML.

#$utils->printHTML($return); 

for my $line (@$return){

    print $line;
	
}
1;
