module spislave (miso,mosi,cs,spi_clk,clk,rst);
input mosi;
output miso;
input spi_clk;
input cs;
input clk;
input rst;

reg [23:0] ser2reg_data;
reg [23:0] ser2reg_data_next;
reg [6:0] ser2reg_cnt;

reg [6:0] cnt;


reg [1:0] cs_d;
always @(posedge clk)
begin:cs_detect
	cs_d <={cs_d[1],cs};
end

reg cs_sync;
always @(cs_d)
begin
	case (cs_d)
		2'b01: cs_sync=1'b1;
		2'b10: cs_sync=1'b0;
		default: cs_sync=cs_sync;
	endcase
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
