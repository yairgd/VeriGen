module  spislave (miso,mosi,cs,spi_clk,clk,rst);
input mosi;
output miso;
input spi_clk;
input cs;
input clk;
input rst;

parameter SPI_WORDLEN = 16 ;

reg [SPI_WORDLEN-1:0] ser2reg_data;
reg [SPI_WORDLEN-1:0] ser2reg_data_next;
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
	if (cs_sync && cnt<SPI_WORDLEN) begin
		ser2reg_data  <={ser2reg_data[SPI_WORDLEN-2:0],mosi};
		cnt<=cnt+1;
		/* 8 MSB bits are command to FPGA*/
		if (cnt==7) begin
			cmd<=ser2reg_data[7:0];
		end

	end
end


always @(posedge clk)
begin:cmd_action
	if (cnt>7) begin
		case (cmd[7:6])
			2'b01: //read
			begin
	
			end
		endcase
	end
end



endmodule
