//if using HR with freq domain spo2, make sure HR is never reset throughout the state machine
module TD_SORT(
input clk,
input reset_n,
output reg [10:0] addr_b,
input signed [21:0] q_b,
input sort_dv,
input [11:0] new_cnt,
output reg [21:0] sort_led1_DC,
output reg [21:0] sort_led1_AC,
output reg sort_done,
output reg [9:0] HR
);

reg [3:0] state;
reg [11:0] counter;
reg [11:0] total_counter;
reg signed [21:0] peak0;
reg signed [21:0] peak1;
reg signed [21:0] trough0;
reg  signed [21:0] trough1;
reg signed [21:0] temp_peak;
reg [21:0] hr_counter;

always@(posedge clk)
	begin
		if(~reset_n)
			begin
				//reset regs
			end
		else 
		begin
					case(state)
					4'b0: //setup counter
						begin
						if(sort_dv)
						begin
						state <= 4'd1;
							if(new_cnt == 12'd1500)
								begin
									counter <= 0;
								end
							else if(new_cnt == 12'd1501)
								begin
									counter <= 1;
								end
							else if (new_cnt == 12'd1502)
								begin
									counter <= 2;
								end
								else begin
									counter <= new_cnt + 3;
								end
						end
						else begin
							state <= 4'd0;
							counter <= counter;
						end
						end
					4'd1: 
						begin
							addr_b <= counter;
							state <= 4'd2;
						end
					4'd2:
							begin
							peak0 <= q_b;
							trough0 <= q_b;
							addr_b <= addr_b;
							state <= 4'd3;
							end
					4'd3:
							begin
								if(total_counter == 12'd1500)
									begin
									total_counter <= 0;
									state <= 4'd4;
									end
								else begin
									total_counter <= total_counter + 1;
									state <= state;
									if(counter == 12'd1502)
									begin
										counter <= 0;
									end
								else begin
									counter <= counter + 1;
									end
								addr_b <= counter;
								peak1 <= q_b;
								trough1 <= q_b;
									if(peak0 < peak1)
										begin
										peak0 <= peak1;	
										end	
									else begin
										peak0 <= peak0;
									end
									if(trough0 > trough1)
									begin
										trough0 <= trough1;
									end
									else begin
										trough0 <= trough0;
									end
								end
							end
					4'd4:
							begin //compute peak and trough
								peak1 <= peak1;
								trough1 <= trough1;
								peak0 <= peak0;
								trough0 <= trough0;
								sort_led1_AC <= peak0 - trough0;
								sort_led1_DC <= ((peak0 + trough0) / 2);
								temp_peak <= peak0 * (9/10);
								state <= 4'd5;
							end
					4'd5:	 //find HR
						begin
							counter <= new_cnt;
							addr_b <= counter;
							state <= 4'd6;
						end
					4'd6:
						begin
							if(counter == 12'd1502)
								counter <= 0;
							else begin
									counter <= counter + 1;
								end	
						addr_b <= counter;
						if(q_b <= trough0)
							begin
								state <= 4'd7;
							end
							else begin
								state <= state;
							end
						end
					4'd7:
						begin
							addr_b <= counter;
							if(counter == 12'd1502)
								counter <= 0;
							else begin
									counter <= counter + 1;
								end	
							if(q_b > temp_peak)
							begin
								state <=4'd8;
								hr_counter <= hr_counter;
							end
							else begin
								state <=state;
								hr_counter <= hr_counter + 1;
							end
						end
					4'd8:
						begin
							hr_counter <= hr_counter * 2 * 1/500 * 60;
							state <= 4'd9;
						end
					4'd9:
						begin
							HR <= hr_counter;
							state <= 4'd10;
							sort_done <= 1;
						end
					4'd10:
						begin
							sort_done <= 0;
							state <= 0;
							hr_counter <= 0;
							counter <= 0;
							total_counter <= 0;
							peak0 <= 0;
							peak1 <= 0;
							trough0 <= 0;
							trough1 <= 0;
							HR <= HR;
						end
					endcase
				end
		end


endmodule
