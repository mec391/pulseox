//need to look at datasheet for correct algo and values

//MAKE SURE TO PCB DESIGN SO THAT LED1 = IR and LED2 =  RED
module final_comp(
input clk,
input reset_n,
input final_comp_dv,
input [23:0] led1_AC_computed,
input [23:0] led1_DC_computed,
input [23:0] led2_AC_computed,
input [23:0] led2_DC_computed,
output reg [23:0] SPO2,
output reg final_comp_done
);
reg [31:0] div_1;
reg [31:0] div_2;
reg [31:0] div_total;
reg [15:0] one_ten = 16'b0110111000000000; //decimal 110.00000000
reg [3:0] state;
reg [15:0] twenty_five = 16'b0001100100000000; //deciaml 25.00000000
reg [31:0] temp;
//try divider operator for now /
 //whole numbers should be passing in .. have to figure out rouding and stuff
always@(posedge clk)
begin
	if(~reset_n)
		begin
			div_1 <= 0;
			div_2 <= 0;
			div_total <= 0;
			state <= 0;
			one_ten <= 16'b0110111000000000; //decimal 110.00000000
		end
	else begin
			case(state)
				4'b0:
					begin
					final_comp_done <= 0;
					if(final_comp_dv)
						begin

						div_2 <= {led2_AC_computed, 8'd0} / {led2_DC_computed, 8'd0} ;
						div_1 <= {led1_AC_computed, 8'd0} / {led1_DC_computed, 8'd0} ;
						state <= 4'b1;
						end
						else begin
							div_1 <= div_1;
							div_2 <= div_2;
							state <= state;
						end
					
					end
					4'b1:
						begin
							div_total <= div_2 / div_1; //try swithcing around
							state<= 4'd2;
						end
					4'd2:
						begin
						//review this
						temp <= one_ten - twenty_five * div_total;
						final_comp_done <= 0;
						state <= 4'd3;
						end
					4'd3:
						begin
							SPO2 <= temp[31:8]; //round to whole number
							final_comp_done <= 1;
							state <=4'd0;
						end

				endcase
	end
end


endmodule