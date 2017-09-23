`timescale 1ns / 1ps

module  spislave # (
	parameter SPI_WORDLEN = 16, 
    	parameter DATA_WIDTH = 8,                // width of data bus in bits (8, 16, 32, or 64)
    	parameter ADDR_WIDTH = 7,                // width of address bus in bits
    	parameter SELECT_WIDTH = (DATA_WIDTH/8)  // width of word select bus (1, 2, 4, or 8)
)
(
//	miso,mosi,cs,spi_clk,clk,rst,rd_value,rd_en,wr_value,wr_en,addr

	/* system signals */
	input clk,
	input rst,

	/* spi signals */
	input mosi,
	output miso,
	input spi_clk,
	input cs,

	 /* signals genrtated by this module from master to slavle */
	output reg  [ADDR_WIDTH-1:0]   wbm_adr_o,    // ADR_O() address output
	input  wire [DATA_WIDTH-1:0]   wbm_dat_i,    // DAT_I() data in
	output reg  [DATA_WIDTH-1:0]   wbm_dat_o,    // DAT_O() data out
	output reg                     wbm_we_o,     // WE_O write enable output
	output wire [SELECT_WIDTH-1:0] wbm_sel_o,    // SEL_O() select output
	output reg                     wbm_stb_o,    // STB_O strobe output
	input  wire                    wbm_ack_i,    // ACK_I acknowledge input
	input  wire                    wbm_err_i,    // ERR_I error input
	input  wire                    wbm_rty_i,    // RTY_I retry input
	output reg                     wbm_cyc_o    // CYC_O cycle output



);


/*
input      [7:0] rd_value;
output reg [7:0] wr_value;
output [5:0] addr;
output reg wr_en;
output reg rd_en;
*/



reg [SPI_WORDLEN-1:0] ser2reg_data;
reg [SPI_WORDLEN-1:0] ser2reg_data_next;
reg [6:0] ser2reg_cnt;

reg [6:0] cnt;


//initial ser2reg_data = 0;

reg [1:0] cs_d;
always @(posedge clk)
begin:cs_detect
	cs_d <={cs_d[0],cs};
end

reg cs_sync;
always @(cs_d)
begin
	case (cs_d)
		2'b01: 
		begin 
		cs_sync=1'b1;
	end
	2'b10: 
	begin
		cs_sync=1'b0;
	end
	default: cs_sync=cs_sync;
endcase
end





reg [7:0] cmd;
reg wbc_trig;
always  @(posedge spi_clk or posedge rst) 
begin:ser2reg
	if (rst) begin
		cnt<=0;
		ser2reg_data<=1'b0;
	end else begin
		if (!cs_sync && cnt<SPI_WORDLEN) begin
			ser2reg_data   <={ser2reg_data[SPI_WORDLEN-2:0], mosi};
			cnt<=cnt+1;
			/* 8 MSB bits are command to FPGA*/
			if (cnt==7) begin
				cmd<=ser2reg_data[7:0];
			end

			/* register value */
			if (cnt==15) begin
				wbm_dat_o<=ser2reg_data[7:0];
				wbm_we_o <=cmd[7:7];
				wbm_adr_o<=cmd[6:0];
				wbc_trig<=1'b1;
			end else begin
				wbc_trig<=1'b0;
			end	


		end
	end
end




localparam  wbc_idle_s=3'd0,wbc_stb_s=3'd1;

reg [2:0] wbc_state;
always @(posedge clk) 
begin:wbc_controller
	if (rst) begin
		wbm_stb_o<=1'b0;
		wbc_state<=wbc_idle_s;	
	end else begin
		case (wbc_state)
			wbc_idle_s:
			begin
				if (wbc_trig) begin
					wbc_state<=wbc_stb_s;
					wbm_stb_o<=1'b1;
					wbm_cyc_o<=1'b1;					
				end else begin
					wbc_state<=wbc_idle_s;
					wbm_stb_o<=1'b0;
				end
			end
			wbc_stb_s:
			begin
				if (wbm_ack_i==1'b0) begin
					wbc_state<=wbc_stb_s;
				end else begin
					wbc_state<=wbc_idle_s;
					wbm_cyc_o<=1'b0;					
				end

			end
		endcase
	end

end
endmodule
