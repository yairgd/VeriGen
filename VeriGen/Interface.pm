package VeriGen::Interface

use VeriGen::PortsIO

use strict;
use warnings;

sub new {
	my ($class,$args)  = @_;
	my $self  =  {
	};

	return bless $self,$class;
}
