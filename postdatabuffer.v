module postdatabuffer(
//MUST FIX CODE SO THAT THE DATA IS SHIFTED OUT OF BASE 4 SWITCH THING
//when done performing computations ...decide if go high after done doing all computations
//turn on post data buffer, keep on until an input 'off' goes high

//must modify spram module so that data width is 24 bit instead of 22

//must instantiate the 3 rams, instantiate the sqrt module on desktop
//clock new data dv high for one clock cycle when done performing computations

//top module
input clk,
input reset_n,

//fft buffer
output reg pdb_done,
output reg [21:0] AC_component,
output reg [21:0] DC_component,
output reg new_comp_DV,
input fft_out_data,
input signed [23:0] Iout,
input signed [23:0] Qout,
);

reg [11:0] sample_counter;
reg [11:0] sample_counter2;
reg state_reg;

//spbramI
reg [63:0] led1_ram_data;
reg [10:0] led1_ram_addr;
reg led1_we;
wire led1_received_data;

//spbramQ
reg [63:0] led2_ram_data;
reg [10:0] led2_ram_addr;
reg led2_we;
wire led2_received_data;

//spbramM
reg [23:0] led3_ram_data;
reg [10:0] led3_ram_addr;
reg led3_we;
wire led3_received_data;

//sqrt module
reg [23:0] sqrt_reg;
wire [13:0] in_remainder;
wire [11:0] in_result;

reg [3:0] clock_counter = 4'd0;
reg [3:0] sorting_reg 4'd0;
reg [23:0] buffer_value0;
reg [23:0] buffer_value1;

always@(posedge clk)
begin
	if(fft_out_data)
		begin
		//go thru and store values
		//use sample counter total to determine how many samples the fft is outputting
			sample_counter = sample_counter + 1;
			led1_ram_data <= {Iout[3:0], Iout[7:4], Iout[11:8], Iout[15:12], Iout[19:16],Iout[23:20]} * {Iout[3:0], Iout[7:4], Iout[11:8], Iout[15:12], Iout[19:16],Iout[23:20]};
			led1_ram_addr <= sample_counter;
			led1_we <= 1;
			led2_ram_data <= {Qout[3:0], Qout[7:4], Qout[11:8], Qout[15:12], Qout[19:16],Qout[23:20]} * {Qout[3:0], Qout[7:4], Qout[11:8], Qout[15:12], Qout[19:16],Qout[23:20]};
			led2_ram_addr <= sample_counter;
			led2_we <= 1;

			state_reg <= 1;
		end

		else if(state_reg)
			begin
				case(state_reg2) //add values
				begin
					2'b0:
						begin
						if(sample_counter2 == samplecounter)
						begin
							state_reg2 <= 2'b1;
							sample_counter2 <= 0;
						end

						else begin
							case(state_reg4) //add values, store in ram3
							2'b0:
							begin
							intermediate1 <= led1_received_data;
							intermediate2 <= led2_received_data;
							led1_we <= 0;
							led2_we <= 0;
							led1_ram_addr <= sample_counter2;
							led2_ram_addr <= sample_counter2;
							sample_counter2 <= sample_counter2;

							led3_we <= 0;	
							state_reg4 <= 1;
							end
							2'b1:
							begin
								led3_ram_data <= intermediate1 + intermediate2;
								led3_ram_addr <= sample_counter2;
								led3_we <= 1;
								sample_counter2 <= sample_counter2 + 1;
								state_reg4 <= 0;
							end
							endcase
							end
						end
					2'b1:
					
						begin
						if(sample_counter2 == samplecounter)
						begin
							state_reg2 <= 2'd2;
							sample_counter2 <= 12'd13;
						end
							
						
						 else begin
							case(state_reg3) //run data from ram3 into sqrt function //takes 13 clock cycles to compute
							2'b0:
								begin
									led3_we <= 0;
									led3_ram_addr <= sample_counter2;
									sqrt_reg <= led3_received_data;
									state_reg3 <= 2'd1;
								end
							2'd1:
								begin
									if(clock_counter == 4'd15)
									begin
										state_reg3 <= 2'd2;
										clock_counter <= 0;
									end
									else begin
										clock_counter <= clock_counter + 1;
									end
								end
							2'd2: //for now just keeping the result, throwing out remainder
								begin
									led3_we <= 0;
									led3_ram_addr <= sample_counter2;
									led3_ram_data <= in_result;
									sample_counter2 <= sample_counter2 + 1;
									state_reg3 <= 2'd0;
								end
							endcase
					2'd2: //sort through ram 3 for AC value, starting at reg 13 to avoid values from DC comp.
						begin
							case(sorting_reg)
							4'd0: 
							begin  //assign first value then move up
							led3_we <= 0;
							led3_ram_addr <= sample_counter2;
							buffer_value0 <= led3_received_data;
							sample_counter2 <= sample_counter2 + 1;
							sorting_reg <= 4'd1;
							end
							4'd1: //assign next value
							begin
								led3_we <= 0;
								led3_ram_addr <= sample_counter2;
								buffer_value1 <= led3_received_data;
								sample_counter2 <= sample_counter2;
								sorting_reg <= 4'd2;
							end
							4'd2: //assign larger of 2 values
							begin
								sorting_reg <= 4'd3;

								if(buffer_value1 > buffer_value0)
								begin
									buffer_value2 <= buffer_value1;
								end
								else begin
									buffer_value2 <= buffer_value0;
								end
							end    //left off here
							4'd3: //begin loop here 
									//move up 1 reg	
								begin
								sorting_reg <= 4'd4;
								led3_ram_addr <= sample_counter2;
								sample_counter2 <= sample_counter2 + 1;
								end
							4'd4:
							begin
								
							end
						end //must also record DC value and pulse a dv, pulse a done computing thing
						end
					end
				end
				endcase
			end


end

sqrt sq0(
.integer_input (sqrt_reg),
.remainder (in_remainder),
.result (in_result),
.reset (reset_n),
.clk (clk)
	);



endmodule


