`timescale 1ns / 1ps
//http://www.armadeus.org/wiki/index.php?title=FpgaArchitecture#Le_bus_Wishbone
/*
* Wishbone RAM
*/
module version #
(
	parameter DATA_WIDTH = 8,              // width of data bus in bits (8, 16, 32, or 64)
	parameter ADDR_WIDTH = 7,              // width of address bus in bits
	parameter SELECT_WIDTH = (DATA_WIDTH/8) // width of word select bus (1, 2, 4, or 8)
)
(
	input  wire                    clk,
	input  wire		       rst, 
	input  [3:0]		       addrmask,

	input  wire [ADDR_WIDTH-1:0]   adr_i,   // ADR_I() address
	input  wire [DATA_WIDTH-1:0]   dat_i,   // DAT_I() data in
	output reg  [DATA_WIDTH-1:0]   dat_o,   // DAT_O() data out
	input  wire                    we_i,    // WE_I write enable input
	input  wire [SELECT_WIDTH-1:0] sel_i,   // SEL_I() select input
	input  wire                    stb_i,   // STB_I strobe input
	output reg                     ack_o,   // ACK_O acknowledge output
	input  wire                    cyc_i    // CYC_I cycle input
);

reg [7:0] r0,r1,r2;

always @(posedge clk) 
begin:rw_regs
	if (rst) begin
		ack_o <=1'b0;
	end else if (stb_i  ) begin
		ack_o<=1'b1;
		if (!we_i) begin
			case (adr_i[2:0])
				3'd0:  dat_o<=8'h12;
				3'd1:  dat_o<=8'h34;
				3'd2:  dat_o<=r2;
				default: dat_o<=0;
			endcase
		end else begin
			case (adr_i[2:0])
				3'd2:  r2<=dat_i;
			endcase
		end
	end else begin
		ack_o<=1'b0;
	end
end
endmodule
