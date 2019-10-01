//wifi module for serial (UART) comm to esp8266
//wrapper module for wifitest module
module wifiv1

#(
   parameter A_u = 8'd65,
   parameter B_u = 8'd66,
   parameter C_u = 8'd67,
   parameter D_u = 8'd68,
   parameter E_u = 8'd69,
   parameter F_u = 8'd70,
   parameter G_u = 8'd71,
   parameter H_u = 8'd72,
   parameter I_u = 8'd73,
   parameter J_u = 8'd74,
   parameter K_u = 8'd75,
   parameter L_u = 8'd76,
   parameter M_u = 8'd77,
   parameter N_u = 8'd78,
   parameter O_u = 8'd79,
   parameter P_u = 8'd80,
   parameter Q_u = 8'd81,
   parameter R_u = 8'd82,
   parameter S_u = 8'd83,
   parameter T_u = 8'd84,
   parameter U_u = 8'd85,
   parameter V_u = 8'd86,
   parameter W_u = 8'd87,
   parameter X_u = 8'd88,
   parameter Y_u = 8'd89,
   parameter Z_u = 8'd90,
   parameter a = 8'd97,
   parameter b = 8'd98,
   parameter c = 8'd99,
   parameter d = 8'd100,
   parameter e = 8'd101,
   parameter f = 8'd102,
   parameter g = 8'd103,
   parameter h = 8'd104,
   parameter i = 8'd105,
   parameter j = 8'd106,
   parameter k = 8'd107,
   parameter l = 8'd108,
   parameter m = 8'd109,
   parameter n = 8'd110,
   parameter o = 8'd111,
   parameter p = 8'd112,
   parameter q = 8'd113,
   parameter r = 8'd114,
   parameter s = 8'd115,
   parameter t = 8'd116,
   parameter u = 8'd117,
   parameter v = 8'd118,
   parameter w = 8'd119,
   parameter x = 8'd120,
   parameter y = 8'd121,
   parameter z = 8'd122,

   parameter newline = 8'd10,
   parameter return = 8'd13,
   parameter quote = 8'd34,
   parameter equal = 8'd61,
   parameter plus = 8'd43,
   parameter comma = 8'd44,
   parameter dot = 8'd46,
   parameter space = 8'd32,
   parameter forward_slash = 8'd47,
   parameter question_mark = 8'd63,
   parameter and_symbol = 8'd38,
   parameter colon = 8'd58,

   parameter zero = 8'd48,
   parameter one = 8'd49,
   parameter two = 8'd50,
   parameter three = 8'd51,
   parameter four = 8'd52,
   parameter five = 8'd53,
   parameter six = 8'd54,
   parameter seven = 8'd55,
   parameter eight = 8'd56,
   parameter nine = 8'd57


  )

(

//top module
input clk,

output tx,
input rx,


//commented out for testing



//fsm
output reg stream_start,
output reg stream_stop,
output reg cpu_reset_n, 
input stream_rdy,
input diag_error,


//data buffer
input [13:0] diag_error_data,

//fifo (for now just doing raw samples led1 and led2)

input [21:0] led1,
input [21:0] led2,
input data_rdy


	);

//io ports as regs/wires because testing
/*reg stream_start = 1'b1;
reg stream_stop = 1'b0;
reg cpu_reset_n = 1'b1; 
reg stream_rdy = 1'b1;
reg diag_error = 1'b0;

reg  [21:0] led1 = 22'd1;
reg  [21:0] led2 = 22'd2;
reg data_rdy = 1'b1;*/
/////////////////


reg [24:0] delay_counter;
reg [3:0] delaycounter_state;
reg [4:0] delaycounter_stream_state;

reg reset_n = 1'b1; //keep until two way wifi comm is figured out

reg [3:0] state;
reg [4:0] stream_state;

wire half_clk;
reg slow_clk;

//lower module
reg [7:0] byte_0;
reg [7:0] byte_1;
reg [7:0] byte_2;
reg [7:0] byte_3;
reg [7:0] byte_4;
reg [7:0] byte_5;
reg [7:0] byte_6;
reg [7:0] byte_7;

//lower module
reg begin_tx;
wire tx_done;

