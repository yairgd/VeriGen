#!/usr/bin/perl
package PortsIO;

use strict;
use warnings;
use enum qw( OutPot InPort InOutPort);

#require Exporter;
#@ISA = qw(Exporter);
#@EXPORT = qw(new);


sub new {
	my ($class,$args)  = @_;
	my $self  =  {
		name   => $args->{name} || 'NameIsNotSet',
		msb    => $args->{msb} || 0,
		lsb    => $args->{lsb} || 0
#		type   => $args->{type} || OutPort
	};

	return bless $self,$class;
}
1;

