module spislave (miso,mosi,cs_rise,cs_fall,spi_clk,clk,rst,cs_sync);
input mosi;
output miso;
input cs_rise,cs_fall;
input spi_clk;
input clk;
input rst;

reg [23:0] ser2reg_data;
reg [23:0] ser2reg_data_next;
reg [6:0] ser2reg_cnt;

reg [6:0] cnt;

output reg cs_sync;

initial cs_sync=1;
always @(posedge clk)
begin
	if (cs_fall==1'b1) begin
		cs_sync=1'b0;
		cnt<=0;
	end
	if (cs_sync==1'b0 && cs_rise==1'b1) begin
		cs_sync<=1'b1;	
	end
end



reg [7:0] cmd;
always  @(posedge spi_clk) 
begin:ser2reg
	if (cs_sync && cnt<24) begin
		ser2reg_data[23:0] <={ser2reg_data[22:0],mosi};
		cnt<=cnt+1;
		/* 8 MSB bits are command to FPGA*/
		if (cnt==7) begin
			cmd<=ser2reg_data[7:0];
		end
	end
end



endmodule
