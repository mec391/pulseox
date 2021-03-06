module fft_buffer_led1
//FFT BUFFER FOR R2FFT (NOT USING AT THE MOMENT)
//INPUT DATA IS STILL IN 2's COMP FORM
//THINGS TO DO:
//(don't do this)convert to 22'b to voltages, adjust everything as needed
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

//must instantiate twiddle and ram (located in his quartus files)
//must instantiate post data buffer and route info signals from fft to it


///////////////////////////fft1 routing begin
reg fft_reset;
assign fft_reset = ~reset_n;

//run automatically when buffer fills or use dv
reg fft_autorun = 1'b0;
reg fft_run = 1'b0;

//run high when done receiving all fft'd values
reg fft_fin;

reg ifft1 = 1'b0;
wire fft_done;
wire [2:0] fft_status;
wire [7:0] fft_bfpexp;

//clock high with input data
reg fft_raw_stream;
reg [21:0] fft_raw_stream_data;
reg [21:0] fft_raw_stream_imag = 22'b0;

//fft output info -- route to post data buffer
wire fft_dmaact_bus_active;
wire [1023:0] dmaa_bus_addr;
wire  [21:0] dmadr_real_data;
wire [21:0] dmadr_imag_data; //route fft_done to data buffer as well

//twiddle rom fft
wire twact1;
wire [1021:0] twa1;
wire [21:0] twdr_cos1;

//blck ram1 fft
wire ract_ram00;
wire [1022:0] ra_ram00;
wire [47:0] rdr_ram00;
wire wact_ram00;
wire [1022:0] wa_ram00;
wire [47:0] wdw_ram00;

//blck ram2 fft
wire ract_ram11;
wire [1022:0] ra_ram11;
wire [47:0] rdr_ram11;
wire wact_ram11;
wire [1022:0] wa_ram11;
wire [47:0] wdw_ram11;
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

//downsample to 40 sps
reg [3:0] downsamplecounter = 4'd0;




always@(posedge clk)
begin

	if(~reset_n)
		begin
		///apply resets to regs	
		end
else 
begin
	if(~startup_reg) //fft and ram is full, begin first computation
		begin
		if(startup_smpl_cntr == 11'd1024)
		begin
			fft_run <= 1;
			startup_reg <= 1;
			startup_smpl_cntr <= 11'd1024;
		end
		else if (in_new_samples) //fill ram and fft
				begin
				if(downsamplecounter == 4'd12)
				begin
								
				fft_run <= 0;
				fft_raw_stream <= 1;
				fft_stream_data <= led1;
 
				led1_ram_addr <= startup_smpl_cntr;
				led1_we <= 1;
				led1_ram_data <= led1;

				startup_smpl_cntr <= startup_smpl_cntr + 1;	
				downsamplecounter <= 0;
				end
				
					
				else begin
					fft_run <= 0;
				fft_raw_stream <= 0;
				fft_stream_data <= 0;
			

				led1_ram_addr <= 0;
				led1_we <= 0;
				led1_ram_data <= 0;
				

				startup_smpl_cntr <= startup_smpl_cntr;
				downsamplecounter <= downsamplecounter + 1;	
				end
				end	
		else 
			begin
				fft_run <= 0;
				fft_raw_stream <= 0;
				fft_stream_data <= 0;
				

				led1_ram_addr <= 0;
				led1_we <= 0;
				led1_ram_data <= 0;
				

				startup_smpl_cntr <= startup_smpl_cntr;
			end
		end 	
else begin   
			case(state) //at least first computation done, shift over ram data 1 reg, when new sample comes in, assign it to ram 1024, begin computation
				begin
					4'b0000:
						begin
						off <= 0;
						fft_run <= 0;
							if(startup_smpl_cntr == 11'd0)
								begin
									state <= 4'b0001;
								end
							else begin
								case(step)
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

								2'd2:
									begin //move addr to new location/turn on WE
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
									end
									end
								endcase
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
										fft_run <= 1;
										state <= 4'b0;

									end
									else begin
		////cycle thru and assign ram values to the fft module
				fft_run <= 0;

				fft_raw_stream <= 1;
				fft_stream_data <= led1_received_data;
				led1_we <= 0;
				led1_ram_addr <= startup_smpl_cntr;

				startup_smpl_cntr <= startup_smpl_cntr + 1;	
									end
								end
						end
						else begin
							fft_run <= 0;

				fft_raw_stream <= 1;
				fft_stream_data <= led1_received_data;
				led1_we <= 0;
				led1_ram_addr <= startup_smpl_cntr;

				startup_smpl_cntr <= startup_smpl_cntr + 1;	
						end
						end
					endcase
				end
		end
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

R2FFT r21(
.clk (clk),
.rst (fft_reset),
.autorun (fft_autorun),
.run (fft_run),
.fin (fft_fin),
.ifft (ifft1),
.done (fft_done),
.status(fft_status),
.bfpexp(fft_bfpexp),
.sact_istream(fft_raw_stream),
.sdw_istream_real(fft_raw_stream_data),
.sdw_istream_imag(fft_raw_stream_imag),
.dmacct(fft_dmaact_bus_active),
.dmaa(dmaa_bus_addr),
.dmadr_real(dmadr_real_data),
.dmadr_imag(dmadr_imag_data),
.twact (twact1),
.twa (twa1),
.twdr_cos(twdr_cos1),
.ract_ram0(ract_ram00),
.ra_ram0(ra_ram00),
.rdr_ram0(rdr_ram00),
.wact_ram0(wact_ram00),
.wa_ram0(wa_ram00),
.wdw_ram0(wdw_ram00),
.ract_ram1(ract_ram11),
.ra_ram1(ra_ram11),
.rdr_ram1(rdr_ram11),
.wact_ram1(wact_ram11),
.wa_ram1(wa_ram11),
.wdw_ram1(wdw_ram11)
	);

//need to instantiate twiddle, dpram 1 and 2, post data buffer


endmodule