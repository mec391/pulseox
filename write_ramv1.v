module write_ramv1

#(parameter CONTROL0   = 6'h00,
parameter LED2STC  =   6'h01,
parameter LED2ENDC  =  6'h02,
parameter LED2LEDSTC  =  6'h03,
parameter LED2LEDENDC  = 6'h04,
parameter ALED2STC   = 6'h05,
parameter ALED2ENDC  = 6'h06,
parameter LED1STC    = 6'h07,
parameter LED1ENDC   = 6'h08,
parameter LED1LEDSTC  =  6'h09,
parameter LED1LEDENDC  = 6'h0a,
parameter ALED1STC  =  6'h0b,
parameter ALED1ENDC  = 6'h0c,
parameter LED2CONVST  =  6'h0d,
parameter LED2CONVEND  = 6'h0e,
parameter ALED2CONVST  = 6'h0f,
parameter ALED2CONVEND = 6'h10,
parameter LED1CONVST   = 6'h11,
parameter LED1CONVEND  = 6'h12,
parameter ALED1CONVST  = 6'h13,
parameter ALED1CONVEND = 6'h14,
parameter ADCRSTCNT0   = 6'h15,
parameter ADCRSTENDCT0 = 6'h16,
parameter ADCRSTCNT1   = 6'h17,
parameter ADCRSTENDCT1 = 6'h18,
parameter ADCRSTCNT2   = 6'h19,
parameter ADCRSTENDCT2  =6'h1a,
parameter ADCRSTCNT3   = 6'h1b,
parameter ADCRSTENDCT3 = 6'h1c,
parameter PRPCOUNT   = 6'h1d,
parameter CONTROL1   = 6'h1e,
parameter SPARE1     = 6'h1f,
parameter TIAGAIN    = 6'h20,
parameter TIA_AMB_GAIN = 6'h21,
parameter LEDCNTRL   = 6'h22,
parameter CONTROL2   = 6'h23,
parameter SPARE2     = 6'h24,
parameter SPARE3     = 6'h25,
parameter SPARE4     = 6'h26,
parameter RESERVED1  = 6'h27,
parameter RESERVED2  = 6'h28,
parameter ALARM    = 6'h29,
parameter LED2VAL   =  6'h2a,
parameter ALED2VAL   = 6'h2b,
parameter LED1VAL  =   6'h2c,
parameter ALED1VAL  =  6'h2d,
parameter LED2ABSVAL =   6'h2e,
parameter LED1ABSVAL  =  6'h2f,
parameter DIAG   =   6'h30)

(
//top module
input clk,

//fsm
input in_reset_n,
input [2:0] in_w_control,

//addr sel
input [7:0] in_addr_w,
input in_w_begin,

//spi
output reg [7:0] out_addr_w,
output reg [23:0] out_data,
output reg out_w_begin

	);

reg [23:0] ram[35:0];