reg init_reg = 1'b0;


//before two way comm comes in
reg stream_stop_reg = 1'b0;


always@(posedge clk)
  begin
	stream_stop <= stream_stop_reg;
    slow_clk <= half_clk;
    cpu_reset_n <= 1'b1;
  end

always@(posedge slow_clk)
  begin
    if(~init_reg) //make sure to turn high after init
      begin
        case(state)
        4'b0000:
          begin
            byte_0 <= A_u;
            byte_1 <= T_u;
            byte_2 <= plus;
            byte_3 <= R_u;
            byte_4 <= S_u;
            byte_5 <= T_u;
            byte_6 <= return;
            byte_7 <= newline;
            begin_tx <= 1;
            delaycounter_state <= 4'b0001;
             state <= 4'b1011;               //add 1 sec delay
          end
          4'b0001:
          
              
                begin
                  byte_0 <= A_u;
                  byte_1 <= T_u;
                  byte_2 <= plus;
                  byte_3 <= C_u;
                  byte_4 <= W_u;
                  byte_5 <= M_u;
                  byte_6 <= O_u;
                  byte_7 <= D_u;
                  begin_tx <= 1;
                  state <= 4'b0010;
              
               
            end
            4'b0010:
              begin
                if(tx_done)
                begin
                  byte_0 <= E_u;
                  byte_1 <= equal;
                  byte_2 <= one;
                  byte_3 <= return;
                  byte_4 <= newline;
                  byte_5 <= 0;
                  byte_6 <= 0;
                  byte_7 <= 0;
                  begin_tx <= 1;
                  delaycounter_state <= 4'b0011; //1 sec delay
                  state <= 4'b1011;
                end
                else begin
                  byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  state <= state;
                end
              end 
              4'b0011:
                
                    begin
                      byte_0 <= A_u;
                      byte_1 <= T_u;
                      byte_2 <= plus;
                      byte_3 <= C_u;
                      byte_4 <= W_u;
                      byte_5 <= J_u;
                      byte_6 <= A_u;
                      byte_7 <= P_u;
                      begin_tx <= 1;
                      state <= 4'b0100;
                    
                   
                end
                4'b0100:
                  begin
                  if(tx_done)
                    begin
                      byte_0 <= equal;
                      byte_1 <= quote;
                      byte_2 <= f;
                      byte_3 <= p;
                      byte_4 <= g;
                      byte_5 <= a;
                      byte_6 <= S_u;
                      byte_7 <= e;
                      begin_tx <= 1;
                      state <= 4'b0101;
                      end
                    else begin
                  byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  state <= state;
                    end
                  end
                  4'b0101:
                    begin
                    if (tx_done)
						  begin
                      byte_0 <= r;
                      byte_1 <= v;
                      byte_2 <= e;
                      byte_3 <= r;
                      byte_4 <= quote;
                      byte_5 <= comma;
                      byte_6 <= quote;
                      byte_7 <= m;
                      begin_tx <= 1;
                      state <= 4'b0110;
                    end
                    else begin
                  byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  state <= state;
                    end
                    end
                  4'b0110:
                    begin
                      if(tx_done)
                      begin
                      byte_0 <= a;
                      byte_1 <= t;
                      byte_2 <= t;
                      byte_3 <= h;
                      byte_4 <= e;
                      byte_5 <= w;
                      byte_6 <= c;
                      byte_7 <= a;
                      begin_tx <= 1;
                      state <= 4'b0111;
                      end
                      else begin
                  byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  state <= state;
                      end
                    end
                    4'b0111:
                    begin
						  if (tx_done)
						  begin
                    byte_0 <= p;
                    byte_1 <= u;
                    byte_2 <= a;
                    byte_3 <= n;
                    byte_4 <= o;
                    byte_5 <= quote;
                    byte_6 <= return;
                    byte_7 <= newline;
                    begin_tx <= 1; //1 sec delay
                    delaycounter_state <= 4'b1000;
                    state <= 4'b1011;
                    end
                    else begin
                         byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  state <= state;
                    end
                   end
                   4'b1000:
                    
                        begin
                          byte_0 <= A_u;
                          byte_1 <= T_u;
                          byte_2 <= plus;
                          byte_3 <= C_u;
                          byte_4 <= I_u;
                          byte_5 <= P_u;
                          byte_6 <= M_u;
                          byte_7 <= U_u;
                          begin_tx <= 1;
                          state <= 4'b1001;
                        end
                        
                    
                    4'b1001:
                      begin
                      if(tx_done)
                        begin
                          byte_0 <= X_u;
                          byte_1 <= equal;
                          byte_2 <= zero;
                          byte_3 <= return;
                          byte_4 <= newline;
                          byte_5 <= 0;
                          byte_6 <= 0;
                          byte_7 <= 0;
                          begin_tx <= 1; //1 sec delay
                          delaycounter_state <= 4'b1010;
                          state <= 4'b1011;
                        end
                        else begin
                        byte_0 <= byte_0;
                           byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  state <= state;
                        end
                      end
                    4'b1010:
                      
                        begin
                        byte_0 <= 0;
                        byte_1 <= 0;
                        byte_2 <= 0;
                        byte_3 <= 0;
                        byte_4 <= 0;
                        byte_5 <= 0;
                        byte_6 <= 0;
                        byte_7 <= 0;
                        state <= 0;
                        begin_tx <= 0;
                        init_reg <= 1;
                        
                       
                      end
                      4'b1011:
                        begin
                        begin_tx <= 0;
                          if (delay_counter == 25'd33554431)
                      begin
                        delay_counter <= 25'd0;
                        state <= delaycounter_state;
                      end
                      else begin
                        delay_counter <= delay_counter + 1;
                        state <= state;
                      end
                        end
        endcase
		  end
else begin
  case(stream_state)
  5'd0:
    begin
      if(stream_rdy)
        begin
          stream_start <= 1;
          stream_state <= 5'd1;
        end
        else begin
          stream_start <= 0;
          stream_state <= 0;
        end
    end
5'd1:
  begin
      if(data_rdy)
        begin
          stream_state <= 5'd2;
        end
        else begin
          stream_state <= stream_state;
        end
  end
  5'd2:
    begin //assume this entire process takes less time than for a new 500 sps sample to come in
                  byte_0 <= A_u;
                  byte_1 <= T_u;
                  byte_2 <= plus;
                  byte_3 <= C_u;
                  byte_4 <= I_u;
                  byte_5 <= P_u;
                  byte_6 <= S_u;
                  byte_7 <= T_u;
                  begin_tx <= 1;
                  stream_state <= 5'd3;
    end

    5'd3:
      begin
          if (tx_done)
            begin
                  byte_0 <= A_u;
                  byte_1 <= R_u;
                  byte_2 <= T_u;
                  byte_3 <= equal;
                  byte_4 <= quote;
                  byte_5 <= T_u;
                  byte_6 <= C_u;
                  byte_7 <= P_u;
                  begin_tx <= 1;
                  stream_state <= 5'd4;
            end
            else begin
                  byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state;
            end
      end
      5'd4:
        begin
          if(tx_done)
            begin
                  byte_0 <= quote;
                  byte_1 <= comma;
                  byte_2 <= quote;
                  byte_3 <= one;
                  byte_4 <= nine;
                  byte_5 <= two;
                  byte_6 <= dot;
                  byte_7 <= one;
                  begin_tx <= 1;
                  stream_state <= 5'd5;
                  end
                  else begin
                  byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state;  
                  end
        end
        5'd5:
          begin
                  if (tx_done)
                    begin
                  byte_0 <= six;
                  byte_1 <= eight;
                  byte_2 <= dot;
                  byte_3 <= four;
                  byte_4 <= two;
                  byte_5 <= dot;
                  byte_6 <= one;
                  byte_7 <= quote;
                  begin_tx <= 1;
                  stream_state <= 5'd6;
                  end
                  else begin
                     byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state;  
                  end
          end
          5'd6:
            begin
              if(tx_done)
                begin
              byte_0 <= comma;
                  byte_1 <= eight;
                  byte_2 <= zero;
                  byte_3 <= return;
                  byte_4 <= newline;
                  byte_5 <= 0;
                  byte_6 <= 0;
                  byte_7 <= 0;
                  begin_tx <= 1;
                  delaycounter_stream_state <= 5'd7;
                  stream_state <= 5'd24;
                  end
                else begin
                   byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                end
            end
            5'd7:
              
              
              begin
                 byte_0 <= A_u;
                  byte_1 <= T_u;
                  byte_2 <= plus;
                  byte_3 <= C_u;
                  byte_4 <= I_u;
                  byte_5 <= P_u;
                  byte_6 <= S_u;
                  byte_7 <= E_u;
                  begin_tx <= 1;
                  stream_state <= 5'd8; 
                  end
                
              
              5'd8:
              begin
              if (tx_done)
                begin
                 byte_0 <= N_u;
                  byte_1 <= D_u;
                  byte_2 <= equal;
                  byte_3 <= one; // might need adjusted
                  byte_4 <= zero; //might need adjusted
                  byte_5 <= five;
                  byte_6 <= return;
                  byte_7 <= newline;
                  begin_tx <= 1;
                  delaycounter_stream_state <= 5'd9;
                  stream_state <= 5'd24;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
              end
              5'd9:
                
                begin
                 byte_0 <= G_u;
                  byte_1 <= E_u;
                  byte_2 <= T_u;
                  byte_3 <= space; 
                  byte_4 <= forward_slash;
                  byte_5 <= i;
                  byte_6 <= n;
                  byte_7 <= d;
                  begin_tx <= 1;
                  stream_state <= 5'd10;
                  end 
                
                5'd10:
                  begin
                   if (tx_done)
                begin
                 byte_0 <= e;
                  byte_1 <= x;
                  byte_2 <= dot;
                  byte_3 <= p; 
                  byte_4 <= h; 
                  byte_5 <= p;
                  byte_6 <= question_mark;
                  byte_7 <= h;
                  begin_tx <= 1;
                  stream_state <= 5'd11;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end  
                  end
                  5'd11:
                    begin
                       if (tx_done)
                begin
                 byte_0 <= e;
                  byte_1 <= a;
                  byte_2 <= r;
                  byte_3 <= t; 
                  byte_4 <= equal; 
                  byte_5 <= led1[21] + 48;
                  byte_6 <= led1[20] + 48;
                  byte_7 <= led1[19] + 48;
                  begin_tx <= 1;
                  stream_state <= 5'd12;

                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end  
                    end
                  5'd12:
                    begin
                            
                       if (tx_done)
                begin
                 byte_0 <= led1[18] + 48;
                  byte_1 <= led1[17] + 48;
                  byte_2 <= led1[16] + 48;
                  byte_3 <= led1[15] + 48; 
                  byte_4 <= led1[14] + 48; 
                  byte_5 <= led1[13] + 48;
                  byte_6 <= led1[12] + 48;
                  byte_7 <= led1[11] + 48;
                  begin_tx <= 1;
                  stream_state <= 5'd13;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end  
                    end
                  5'd13:
                    begin
                       if (tx_done)
                begin
                 byte_0 <= led1[10] + 48;
                  byte_1 <= led1[9] + 48;
                  byte_2 <= led1[8] + 48;
                  byte_3 <= led1[7] + 48; 
                  byte_4 <= led1[6] + 48; 
                  byte_5 <= led1[5] + 48;
                  byte_6 <= led1[4] + 48;
                  byte_7 <= led1[3] + 48;
                  begin_tx <= 1;
                  stream_state <= 5'd14;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end  
                    end
                    5'd14:
                      begin
                          if (tx_done)
                begin
                 byte_0 <= led1[2] + 48;
                  byte_1 <= led1[1] + 48;
                  byte_2 <= led1[0] + 48;
                  byte_3 <= and_symbol; 
                  byte_4 <= b; 
                  byte_5 <= l;
                  byte_6 <= d;
                  byte_7 <= o;
                  begin_tx <= 1;
                  stream_state <= 5'd15;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end   
                      end
                5'd15:
                  begin
                        if (tx_done)
                begin
                 byte_0 <= x;
                  byte_1 <= equal;
                  byte_2 <= led2[21] + 48;
                  byte_3 <= led2[20] + 48; 
                  byte_4 <= led2[19] + 48; 
                  byte_5 <= led2[18] + 48;
                  byte_6 <= led2[17] + 48;
                  byte_7 <= led2[16] + 48;
                  begin_tx <= 1;
                  stream_state <= 5'd16;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end  
                  end 
                  5'd16:
                  begin
                           if (tx_done)
                begin
                 byte_0 <= led2[15] + 48;
                  byte_1 <= led2[14] + 48;
                  byte_2 <= led2[13] + 48;
                  byte_3 <= led2[12] + 48; 
                  byte_4 <= led2[11] + 48; 
                  byte_5 <= led2[10] + 48;
                  byte_6 <= led2[9] + 48;
                  byte_7 <= led2[8] +48;
                  begin_tx <= 1;
                  stream_state <= 5'd17;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end  
                  end
                  5'd17:
                    begin
                                if (tx_done)
                begin
                 byte_0 <= led2[7] + 48;
                  byte_1 <= led2[6] + 48;
                  byte_2 <= led2[5] + 48;
                  byte_3 <= led2[4] + 48; 
                  byte_4 <= led2[3] + 48; 
                  byte_5 <= led2[2] + 48;
                  byte_6 <= led2[1] + 48;
                  byte_7 <= led2[0] + 48;
                  begin_tx <= 1;
                  stream_state <= 5'd18;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
                    end
                    5'd18:
                    begin
                                if (tx_done)
                begin
                 byte_0 <= space;
                  byte_1 <= H_u;
                  byte_2 <= T_u;
                  byte_3 <= T_u; 
                  byte_4 <= P_u; 
                  byte_5 <= forward_slash;
                  byte_6 <= one;
                  byte_7 <= dot;
                  begin_tx <= 1;
                  stream_state <= 5'd19;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
                    end
                    5'd19:
                    begin
                                if (tx_done)
                begin
                 byte_0 <= one;
                  byte_1 <= return;
                  byte_2 <= newline;
                  byte_3 <= H_u; 
                  byte_4 <= o; 
                  byte_5 <= s;
                  byte_6 <= t;
                  byte_7 <= colon;
                  begin_tx <= 1;
                  stream_state <= 5'd20;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
                    end
                  5'd20:
                  begin
                              if (tx_done)
                begin
                 byte_0 <= space;
                  byte_1 <= one;
                  byte_2 <= nine;
                  byte_3 <= two; 
                  byte_4 <= dot; 
                  byte_5 <= one;
                  byte_6 <= six;
                  byte_7 <= eight;
                  begin_tx <= 1;
                  stream_state <= 5'd21;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
                  end
                  5'd21:
                  begin
                              if (tx_done)
                begin
                 byte_0 <= dot;
                  byte_1 <= four;
                  byte_2 <= two;
                  byte_3 <= dot; 
                  byte_4 <= one; 
                  byte_5 <= return;
                  byte_6 <= newline;
                  byte_7 <= return;
                  begin_tx <= 1;
                  stream_state <= 5'd22;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
                  end
                  5'd22:
                  begin
                              if (tx_done)
                begin
                 byte_0 <= newline;
                  byte_1 <= 0;
                  byte_2 <= 0;
                  byte_3 <= 0; 
                  byte_4 <= 0; 
                  byte_5 <= 0;
                  byte_6 <= 0;
                  byte_7 <= 0;
                  begin_tx <= 1;
                  delaycounter_stream_state <= 5'd23;
                  stream_state <= 5'd24;
                  end 
                  else begin
                       byte_0 <= byte_0;
                  byte_1 <= byte_1;
                  byte_2 <= byte_2;
                  byte_3 <= byte_3;
                  byte_4 <= byte_4;
                  byte_5 <= byte_5;
                  byte_6 <= byte_6;
                  byte_7 <= byte_7;
                  begin_tx <= 0;
                  stream_state <= stream_state; 
                  end
                  end
                  5'd23:
                    
                begin
                 byte_0 <= 0;
                  byte_1 <= 0;
                  byte_2 <= 0;
                  byte_3 <= 0; 
                  byte_4 <= 0; 
                  byte_5 <= 0;
                  byte_6 <= 0;
                  byte_7 <= 0;
                  begin_tx <= 0;
                  stream_state <= 5'd1;
                  end 
                 
                  

                //1 sec delay sequence
                //have reg value determine next state with counter
                5'd24:
                  begin
                  begin_tx <= 0;
                    if (delay_counter == 25'd33554431)
                      begin
                        delay_counter <= 25'd0;
                        stream_state <= delaycounter_stream_state;
                      end
                      else begin
                        delay_counter <= delay_counter + 1;
                        stream_state <= stream_state;

                      end
                  end 
                
  endcase
      end  


end 

  


divide_by_2 di2(
.clk (clk),
.half_clk (half_clk),
.reset_n (reset_n)

  );

wifitestwrapper wft0(
.clk (slow_clk),
.tx (tx),
.rx (rx),
.begin_tx(begin_tx),
.done_tx (tx_done),
.byte_0 (byte_0),
.byte_1 (byte_1),
.byte_2 (byte_2),
.byte_3 (byte_3),
.byte_4 (byte_4),
.byte_5 (byte_5),
.byte_6 (byte_6),
.byte_7 (byte_7)

  );

endmodule

module wifitestwrapper
#(
  parameter b0 = 4'd0,
  parameter b1 = 4'd1,
  parameter b2 = 4'd2,
  parameter b3 = 4'd3,
  parameter b4 = 4'd4,
  parameter b5 = 4'd5,
  parameter b6 = 4'd6,
  parameter b7 = 4'd7
  )

(
input clk,
input rx,
output tx,

//upper module
input begin_tx,
output reg done_tx,
input [7:0] byte_0,
input [7:0] byte_1,
input [7:0] byte_2,
input [7:0] byte_3,
input [7:0] byte_4,
input [7:0] byte_5,
input [7:0] byte_6,
input [7:0] byte_7
  );

//lower module
wire doing_work;
reg [7:0] send_data;
reg send_dv;
wire finished;

reg reset_n = 1'b1;

reg [7:0] bytes [7:0];
reg [3:0] state;

always@(posedge clk)
begin
  if(~reset_n)
    begin
            bytes[b0] <= 0;
            bytes[b1] <= 0;
            bytes[b2] <= 0;
            bytes[b3] <= 0;
            bytes[b4] <= 0;
            bytes[b5] <= 0;
            bytes[b6] <= 0;
            bytes[b7] <= 0;
            state <= 0;
            send_data <= 0;
            send_dv <= 0;
    end
    else 
        begin
        case(state)
        4'b0000:
          begin
          if(begin_tx)
            begin
            bytes[b0] <= byte_0;
            bytes[b1] <= byte_1;
            bytes[b2] <= byte_2;
            bytes[b3] <= byte_3;
            bytes[b4] <= byte_4;
            bytes[b5] <= byte_5;
            bytes[b6] <= byte_6;
            bytes[b7] <= byte_7;
            state <= 4'b0001;
            done_tx <= 0;
            end
          else begin
            bytes[b0] <= 0;
            bytes[b1] <= 0;
            bytes[b2] <= 0;
            bytes[b3] <= 0;
            bytes[b4] <= 0;
            bytes[b5] <= 0;
            bytes[b6] <= 0;
            bytes[b7] <= 0;
            state <= state;
            done_tx <= 0;
          end
          end
          4'b0001:
            begin
          if(bytes[b0] != 0)
            begin
            send_data <= bytes[b0];
            send_dv <= 1;
            state <= 4'b0010;
            done_tx <= 0;
            end
            else begin
              send_data <= 0;
              send_dv <= 0;
              state <= 0;
              done_tx <= 1;
            end
				end
            4'b0010:
            begin
              if(finished)
                begin
                  if(bytes[b1] != 0)
                    begin
                      send_data <= bytes[b1];
                      send_dv <= 1;
                      state <= 4'b0011;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end
            end
            4'b0011:
              begin
              if(finished)
                begin
                  if(bytes[b2] != 0)
                    begin
                      send_data <= bytes[b2];
                      send_dv <= 1;
                      state <= 4'b0100;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end
              end
              4'b0100:
                begin
                  if(finished)
                begin
                  if(bytes[b3] != 0)
                    begin
                      send_data <= bytes[b3];
                      send_dv <= 1;
                      state <= 4'b0101;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end
                end
                4'b0101:
                  begin
                     if(finished)
                begin
                  if(bytes[b4] != 0)
                    begin
                      send_data <= bytes[b4];
                      send_dv <= 1;
                      state <= 4'b0110;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end
                  end
              4'b0110:
                begin
                   
                     if(finished)
                begin
                  if(bytes[b5] != 0)
                    begin
                      send_data <= bytes[b5];
                      send_dv <= 1;
                      state <= 4'b0111;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end
                  end
                4'b0111:
                begin
                     
                     if(finished)
                begin
                  if(bytes[b6] != 0)
                    begin
                      send_data <= bytes[b6];
                      send_dv <= 1;
                      state <= 4'b1000;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end
                end
                4'b1000:
                  begin
                       
                     if(finished)
                begin
                  if(bytes[b7] != 0)
                    begin
                      send_data <= bytes[b7];
                      send_dv <= 1;
                      state <= 4'b1001;
                      done_tx <= 0;
                    end
                    else begin
                      send_data <= 0;
                      send_dv <= 0;
                      state <= 0;
                      done_tx <= 1;
                    end
                end
                else begin
                  send_data <= send_data;
                  send_dv <= 0;
                  state <= state;
                  done_tx <= 0; 
                end 
                  end
                4'b1001:
                  begin
                    if(finished)
                      begin
                        done_tx <= 1;
                        send_data <= 0;
                        send_dv <= 0;
                        state <= 0;
                      end
                      else begin
                        done_tx <= 0;
                        send_data <= send_data;
                        send_dv <= 0;
                        state <= state;
                      end
                  end
						endcase
                end
            end
        
        
    




wifitest_two wi0(
.clk (clk),
.rx (rx),
.tx (tx),
.doing_work (doing_work),
.send_data (send_data),
.send_dv (send_dv),
.finished (finished)

  );
endmodule

module wifitest_two
#(parameter A = 8'd65,
  parameter T = 8'd84,
  parameter rc = 8'd13,
  parameter nl = 8'd10,
  parameter space = 8'd32
  )
