module registers (clk,rst,rd_en,wr_wn,addr,value_i,value_o);
input clk;
input rst;
input rd_en;
input wr_en;
input [5:0] addr;
input [7:0] value_i;
output reg [7:0] value_o;

reg [7:0] regs[5:0];




endmodule
