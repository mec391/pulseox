module FSM

	
(
//top module
input reading_done,

input clk,

//cpu regs
input in_cpu_start,
input in_cpu_stop,
input in_cpu_reset_n,
output reg out_config_er,
output reg out_stream_rdy,

//afe
input in_afe_diag_end,
input in_afe_adc_rdy,

//data buffer
output reg [1:0] out_data_buffer_control,
input [1:0] in_diag_er,

//write ram
output reg [2:0] out_write_control,

//read ram
output reg out_en_write_a,

//address sel
output reg [2:0] out_addr_rw,
output reg out_read_begin,
output reg out_write_begin,
input in_cyc_done,

//spi
input in_read_write_done,


//reset for all other modules
output reg out_reset_n,

//testing
output reg kill_me

	);


reg [7:0] next_state;
reg [16:0] sampling_counter;

always@(posedge clk)
begin


	if (~in_cpu_reset_n)
	begin
		next_state <= 8'b0;
	end

	else 
	
	case(next_state)
	8'b0: //reset fsm output regs and other modules
			begin
				out_reset_n <= 0;
				kill_me <= 1;
				out_config_er <= 0;
				out_stream_rdy <= 0;
				out_data_buffer_control <= 0;
				out_write_control <= 0;
				out_en_write_a <= 0;
				out_addr_rw <= 0;
				out_read_begin <= 0;
				out_write_begin <= 0;

				next_state <= 8'b00000001;
			end
	8'b00000001: //1 clock cycle delay for resets...might need 1 or 2 more
			begin
				out_reset_n <= 0;
				next_state <= 8'b10000000;
			end

	//////////////////////////////////////////

	8'b10000000:
			begin
				out_reset_n <= 1;
				next_state <= 8'b10000001;
			end
	8'b10000001:
			begin
				out_reset_n <= 1;
				next_state <= 8'b00000010;
			end



	///////////////////////////////////////





	8'b00000010: //write 8 to reg 0
			begin
				out_reset_n <= 1;
				out_addr_rw <= 1;
				out_en_write_a <= 0;
				out_write_control <= 1;
				out_write_begin <= 1;
				next_state <= 8'b00000011;
			end
	8'b00000011: 
			begin //wait for write to complete
				out_reset_n <= 1;
				out_write_begin <= 0;
				out_write_control <= 1;
				out_addr_rw <= 1;
				out_en_write_a <= 0;
				if (in_read_write_done)
					begin 
					next_state <= 8'b00000100;   
					end
				else 
					begin
					next_state <= 8'b00000011; 
					end
			end
	8'b00000100: //diagnostics mode
				//write 4 to reg 0
				begin
				out_reset_n <= 1;
				out_write_control <= 3'b010; 
				out_addr_rw <= 1;
				out_en_write_a <= 0;
				out_write_begin <= 1;

				next_state <= 8'b00000101;   
				end
				
	8'b00000101: //wait for diag end pin to run high
				begin
				kill_me <= 0;
					out_reset_n <= 1;
					out_write_begin <= 0;
					out_write_control <= 3'b010;
					out_addr_rw <= 1;
					out_en_write_a <= 0;
						if (in_read_write_done) //testing purposes				
						begin
							next_state <= 8'b00000110;  
				
						end			
						else 
						begin
							next_state <= 8'b00000101;	
							
						end
				end
	8'b00000110://write 1 to reg 0
				begin
					out_reset_n <= 1;
					out_write_control <= 3'b011;
					out_addr_rw <= 1;
					out_en_write_a <= 0;
					out_write_begin <= 1;

					next_state <= 8'b00000111;
				end
	8'b00000111: //wait for write to complete
				begin
					out_reset_n <= 1;
					out_write_begin <= 0;
					out_write_control <= 3'b011;
					out_addr_rw <= 1;
					out_en_write_a <= 0;
						if (in_read_write_done)
						begin
							next_state <= 8'b00001000;
						end
						else 
						begin
							next_state <= 8'b00000111;	
						end
				end
				//read reg 48 on afe
	8'b00001000:
				begin
					out_reset_n <= 1;
					out_addr_rw <= 3'b010;
					out_en_write_a <= 0;
					out_read_begin <= 1;

					next_state <= 8'b00001001;
				end
	8'b00001001: //when read complete, pass data to ram
				begin
					out_reset_n <= 1;
					out_read_begin <= 0;
					out_addr_rw <= 3'b010;
					if(in_read_write_done)
						begin
							out_en_write_a <= 1;
							next_state <= 8'b00001010;			
						end				
						else 
						begin
							out_en_write_a <= 0;
							next_state <= 8'b00001001;	
						end
				end	
	8'b00001010: // 1 clock delay for data from spi to read reg to occur
				begin
						out_reset_n <= 1;
						out_en_write_a <= 1;
						next_state <= 8'b00001011;				
				end				
	8'b00001011://tell data buffer to process data
				begin
						out_reset_n <= 1;
						out_en_write_a <= 0;
						out_data_buffer_control <= 2'b01;
						next_state <= 8'b00001100;
				end
	8'b00001100: //perform function if error or not
				begin
						out_reset_n <= 1;
						 
						out_data_buffer_control <= 2'b01;
								case(in_diag_er)
								2'b00: next_state <= 8'b00001100; //error not yet calculated
								2'b01: next_state <= 8'b00001101; //error
								2'b10: next_state <= 8'b00001110; //no error
								default: next_state <= 8'b00001100;
								endcase
				end
			//report error//wait for reset
	8'b00001101:
				begin
				out_reset_n <= 1;
				out_config_er <= 1;
				next_state <= 8'b00001101;	
				end
			//proceed to configuration because no error
	8'b00001110: //set afe to write mode
				begin
					out_reset_n <= 1;
					out_data_buffer_control <= 0;
					out_addr_rw <= 1;
					out_en_write_a <= 0;
					out_write_control <= 3'b100;
					out_write_begin <= 1;

					next_state <= 8'b00001111;
				end
	8'b00001111: //wait for write mode to complete
				begin
					out_reset_n <= 1;
					out_data_buffer_control <= 0;
					out_addr_rw <= 1;
					out_en_write_a <= 0;
					out_write_control <= 3'b100;
					out_write_begin <= 0;
						if (in_read_write_done)
							begin
								next_state <= 8'b00010000;
							end
						else 
						begin
							next_state <= next_state;
						end
								
				end
	8'b00010000://write default settings to config regs
				begin
					out_reset_n <= 1;
					out_en_write_a <= 0;
					out_addr_rw <= 3'b011;
					out_write_control <= 3'b101;
					out_write_begin <= 1;

					next_state <= 8'b00010001;
				end
	8'b00010001: //wait for cycling to finish
				begin
					out_reset_n <= 1;
					out_en_write_a <= 0;
					out_addr_rw <= 3'b011;
					out_write_control <= 3'b101;
					out_write_begin <= 0;
					if (in_cyc_done)
							begin
								next_state <= 8'b00010010;
							end
					else 
							begin
								next_state <= 8'b00010001;
							end
				end
	8'b00010010: //put afe back in read mode
				begin
				
					out_reset_n <= 1;
					out_addr_rw <= 3'b001;
					out_en_write_a <= 0;
					out_write_control <= 3'b011;
					out_write_begin <= 1;

					next_state <= 8'b00010011;
				end
	8'b00010011: //wait for write to complete
				begin
					out_reset_n <= 1;
					out_write_begin <= 0;
					out_addr_rw <= 3'b001;
					out_en_write_a <= 0;
					out_write_control <= 3'b011;
					if (in_read_write_done)
						begin
							next_state <= 8'b00010100;
						end
					else 
						begin
							next_state <= 8'b00010011;
						end
				end
				// idle mode (may need to add code for receiving config
				// data from cpu). Also for receiving
				// data for stream duration
				// as it is currently configured for start/stop only.
	
	8'b00010100: //tell cpu it is ready for data
				begin
					out_stream_rdy <= 1;
					out_reset_n <= 1;
					kill_me <= 1;

					if (in_cpu_start)
					begin
					next_state <= 8'b00010101;
					end
					else begin
						next_state <= next_state;
					end

					end
					/*if (in_cpu_start)
						begin
							next_state <= 8'b00010101;   ///commented out for testing
							out_stream_rdy <= 0;
						end
					else 
						begin
							next_state <= 8'b00010100;
							out_stream_rdy <= 1;
						end
				end */

				//begin streaming

	8'b00010101: 
				begin
						kill_me <= 0;
					out_reset_n <= 1;
					next_state <= 8'b00010110;
					out_en_write_a <= 1;
					out_data_buffer_control <= 2'b10;
					out_read_begin <= 1;
					out_addr_rw <= 3'b100;

					/*if(in_cpu_stop)
					begin
						next_state <= 8'b00010100;
						out_en_write_a <= 0;	
						out_data_buffer_control <= 2'b00;   //testing
					end 
					else
						begin
										
							
									if (in_afe_adc_rdy)
										begin
										
													out_en_write_a <= 1;
							out_data_buffer_control <=2'b10;
							next_state <= 8'b00010101;
											out_read_begin <= 1;
											out_addr_rw <= 3'b100;
										end
									else 
										begin
										out_en_write_a <= 1;
							out_data_buffer_control <=2'b10;
							next_state <= 8'b00010101;
											out_read_begin <= 0;
											out_addr_rw <= 3'b100;
										end
						end */

				end
				8'b00010110:
				begin
				kill_me <= 1;
				out_reset_n <= 1;
				out_read_begin <= 0;
				if(sampling_counter == 17'd100000) //testing purposes, replace with adc_rdy
					begin
					next_state <= 8'b00010101;
					sampling_counter <= 0;
					end
					else begin
					next_state <= 8'b00010110;
					sampling_counter <= sampling_counter + 1;
					end
				
				end
				
		//default is same as 8'b0 state so it initializes on startup
		default:
				begin
				out_reset_n <= 0;

				out_config_er <= 0;
				out_stream_rdy <= 0;
				out_data_buffer_control <= 0;
				out_write_control <= 0;
				out_en_write_a <= 0;
				out_addr_rw <= 0;
				out_read_begin <= 0;
				out_write_begin <= 0;

				next_state <= 8'b00000001;
				end
	endcase		
end



endmodule