(
//top module
    input clk,
   
    input rx,
    output tx,

//wrapper module
    output reg doing_work,
    input [7:0] send_data,
    input send_dv,
    output reg finished

    );




reg reset_n = 1'b1; //keep this until two way wifi comm is figured out
reg [7:0] delaycounter;
reg [3:0] init_state;

wire [7:0] rx_data;
wire rx_done;
wire rx_busy;
wire rx_er;

reg tx_dv;
reg [7:0] uart_tx_data;
wire tx_done;
wire tx_busy;
reg one_delay;

always@(posedge clk)
    begin
   

if(~reset_n)
  begin
    init_state <= 0;
    one_delay <= 0;
    uart_tx_data <= 0;
    tx_dv <= 0;
    doing_work <= 0;
  end

  else 
        begin
          case(init_state)
      4'b0000:
		begin
        finished <= 0;
              if(send_dv)
                begin
                uart_tx_data <= send_data;
                tx_dv <= 1;
                init_state <= 4'b0001;
                doing_work <= 1;
                end
                else begin
                  uart_tx_data <= 0;
                  tx_dv <= 0;
                  init_state <= 0;
                  doing_work <= 0;
                end
               end
            4'b0001:
              begin
                if (tx_done)
                  begin
                    uart_tx_data <= send_data;
                    tx_dv <= 0;
                    init_state <= 0;
                    doing_work <= 0;
                    finished <= 1;
                  end
                  else begin
                  if(tx_busy)
                  begin
                    uart_tx_data <=send_data;
                    tx_dv <= 0;
                    init_state <= init_state;
                    doing_work <= 1;
                    end
                    else begin
                        uart_tx_data <=send_data;
                        tx_dv <= 1;
                        init_state <= init_state;
                        doing_work <= 1;
                    end
                 
					  end
					  end
              endcase
				  end
