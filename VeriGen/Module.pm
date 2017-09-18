package VeriGen::Module
use Verigen::OutPort
use Verigen::InPort



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


always @(posedge clk)
begin:counter
	if (reset==1'b10) begin
		$counter<=
	end else begin
			
	end
end


