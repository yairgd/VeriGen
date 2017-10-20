`timescale 1ns / 1ps
//iverilog tb1.v spisalve.v  version.v
module tb1; 
reg clk, spi_clk,reset, enable; 
wire [3:0] count; 
reg [SPI_WORDLEN-1:0] data_out;
reg [SPI_WORDLEN-1:0] data_in;
//reg cs;


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
//	data_out[31:24] = 8'b10000010;
	data_out[31:24] = 8'haa;



	clk = 0;
	spi_clk = 0;
	cnt = 0;
	enable = 0;
//	cs=1;

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
	if (spi_cnt==4) begin
		spi_clk=~spi_clk;
		spi_cnt =0;
	end else begin
		spi_cnt=spi_cnt+1;
	end

end

//assign mosi = data_out[SPI_WORDLEN-1:31];



/*
reg mosi_o,mosi;
always @(posedge spi_clk or posedge reset)
begin:mosi1
	if (reset==1) begin
	//	spi_clk=1;
		cs<=1;
		cnt<=0;
		#123;
	end else if (cnt<SPI_WORDLEN) begin
		{mosi ,data_out }<={data_out[SPI_WORDLEN-1:0] ,1'b0 };
		mosi_o <=mosi;
		cs<=1'b0;
		cnt<=cnt+1;
	end else begin
		cs<=1;
		#5000
		$finish;
	end
end

*/





wire  [ADDR_WIDTH-1:0]   spi_adr;    // ADR_O() address output
wire  [DATA_WIDTH-1:0]   spi_dat_i;    // DAT_I() data in
wire  [DATA_WIDTH-1:0]   spi_dat_o;    // DAT_O() data out
wire 			 spi_we;     // WE_O write enable output
wire  [SELECT_WIDTH-1:0] spi_sel;    // SEL_O() select output
wire  		         spi_stb;    // STB_O strobe output
wire			 spi_ack;    // ACK_I acknowledge input
wire			 spi_err;    // ERR_I error input
wire			 spi_rty;    // RTY_I retry input
wire 			 spi_cyc;    // CYC_O cycle output



wire  [ADDR_WIDTH-1:0]   bfm_adr;    // ADR_O() address output
wire  [DATA_WIDTH-1:0]   bfm_dat_i;    // DAT_I() data in
wire  [DATA_WIDTH-1:0]   bfm_dat_o;    // DAT_O() data out
wire 			 bfm_we;     // WE_O write enable output
wire  [4-1:0] bfm_sel;    // SEL_O() select output
wire  		         bfm_stb;    // STB_O strobe output
wire			 bfm_ack;    // ACK_I acknowledge input
wire			 bfm_err;    // ERR_I error input
wire			 bfm_rty;    // RTY_I retry input
wire 			 bfm_cyc;    // CYC_O cycle output




spimaster #() spimaster_ins (
	.clk(clk),.rst(reset),.cs(cs),.mosi(mosi),.miso (miso),.spi_clk(spi_clk),
	.wbs_adr_i (bfm_adr), .wbs_dat_i(bfm_dat_o),     .wbs_dat_o(bfm_dat), .wbs_we_i (bfm_we_e),  .wbs_sel_i (bfm_sel),
	.wbs_ack_o (bfm_ack), .wbs_err_i(bfm_err),     .wbs_rty_i(bfm_rty), .wbs_cyc_i(bfm_cyc), .wbs_stb_i (bfm_stb) );
	


spislave #() spislave_ins (
	.miso(miso),.mosi(mosi), .cs(cs), .spi_clk(spi_clk&(cs==0))  ,.clk(clk),.rst(reset),
	.wbm_adr_o(spi_adr), .wbm_dat_i(spi_dat_i), .wbm_dat_o(spi_dat_o), .wbm_we_o (spi_we), .wbm_sel_o ( spi_sel ),
	.wbm_ack_i(spi_ack), .wbm_err_i(spi_err),   .wbm_rty_i(spi_rty),   .wbm_cyc_o(spi_cyc),.wbm_stb_o ( spi_stb ) );




//version  #()   ver_inst (
//	.clk(clk),.rst(reset),.addrmask(4'b0000),.adr_i (wbm_adr_o), .dat_i (wbm_dat_o),.dat_o (wbm_dat_i),.sel_i(1'b0),
//	.we_i (wbm_we_o), .stb_i (wbm_stb_o), .ack_o (wbm_ack_i),.cyc_i (1'b0) ); 


inout scl_pin;
inout sda_pin;
sw_i2c  #()   sw_i2c_inst (
	.clk(clk),.rst(reset),.addrmask(4'b0000),.adr_i (spi_adr), .dat_i (spi_dat_o),.dat_o (spi_dat_i),.sel_i(spi_sel),
	.we_i (wbm_we_o), .stb_i (wbm_stb_o), .ack_o (spi_ack),.cyc_i (1'b0), .scl_pin (scl_pin) , .sda_pin(sda_pin)  ); 




endmodule