end


uart_rx urx0(
.i_Clock (clk),
.i_Rx_Serial (rx),
.o_Rx_DV (uart_rx_dv),
.o_Rx_Byte (uart_rx_data),
.reset_n (reset_n)
  );

uart_tx utx0(
.i_Clock (clk),
.i_Tx_DV (tx_dv),
.i_Tx_Byte (uart_tx_data),
.o_Tx_Active (tx_busy),
.o_Tx_Serial (tx),
.o_Tx_Done (tx_done),
.reset_n (reset_n)
  );


endmodule




//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_rx 
  #(parameter CLKS_PER_BIT = 217,
   parameter s_IDLE         = 3'b000,
  parameter s_RX_START_BIT = 3'b001,
  parameter s_RX_DATA_BITS = 3'b010,
  parameter s_RX_STOP_BIT  = 3'b011,
  parameter s_CLEANUP      = 3'b100) //double check if correct
  (
   input        i_Clock,
   input reset_n,
   input        i_Rx_Serial,
   output       o_Rx_DV,
   output [7:0] o_Rx_Byte
   );
    
 
   
  reg           r_Rx_Data_R = 1'b1;
  reg           r_Rx_Data   = 1'b1;
   
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total
  reg [7:0]     r_Rx_Byte     = 0;
  reg           r_Rx_DV       = 0;
  reg [2:0]     r_SM_Main     = 0;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock)
    begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
   
   
  // Purpose: Control RX state machine
  always @(posedge i_Clock)
    begin
       if (~reset_n)
       begin
         r_SM_Main <=s_IDLE;
       end
       else begin
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)          // Start bit detected
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end
         
        // Check middle of start bit to make sure it's still low
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
      end
    end   
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule // uart_rx




