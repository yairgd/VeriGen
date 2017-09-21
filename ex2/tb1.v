module tb1; 
reg clk, spi_clk,reset, enable; 
wire [3:0] count; 
reg [SPI_WORDLEN-1:0] data_out;
reg [SPI_WORDLEN-1:0] data_in;
reg rst;
reg cs;


reg [7:0]cnt;

time delay;


localparam SPI_WORDLEN=16;

initial 
begin
	$dumpfile("test.vcd");
	$dumpvars(0,tb1);
	data_out[15:8] = 8'b01000000;
	data_out[7:0] = 8'hff;

	reset=1;
	#5
	reset=0;

	cs=1;
	clk = 0;
	spi_clk = 0;
	cnt = 0;
	enable = 0;

	#1700

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
assign mosi = data_out[SPI_WORDLEN-1];




always @(posedge clk)
begin:mosi
	if (cs==1'b0  ) begin  
		data_out <={data_out[SPI_WORDLEN-2:0] ,1'b0 };
		cnt<=cnt+1;
		if (cnt==SPI_WORDLEN+2) begin
			cs=1;
			#5000
			$finish;
		end
	end
end





spislave #(16) spislave_ins (.miso(),.mosi(data_out[SPI_WORDLEN-1]), .cs(cs), .spi_clk(spi_clk)  ,.clk(clk),.rst(reset));


endmodule
