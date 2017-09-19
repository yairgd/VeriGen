use lib '../';
use VeriGen::PortsIO;
#@ISA = qw (PortsIO);
PortsIO->new ( {name=>"clk"} );