//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_tx 
  #(parameter CLKS_PER_BIT = 217)
  (
   input       i_Clock,
   input reset_n,
   input       i_Tx_DV,
   input [7:0] i_Tx_Byte, 
   output      o_Tx_Active,
   output reg  o_Tx_Serial,
   output      o_Tx_Done
   );
  
  parameter s_IDLE         = 3'b000;
  parameter s_TX_START_BIT = 3'b001;
  parameter s_TX_DATA_BITS = 3'b010;
  parameter s_TX_STOP_BIT  = 3'b011;
  parameter s_CLEANUP      = 3'b100;
   
  reg [2:0]    r_SM_Main     = 0;
  reg [7:0]    r_Clock_Count = 0;
  reg [2:0]    r_Bit_Index   = 0;
  reg [7:0]    r_Tx_Data     = 0;
  reg          r_Tx_Done     = 0;
  reg          r_Tx_Active   = 0;
     
  always @(posedge i_Clock)
    begin
       if(~reset_n)
       begin 
       r_SM_Main <= s_IDLE;
       end
      case (r_SM_Main)
        s_IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (i_Tx_DV == 1'b1)
              begin
                r_Tx_Active <= 1'b1;
                r_Tx_Data   <= i_Tx_Byte;
                r_SM_Main   <= s_TX_START_BIT;
              end
            else
              r_SM_Main <= s_IDLE;
          end // case: s_IDLE
         
         
        // Send out Start Bit. Start bit = 0
        s_TX_START_BIT :
          begin
            o_Tx_Serial <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_START_BIT;
              end
            else
              begin
                r_Clock_Count <= 0;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
          end // case: s_TX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        s_TX_DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
             
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count <= 0;
                 
                // Check if we have sent out all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_TX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_TX_STOP_BIT;
                  end
              end
          end // case: s_TX_DATA_BITS
         
         
        // Send out Stop bit.  Stop bit = 1
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_TX_STOP_BIT;
              end
            else
              begin
                r_Tx_Done     <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
                r_Tx_Active   <= 1'b0;
              end
          end // case: s_Tx_STOP_BIT
         
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_Tx_Done <= 1'b1;
            r_SM_Main <= s_IDLE;
          end
         
         
        default :
          r_SM_Main <= s_IDLE;
         
      endcase
    end
 
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
   
endmodule


module divide_by_2 
(
input clk,
input reset_n,
output reg half_clk

  );


 always@(posedge clk)
  begin
      if(~reset_n)
        begin
          half_clk <= 0;
        end
      else begin
        half_clk <= ~half_clk;
      end
  end

 endmodule