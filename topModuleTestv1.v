module systemwithoutdsp(

input clk,
input diag_end,
//input adc_rdy, //calculate delay time between adc rdy
				 // based on prp, put that into fsm during
				 //streaming mode

input miso, 
output mosi,
output sclk,
output cs_n,

//august update
output tx,
input rx,

output hardware_test
);
//testing
reg cpu_stop = 1'b0;
reg adc_rdy = 1'b1;
wire spi_rw_done;
wire wri_w_begin_test;
wire [2:0] w_control;
//testing purposes
assign spi_rw_done = fsm_read_write_done;
assign wri_w_begin_test = wri_w_begin;
assign w_control = fsm_write_control;

//hardware debug
/////////////////////
assign hardware_test = lsb_data_led1;
wire lsb_data_led1;
assign lsb_data_led1 = data_led1_a[0];
///////////////////

wire new_samples_a;

//route to fsm
reg cpu_start_en = 1'b1;
reg reset_n = 1'b1;
//route to dpbram
 reg we_b = 1'b0;


//fsm io
wire [1:0] fsm_data_buffer_control; 
wire [1:0] fsm_diag_er;
wire [2:0] fsm_write_control;
wire fsm_en_write_a;
wire [2:0] fsm_addr_rw;
wire fsm_read_begin;
wire fsm_write_begin;
wire fsm_cyc_done;
wire fsm_read_write_done;
wire fsm_reset_n;

//address selector
wire [7:0] add_addr_r;
wire add_r_begin;
wire add_strm_dn;
wire [7:0] add_addr_w;
wire add_w_begin;
wire [2:0] add_addr_r_read;

//data buffer
wire [2:0] dat_out_addr;
wire [23:0] dat_strm_data;
wire [21:0] led_one_a;
wire [21:0] led_two_a;
wire final_comp_complete_a;

//write ram
wire [7:0] wri_addr_w;
wire [23:0] wri_data;
wire wri_w_begin;

//spi
wire [23:0] spi_data;


//wifi
wire stream_start_a;
wire stream_stop_a;
wire cpu_reset_n_a;
wire stream_rdy_a;

//to fifo
wire [21:0] data_led1_a;
wire [21:0] data_led2_a;
wire data_rdy_a;
wire [23:0] hr_a;
wire [9:0] spo2_a;

spibufferv3 spi0(
.clk (clk),
.mosi (mosi),
.miso (miso),
.cs_n (cs_n),
.sclk (sclk),

//other modules
.in_addr_r (add_addr_r),
.read_begin (add_r_begin),
.in_addr_w (wri_addr_w),
.write_begin (wri_w_begin),
.in_data (wri_data),
.reset_n (fsm_reset_n),
.read_or_write_done (fsm_read_write_done),
.out_data (spi_data)
	);

FSM fsm0(
.kill_me(kill_me_a),
.reading_done (add_strm_dn),

.clk (clk),
.in_cpu_start (stream_start_a),
.in_afe_diag_end (diag_end),
.in_afe_adc_rdy (adc_rdy),
.in_cpu_reset_n (cpu_reset_n_a),
.in_cpu_stop (stream_stop_a),
.out_stream_rdy (stream_rdy_a),

//routed to/from other modules
.out_data_buffer_control (fsm_data_buffer_control),
.in_diag_er (fsm_diag_er),
.out_write_control(fsm_write_control),
.out_en_write_a (fsm_en_write_a),
.out_addr_rw (fsm_addr_rw),
.out_read_begin (fsm_read_begin),
.out_write_begin (fsm_write_begin),
.in_cyc_done (fsm_cyc_done),
.in_read_write_done (fsm_read_write_done),
.out_reset_n (fsm_reset_n)

	);

addr_sel add0(
.clk (clk),

//other modules
.in_reset_n (fsm_reset_n),
.in_addr_sel_rw (fsm_addr_rw),
.in_r_begin (fsm_read_begin),
.in_w_begin (fsm_write_begin),
.out_cyc_done (fsm_cyc_done),
.out_addr_r (add_addr_r),
.out_r_begin (add_r_begin),
.in_rw_done (fsm_read_write_done),
.out_strm_dn (add_strm_dn),
.out_addr_w (add_addr_w),
.out_w_begin (add_w_begin),
.out_addr_r_read (add_addr_r_read)
	);


DPBRAM dpb0(
.clk (clk),
.we_b (we_b),
.we_a (fsm_en_write_a),
.q_b (dat_strm_data),
.data_a (spi_data),
.addr_a (add_addr_r_read),
.addr_b (dat_out_addr)

	);

write_ramv1 wri0(
.clk (clk),

//other modules
.in_reset_n (fsm_reset_n),
.in_w_control (fsm_write_control),
.in_addr_w (add_addr_w),
.in_w_begin (add_w_begin),
.out_addr_w (wri_addr_w),
.out_data (wri_data),
.out_w_begin (wri_w_begin)
	);

data_buffer dat0(
.clk (clk),

//other modules
.in_reset_n (fsm_reset_n),
.in_data_control (fsm_data_buffer_control),
.out_diag_er (fsm_diag_er),
.in_strm_dn (add_strm_dn),
.out_addr (dat_out_addr),
.in_strm_data (dat_strm_data),
.new_samples (new_samples_a),

//august update
.led_one(led_one_a),
.led_two(led_two_a),

//feb update
.final_comp_complete (final_comp_complete_a),
.HR_out (hr_a),
.SPO2_out (spo2_a)

	);

fifov1 fif0(
.clk (clk),
.reset_n (reset_n),
.new_samples (final_comp_complete_a),
.led_one (spo2_a),
.led_two (hr_a),

//to wifi
.data_led1 (data_led1_a),
.data_led2 (data_led2_a),
.data_rdy (data_rdy_a),
	);

wifiv1 wf1(
.clk (clk),
.tx (tx),
.rx(rx),
//to fsm
.stream_start (stream_start_a),
.stream_stop (stream_stop_a),
.cpu_reset_n (cpu_reset_n_a),
.stream_rdy (stream_rdy_a),

//to fifo
.led1 (data_led1_a),
.led2 (data_led2_a),
.data_rdy (data_rdy_a)
	);
	endmodule