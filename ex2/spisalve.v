module  spislave # (
	parameter SPI_WORDLEN = 16 
)
(	miso,mosi,cs,spi_clk,clk,rst,rd_value,rd_en,wr_value,wr_en,addr
);
input mosi;
output miso;
input spi_clk;
input cs;
input clk;
input rst;

input      [7:0] rd_value;
output reg [7:0] wr_value;
output [5:0] addr;
output reg wr_en;
output reg rd_en;




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
				value<=ser2reg_data[15:8];
			end


		end
	end
end


reg [7:0] value;
wire [1:0] opcode = cmd[7:6];
wire [5:0] addr = cmd[5:0];
always @(posedge clk)
begin:cmd_action
	if (cnt>7 && cs_sync == 0) begin
		case (opcode)
			2'b01: //read
			begin
				rd_en<=1'b1;
			end
			2'b10: //write
			begin
			end
		endcase
	end
end



endmodule
