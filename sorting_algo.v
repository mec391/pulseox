module sorting_algo(

//top
input clk,
input reset_n,

//data from sqrt module
input sqrt_DV,
input [23:0] data_from_sqrt,


//data to post_data_buffer
output reg [23:0] AC_comp,
output reg [23:0] DC_comp,
output  [9:0] HR,
output reg sort_DV,
output tx

//tb
/*
output [9:0] HR_raw1,
output [23:0] testreg_a,
output [23:0] test_reg2a,
output [9:0] addr1,
output we1
*/
);
reg [3:0] state;
reg [23:0] testreg;
reg [23:0] test_reg2;

reg [23:0] data;
wire [23:0] q;
reg we;
reg [9:0] addr;
reg [9:0] HR_raw;
wire [9:0] hr_bpm;

//tb
/*
assign HR_raw1 = HR_raw;
assign testreg_a = testreg;
assign test_reg2a = test_reg2;
assign addr1 = addr;
assign we1 = we;
*/
//endtb

assign HR = hr_bpm;

always@(posedge clk)
begin
if (~reset_n)
begin
	state <= 0;
	testreg <= 0;
	test_reg2 <= 0;
	data <= 0;
	we <= 0;
	addr <= 0;
	HR_raw <= 0;
end
else begin
	case(state)
	4'b0:
		begin
		we <= 1;
		//addr <= 0; //start pulling data / assign DC comp
			if((sqrt_DV == 1'd1) && (data_from_sqrt != 24'd0))
				begin
					DC_comp <= data_from_sqrt;
					data <= data_from_sqrt;
					state <= 4'b1;
				end
			else begin
				data <= data;
				state <= state;
				DC_comp <= DC_comp;
			end
			end
		4'b1: //continue to pull data till full
			begin
				if((sqrt_DV) && (addr < 10'd510)) 
				begin
				addr <= addr + 1;
				data <= data_from_sqrt;
				state <= state;
				DC_comp <= DC_comp;
				end
			else if(addr == 10'd510)
				begin
					addr <= 10'd12; //10'd13//start of sorting algo
					data <= data;
					state <= 4'd7; //3/2 delay
					DC_comp <= DC_comp;
					we <= 0;	
				end
			else
				begin
					addr <= addr;
					data <= data;
					state <= state;
					DC_comp <= DC_comp;
				end
				end
			4'd2: //find AC comp & HR
				begin
					testreg <= q;
					state <= 4'd3;
				end
			4'd3:
				begin
					if(addr == 10'd510)
						begin
							state <= 4'd4;
							test_reg2 <=test_reg2;
							testreg <= testreg;
							HR_raw <= HR_raw;
						end
					else if(test_reg2 < testreg)
					begin
						test_reg2 <= testreg;
						testreg <= testreg; /////3/2
						HR_raw <= addr;
						addr <= addr +1;
						state <= 4'd2;
					end
					else begin
						test_reg2 <= test_reg2;
						testreg <= testreg;
						addr <= addr + 1;
						HR_raw <= HR_raw;
						state <= 4'd2;
					end
				end
			4'd4: // Do AC comp,DC is done and HR is auto-routed
				begin
					addr <= 0;
					state <= 4'd5;
					AC_comp <= test_reg2;
					HR_raw <= HR_raw;
				end
			4'd5: //1 clk delay for everything to align
				begin
					addr <= 0;
					state <= 4'd6;
					sort_DV <= 1;
					AC_comp <= AC_comp;
					HR_raw <= HR_raw;
				end
			4'd6:
				begin
					state <= 4'd0;
					AC_comp <= AC_comp;
					DC_comp <= DC_comp;
					HR_raw <= 0;//HR_raw;//need to keep this routed
					sort_DV <= 0;
					testreg <= 0; //3/1/2020
					test_reg2 <= 0; //3/1/2020
					addr <= 0;
				end
			//3/2 addition
			4'd7:
				begin
					addr <= 10'd13; //10'd13//start of sorting algo
					data <= data;
					state <= 4'd2; //3/2 delay
					DC_comp <= DC_comp;
					we <= 0;	
				end

	endcase	
		end
end

//wires for debug
wire [9:0] addr_b;
wire [23:0] q_b;

//arduino debugger modules
/*
data_to_uart dat0(
.clk (clk),
.reset_n (reset_n),
.addr_b (addr_b),
.q_b (q_b),
.tx (tx)
	);
*/

single_port_ram_sort sprs1(
.data_a (data),
.addr_a (addr),
.we_a (we),
.clk (clk),
.q_a (q),
//debug module
.data_b (23'd0),
.addr_b (addr_b),
.we_b (1'b0),
.q_b (q_b)
	);

//instantiate hr table
HRtable hrt0(
.clk (clk),
.reset_n (reset_n),
.HR_input (HR_raw),
.outHR1 (hr_bpm)
	);

endmodule


//pass HR addr to table for actual heart rate in bpm
module HRtable(
input clk,
input reset_n,
input [9:0] HR_input,
output [9:0] outHR1

	);
	reg [9:0] outHR;
	assign outHR1 = outHR;
	
	always@(posedge clk)
	begin


	if(HR_input < 10'd427)
	begin
		case(HR_input)
		
		
		
10'd13:
begin
outHR <= 10'd31;
end


10'd14:
begin
outHR <= 10'd34;
end
10'd15:
begin
outHR <= 10'd36;
end
10'd16:
begin
outHR <= 10'd38;
end
10'd17:
begin
outHR <= 10'd41;
end
10'd18:
begin
outHR <= 10'd43;
end
10'd19:
begin
outHR <= 10'd46;
end
10'd20:
begin
outHR <= 10'd48;
end
10'd21:
begin
outHR <= 10'd50;
end
10'd22:
begin
outHR <= 10'd53;
end
10'd23:
begin
outHR <= 10'd55;
end
10'd24:
begin
outHR <= 10'd58;
end
10'd25:
begin
outHR <= 10'd60;
end
10'd26:
begin
outHR <= 10'd62;
end
10'd27:
begin
outHR <= 10'd65;
end
10'd28:
begin
outHR <= 10'd67;
end
10'd29:
begin
outHR <= 10'd70;
end
10'd30:
begin
outHR <= 10'd72;
end
10'd31:
begin
outHR <= 10'd74;
end
10'd32:
begin
outHR <= 10'd77;
end
10'd33:
begin
outHR <= 10'd79;
end
10'd34:
begin
outHR <= 10'd82;
end
10'd35:
begin
outHR <= 10'd84;
end
10'd36:
begin
outHR <= 10'd86;
end
10'd37:
begin
outHR <= 10'd89;
end
10'd38:
begin
outHR <= 10'd91;
end
10'd39:
begin
outHR <= 10'd94;
end
10'd40:
begin
outHR <= 10'd96;
end
10'd41:
begin
outHR <= 10'd98;
end
10'd42:
begin
outHR <= 10'd101;
end
10'd43:
begin
outHR <= 10'd103;
end
10'd44:
begin
outHR <= 10'd106;
end
10'd45:
begin
outHR <= 10'd108;
end
10'd46:
begin
outHR <= 10'd110;
end
10'd47:
begin
outHR <= 10'd113;
end
10'd48:
begin
outHR <= 10'd115;
end
10'd49:
begin
outHR <= 10'd118;
end
10'd50:
begin
outHR <= 10'd120;
end
10'd51:
begin
outHR <= 10'd122;
end
10'd52:
begin
outHR <= 10'd125;
end
10'd53:
begin
outHR <= 10'd127;
end
10'd54:
begin
outHR <= 10'd130;
end
10'd55:
begin
outHR <= 10'd132;
end
10'd56:
begin
outHR <= 10'd134;
end
10'd57:
begin
outHR <= 10'd137;
end
10'd58:
begin
outHR <= 10'd139;
end
10'd59:
begin
outHR <= 10'd142;
end
10'd60:
begin
outHR <= 10'd144;
end
10'd61:
begin
outHR <= 10'd146;
end
10'd62:
begin
outHR <= 10'd149;
end
10'd63:
begin
outHR <= 10'd151;
end
10'd64:
begin
outHR <= 10'd154;
end
10'd65:
begin
outHR <= 10'd156;
end
10'd66:
begin
outHR <= 10'd158;
end
10'd67:
begin
outHR <= 10'd161;
end
10'd68:
begin
outHR <= 10'd163;
end
10'd69:
begin
outHR <= 10'd166;
end
10'd70:
begin
outHR <= 10'd168;
end
10'd71:
begin
outHR <= 10'd170;
end
10'd72:
begin
outHR <= 10'd173;
end
10'd73:
begin
outHR <= 10'd175;
end
10'd74:
begin
outHR <= 10'd178;
end
10'd75:
begin
outHR <= 10'd180;
end
10'd76:
begin
outHR <= 10'd182;
end
10'd77:
begin
outHR <= 10'd185;
end
10'd78:
begin
outHR <= 10'd187;
end
10'd79:
begin
outHR <= 10'd190;
end
10'd80:
begin
outHR <= 10'd192;
end
10'd81:
begin
outHR <= 10'd194;
end
10'd82:
begin
outHR <= 10'd197;
end
10'd83:
begin
outHR <= 10'd199;
end
10'd84:
begin
outHR <= 10'd202;
end
10'd85:
begin
outHR <= 10'd204;
end
10'd86:
begin
outHR <= 10'd206;
end
10'd87:
begin
outHR <= 10'd209;
end
10'd88:
begin
outHR <= 10'd211;
end
10'd89:
begin
outHR <= 10'd214;
end
10'd90:
begin
outHR <= 10'd216;
end
10'd91:
begin
outHR <= 10'd218;
end
10'd92:
begin
outHR <= 10'd221;
end
10'd93:
begin
outHR <= 10'd223;
end
10'd94:
begin
outHR <= 10'd226;
end
10'd95:
begin
outHR <= 10'd228;
end
10'd96:
begin
outHR <= 10'd230;
end
10'd97:
begin
outHR <= 10'd233;
end
10'd98:
begin
outHR <= 10'd235;
end
10'd99:
begin
outHR <= 10'd238;
end
10'd100:
begin
outHR <= 10'd240;
end
10'd101:
begin
outHR <= 10'd242;
end
10'd102:
begin
outHR <= 10'd245;
end
10'd103:
begin
outHR <= 10'd247;
end
10'd104:
begin
outHR <= 10'd250;
end
10'd105:
begin
outHR <= 10'd252;
end
10'd106:
begin
outHR <= 10'd254;
end
10'd107:
begin
outHR <= 10'd257;
end
10'd108:
begin
outHR <= 10'd259;
end
10'd109:
begin
outHR <= 10'd262;
end
10'd110:
begin
outHR <= 10'd264;
end
10'd111:
begin
outHR <= 10'd266;
end
10'd112:
begin
outHR <= 10'd269;
end
10'd113:
begin
outHR <= 10'd271;
end
10'd114:
begin
outHR <= 10'd274;
end
10'd115:
begin
outHR <= 10'd276;
end
10'd116:
begin
outHR <= 10'd278;
end
10'd117:
begin
outHR <= 10'd281;
end
10'd118:
begin
outHR <= 10'd283;
end
10'd119:
begin
outHR <= 10'd286;
end
10'd120:
begin
outHR <= 10'd288;
end
10'd121:
begin
outHR <= 10'd290;
end
10'd122:
begin
outHR <= 10'd293;
end
10'd123:
begin
outHR <= 10'd295;
end
10'd124:
begin
outHR <= 10'd298;
end
10'd125:
begin
outHR <= 10'd300;
end
10'd126:
begin
outHR <= 10'd302;
end
10'd127:
begin
outHR <= 10'd305;
end
10'd128:
begin
outHR <= 10'd307;
end
10'd129:
begin
outHR <= 10'd310;
end
10'd130:
begin
outHR <= 10'd312;
end
10'd131:
begin
outHR <= 10'd314;
end
10'd132:
begin
outHR <= 10'd317;
end
10'd133:
begin
outHR <= 10'd319;
end
10'd134:
begin
outHR <= 10'd322;
end
10'd135:
begin
outHR <= 10'd324;
end
10'd136:
begin
outHR <= 10'd326;
end
10'd137:
begin
outHR <= 10'd329;
end
10'd138:
begin
outHR <= 10'd331;
end
10'd139:
begin
outHR <= 10'd334;
end
10'd140:
begin
outHR <= 10'd336;
end
10'd141:
begin
outHR <= 10'd338;
end
10'd142:
begin
outHR <= 10'd341;
end
10'd143:
begin
outHR <= 10'd343;
end
10'd144:
begin
outHR <= 10'd346;
end
10'd145:
begin
outHR <= 10'd348;
end
10'd146:
begin
outHR <= 10'd350;
end
10'd147:
begin
outHR <= 10'd353;
end
10'd148:
begin
outHR <= 10'd355;
end
10'd149:
begin
outHR <= 10'd358;
end
10'd150:
begin
outHR <= 10'd360;
end
10'd151:
begin
outHR <= 10'd362;
end
10'd152:
begin
outHR <= 10'd365;
end
10'd153:
begin
outHR <= 10'd367;
end
10'd154:
begin
outHR <= 10'd370;
end
10'd155:
begin
outHR <= 10'd372;
end
10'd156:
begin
outHR <= 10'd374;
end
10'd157:
begin
outHR <= 10'd377;
end
10'd158:
begin
outHR <= 10'd379;
end
10'd159:
begin
outHR <= 10'd382;
end
10'd160:
begin
outHR <= 10'd384;
end
10'd161:
begin
outHR <= 10'd386;
end
10'd162:
begin
outHR <= 10'd389;
end
10'd163:
begin
outHR <= 10'd391;
end
10'd164:
begin
outHR <= 10'd394;
end
10'd165:
begin
outHR <= 10'd396;
end
10'd166:
begin
outHR <= 10'd398;
end
10'd167:
begin
outHR <= 10'd401;
end
10'd168:
begin
outHR <= 10'd403;
end
10'd169:
begin
outHR <= 10'd406;
end
10'd170:
begin
outHR <= 10'd408;
end
10'd171:
begin
outHR <= 10'd410;
end
10'd172:
begin
outHR <= 10'd413;
end
10'd173:
begin
outHR <= 10'd415;
end
10'd174:
begin
outHR <= 10'd418;
end
10'd175:
begin
outHR <= 10'd420;
end
10'd176:
begin
outHR <= 10'd422;
end
10'd177:
begin
outHR <= 10'd425;
end
10'd178:
begin
outHR <= 10'd427;
end
10'd179:
begin
outHR <= 10'd430;
end
10'd180:
begin
outHR <= 10'd432;
end
10'd181:
begin
outHR <= 10'd434;
end
10'd182:
begin
outHR <= 10'd437;
end
10'd183:
begin
outHR <= 10'd439;
end
10'd184:
begin
outHR <= 10'd442;
end
10'd185:
begin
outHR <= 10'd444;
end
10'd186:
begin
outHR <= 10'd446;
end
10'd187:
begin
outHR <= 10'd449;
end
10'd188:
begin
outHR <= 10'd451;
end
10'd189:
begin
outHR <= 10'd454;
end
10'd190:
begin
outHR <= 10'd456;
end
10'd191:
begin
outHR <= 10'd458;
end
10'd192:
begin
outHR <= 10'd461;
end
10'd193:
begin
outHR <= 10'd463;
end
10'd194:
begin
outHR <= 10'd466;
end
10'd195:
begin
outHR <= 10'd468;
end
10'd196:
begin
outHR <= 10'd470;
end
10'd197:
begin
outHR <= 10'd473;
end
10'd198:
begin
outHR <= 10'd475;
end
10'd199:
begin
outHR <= 10'd478;
end
10'd200:
begin
outHR <= 10'd480;
end
10'd201:
begin
outHR <= 10'd482;
end
10'd202:
begin
outHR <= 10'd485;
end
10'd203:
begin
outHR <= 10'd487;
end
10'd204:
begin
outHR <= 10'd490;
end
10'd205:
begin
outHR <= 10'd492;
end
10'd206:
begin
outHR <= 10'd494;
end
10'd207:
begin
outHR <= 10'd497;
end
10'd208:
begin
outHR <= 10'd499;
end
10'd209:
begin
outHR <= 10'd502;
end
10'd210:
begin
outHR <= 10'd504;
end
10'd211:
begin
outHR <= 10'd506;
end
10'd212:
begin
outHR <= 10'd509;
end
10'd213:
begin
outHR <= 10'd511;
end
10'd214:
begin
outHR <= 10'd514;
end
10'd215:
begin
outHR <= 10'd516;
end
10'd216:
begin
outHR <= 10'd518;
end
10'd217:
begin
outHR <= 10'd521;
end
10'd218:
begin
outHR <= 10'd523;
end
10'd219:
begin
outHR <= 10'd526;
end
10'd220:
begin
outHR <= 10'd528;
end
10'd221:
begin
outHR <= 10'd530;
end
10'd222:
begin
outHR <= 10'd533;
end
10'd223:
begin
outHR <= 10'd535;
end
10'd224:
begin
outHR <= 10'd538;
end
10'd225:
begin
outHR <= 10'd540;
end
10'd226:
begin
outHR <= 10'd542;
end
10'd227:
begin
outHR <= 10'd545;
end
10'd228:
begin
outHR <= 10'd547;
end
10'd229:
begin
outHR <= 10'd550;
end
10'd230:
begin
outHR <= 10'd552;
end
10'd231:
begin
outHR <= 10'd554;
end
10'd232:
begin
outHR <= 10'd557;
end
10'd233:
begin
outHR <= 10'd559;
end
10'd234:
begin
outHR <= 10'd562;
end
10'd235:
begin
outHR <= 10'd564;
end
10'd236:
begin
outHR <= 10'd566;
end
10'd237:
begin
outHR <= 10'd569;
end
10'd238:
begin
outHR <= 10'd571;
end
10'd239:
begin
outHR <= 10'd574;
end
10'd240:
begin
outHR <= 10'd576;
end
10'd241:
begin
outHR <= 10'd578;
end
10'd242:
begin
outHR <= 10'd581;
end
10'd243:
begin
outHR <= 10'd583;
end
10'd244:
begin
outHR <= 10'd586;
end
10'd245:
begin
outHR <= 10'd588;
end
10'd246:
begin
outHR <= 10'd590;
end
10'd247:
begin
outHR <= 10'd593;
end
10'd248:
begin
outHR <= 10'd595;
end
10'd249:
begin
outHR <= 10'd598;
end
10'd250:
begin
outHR <= 10'd600;
end
10'd251:
begin
outHR <= 10'd602;
end
10'd252:
begin
outHR <= 10'd605;
end
10'd253:
begin
outHR <= 10'd607;
end
10'd254:
begin
outHR <= 10'd610;
end
10'd255:
begin
outHR <= 10'd612;
end
10'd256:
begin
outHR <= 10'd614;
end
10'd257:
begin
outHR <= 10'd617;
end
10'd258:
begin
outHR <= 10'd619;
end
10'd259:
begin
outHR <= 10'd622;
end
10'd260:
begin
outHR <= 10'd624;
end
10'd261:
begin
outHR <= 10'd626;
end
10'd262:
begin
outHR <= 10'd629;
end
10'd263:
begin
outHR <= 10'd631;
end
10'd264:
begin
outHR <= 10'd634;
end
10'd265:
begin
outHR <= 10'd636;
end
10'd266:
begin
outHR <= 10'd638;
end
10'd267:
begin
outHR <= 10'd641;
end
10'd268:
begin
outHR <= 10'd643;
end
10'd269:
begin
outHR <= 10'd646;
end
10'd270:
begin
outHR <= 10'd648;
end
10'd271:
begin
outHR <= 10'd650;
end
10'd272:
begin
outHR <= 10'd653;
end
10'd273:
begin
outHR <= 10'd655;
end
10'd274:
begin
outHR <= 10'd658;
end
10'd275:
begin
outHR <= 10'd660;
end
10'd276:
begin
outHR <= 10'd662;
end
10'd277:
begin
outHR <= 10'd665;
end
10'd278:
begin
outHR <= 10'd667;
end
10'd279:
begin
outHR <= 10'd670;
end
10'd280:
begin
outHR <= 10'd672;
end
10'd281:
begin
outHR <= 10'd674;
end
10'd282:
begin
outHR <= 10'd677;
end
10'd283:
begin
outHR <= 10'd679;
end
10'd284:
begin
outHR <= 10'd682;
end
10'd285:
begin
outHR <= 10'd684;
end
10'd286:
begin
outHR <= 10'd686;
end
10'd287:
begin
outHR <= 10'd689;
end
10'd288:
begin
outHR <= 10'd691;
end
10'd289:
begin
outHR <= 10'd694;
end
10'd290:
begin
outHR <= 10'd696;
end
10'd291:
begin
outHR <= 10'd698;
end
10'd292:
begin
outHR <= 10'd701;
end
10'd293:
begin
outHR <= 10'd703;
end
10'd294:
begin
outHR <= 10'd706;
end
10'd295:
begin
outHR <= 10'd708;
end
10'd296:
begin
outHR <= 10'd710;
end
10'd297:
begin
outHR <= 10'd713;
end
10'd298:
begin
outHR <= 10'd715;
end
10'd299:
begin
outHR <= 10'd718;
end
10'd300:
begin
outHR <= 10'd720;
end
10'd301:
begin
outHR <= 10'd722;
end
10'd302:
begin
outHR <= 10'd725;
end
10'd303:
begin
outHR <= 10'd727;
end
10'd304:
begin
outHR <= 10'd730;
end
10'd305:
begin
outHR <= 10'd732;
end
10'd306:
begin
outHR <= 10'd734;
end
10'd307:
begin
outHR <= 10'd737;
end
10'd308:
begin
outHR <= 10'd739;
end
10'd309:
begin
outHR <= 10'd742;
end
10'd310:
begin
outHR <= 10'd744;
end
10'd311:
begin
outHR <= 10'd746;
end
10'd312:
begin
outHR <= 10'd749;
end
10'd313:
begin
outHR <= 10'd751;
end
10'd314:
begin
outHR <= 10'd754;
end
10'd315:
begin
outHR <= 10'd756;
end
10'd316:
begin
outHR <= 10'd758;
end
10'd317:
begin
outHR <= 10'd761;
end
10'd318:
begin
outHR <= 10'd763;
end
10'd319:
begin
outHR <= 10'd766;
end
10'd320:
begin
outHR <= 10'd768;
end
10'd321:
begin
outHR <= 10'd770;
end
10'd322:
begin
outHR <= 10'd773;
end
10'd323:
begin
outHR <= 10'd775;
end
10'd324:
begin
outHR <= 10'd778;
end
10'd325:
begin
outHR <= 10'd780;
end
10'd326:
begin
outHR <= 10'd782;
end
10'd327:
begin
outHR <= 10'd785;
end
10'd328:
begin
outHR <= 10'd787;
end
10'd329:
begin
outHR <= 10'd790;
end
10'd330:
begin
outHR <= 10'd792;
end
10'd331:
begin
outHR <= 10'd794;
end
10'd332:
begin
outHR <= 10'd797;
end
10'd333:
begin
outHR <= 10'd799;
end
10'd334:
begin
outHR <= 10'd802;
end
10'd335:
begin
outHR <= 10'd804;
end
10'd336:
begin
outHR <= 10'd806;
end
10'd337:
begin
outHR <= 10'd809;
end
10'd338:
begin
outHR <= 10'd811;
end
10'd339:
begin
outHR <= 10'd814;
end
10'd340:
begin
outHR <= 10'd816;
end
10'd341:
begin
outHR <= 10'd818;
end
10'd342:
begin
outHR <= 10'd821;
end
10'd343:
begin
outHR <= 10'd823;
end
10'd344:
begin
outHR <= 10'd826;
end
10'd345:
begin
outHR <= 10'd828;
end
10'd346:
begin
outHR <= 10'd830;
end
10'd347:
begin
outHR <= 10'd833;
end
10'd348:
begin
outHR <= 10'd835;
end
10'd349:
begin
outHR <= 10'd838;
end
10'd350:
begin
outHR <= 10'd840;
end
10'd351:
begin
outHR <= 10'd842;
end
10'd352:
begin
outHR <= 10'd845;
end
10'd353:
begin
outHR <= 10'd847;
end
10'd354:
begin
outHR <= 10'd850;
end
10'd355:
begin
outHR <= 10'd852;
end
10'd356:
begin
outHR <= 10'd854;
end
10'd357:
begin
outHR <= 10'd857;
end
10'd358:
begin
outHR <= 10'd859;
end
10'd359:
begin
outHR <= 10'd862;
end
10'd360:
begin
outHR <= 10'd864;
end
10'd361:
begin
outHR <= 10'd866;
end
10'd362:
begin
outHR <= 10'd869;
end
10'd363:
begin
outHR <= 10'd871;
end
10'd364:
begin
outHR <= 10'd874;
end
10'd365:
begin
outHR <= 10'd876;
end
10'd366:
begin
outHR <= 10'd878;
end
10'd367:
begin
outHR <= 10'd881;
end
10'd368:
begin
outHR <= 10'd883;
end
10'd369:
begin
outHR <= 10'd886;
end
10'd370:
begin
outHR <= 10'd888;
end
10'd371:
begin
outHR <= 10'd890;
end
10'd372:
begin
outHR <= 10'd893;
end
10'd373:
begin
outHR <= 10'd895;
end
10'd374:
begin
outHR <= 10'd898;
end
10'd375:
begin
outHR <= 10'd900;
end
10'd376:
begin
outHR <= 10'd902;
end
10'd377:
begin
outHR <= 10'd905;
end
10'd378:
begin
outHR <= 10'd907;
end
10'd379:
begin
outHR <= 10'd910;
end
10'd380:
begin
outHR <= 10'd912;
end
10'd381:
begin
outHR <= 10'd914;
end
10'd382:
begin
outHR <= 10'd917;
end
10'd383:
begin
outHR <= 10'd919;
end
10'd384:
begin
outHR <= 10'd922;
end
10'd385:
begin
outHR <= 10'd924;
end
10'd386:
begin
outHR <= 10'd926;
end
10'd387:
begin
outHR <= 10'd929;
end
10'd388:
begin
outHR <= 10'd931;
end
10'd389:
begin
outHR <= 10'd934;
end
10'd390:
begin
outHR <= 10'd936;
end
10'd391:
begin
outHR <= 10'd938;
end
10'd392:
begin
outHR <= 10'd941;
end
10'd393:
begin
outHR <= 10'd943;
end
10'd394:
begin
outHR <= 10'd946;
end
10'd395:
begin
outHR <= 10'd948;
end
10'd396:
begin
outHR <= 10'd950;
end
10'd397:
begin
outHR <= 10'd953;
end
10'd398:
begin
outHR <= 10'd955;
end
10'd399:
begin
outHR <= 10'd958;
end
10'd400:
begin
outHR <= 10'd960;
end
10'd401:
begin
outHR <= 10'd962;
end
10'd402:
begin
outHR <= 10'd965;
end
10'd403:
begin
outHR <= 10'd967;
end
10'd404:
begin
outHR <= 10'd970;
end
10'd405:
begin
outHR <= 10'd972;
end
10'd406:
begin
outHR <= 10'd974;
end
10'd407:
begin
outHR <= 10'd977;
end
10'd408:
begin
outHR <= 10'd979;
end
10'd409:
begin
outHR <= 10'd982;
end
10'd410:
begin
outHR <= 10'd984;
end
10'd411:
begin
outHR <= 10'd986;
end
10'd412:
begin
outHR <= 10'd989;
end
10'd413:
begin
outHR <= 10'd991;
end
10'd414:
begin
outHR <= 10'd994;
end
10'd415:
begin
outHR <= 10'd996;
end
10'd416:
begin
outHR <= 10'd998;
end
10'd417:
begin
outHR <= 10'd1001;
end
10'd418:
begin
outHR <= 10'd1003;
end
10'd419:
begin
outHR <= 10'd1006;
end
10'd420:
begin
outHR <= 10'd1008;
end
10'd421:
begin
outHR <= 10'd1010;
end
10'd422:
begin
outHR <= 10'd1013;
end
10'd423:
begin
outHR <= 10'd1015;
end
10'd424:
begin
outHR <= 10'd1018;
end
10'd425:
begin
outHR <= 10'd1020;
end
10'd426:
begin
outHR <= 10'd1022;
end


			endcase
			end
			else begin
				outHR <= 10'd1022;
			end
	end
	endmodule


// to route data to uart
// tx go from sortalgo->postbuffer->ledbuffer->databuffer->top
module data_to_uart(
 input clk,
 input reset_n,
 output reg [9:0] addr_b,
 input [23:0] q_b,
 output tx
	);

wire half_clk;
reg tx_dv;
reg [7:0] uart_tx_data;
wire tx_busy;
wire tx_done;
reg [3:0] state;
reg [21:0] cnt;
always@(posedge half_clk)
begin
	if(~reset_n)
		begin
			//reset regs
		end
	else begin
		case (state)
		4'd0:
			begin
				if (addr_b == 9'd256)
					begin
						addr_b <= 9'd0;
					state = 4'd4;
					end
					else begin
						addr_b <= addr_b + 1;
					end
				state <= 4'd1;
			end
		4'd1:
			begin
				if(~tx_busy)
				begin
					uart_tx_data <= q_b[23:16];
					tx_dv <= 1;
					state <= 4'd2;
				end
				else begin
					tx_dv <= 0;
					state <= state;
				end
			end
		4'd2:
			begin
				if(~tx_busy)
				begin
					uart_tx_data <= q_b[15:8];
					tx_dv <= 1;
					state <= 4'd3;
				end
				else begin
					tx_dv <= 0;
					state <= state;
				end
			end
		4'd3:
			begin
				if(~tx_busy)
				begin
					uart_tx_data <= q_b[7:0];
					tx_dv <= 1;
					state <= 4'd0;
				end
				else begin
					tx_dv <= 0;
					state <= state;
				end
			end
		4'd4:
			begin
				if(cnt == 22'd1100000)
				begin
					cnt = 0;
					state <= 4'd1;
				end
				else begin
					cnt = cnt + 1;
					state <= state;
				end
			end
		endcase
	end
end
divide_by_2 di3(
.clk(clk),
.half_clk (half_clk),
.reset_n (reset_n)
	);

uart_tx utx1(
.i_Clock (half_clk),
.i_Tx_DV (tx_dv),
.i_Tx_Byte (uart_tx_data),
.o_Tx_Active (tx_busy),
.o_Tx_Serial (tx),
.o_Tx_Done (tx_done),
.reset_n (reset_n)
	);
endmodule

