


module TD_circ_buffer
(
	input clk,
	input reset_n,

	input signed[21:0] led1,
	input in_new_samples,

	output [21:0] led1_AC,
	output [21:0] led1_DC,
	output [9:0] HR,
	output out_new_data


);

//dp ram routing
reg [21:0] data_a;
reg [10:0] addr_a;
reg we_a;
wire [21:0] q_a;
 ///route to sort algo
wire [10:0] addr_b; //
wire [21:0] q_b; //

//sort algo routing
reg sort_dv;
reg [11:0] new_cnt = 12'd1501;
wire [21:0] sort_led1_AC;
wire [21:0] sort_led1_DC;
assign led1_AC = sort_led1_AC;
assign led1_DC = sort_led1_DC;


reg startup_reg;
reg [11:0] startup_sample_cnt;
reg [3:0] state;
always@(posedge clk)
begin
	if(~reset_n)
		begin
			//reset regs
		end
	else begin
		if(~startup_reg) //fill up ram from 0 to 1499
		begin
					we_a <= 1;
					if(startup_sample_cnt == 12'd1501)
					begin
						startup_sample_cnt <= startup_sample_cnt;
						addr_a <= addr_a;
						startup_reg <= 1;
						data_a <= data_a;

					end
					else
						begin
							if(in_new_samples)
								begin
									addr_a <= startup_sample_cnt;
									data_a <= led1;
									startup_sample_cnt <= startup_sample_cnt + 1;
								end
								else begin
									addr_a <= addr_a;
									data_a <= data_a;
									startup_sample_cnt <= startup_sample_cnt;
								end
						end
				end
		else begin
			//add a new sample and a DV
					if(in_new_samples)
						begin
						addr_a <= new_cnt;
						data_a <= led1;
						sort_dv <= 1;
							if(new_cnt == 12'd1502)
								begin
									new_cnt <= 0;
								end
								else begin
									new_cnt <= new_cnt + 1;
								end

						end
					else begin
						addr_a <= addr_a;
						data_a <= data_a;
						sort_dv <= 0;
						new_cnt <= new_cnt;
					end
				end
	end
end

TD_DPRAM td_ram0(
.data_a (data_a),
.data_b (22'd0),
.addr_a (addr_a),
.addr_b (addr_b),
.we_a (we_a),
.we_b (1'b0),
.clk (clk),
.q_a (q_a),
.q_b (q_b)
	);

TD_SORT td_s0(
.clk (clk),
.reset_n (reset_n),
.addr_b (addr_b),
.q_b (q_b),
.sort_dv (sort_dv),
.new_cnt (new_cnt),
.sort_led1_DC (sort_led1_DC),
.sort_led1_AC (sort_led1_AC),
.HR (HR),
.sort_done (out_new_data)
);

endmodule