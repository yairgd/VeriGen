`timescale 1ns / 1ps

module tb1; 
reg clk, spi_clk,reset, enable; 
wire [3:0] count; 
reg [SPI_WORDLEN-1:0] data_out;
reg [SPI_WORDLEN-1:0] data_in;
reg cs;


reg [7:0]cnt;

time delay;


localparam SPI_WORDLEN=16;
localparam ADDR_WIDTH = 7;
localparam DATA_WIDTH = 8;
localparam SELECT_WIDTH = 1;

initial 
begin
	$dumpfile("test.vcd");
	$dumpvars(0,tb1);
	data_out[15:8] = 8'b10000001;
	data_out[7:0] = 8'hff;

	reset=0;
	#5
	reset=1;
	#1500
	reset=0;

	clk = 0;
	spi_clk = 0;
	cnt = 0;
	enable = 0;


end 


reg [4:0] spi_cnt;
initial  spi_cnt =0;
always
begin
	#10 
	clk = ~clk;
	#3
	if (spi_cnt==8) begin
		spi_clk=~spi_clk;
		spi_cnt =0;
	end else begin
		spi_cnt=spi_cnt+1;
	end

end

assign mosi = data_out[SPI_WORDLEN-1];




always @(posedge spi_clk or posedge reset)
begin:mosi
	if (reset==1) begin
		cs<=1;
		cnt<=0;
		#5000;
	end else if (cnt<SPI_WORDLEN) begin
		data_out <={data_out[SPI_WORDLEN-2:0] ,1'b0 };
		cs<=1'b0;
		cnt<=cnt+1;
	end else begin
		cs<=1;
		#5000
		$finish;
	end
end







wire  [ADDR_WIDTH-1:0]   wbm_adr_o;    // ADR_O() address output
wire  [DATA_WIDTH-1:0]   wbm_dat_i;    // DAT_I() data in
wire  [DATA_WIDTH-1:0]   wbm_dat_o;    // DAT_O() data out
wire 			 wbm_we_o;     // WE_O write enable output
wire  [SELECT_WIDTH-1:0] wbm_sel_o;    // SEL_O() select output
wire  		         wbm_stb_o;    // STB_O strobe output
wire			 wbm_ack_i;    // ACK_I acknowledge input
wire			 wbm_err_i;    // ERR_I error input
wire			 wbm_rty_i;    // RTY_I retry input
wire 			 wbm_cyc_o;    // CYC_O cycle output

spislave #(16) spislave_ins (.miso(),.mosi(data_out[SPI_WORDLEN-1]), .cs(cs), .spi_clk(spi_clk)  ,.clk(clk),.rst(reset),
	.wbm_adr_o(wbm_adr_o),.wbm_dat_i(wbm_dat_i),.wbm_dat_o(wbm_dat_o),.wbm_we_o(wbm_we_o),.wbm_sel_o(wbm_sel_o),
	.wbm_ack_i(wbm_ack_i),.wbm_err_i(wbm_err_i),.wbm_rty_i(wbm_rty_i),.wbm_cyc_o(wbm_cyc_o) );




endmodule
