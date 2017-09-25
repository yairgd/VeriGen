`timescale 1ns / 1ps
//iverilog tb1.v spisalve.v  version.v
module tb1; 
reg clk, spi_clk,reset, enable; 
wire [3:0] count; 
reg [SPI_WORDLEN-1:0] data_out;
reg [SPI_WORDLEN-1:0] data_in;
reg cs;


reg [7:0]cnt;

time delay;


localparam SPI_WORDLEN=32;
localparam ADDR_WIDTH = 7;
localparam DATA_WIDTH = 8;
localparam SELECT_WIDTH = 1;

initial 
begin
	$dumpfile("test.vcd");
	$dumpvars(0,tb1);
	data_out=0;
	data_out[23:16] = 8'h56;
//	data_out[31:24] = 8'b00000001;
	data_out[31:24] = 8'b10000010;

	clk = 0;
	spi_clk = 0;
	cnt = 0;
	enable = 0;
	cs=1;

	#50000;
end 


reg [4:0] spi_cnt;
reg rst_done;
initial  spi_cnt =0;
initial rst_done=0;
always
begin
	#10 
	clk = ~clk;
	/* emulate sync reset with clk */
	if (rst_done==0) begin
		reset=1;
		rst_done=1;
	end else begin
		reset=0;
	end
//	#3
	if (spi_cnt==8) begin
		spi_clk=~spi_clk;
		spi_cnt =0;
	end else begin
		spi_cnt=spi_cnt+1;
	end

end

assign mosi = data_out[SPI_WORDLEN-1:31];
//reg mosi;
//initial mosi=0;
reg [6:0] cnt_cs;

assign spi_clk_0 = spi_clk & (cs==0);
always @(posedge spi_clk or posedge reset)
begin:mosi1
	if (reset==1) begin
	//	cs<=1;
		cnt<=0;
		cnt_cs<=5;
	//	#5000;
		cs<=0;
	end else if (cnt<SPI_WORDLEN) begin
	//	if (cnt_cs==1) begin
	//		cnt_cs<=cnt_cs-1;

	//	end else if (cnt_cs<=1) begin 
		//	{mosi ,data_out }<={data_out[SPI_WORDLEN-1:0] ,1'b0 };
		//	cs<=1'b0;
			

			data_out<={data_out[SPI_WORDLEN-2:0] ,1'b0 };
			cnt<=cnt+1;
	//	end else begin
	//		cnt_cs<=cnt_cs-1;
	//		cs<=1'b0;
	//	end
	end else begin
		#1000;
		cs<=1;
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

//reg mosi;
spislave #() spislave_ins (
	.miso(),.mosi(mosi), .cs(cs), .spi_clk(spi_clk_0)  ,.clk(clk),.rst(reset),
	.wbm_adr_o(wbm_adr_o),.wbm_dat_i(wbm_dat_i),.wbm_dat_o(wbm_dat_o),.wbm_we_o(wbm_we_o),.wbm_sel_o(wbm_sel_o),
	.wbm_ack_i(wbm_ack_i),.wbm_err_i(wbm_err_i),.wbm_rty_i(wbm_rty_i),.wbm_cyc_o(wbm_cyc_o),.wbm_stb_o ( wbm_stb_o) );




version  #()   ver_inst (
	.clk(clk),.rst(reset),.addrmask(4'b0000),.adr_i (wbm_adr_o), .dat_i (wbm_dat_o),.dat_o (wbm_dat_i),.sel_i(1'b0),
	.we_i (wbm_we_o), .stb_i (wbm_stb_o), .ack_o (wbm_ack_i),.cyc_i (1'b0) ); 



endmodule