always@(posedge clk)
begin
	if(~in_reset_n)
		begin
			//timing regs, default to table2 afe4490 datasheet
			
	/*		ram[0] <= 0;
			ram[1] <= 6050;
			ram[2] <= 7998;
			ram[3] <= 6000;
			ram[4] <= 7999;
			ram[5] <= 50;
			ram[6] <= 1998;
			ram[7] <= 2050;
			ram[8] <= 3998;
			ram[9] <= 2000;
			ram[10] <= 3999;
			ram[11] <= 4050;
			ram[12] <= 5998;
			ram[13] <= 4;
			ram[14] <= 1999;
			ram[15] <= 2004;
			ram[16] <= 3999;
			ram[17] <= 4004;
			ram[18] <= 5999;
			ram[19] <= 6004;
			ram[20] <= 7999;
			ram[21] <= 0;
			ram[22] <= 3;
			ram[23] <= 2000;
			ram[24] <= 2003;
			ram[25] <= 4000;
			ram[26] <= 4003;
			ram[27] <= 6000;
			ram[28] <= 6003;
			ram[29] <= 7999;
		//control regs
			ram[30] <=
			ram[31] <= 0;      //blank reg
			ram[32] <=
			ram[33] <=
			ram[34] <=
			ram[35] <= 
					*/

		//config based on arduino code
		ram[CONTROL0] <= 24'h0;
	 ram[TIAGAIN] <= 24'h000000; // CF = 5pF, RF = 500kR
     ram[TIA_AMB_GAIN] <= 24'h000001; 
     
     ram[LEDCNTRL] <= 24'h001414;    
     ram[CONTROL2] <= 24'h000000; // LED_RANGE=100mA, LED=50mA 
     ram[CONTROL1] <= 24'h010707; // Timers ON, average 3 samples  
    
     ram[PRPCOUNT] <=  24'h001F3F; //about 500 samples per sec ???

    ram[LED2STC] <=  24'h001770;
    ram[LED2ENDC] <= 24'h001F3E; 
    ram[LED2LEDSTC] <= 24'h001770;
    ram[LED2LEDENDC] <= 24'h001F3F;
    ram[ALED2STC] <= 24'h000000; 
    ram[ALED2ENDC] <= 24'h0007CE;
    ram[LED2CONVST] <= 24'h000002; 
    ram[LED2CONVEND] <= 24'h0007CF;
    ram[ALED2CONVST] <= 24'h0007D2;
    ram[ALED2CONVEND] <= 24'h000F9F;

    ram[LED1STC] <= 24'h0007D0; 
    ram[LED1ENDC] <= 24'h000F9E;
    ram[LED1LEDSTC] <= 24'h0007D0;
    ram[LED1LEDENDC] <= 24'h000F9F;
    ram[ALED1STC] <= 24'h000FA0; 
    ram[ALED1ENDC] <= 24'h00176E;
    ram[LED1CONVST] <= 24'h000FA2; 
    ram[LED1CONVEND] <= 24'h00176F;
    ram[ALED1CONVST] <= 24'h001772;
    ram[ALED1CONVEND] <= 24'h001F3F; 

    ram[ADCRSTCNT0] <= 24'h000000; 
    ram[ADCRSTENDCT0] <=24'h000000; 
    ram[ADCRSTCNT1] <=  24'h0007D0; 
    ram[ADCRSTENDCT1] <=  24'h0007D0;
    ram[ADCRSTCNT2] <= 24'h000FA0; 
    ram[ADCRSTENDCT2] <=  24'h000FA0; 
    ram[ADCRSTCNT3] <= 24'h001770; 
    ram[ADCRSTENDCT3] <= 24'h001770;



			out_addr_w <= 0;
			out_data <= 0;
			out_w_begin <= 0;
		end

	else 
		begin
			case (in_w_control)
			3'b000: //take no action
				begin
					if(in_w_begin)
					begin
					out_addr_w <= 0;
					out_data <= 0;
					out_w_begin <= 0;
					end
					else 
					begin
					out_addr_w <= 0;
					out_data <= 0;
					out_w_begin <= 0;	
					end
				end
			3'b001: //reset afe
				
						begin
							if(in_w_begin)
							begin
							out_addr_w <= 0;
							out_data <= 24'd8;
							out_w_begin <= 1;
							end
							else
							begin
								out_addr_w <= 0;
								out_data <= 24'd8;
								out_w_begin <= 0;
							end
						end
				
			3'b010: //perform diagnostics afe
				
						begin
							if(in_w_begin)
							begin
							out_addr_w <= 0;
							out_data <= 4;
							out_w_begin <= 1;
							end
							else begin
								out_addr_w <= 0;
								out_data <= 4;
								out_w_begin <= 0;
							end
						end
					
			
			3'b011: //set afe to read mode
				
						begin
							if(in_w_begin)
							begin
							out_addr_w <= 0;
							out_data <= 1;
							out_w_begin <= 1;
							end
							else begin
								out_addr_w <= 0;
								out_data <= 1;
								out_w_begin <= 0;
							end
						end
					
			3'b100: //set afe to write mode
						begin
							if(in_w_begin)
							begin
							out_addr_w <= 0;
							out_data <= 0;
							out_w_begin <= 1;
							end
							else begin
								out_addr_w <= 0;
								out_data <= 0;
								out_w_begin <= 0;
							end
						end
					
			3'b101: //write default config data to afe
				begin
					if(in_w_begin)
					begin
					 out_data <= ram[in_addr_w];
					 out_addr_w <= in_addr_w;
					 out_w_begin <= 1;
					 end
					 else begin
					 	out_data <= ram[in_addr_w];
					 	out_addr_w <= in_addr_w;
					 	out_w_begin <= 0;
					 end
				end
			default :
			begin
				out_data <= 0;
				out_addr_w <= 0;
				out_w_begin <= 0;
			end
			endcase
			end
			
		end






endmodule
