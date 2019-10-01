//led1 shift reg
module single_port_ram
(
	input [21:0] data,
	input [10:0] addr,
	input we, clk,
	output [21:0] q
);

	// Declare the RAM variable
	reg [21:0] ram[1025:0];  // need 1024 samples

	// Variable to hold the registered read address
	reg [10:0] addr_reg;
	
	always @ (posedge clk)
	begin
	// Write
		if (we)
			ram[addr] <= data;
		
		addr_reg <= addr;
		
	end
		
	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = ram[addr_reg];
	
endmodule