//must do bit reversal on output
module post_data_buffer_rhiddi(

//top module
input clk,

//fsm
input reset_n,

//fft_buffer_rhiddi
output reg [21:0] AC_comp,
output reg [21:0] DC_comp,
output reg new_comp_DV,
input fft_sync, //from fft
input [43:0] fft_data, //from fft


);

reg [11:0] fft_counter;
reg [21:0] realvalue;
reg [21:0] complexvalue;
reg [21:0] sum;

always@(posedge clk)
begin
	if(~reset_n)
	begin
		//sets reg's to 0
	end
	else begin
		if(fft_counter == 12'd1024)
			begin
				fft_counter <= 0;
				compute_reg <= 1;
			end
		else begin
				
				if(fft_sync && fft_counter < 12'd1024) //only care about first 500 samples though
					begin
						fft_counter <= fft_counter + 1;
						realvalue <= {fft_data[3:0], fft_data[7:4], fft_data[11:8], fft_data[15:12], fft_data[19:16], fft_data[23:22]} * {fft_data[3:0], fft_data[7:4], fft_data[11:8], fft_data[15:12], fft_data[19:16], fft_data[23:22]};
						complexvalue <= fft_data[21:0] * fft_data[21:0]; //fix for bit reversal
						sum <= realvalue + complexvalue;


						compute_reg <= 0;
						//left off here, going to route into sqrt module

					end
				else
				begin
					if()
				end
		end
	end
end

sqrt sqrt0(
	.reset //not sure if this sqrt module is any good
	);

endmodule