module pulse_ox (
	input i_clk,   
	input i_rst_n,  
	
	input i_miso,
	output o_mosi,
	output o_sclk,
	output o_cs_n
);


#parameter CONTROL0      0x00;
#parameter LED2STC       0x01;
#parameter LED2ENDC      0x02;
#parameter LED2LEDSTC    0x03;
#parameter LED2LEDENDC   0x04;
#parameter ALED2STC      0x05;
#parameter ALED2ENDC     0x06;
#parameter LED1STC       0x07;
#parameter LED1ENDC      0x08;
#parameter LED1LEDSTC    0x09;
#parameter LED1LEDENDC   0x0a;
#parameter ALED1STC      0x0b;
#parameter ALED1ENDC     0x0c;
#parameter LED2CONVST    0x0d;
#parameter LED2CONVEND   0x0e;
#parameter ALED2CONVST   0x0f;
#parameter ALED2CONVEND  0x10;
#parameter LED1CONVST    0x11;
#parameter LED1CONVEND   0x12;
#parameter ALED1CONVST   0x13;
#parameter ALED1CONVEND  0x14;
#parameter ADCRSTCNT0    0x15;
#parameter ADCRSTENDCT0  0x16;
#parameter ADCRSTCNT1    0x17;
#parameter ADCRSTENDCT1  0x18;
#parameter ADCRSTCNT2    0x19;
#parameter ADCRSTENDCT2  0x1a;
#parameter ADCRSTCNT3    0x1b;
#parameter ADCRSTENDCT3  0x1c;
#parameter PRPCOUNT      0x1d;
#parameter CONTROL1      0x1e;
#parameter SPARE1        0x1f;
#parameter TIAGAIN       0x20;
#parameter TIA_AMB_GAIN  0x21;
#parameter LEDCNTRL      0x22;
#parameter CONTROL2      0x23;
#parameter SPARE2        0x24;
#parameter SPARE3        0x25;
#parameter SPARE4        0x26;
#parameter RESERVED1     0x27;
#parameter RESERVED2     0x28;
#parameter ALARM         0x29;
#parameter LED2VAL       0x2a;
#parameter ALED2VAL      0x2b;
#parameter LED1VAL       0x2c;
#parameter ALED1VAL      0x2d;
#parameter LED2ABSVAL    0x2e;
#parameter LED1ABSVAL    0x2f;
#parameter DIAG          0x30;

reg r_init;
reg [3:0] r_init_SM;
always@(posedge i_clk)
begin
if(~r_init)
begin

end

end


//instantiate the SPI module - CPOL 0, CPHA 0




endmodule



module my_spi( // custom designed SPI for the AFE4490
	input i_clk,
	input i_rst_n,
	input i_miso,
	output o_mosi,
	output o_sclk, //62.5ns min -- 16MHz min
	output o_cs_n,

	input [7:0] i_addr,
	input [23:0] i_wr_data,
	input i_rd_wr, //1 for read perform, 0 for write perform

	input i_DV,
	output o_done,
	output [23:0] o_rd_data
);

reg [3:0] cnt = 8;
reg [3:0] r_SM;
always@(posedge i_clk)
begin
case(r_SM) //idle
0:begin
o_cs_n <= 1;
o_mosi <= 1;
o_sclk <= 1;
if(i_DV) r_SM <= 1;
else r_SM <= 0;
end
1:begin //toggle cs low
o_cs_n <= 0;
o_sclk <= 0;
r_SM <= 2;
end
2:begin //send addr bits
if(cnt = 0) r_SM < = 4;
else begin
o_mosi <= i_addr[7];
o_sclk <= 0;
r_SM < =3;
end
end
3: begin //toggle clock and shift data
cnt <= cnt - 1;
o_mosi <= o_mosi << 1;
o_sclk <= 1;
r_SM <= 2;
end
4:begin
cnt <= 8;
end
endcase 
end


endmodule