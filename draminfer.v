//notes:
//assume a true dual port BRAM w/single clock
//possible instantiation may replace inference after device is chosen
//7 registers, led, ambient, led-ambient, "led2...", reg 48 diag data
//two msb are 00, no value, can chop off when passed to data buffer
module DPBRAM
(
//EITHER MODIFY I/O PORTS OR....
//LEAVE Q_A OPEN, ROUTE WE_B TO A REG THAT IS ALWAYS LOW
//LEAVE DATA_B OPEN

	input [23:0] data_a, data_b, //24 bit data inputs
	input [2:0] addr_a, addr_b, //3 BIT ADDRESSES 0-6
	input we_a, we_b, clk, //write enables and clk
	output reg [23:0] q_a, q_b //24 bit data output
);

	// Declare the RAM variable
	reg [23:0] ram[8:0]; //24 bit data 7 addresses,
						//addr sel takes reg 42-48 and sends
						//0-6..
						//2 unused regs, 8:0 is min for inference
	
	// Port A
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end
	end
	
	// Port B
	always @ (posedge clk)
	begin
		if (we_b)
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else
		begin
			q_b <= ram[addr_b];
		end
	end
	
endmodule
