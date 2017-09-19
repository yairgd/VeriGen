package VeriGen::Module
use Verigen::OutPort
use Verigen::InPort

#http://perltricks.com/article/25/2013/5/20/Old-School-Object-Oriented-Perl/

use strict;
use warnings;


sub new {
	my ($class,$args)  = @_;
	my $self  =  {
		name   => $args->{name} || 'HelloModule',
		ifs    => () 
	};
	push $self =>{ifs} , OutPort->new("counter");
	push $self =>{ifs} , InPort->new ("rst");
	push $self =>{ifs} , InPort->new ("clk");
	return bless $self,$class;
}



sub add_integace {
    my $self = shift;
    my $area = $self->{length} * $self->{width};
    return $area;
}

1;
__END__


always @(posedge $clk)
begin:counter
	if ($rst==1'b10) begin
		$counter<=8'b0;
	end else begin
		$counter<=$counter + 1		
	end
end


