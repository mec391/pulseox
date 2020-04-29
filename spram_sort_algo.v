module single_port_ram_sort
///IMPORTANT: modified to dual port for debug
(
	input [23:0] data_a, data_b,
	input [9:0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [23:0] q_a, q_b
);

	// Declare the RAM variable
	reg [23:0] ram[539:0];  // need 1024 samples

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