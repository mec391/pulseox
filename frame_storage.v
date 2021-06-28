module frame_storage( 
//this module receives data from the the ALU, 
//determines what the frame should be, 
//and sends frames to the the TFT driver pixel by pixel
input i_clk,
input i_rst_n,

//data from ALU
input [?:0] i_hr,
input [?:0] i_spo2,
input i_ALU_DV,

//data to TFT driver
input [15:0] i_row_pixel,
input [15:0] i_col_pixel,
output [7:0] o_Red,
output [7:0] o_Green,
output [7:0] o_Blue

);

//ram_data[23:16] = red, ram_data[15:8] = green, ram_data[7:0] = blue
reg [23:0] ram_data [0:479][0:799];


//102 frames per second at 50 Mhz
//for now just cycle between R G and B
int i = 0;
int j = 0;
reg init_reg = 0;
reg r_SM = 0;
reg [15:0] frame_cnt = 0;
always@(posedge i_clk)
begin
if(~init_reg) begin
for (i = 0; i < 480; i = i + 1)begin
for (j = 0; j < 800; j = j + 1)begin
ram_data[i][j] <= 24'b11111111_00000000_00000000;
end end
init_reg <= 1;
end
else begin
case(r_SM)
0: begin
if(frame_cnt == 102) begin
frame_cnt <= 0;
for (i = 0; i < 480; i = i + 1)begin
for (j = 0; j < 800; j = j + 1)begin
ram_data[i][j] <= 24'b00000000_11111111_00000000;
end end
r_SM <= 1;
end
else r_SM <= 0;
end
1:begin
if(frame_cnt == 102) begin
frame_cnt <= 0;
for (i = 0; i < 480; i = i + 1)begin
for (j = 0; j < 800; j = j + 1)begin
ram_data[i][j] <= 24'b00000000_00000000_11111111;
end end
r_SM <= 2;
end
else r_SM <= 1;
end
2:begin
if(frame_cnt == 102) begin
frame_cnt <= 0;
for (i = 0; i < 480; i = i + 1)begin
for (j = 0; j < 800; j = j + 1)begin
ram_data[i][j] <= 24'b11111111_00000000_00000000;
end end
r_SM <= 0;
end
else r_SM <= 2;
end
endcase
end

end

endmodule