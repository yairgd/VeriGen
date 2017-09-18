package VeriGen::OutPort
use VeriGen::Interface

use strict;
use warnings;

@ISA = qw (Interface)

#use enum qw(OutPot,InPort);

sub new {
	my ($class,$args)  = @_;
	my $self  =  {
		name   => $args->{name} || 'HelloModule',
		#	type   => () 
	};

	return bless $self,$class;
}
