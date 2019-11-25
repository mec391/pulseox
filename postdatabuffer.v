module postdatabuffer(
//when done performing computations ...decide if go high after done doing all computations
//turn on post data buffer, keep on until an input 'off' goes high

//clock new data dv high for one clock cycle when done performing computations
//top module
input clk,
input reset_n,

//fft buffer
output reg pdb_done;
output reg [21:0] AC_component;
output reg [21:0] DC_component;
output reg new_comp_DV;
input fft_out_data;
input signed [23:0] Iout;
input signed [23:0] Qout;
);

reg [11:0] sample_counter;

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
reg [24:0] led3_ram_data;
reg [10:0] led3_ram_addr;
reg led3_we;
wire led3_received_data;

always@(posedge clk)
begin
	if(fft_out_data == 1'b1)
		begin
			sample_counter = sample_counter + 1;
			led1
		end
end





endmodule


