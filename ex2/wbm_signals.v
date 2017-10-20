module wbm_signals # (
	parameter DATA_WIDTH = 7,                // width of data bus in bits (8, 16, 32, or 64)
	parameter ADDR_WIDTH = 8,                // width of address bus in bits
	parameter SELECT_WIDTH = (DATA_WIDTH/8)  // width of word select bus (1, 2, 4, or 8)
)
(
	/* signals to contoll master */
	input  wire [ADDR_WIDTH-1:0]   wbc_adr_o,    // ADR_O() address output
	output wire [DATA_WIDTH-1:0]   wbc_dat_i,    // DAT_I() data in
	input  wire [DATA_WIDTH-1:0]   wbc_dat_o,    // DAT_O() data out


        /* signals genrtated by this module from master to slavle */
	output wire [ADDR_WIDTH-1:0]   wbm_adr_o,    // ADR_O() address output
	input  wire [DATA_WIDTH-1:0]   wbm_dat_i,    // DAT_I() data in
	output wire [DATA_WIDTH-1:0]   wbm_dat_o,    // DAT_O() data out
	output wire                    wbm_we_o,     // WE_O write enable output
	output wire [SELECT_WIDTH-1:0] wbm_sel_o,    // SEL_O() select output
	output wire                    wbm_stb_o,    // STB_O strobe output
	input  wire                    wbm_ack_i,    // ACK_I acknowledge input
	input  wire                    wbm_err_i,    // ERR_I error input
	input  wire                    wbm_rty_i,    // RTY_I retry input
	output wire                    wbm_cyc_o,    // CYC_O cycle output
);


endmodule
