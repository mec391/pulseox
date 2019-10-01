module fifov1(
	
//	for now just passing led1 and led2 values
// 	no reason to use actual fifo when fixed speeds going 
//in and coming out

//since wifi is at 25 mhz, make sure to output signal for 2 clock cycles

//top
input clk,
//fsm
input reset_n,

//data_buffer
input new_samples,
input [21:0] led_one,
input [21:0] led_two,

//hr alu
/*input [9:0] hr,
input [9:0] hr_dv,

//spo2 alu
input [9:0] spo2,
input [9:0] spo2_dv
*/


//wifi
//decide on 1 data line or multiple data lines
output reg [21:0] data_led1,
output reg [21:0] data_led2,
output reg data_rdy




);
//need to create ram for each set of data, write code to store that data and ship out
reg [2:0] delay_reg;

always@(posedge clk)
	begin
		if (~reset_n)
			begin
				data_led1 <= 0;
				data_led2 <= 0;
				data_rdy <= 0;
			end
		else begin
		case (delay_reg)
				3'b000: //adding delay because crossing clock domains
					begin
						if(new_samples)
					begin
					data_led1 <= led_one;
					data_led2 <= led_two;
					data_rdy <= 1;
					delay_reg <= 3'b001;
					end
				else begin
					data_led1 <= data_led1;
					data_led2 <= data_led2;
					data_rdy <= 0;
					delay_reg <= delay_reg;
				end
				end
				3'b001:
					begin
					data_led1 <= data_led1;
					data_led2 <= data_led2;
					data_rdy <= 1;
					delay_reg <= 3'b010;
					end
				3'b010:
					begin
					data_led1 <= data_led1;
					data_led2 <= data_led2;
					data_rdy <= 1;
					delay_reg <= 3'b011;
					end
				3'b011:
					begin
					data_led1 <= data_led1;
					data_led2 <= data_led2;
					data_rdy <= 0;
					delay_reg <= 3'b000;
					end
			
					
			
			endcase
			end	
	end

endmodule