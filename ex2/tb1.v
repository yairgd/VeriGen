module tb1; 
reg clk, spi_clk,reset, enable; 
wire [3:0] count; 
reg [23:0] data_out;
reg [23:0] data_in;
reg rst;
reg cs;


reg [7:0]cnt;

time delay;

initial 
begin
	$dumpfile("test.vcd");
	$dumpvars(0,tb1);
	data_out[23:0]=24'h123456;
	clk = 0;
	spi_clk = 0;
	cnt = 0;
	reset = 0; 
	enable = 0;
	cs =1;

	#5  rst = 0;
	#5 rst = 1;
	#5 rst = 0;

	delay = 121; //$dist_uniform(seed, 50, 100);
	#delay;
	cs = 0;

end 



always
begin
	#10 clk = ~clk; 
	#80 spi_clk = ~spi_clk;
end
assign mosi = data_out[23];


wire cs_sync;


always @(posedge clk)
begin:mosi
	if (cs_sync==1'b0  ) begin  
		data_out[23:1]<={data_out[22:0], 1'b0};
		cnt<=cnt+1;
		if (cnt==35) begin
			cs=1;
			#5000
			$finish;
		end
//	end else begin
	//	$finish;
	end
end



wire cs_fall,cs_rise;
edge_detect edd_cs ( .async_sig(cs), .clk(clk),.rise(cs_rise),.fall(cs_fall),.rst( 0) );


spislave spislave_ins (.miso(),.mosi(data_out[23]),.cs_rise ( cs_rise  ), .cs_fall(cs_fall),.cs_sync(cs_sync), .spi_clk(spi_clk)  ,.clk(clk));


endmodule
