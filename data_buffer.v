module data_buffer(

//top module
input clk,

//fsm
input in_reset_n,

input [1:0] in_data_control,
output reg [1:0] out_diag_er,


//addr sel
input in_strm_dn,




//temporary data to fifo
output reg signed [21:0] led_one,   
output reg [21:0] aled_one,
output reg [21:0] led_one_aled_one,
output reg signed [21:0] led_two,
output reg [21:0] aled_two,
output reg [21:0] led_two_aled_two,

//fpga cpu comm
output reg [13:0] out_er_data,

//alu


//calibration

//read ram
output reg [2:0] out_addr,
input [23:0] in_strm_data,


output reg new_samples
	);

reg er;
reg diag_step;
reg [3:0] reg_counter;



always@(posedge clk)
begin

	if(~in_reset_n) 
	begin
		er <= 0;
		diag_step <= 0;
		reg_counter <= 0;
		out_addr <= 0;
		out_er_data <= 0;
		out_diag_er <= 0;
		led_one <= 0;
		aled_one <= 0;
		led_one_aled_one <= 0;
		led_two <= 0;
		aled_two <= 0;
		led_two_aled_two <= 0;
	end

else begin

	case(in_data_control)
		2'b00: //perform no action
			begin
		er <= 0;
		diag_step <= 0;
		reg_counter <= 0;
		out_addr <= 0;
		out_er_data <= 0;
		out_diag_er <= 0;
		led_one <= 0;
		aled_one <= 0;
		led_one_aled_one <= 0;
		led_two <= 0;
		aled_two <= 0;
		led_two_aled_two <= 0;
			end
		2'b01: //get diag info, process, send out
			begin
				if(~diag_step)
				begin
				out_addr <= 3'b110;
				out_er_data <= in_strm_data[13:0];
				er <= | in_strm_data[13:0];
				diag_step <= 1;
				end
				else 
				begin
					case(er)
						1'b0: //no errors
						begin
							out_diag_er <= 2'b10;
						end
						1'b1: //errors
							out_diag_er <= 2'b01;
					endcase
				end
			end
		2'b10: //perform streaming process
			begin
				case (reg_counter)
					4'b0000:
							begin
							new_samples <= 0;
							if(in_strm_dn)
							begin
								out_addr <= 0;
								led_two <= in_strm_data[21:0];
								reg_counter <= 4'b0001;
							end
							else begin
								out_addr <= 0;
								led_two <= led_two;
								reg_counter <= reg_counter;
							end
							end
					4'b0001: //delay
							begin
								out_addr <= 0;
								led_two <= in_strm_data[21:0];
								reg_counter <= 4'b0010;
								
							end
					4'b0010:
							begin
								out_addr <= 1;
								aled_two <= in_strm_data[21:0];
								reg_counter <= 4'b0011;
								//shift out of twos comp
								/*if(led_two[21] == 1)
									begin
										led_two[21] <= 0;
									end
								else
								begin
										led_two[21] <= 1;
								end
								*/
								 
							end
					4'b0011: //delay
							begin
								out_addr <= 1;
								aled_two <= in_strm_data[21:0];
								reg_counter <= 4'b0100;
							end
					4'b0100:
							begin
								out_addr <= 3'b010;
								led_one <= in_strm_data[21:0];
								reg_counter <= 4'b0101;
							end
					4'b0101: //delay
							begin
								out_addr <= 3'b010;
								led_one <= in_strm_data[21:0];
								reg_counter <= 4'b0110;
							end
					4'b0110:
							begin
								out_addr <= 3'b011;
								aled_one <= in_strm_data[21:0];
								reg_counter <= 4'b0111;
								//shift out of twos comp
								/*if (led_one[21] == 1)
									begin
										led_one[21] <= 0;
									end
									else begin
										led_one[21] <= 1;
									end
									*/
							end
					4'b0111: //delay
							begin
								out_addr <= 3'b011;
								aled_one <= in_strm_data[21:0];
								reg_counter <= 4'b1000;
							end

					4'b1000:
							begin
								out_addr <= 3'b100;
								led_two_aled_two <= in_strm_data[21:0];
								reg_counter <= 4'b1001;
							end
					4'b1001: //delay
							begin
								out_addr <= 3'b100;
								led_two_aled_two <= in_strm_data[21:0];
								reg_counter <= 4'b1010;
							end
					4'b1010:
							begin
								out_addr <= 3'b101;
								led_one_aled_one <= in_strm_data[21:0];
								reg_counter <= 4'b1011;
							end
					4'b1011:
							begin
								out_addr <= 3'b101;
								led_one_aled_one <= in_strm_data[21:0];
								reg_counter <= 4'b0000;
								new_samples <= 1;
							end

				endcase
			end



	endcase
	end
end

always@(posedge clk)
begin
	//write code so that when a DV comes in from both fft buffers, data gets xffered to final calc and dv gets sent.
end

endmodule


