//led1 buffer routing with rhiddi fft
module fft_buffer_led1_rhiddi_ftt
(
//top
input clk,

//fsm
input reset_n,

//data buffer
input signed [21:0] led1,
input in_new_samples,

output  [23:0] led1_AC,
output  [23:0] led1_DC,
output  [9:0] HR,
output  out_new_data,
output tx

//testing
/*
output [43:0] data_to_fft,
output [11:0] in_counter,
output [11:0] out_counter,
output [11:0] ram_addr,
output [3:0] state_out,
output sync_in1
*/
	);


///fft routing
wire fft_reset;
assign fft_reset = ~reset_n;
reg sync_in;
reg [35:0] din;
wire sync_out; //route to post_data
wire [35:0] dout; //route to post_data

//post_data
wire [23:0] AC_comp;
wire [23:0] DC_comp;
wire new_data_dv;
wire [9:0] hr_comp;

assign HR = hr_comp;
assign led1_AC = AC_comp;
assign led1_DC = DC_comp;
assign out_new_data = new_data_dv;

//single port bram led1
reg [21:0] led1_ram_data;
reg [10:0] led1_ram_addr;
reg led1_we;
wire [21:0] led1_received_data;


/////

reg [3:0] downsamplecounter;
reg startup_reg;
reg [3:0] startup_state;
reg [11:0] startup_smpl_cntr;
reg [11:0] input_counter = 12'd1024;
reg [11:0] output_counter;
reg [3:0] state;
reg [11:0] total_counter;

//testing
/*
assign data_to_fft = din;
assign in_counter = input_counter;
assign out_counter = output_counter;
assign ram_addr = led1_ram_addr;
assign state_out = state;
assign sync_in1 = sync_in;
*/
always@(posedge clk)
begin
	if(~reset_n)
	begin
		sync_in <= 0;
		din <= 0;
		led1_ram_data <= 0;
		led1_ram_addr <= 0;
		led1_we <= 0;
		downsamplecounter <= 0;
		startup_reg <= 0;
		startup_state <= 0;
		startup_smpl_cntr <= 0;
		input_counter <= 12'd1024;
		output_counter <= 0;
		state <= 0;
		total_counter <= 0;
	end
	else begin
		if(~startup_reg) //system startup:  fill ram to addr 1023, read values into fft, perform comp, leave startup mode
			begin
				case(startup_state)
					4'd0:
						begin
						if(startup_smpl_cntr == 11'd1024)
						begin
							startup_state <= 4'd1;
							startup_smpl_cntr <= 0;
							led1_we <= 0;
							led1_ram_addr <= 0;
						end
						else begin
							if(in_new_samples) //store every 12th sample in ram
							begin
								if(downsamplecounter == 4'd11)
									begin
										led1_ram_addr <= startup_smpl_cntr;
										led1_we <= 1;
										led1_ram_data <= led1;
										startup_smpl_cntr <= startup_smpl_cntr + 1;
										downsamplecounter <= 0;
									end
								else begin
									led1_ram_addr <= led1_ram_addr;
									led1_we <= 1;
									led1_ram_data <= led1_ram_data;
									startup_smpl_cntr <= startup_smpl_cntr;
									downsamplecounter <= downsamplecounter + 1;
								end
								end
								else begin
								led1_ram_addr <= led1_ram_addr;
								led1_we <= 1;
								led1_ram_data <= led1_ram_data;
								startup_smpl_cntr <= startup_smpl_cntr;
								downsamplecounter <= downsamplecounter;
								end
						end

			end

				4'd1: //read values into fft
				begin
					if(startup_smpl_cntr == 11'd1024)
						begin
							startup_reg <= 1;
							startup_smpl_cntr <= startup_smpl_cntr;
							sync_in <= 0;
						end
					else begin
							sync_in <= 1;
							if(led1_received_data[21] == 1'b1)
							begin
							din <= {2'b11, led1_received_data[21:6], 18'h00000};
							end
							else begin
							din <= {2'b00, led1_received_data[21:6], 18'h00000};
							end
							led1_we <= 0;
							led1_ram_addr <= startup_smpl_cntr;
							startup_smpl_cntr <= startup_smpl_cntr + 1;

						end
				end
				endcase
				end
		else begin //streaming sequence after first set of fft data is sent
			case(state)
			4'd0:
			
					
					 begin
						if(in_new_samples)
						begin
						if(downsamplecounter ==4'd11)
							begin
						led1_ram_addr <= input_counter;
						led1_we <= 1;
						led1_ram_data <= led1;
						downsamplecounter <= 4'd0;
						state <= 4'b0001;
							end
							else begin
						led1_ram_addr <= 0;
						led1_we <= 0;
						led1_ram_data <= 0;
						downsamplecounter <= downsamplecounter + 1;
						state <= state;
							end
						end
						else begin
						led1_ram_addr <= 0;
						led1_we <= 0;
						led1_ram_data <= 0;
						downsamplecounter <= downsamplecounter;
						state <= 4'b0000;	
						end
					end
					4'd1: //assign output counter
						begin
						if(input_counter == 12'd1023)
						begin
							output_counter <= 0;
							led1_ram_addr <= output_counter;
							led1_we <= 0;
							state <= 4'd2;
						end
						else if(input_counter == 12'd1024)
						begin
							output_counter <= 12'd1;
							led1_ram_addr <= output_counter;
							led1_we <= 0;
							state <= 4'd2;
						end
						else begin
							output_counter <= input_counter + 2;
							led1_ram_addr <= output_counter;
							led1_we <= 0;
							state <= 4'd2;
						end
						end
					4'd2: //fill fft
						begin
						sync_in <= 1;
						led1_we <= 0;
							if(total_counter == 12'd1025)
							begin
							state <=4'd3;
							total_counter <= 0;
							end
							else begin
							total_counter <= total_counter + 1;
							state <=  state;
							if(output_counter == 12'd1024)
								begin
									output_counter <= 0;
									led1_ram_addr <= output_counter;
									if(led1_received_data[21] == 1)
							begin
							din <= {2'b11, led1_received_data[21:6], 18'd0};
							end
							else begin
							din <= {2'b00, led1_received_data[21:6], 18'd0};
							end
								end
								else begin
							led1_ram_addr <= output_counter;
							output_counter <= output_counter + 1;
							if(led1_received_data[21] == 1)
							begin
							din <= {2'b11, led1_received_data[21:6], 18'd0};
							end
							else begin
							din <= {2'b00, led1_received_data[21:6], 18'd0};
							end
							end
							end
						end

					4'd3: //change the value of input_counter, go back to state 0 and wait for new sample
						begin
							sync_in <= 0;
							if(input_counter == 12'd1024)
							begin
								input_counter <= 0;
								state <= 4'd0;
							end
							else begin
								input_counter <= input_counter + 1;
								state <= 4'd0;
							end
					
						end
					endcase
				end
end
end


single_port_ram spr0(
.data (led1_ram_data),
.addr (led1_ram_addr),
.we (led1_we),
.clk (clk),
.q (led1_received_data)
);


fft_test fft0(
.clk (clk),
.rst (fft_reset),
.sync_in (sync_in),
.din (din),
.sync_out(sync_out),
.dout (dout)
	);

post_data_buffer_rhiddi pdbr0(
.clk (clk),
.reset_n(reset_n),
.AC_comp (AC_comp),
.DC_comp (DC_comp),
.new_comp_DV (new_data_dv),
.fft_sync (sync_out),
.fft_data (dout),
.HR (hr_comp),
.tx (tx)
	);



endmodule