`timescale 1ns / 1ps
//http://www.armadeus.org/wiki/index.php?title=FpgaArchitecture#Le_bus_Wishbone
/*
* Wishbone RAM
*/
module sw_i2c #
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
	input  wire                    cyc_i,    // CYC_I cycle input

	/* i2c interface */
	inout scl_pin,
	inout sda_pin

);

/*
    input  wire        scl_i,
    output wire        scl_o,
    output wire        scl_t,
    input  wire        sda_i,
    output wire        sda_o,
    output wire sda_t,

assign scl_i = scl_pin;
assign scl_pin = scl_t ? 1'bz : scl_o;
assign sda_i = sda_pin;
assign sda_pin = sda_t ? 1'bz : sda_o;
*/


/*
*  I2C Contorl Reg :
*  	0 - scl_t
*  	1 - scl_i
*  	2 - scl_o
*  	3 - sda_t
*  	4 - sda_i
*  	5 - sda_o
*
*  r0-1 - contol on I2C0-1
*/
reg [7:0] r0;


reg scl_o;
reg sda_o;
reg scl_t;
reg sda_t;

assign scl_i = scl_pin;
assign scl_pin = scl_t ? 1'bz : scl_o;
assign sda_i  = sda_pin;
assign sda_pin = scl_t ? 1'bz : sda_o;



always @(posedge clk) 
begin:rw_regs
	if (rst) begin
		ack_o <=1'b0;
		scl_t<=1'b1; // set i2c pin in high impedance mode
	end else if (stb_i  && addrmask==adr_i[6:3] ) begin
		ack_o<=1'b1;
		if (!we_i) begin
			case (adr_i[2:0])
				3'd0: begin
					data_o={1'b1,1'b1,sta_o,sda_i,sda_t,scl_o,scl_i,scl_t};
				end
				default: dat_o<=8'aa; // magic
			endcase
		end else begin
			case (adr_i[2:0])
				3'd0: begin
					scl_t<=dat_i[0];
					sda_t<=dat_i[3];
					scl_o<=dat_i[2];
					sda_o<=dat_i[5];
				end
			endcase
		end
	end else begin
		ack_o<=1'b0;
	end
end
endmodule
