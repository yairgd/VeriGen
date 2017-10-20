
`timescale 1ns / 1ps

module  spimaster # (
	parameter SPI_WORDLEN = 32, 
    	parameter DATA_WIDTH = 32,                // width of data bus in bits (8, 16, 32, or 64)
    	parameter ADDR_WIDTH = 7,                // width of address bus in bits
    	parameter SELECT_WIDTH = (DATA_WIDTH/8)  // width of word select bus (1, 2, 4, or 8)
)
(

	/* system signals */
	input clk,
	input rst,
	input [3:0] addrmask  ,

	/* spi master signals */
	output reg mosi,
	input      miso,
	input      spi_clk,
	output reg cs,

	/* signals genrtated by this module from slave to master */
	input   wire [ADDR_WIDTH-1:0]    wbs_adr_i,   // ADR_I() address
    	input   wire  [DATA_WIDTH-1:0]   wbs_dat_i,   // DAT_I() data in
    	output  reg [DATA_WIDTH-1:0]    wbs_dat_o,   // DAT_O() data out
    	input   wire                     wbs_we_i,    // WE_I write enable input
    	input   wire [SELECT_WIDTH-1:0]  wbs_sel_i,   // SEL_I() select input
    	input   wire                     wbs_stb_i,   // STB_I strobe input
    	output  reg                     wbs_ack_o,   // ACK_O acknowledge output
	input  wire                      wbs_err_i,   // ERR_I error input
	input  wire                      wbs_rty_i,   // RTY_I retry input
	input   wire 			 wbs_cyc_i    // CYC_I cycle input
);






reg [SPI_WORDLEN-1:0] ser2reg_data;
reg [SPI_WORDLEN-1:0] ser2reg_data_next;
reg [6:0] ser2reg_cnt;

reg [6:0] cnt;


/* SPI serial register with async reset  */
reg ack;
always  @(posedge spi_clk or posedge rst) 
begin:ser2reg

	if (rst) begin
		cs<=1'b1;
		cnt<=32;
		ack<=1'b1;
	end else begin
		if (spi_trig==1) begin
			cnt=8'h0;
			cs<=0;
			ser2reg_data<=r2;
			ack<=1'b0;
		end
		if (cnt<32  && spi_trig==1'b0 ) begin
			{mosi,ser2reg_data} <={ser2reg_data ,1'b0};
			cnt=cnt+1;
		end
		if (cnt==32) begin
			ack<=1'b1;
		end
	end

end



reg [7:0]    r1; // conrol register 
reg [31:0]   r2; // data register
assign spi_trig = r1[0];


/* WB slave implemanattion */
always @(posedge clk) 
begin:rw_regs
	if (rst) begin
		wbs_ack_o <=1'b1;
	end else if (wbs_stb_i  && addrmask==wbs_adr_i[6:3] ) begin
		wbs_ack_o<=ack;
		if (!wbs_we_i) begin
			case (wbs_adr_i[2:0])
				default: wbs_dat_o<=8'haa; // magic
			endcase
			r1[0]<=1'b0;
		end else begin
			case (wbs_adr_i[2:0])
				3'd0: begin
					r1<=wbs_dat_i[7:0];
				end
				3'd1:  begin
					r2<=wbs_dat_i;	
				end
			endcase
		end
	end else begin
		wbs_ack_o<=1'b1;
	end
end



endmodule
