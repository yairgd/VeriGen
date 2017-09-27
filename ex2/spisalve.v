`timescale 1ns / 1ps

module  spislave # (
	parameter SPI_WORDLEN = 32, 
    	parameter DATA_WIDTH = 8,                // width of data bus in bits (8, 16, 32, or 64)
    	parameter ADDR_WIDTH = 7,                // width of address bus in bits
    	parameter SELECT_WIDTH = (DATA_WIDTH/8)  // width of word select bus (1, 2, 4, or 8)
)
(

	/* system signals */
	input clk,
	input rst,

	/* spi signals */
	input mosi,
	output  miso,
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






reg [SPI_WORDLEN-1:0] ser2reg_data;
reg [SPI_WORDLEN-1:0] ser2reg_data_next;
reg [6:0] ser2reg_cnt;

reg [6:0] cnt;


//initial ser2reg_data = 0;

reg [1:0] mosi_d;
always @(posedge clk)
begin:mosi_detect
	if ( spi_clk_d ==2'b01 ) begin
	mosi_d <={mosi_d[0],mosi};
	end	
end

reg [1:0] cs_d;
always @(posedge clk)
begin:cs_detect
	cs_d <={cs_d[0],cs};
end

reg [1:0] spi_clk_d;
always @(posedge clk)
begin:spi_clk_detect
	spi_clk_d <={spi_clk_d[0],spi_clk};
end

/*
reg cs_sync;
always @(posedge clk)
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
*/


/* short trigger for the wishbone bus controller */
reg [6:0] cnt_prev;
always  @(posedge clk) 
begin:wbc_trigger
	cnt_prev<=cnt;
	if (cnt==17 && cnt_prev==16) begin
			wbc_trig<=1'b1;
	end else begin
			wbc_trig<=1'b0;			
	end
end


reg [7:0] cmd;
reg [7:0] out_data;
assign miso =  out_data[7];
reg wbc_trig;
reg d;
always  @(posedge clk) 
begin:ser2reg


	if (rst==1 || cs_d==2'b01) begin
		cnt=8'h1;
	//	ser2reg_data<=32'b0;
		out_data=8'haa;
		d=1'b0;
	//	ser2reg_data   <={ser2reg_data, mosi};
	
	end else if (d==0 && ( spi_clk_d ==2'b01  || cnt==33) ) begin
	//	ser2reg_data   <={ser2reg_data[SPI_WORDLEN-2:0], mosi};
		ser2reg_data   ={ser2reg_data, mosi};

		if (! (cnt==DATA_WIDTH+0) && ! (cnt==3*DATA_WIDTH+0 )  && ! (cnt==2*DATA_WIDTH+0 ) ) begin
			out_data       =   {out_data[DATA_WIDTH-2:0],1'b0};
		end

		/* 8 MSB bits are command to FPGA*/
		if (cnt==DATA_WIDTH+0) begin
			cmd=ser2reg_data[DATA_WIDTH-1:0];
			out_data=ser2reg_data[DATA_WIDTH-1:0];
		end

		/* register value */
		if (cnt==2*DATA_WIDTH+0) begin
			wbm_dat_o=ser2reg_data[7:0];
			wbm_we_o =cmd[7:7];
			wbm_adr_o=cmd[6:0];
			out_data=ser2reg_data[DATA_WIDTH-1:0];

		end

		if (cnt==3*DATA_WIDTH+0) begin
			out_data=wbm_dat_i;
		end


		cnt=cnt+1;
	end else begin if (d==1 &&  spi_clk_d ==2)
		d=0;
	end

end




localparam  wbc_idle_s=3'd0,wbc_stb_s=3'd1;

reg [2:0] wbc_state;
always @(posedge clk) 
begin:wbc_controller
	if (rst) begin
		wbm_stb_o<=1'b0;
		wbc_state<=wbc_idle_s;	
		wbc_state<=1'b0;
	end else begin
		case (wbc_state)
			wbc_idle_s:
			begin
				if (wbc_trig ) begin
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
