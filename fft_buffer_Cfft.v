module fft_buffer_led1_CFFT

//

//FFT BUFFER FOR CFFT
//INPUT DATA IS STILL IN 2's COMP FORM
//THINGS TO DO:
//(don't do this)convert to 22'b to voltages, adjust everything as needed--fixed point
//instantiate all the stuff
//write code for post data buffer


//modify data buffer to route with fft buffers and final data comp
//write final data comp
//write data from final data comp to fifo for data to wifi
//redo wifi to computed data
(
//top
input clk,

//fsm
input reset_n,

//data buffer
input signed [21:0] led1,
input in_new_samples,

output reg [21:0] led1_AC,
output reg [21:0] led1_DC,
output reg out_new_data


);



///////////////////////////fft1 routing begin
reg fft_reset;
assign fft_reset = ~reset_n;

reg start1 = 1'b0; //run high 1 clk before data input
reg invert1 = 1'b0;
reg signed [21:0] Iin1;
reg signed [21:0] Qin1 = 22'b0;
wire inputbusy1; //high when performing computuation
wire outdataen; //goes high when data output from fft
wire signed [23:0] Iout1;
wire signed [23:0] Qout1;
wire outposition; //not currently routed to post data buffer
///////////////////////////fft1 routing end

//post data buffer
wire post_data_buffer_done;
wire AC_comp;
wire DC_comp;
wire new_data_DV;

assign led1_AC = AC_comp;
assign led1_DC = DC_comp;
assign out_new_data = new_data_DV;

//single port bram led1 
reg [21:0] led1_ram_data;
reg [10:0] led1_ram_addr;
reg led1_we;
wire led1_received_data;


reg off;
reg startup_reg = 1'b0;
reg [10:0] startup_smpl_cntr = 11'b0;
reg [3:0] state;
reg [1:0] step;
reg [21:0] intermediate2;
reg [21:0] intermediate3;
reg [1:0] startup_state;
reg [1:0] fft_state;

//downsample to 40 sps
reg [3:0] downsamplecounter = 4'd0;

