module fft_buffer
//replaces wrapper_ram for fft calculations
(
//top
input clk,

//fsm
input reset_n,

//data buffer
input [21:0] led1,
input [21:0] led2,
input in_new_samples,

output reg [9:0] hr,
output reg hr_dv,

output reg [9:0] spo2,
output reg spo2_dv,
);

//must instantiate 2 fft modules (one for led1 and led2)
//must instantiate twiddle and ram (located in his quartus files)
//must instantiate post data buffer and route info signals from fft to it


///////////////////////////fft1 routing
reg fft_reset;
assign fft_reset = ~reset_n;

//run automatically when buffer fills or use dv
reg fft_autorun = 1'b0;
reg fft_run = 1'b0;

//run high when done receiving all fft'd values
reg fft_fin;

reg ifft = 1'b0;
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
wire [21:0] dmadr_imag_data;

//twiddle rom fft
wire twact;
wire [1021:0] twa;
wire [21:0] twdr_cos;

//blck ram1 fft
wire ract_ram0;
wire [1022:0] ra_ram0;
wire [47:0] rdr_ram0;
wire wact_ram0;
wire [1022:0] wa_ram0;
wire [47:0] wdw_ram0;

//blck ram2 fft
wire ract_ram1;
wire [1022:0] ra_ram1;
wire [47:0] rdr_ram1;
wire wact_ram1;
wire [1022:0] wa_ram1;
wire [47:0] wdw_ram1;
///////////////////////////fft1 routing

//single port bram led1 
reg [22:0] led1_ram_data;
reg [10:0] led1_ram_addr;
reg led1_we;
wire led1_received_data;

//single port bram led2
reg [22:0] led2_ram_data;
reg [10:0] led2_ram_addr;
reg led2_we;
wire led2_received_data;



reg startup_reg = 1'b0;
reg [10:0] startup_smpl_cntr = 11'b0;
reg [3:0] state;
reg step;

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
			startup_smpl_cntr <= 0;
		end
		else if (in_new_samples) //fill ram and fft
				begin
				fft_run <= 0;
				fft_raw_stream <= 1;
				fft_stream_data <= led1;
				fft_raw_stream2 <= 1;
				fft_stream_data2 <= led2;
 
				led1_ram_addr <= startup_smpl_cntr;
				led1_we <= 1;
				led1_ram_data <= led1;
				led2_ram_addr <= startup_smpl_cntr;
				led2_we <= 1;
				led2_ram_data <= led2;

				startup_smpl_cntr <= startup_smpl_cntr + 1;		
				end	
		else 
			begin
				fft_run <= 0;
				fft_raw_stream <= 0;
				fft_stream_data <= 0;
				fft_raw_stream2 <= 0;
				fft_stream_data2 <= 0;

				led1_ram_addr <= 0;
				led1_we <= 0;
				led1_ram_data <= 0;
				led2_ram_addr <= 0;
				led2_we <= 0;
				led2_ram_data <= 0;

				startup_smpl_cntr <= startup_smpl_cntr;
			end
		end	
else begin
			case(state) //at least first computation done, shift over ram data 1 reg, when new sample comes in, assign it to ram 0, begin computation
				begin
					4'b0000:
						begin
							if(startup_smpl_cntr == 11'd1024)
								begin
									startup_smpl_cntr <= 0;
									state <= 4'b0001;
								end
							else begin
								case(step)
								1'b0:
									begin
									led2_ram_data <= led2_received_data;
									led2_ram_addr <= startup_smpl_cntr;
									led2_we <= 0;
									step <= 1;
									end
								1'b1:
									begin
									led2_ram_data <= led2_ram_data;
									led2_ram_addr <= led2_ram_addr;
									led2_we <= 1;
									step <= 0;
									startup_smpl_cntr <= startup_smpl_cntr + 1;
									end
								endcase
							end
						end
					4'b0001:
						begin
						if (in_new_samples)
						begin
						led1_ram_addr <= 0;
						led1_we <= 1;
						led1_ram_data <= led1;
						led2_ram_addr <= 0;
						led2_we <= 1;
						led2_ram_data <= led2;
						state <= 4'b0010;
						end
						else begin
						led1_ram_addr <= 0;
						led1_we <= 0;
						led1_ram_data <= 0;
						led2_ram_addr <= 0;
						led2_we <= 0;
						led2_ram_data <= 0;
						state <= 4'b0001;	
						end
					4'b0010:
						begin
							//this is from the post data buffer to tell me when the fft is done outputing data
							if(post_data_buffer_done)
								begin
									if(startup_smpl_cntr == 11'd1024)
									begin
										fft_run <= 1;
										startup_smpl_cntr <= 0;
										state <= 4'b0;
									end
									else begin
										////cycle thru and assign ram values to the fft module
										
									end
								end
						end
						end
					endcase
				end
		end
end
end

end


endmodule