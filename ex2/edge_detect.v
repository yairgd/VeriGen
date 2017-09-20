module edge_detect (input async_sig,
	input clk,
	input rst,
	output reg rise,
	output reg fall);

reg [1:3] resync;

initial resync = 0;
always @(posedge clk)
begin
	// detect rising and falling edges.
	rise <= resync[2] & !resync[3];
	fall <= resync[3] & !resync[2];
	// update history shifter.
	resync <= {async_sig , resync[1:2]};


end

endmodule