always@(posedge clk)
begin
	if(~reset_n)
		begin
			//set all regs's to 0
		end
	else 
	begin
		if(~startup_reg)
			case(startup_state)
			2'd0: //fill ram
				begin
					if(startup_smpl_cntr == 11'd1024)
						begin
							startup_state <= 2'd1;
							startup_smpl_cntr <= 0;
						end
					else begin
						startup_state <= 2'd0;
						if(in_new_samples) //store every 12th sample in ram
							begin
								if(downsamplecounter == 4'd12)
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
							else begin
								led1_ram_addr <= led1_ram_addr;
								led1_we <= 1;
								led1_ram_data <= led1_ram_data;
								startup_smpl_cntr <= startup_smpl_cntr;
								downsamplecounter <= downsamplecounter;
							end

							end
					end

				end
			2'd1: //pulse fft to start filling
				begin
					start1 <= 1;
					startup_state <= 2'd2;
				end
			2'd2:
				begin
					start1 <= 0; //start filling
					if(startup_smpl_cntr == 11'd1024)
						begin
							startup_reg = 1;
							startup_smpl_cntr <= 11'd1024;
						end
					else begin
						Iin1 <= led1_received_data;
						led1_we <= 0;
						led1_ram_addr <= startup_smpl_cntr;
						startup_smpl_cntr <= startup_smpl_cntr + 1;
					end
				end
			endcase
	else begin
		case(state) //at least first set of data sent to fft, shift over ram data 1 reg, when new sample comes in, assign it to ram 1024, begin computation
				begin //this needs reviewed for correctness
					4'b0000:
						begin
						off <= 0;
							if(startup_smpl_cntr == 11'd0)
								begin
									state <= 4'b0001;
								end
							else begin
							if(first_part == 1'b0)
							begin
								case(step) //code for starting at 1024
								2'd0:
									begin //get to correct address
									led1_ram_data <= led1_ram_data;
									led1_ram_addr <= startup_smpl_cntr;
									led1_we <= 0;
									step <= 1;
									end
								2'd1:
									begin //assign intermediate reg that value at addr
									intermediate2 <= led1_received_data;
									led1_ram_data <= led1_ram_data;
									led1_ram_addr <= led1_ram_addr;
									led1_we <= 0;
									step <= 2'd2;
									startup_smpl_cntr <= startup_smpl_cntr - 1;
									end
								2'd2:
									begin //move addr to new location/turn on WE/assign value there to a reg
									intermediate3 <= led1_received_data;
									led1_ram_addr <= startup_smpl_cntr;
									led1_ram_data <= led1_ram_data;
									led1_we <= 1;
									startup_smpl_cntr <= startup_smpl_cntr;
									step <= 2'd3;
									end
								2'd3:
									begin //assign old reg value to new addr
									led1_ram_addr <= led1_ram_addr;
									led1_ram_data <= intermediate2;
									led1_we <= 1;
									startup_smpl_cntr <= startup_smpl_cntr;
									step <= 0;
									first_part <= 1;
									end
									end
								endcase
								end
								else begin 
									case(step2) //code for rest of values
									4'd0:
										begin//move down 1 value
									led1_ram_data <= led1_ram_data;
									led1_ram_addr <= startup_smpl_cntr;
									led1_we <= 0;
									step2 <= 1;
									startup_smpl_cntr <= startup_smpl_cntr - 1;
									end
									4'd1:
									begin //assign intermediate reg that value at addr
									intermediate2 <= led1_received_data;
									led1_ram_data <= led1_ram_data;
									led1_ram_addr <= led1_ram_addr;
									led1_we <= 0;
									step2 <= 4'd2;
									startup_smpl_cntr <= startup_smpl_cntr;
									end		
									4'd2://assign prev value to current reg
									begin
										led1_ram_data <= intermediate3;
										led1_ram_addr <= startup_smpl_cntr;
										led1_we <= 1;
										step2 <= 4'd3;
										startup_smpl_cntr <= startup_smpl_cntr;
									end
									4'd3: //move down/turn off we
										begin
											led1_ram_addr <= startup_smpl_cntr;
											led1_ram_data <= led1_ram_data;
											led1_we <= 0;
											step2 <= 4'd4;
											startup_smpl_cntr <= startup_smpl_cntr - 1;
										end
									4'd4: //assign int3 reg the value
										begin
											led1_ram_addr <= startup_smpl_cntr;
											led1_ram_data <= led1_ram_data;
											led1_we <= 0;
											intermediate3 <= led1_received_data;
											step2 <= 4'd5;
											startup_smpl_cntr <= startup_smpl_cntr;
										end
									4'd5: //assign ram old value
										begin
											led1_ram_addr <= startup_smpl_cntr;
											led1_we <= 1;
											led1_ram_data <= intermediate2;
											startup_smpl_cntr <= startup_smpl_cntr;
											step2 <= 4'd0;
										end
									endcase	
								end
							end
						end
					4'b0001: //assign addr 1024 new sample when it comes in
						begin
						if (in_new_samples)
							if(downsamplecounter ==4'd12)
							begin
						led1_ram_addr <= 11'd1024;
						led1_we <= 1;
						led1_ram_data <= led1;
						downsamplecounter <= 4'd0;
						state <= 4'b0010;
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
						state <= 4'b0001;	
						end
					4'b0010:
						begin
							//this is from the post data buffer to tell me when the fft is done outputing data
							if(post_data_buffer_done) 
								begin
								off <= 1;
									if(startup_smpl_cntr == 11'd1024)
									begin
										state <= 4'b0;
									end
									else begin
		////cycle thru and assign ram values to the fft module
								case(fft_state)
								2'd1: //pulse fft to start filling
				begin
					start1 <= 1;
					startup_state <= 2'd2;
				end
			2'd2:
				begin
					start1 <= 0;
					if(startup_smpl_cntr == 11'd1024)
						begin
							startup_reg = 1;
							startup_smpl_cntr <= 11'd1024;
						end
					else begin
						Iin1 <= led1_received_data;
						led1_we <= 0;
						led1_ram_addr <= startup_smpl_cntr;
						startup_smpl_cntr <= startup_smpl_cntr + 1;
					end
				end
					
						end
						end
					endcase
	end

	end
end


single_port_ram sp1(
.data (led1_ram_data),
.addr (led1_ram_addr),
.we (led1_we),
.clk (clk),
.q(led1_received_data)
	);

cfft cfft1(
.clk (clk),
.rst (fft_reset),
.start(start1),
.invert(invert1),
.Iin (Iin1),
.Qin (Qin1),
.inputbusy(inputbusy1),
.outdataen(outdataen1),
.Iout(Iout1),
.Qout(Qout1),
.OutPosition(outposition1)
	);

postdatabuffer pdb1(
.clk(clk),
.reset_n(reset_n),
.pdb_done(post_data_buffer_done);
.AC_component(AC_comp);
.DC_component(DC_comp);
.new_comp_DV(new_data_DV);
.fft_out_data(outdataen1);
.Iout(Iout1);
.Qout(Qout1);
	);

endmodule