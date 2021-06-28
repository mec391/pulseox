module pulse_ox (
	input i_clk,   
	input i_rst_n,  
	
	input i_miso,
	output o_mosi,
	output o_sclk,
	output o_cs_n
);


parameter CONTROL0      ='h00;
parameter LED2STC       ='h01;
parameter LED2ENDC      ='h02;
parameter LED2LEDSTC    ='h03;
parameter LED2LEDENDC   ='h04;
parameter ALED2STC      ='h05;
parameter ALED2ENDC     ='h06;
parameter LED1STC       ='h07;
parameter LED1ENDC      ='h08;
parameter LED1LEDSTC    ='h09;
parameter LED1LEDENDC   ='h0a;
parameter ALED1STC      ='h0b;
parameter ALED1ENDC     ='h0c;
parameter LED2CONVST    ='h0d;
parameter LED2CONVEND   ='h0e;
parameter ALED2CONVST   ='h0f;
parameter ALED2CONVEND  ='h10;
parameter LED1CONVST    ='h11;
parameter LED1CONVEND   ='h12;
parameter ALED1CONVST   ='h13;
parameter ALED1CONVEND  ='h14;
parameter ADCRSTCNT0    ='h15;
parameter ADCRSTENDCT0  ='h16;
parameter ADCRSTCNT1    ='h17;
parameter ADCRSTENDCT1  ='h18;
parameter ADCRSTCNT2    ='h19;
parameter ADCRSTENDCT2  ='h1a;
parameter ADCRSTCNT3    ='h1b;
parameter ADCRSTENDCT3  ='h1c;
parameter PRPCOUNT      ='h1d;
parameter CONTROL1      ='h1e;
parameter SPARE1        ='h1f;
parameter TIAGAIN       ='h20;
parameter TIA_AMB_GAIN  ='h21;
parameter LEDCNTRL      ='h22;
parameter CONTROL2      ='h23;
parameter SPARE2        ='h24;
parameter SPARE3        ='h25;
parameter SPARE4        ='h26;
parameter RESERVED1     ='h27;
parameter RESERVED2     ='h28;
parameter ALARM         ='h29;
parameter LED2VAL       ='h2a;
parameter ALED2VAL      ='h2b;
parameter LED1VAL       ='h2c;
parameter ALED1VAL      ='h2d;
parameter LED2ABSVAL    ='h2e;
parameter LED1ABSVAL    ='h2f;
parameter DIAG          ='h30;

reg r_init;
reg [3:0] r_init_SM;
always@(posedge i_clk)
begin
if(~r_init) //write initialization info to AFE4490
begin

end
else begin //stream data from AFE4490

end
end


//instantiate the SPI module - CPOL 0, CPHA 0

//instantiate the memory controller and algo

//instantiate the UART out

endmodule


//use the spi module from the TB
/*
module my_spi( // custom designed SPI for the AFE4490
	input i_clk,
	input i_rst_n,
	input i_miso,
	output reg o_mosi,
	output reg o_sclk, //62.5ns min -- 16MHz min
	output reg o_cs_n,

	input [7:0] i_addr,
	input [23:0] i_wr_data,
	input i_rd_wr, //1 for read perform, 0 for write perform

	input i_DV,
	output reg o_done,
	output reg [23:0] o_rd_data
);
reg [7:0] r_addr = 0;
reg [24:0] r_data = 0;
reg [4:0] cnt = 8;
reg [3:0] r_SM = 0;

always@(posedge i_clk)
begin
case(r_SM) //idle
0:begin
o_done <= 0;
cnt <= 8;
o_cs_n <= 1;
o_mosi <= 1;
o_sclk <= 0; //try keeping sclk low on idle
if(i_DV) begin r_SM <= 1;  r_addr <= i_addr; r_data <= i_wr_data; end
else r_SM <= 0;
end
1:begin //toggle cs low
o_cs_n <= 0;
o_sclk <= 0;
r_SM <= 2;
end
2:begin //toggle clock and send addr bit
if(cnt == 0) begin
	cnt <= 24;
	o_sclk <= 0;
	if(i_rd_wr) r_SM <= 4; //go to read SM
	else begin r_SM <= 6; o_mosi <= r_data[23]; end //go to write SM
	end
else begin
o_mosi <= r_addr[7];
o_sclk <= 0;
r_SM <= 3;
end
end
3: begin //toggle clock and shift data
cnt <= cnt - 1;
r_addr <= r_addr << 1;
o_sclk <= 1;
r_SM <= 2;
end
4:begin //read SM -- toggle hi and shift in data
if(cnt == 0) begin
cnt <= 8;
o_sclk <= 0;
o_done <= 1;
r_SM <= 0;
end
else begin
o_sclk <= 1;
o_rd_data[0] <= i_miso;
r_SM <= 5;
end
end
5:begin //read SM -- shift data and toggle lo 
o_rd_data <= o_rd_data << 1;
cnt <= cnt - 1;
o_sclk <= 0;
end
6:begin //write SM -- shift data and toggle hi
cnt <= cnt - 1;
r_data <= r_data << 1;
o_sclk <= 1;
r_SM <= 7;
end
7:begin //write SM -- write data and toggle lo
if(cnt == 0) begin
cnt <= 8;
r_SM <= 0;
o_done <= 1;
o_sclk <= 0;
end
else begin
o_sclk <= 0;
o_mosi <= r_data[23];
r_SM <= 6;
end
end
endcase 
end


endmodule

*/