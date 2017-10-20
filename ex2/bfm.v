module  bfm # (
	parameter SPI_WORDLEN = 32, 
    	parameter DATA_WIDTH = 32,                // width of data bus in bits (8, 16, 32, or 64)
    	parameter ADDR_WIDTH = 7,                // width of address bus in bits
    	parameter SELECT_WIDTH = (DATA_WIDTH/8)  // width of word select bus (1, 2, 4, or 8)
)
(
	input clk,
	input rst,

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

reg [31:0] tx_memory [0:1024];  
initial begin
   $readmemh("memory.list", tx_memory);
end	


/* 
* loads 4 bytes from memory to wb data out
*/
reg wbc_trig;
reg [6:0] cnt_prev;
reg [10:0] cnt;
reg [31:0] rx_data;
always  @(posedge clk) 
begin:wbc_trigger
	if (rst) begin
		wbc_trig<=1'b0;
		cnt<=10'b0;
	end else begin
		if (wbc_state == wbc_idle_s) begin
			wbm_dat_o<={tx_memory[cnt*4+3], tx_memory[cnt*4+2],tx_memory[cnt*4+1],tx_memory[cnt*4+0]};
			cnt<=cnt+1;
			wbc_trig<=1'b1;
		end else begin
			wbc_trig<=1'b0;
		end
	end
end



/* WB master */
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
