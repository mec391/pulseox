module addr_sel


(

//TOP MODULE
input clk,

//FSM
input in_reset_n,

input [2:0] in_addr_sel_rw,
input in_r_begin,
input in_w_begin,
output reg out_cyc_done,

//SPI
output reg [7:0] out_addr_r, 
output reg out_r_begin,
input in_rw_done,

//DATA BUFFER
output reg out_strm_dn,

//WRITE RAM
output reg [7:0] out_addr_w,
output reg out_w_begin,

//read ram
output reg [2:0] out_addr_r_read //same as out_addr_r only 
								 //regs are mapped for read ram

);


reg [2:0] stream_cycle;

always@(posedge clk)
begin
     if (~in_reset_n)
     		begin
     			out_cyc_done <= 0;
     			out_addr_r <= 0;
     			out_r_begin <= 0;
     			out_strm_dn <= 0;
     			out_addr_w <= 0;
     			out_w_begin <= 0;
     			out_addr_r_read <= 0;
     		end

     else 
     	begin
     		case (in_addr_sel_rw)
     			3'b000:
     				begin
     					out_addr_w <= 0;
     					out_w_begin <= 0;
     					out_addr_r <= 0;
     					out_r_begin <= 0;
     					out_addr_r_read <= 0;
     					out_cyc_done <= 0;
     					out_strm_dn <= 0;
     				end
     			3'b001: //send a zero addr. and DV pulse to write ram
     				begin
     					if(in_w_begin)
     						begin
     						out_addr_w <= 0;
     						out_w_begin <= 1;
     						end
     					else 
     						begin
     						out_addr_w <= 0;
     						out_w_begin <= 0;
     						end
     				end
     			3'b010: //send 48 to spi and read ram
     				begin
     					if(in_r_begin)
     						begin
     							out_addr_r <= 8'b00110000;
     							out_addr_r_read <= 3'b110;
     							out_r_begin <= 1;
     						end
     					else 
     						begin
     							out_addr_r <= 8'b00110000;
     							out_addr_r_read <= 3'b110;
     							out_r_begin <=0;
     						end
     				end
     			3'b011: //cycle through write config addresses
     				begin	
     					if (out_addr_w == 8'b00100011) //addr reaches 35
     						begin
     							if(in_rw_done)
     							begin
     								out_addr_w <= out_addr_w;
     								out_w_begin <= 0;
     								out_cyc_done <= 1;
     							end
     							else begin
     							out_addr_w <= out_addr_w;
     							out_w_begin <= 0;
     							out_cyc_done <= 0;
     							end
     						end
     						//skipping reg 30 cuts the signal for reg 30 in half, may cause problems
     					//else if (out_addr_w == 8'b00011110) //skip reg 31
     						//	begin
							//	out_addr_w <= out_addr_w + 1;
     						//	out_w_begin <= 0;
     						//	out_cyc_done <= 0; 
							//	end
     					else if(in_w_begin) //begin cycling
     						begin
     							out_addr_w <= 8'b00000001;
     							out_w_begin <= 1;
     							out_cyc_done <= 0;
     						end
     					else if (in_rw_done) //count up
     						begin
     							out_addr_w <= out_addr_w + 1;
     							out_w_begin <=1;
     							out_cyc_done <= 0;
     						end
     					else
     						begin
     							out_addr_w <= out_addr_w; //wait for any of above processes
     							out_w_begin <= 0;
     							out_cyc_done <= 0;
     						end
     				end
     			3'b100: //cycle through read stream regs
     				begin
     					
     					if (in_r_begin) //start at 42
     						begin
     							out_strm_dn <= 0;
     							out_addr_r <= 8'b00101010;
     							out_addr_r_read <= 0;
     							out_r_begin <= 1;
     						end
							else if (out_addr_r == 8'b00101111) //finish at 47
     						begin
     							if (in_rw_done)
     							begin
     							out_strm_dn <= 1;
     							out_addr_r <= out_addr_r;
     							out_addr_r_read <= out_addr_r_read;
     							out_r_begin <= 0;
     							end
     							else begin
     								out_strm_dn <= 0;
     								out_addr_r <= out_addr_r;
     								out_addr_r_read <= out_addr_r_read;
     								out_r_begin <= 0;
     							end
     						end
     					else if (in_rw_done) //count up
     						begin
     							out_strm_dn <= 0;
     							out_addr_r <= out_addr_r + 1;
     							out_addr_r_read <= out_addr_r_read + 1;
     							out_r_begin <= 1;
     						end
     					else   // wait for an above process to occur
     						begin
     							out_strm_dn <= 0;
     							out_addr_r <= out_addr_r;
     							out_addr_r_read <= out_addr_r_read;
     							out_r_begin <= 0;
     						end
     				end
     				default: 
     						begin
     					out_addr_w <= 0;
     					out_w_begin <= 0;
     					out_addr_r <= 0;
     					out_addr_r_read <= 0;
     					out_r_begin <= 0;
     					out_cyc_done <= 0;
     					out_strm_dn <= 0;
     						end

     		endcase
     	end	
end


endmodule