module TD_DPRAM
(


	input [21:0] data_a, data_b, //24 bit data inputs
	input [10:0] addr_a, addr_b, //3 BIT ADDRESSES 0-6
	input we_a, we_b, clk, //write enables and clk
	output reg [21:0] q_a, q_b //24 bit data output
);

	// Declare the RAM variable
	reg [21:0] ram[1502:0]; //24 bit data 7 addresses,
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
