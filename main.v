module main(
	// Clock Input
	input CLOCK_50,
	input CLOCK_27,

	input wire [35:0] GPIO_0,
	input [9:0] SW,
	input [3:0] KEY,

	output wire [35:0] GPIO_1,
	output [6:0] HEX0, HEX1, HEX2, HEX3,
	
	output [7:0] LEDG,
	output [9:0] LEDR,

	// I2C
	inout I2C_SDAT,
	output I2C_SCLK,

	// Audio CODEC
	inout AUD_BCLK, // Audio CODEC Bit-Stream Clock
	input AUD_ADCDAT, // Audio CODEC ADC Data
	output AUD_ADCLRCK, // Audio CODEC ADC LR Clock
	output AUD_DACLRCK, // Audio CODEC DAC LR Clock
	output AUD_DACDAT, // Audio CODEC DAC Data
	output AUD_XCK // Audio CODEC Chip Clock
);

	// START Key block
	wire key_reset;

	button btn(
		.clk(CLOCK_50),
		.key(KEY[0]),

		.btn_pressed(key_reset)
	);

	// START Distance block
	assign echo = GPIO_0[0];
	assign GPIO_1[0] = trigger;
	wire [11:0] distance;

	wire flag;
	ranging_module range(
		.clk(CLOCK_50),
		.echo(echo),
		.reset(reset),

		.trig(trigger),
		.flag(flag),
		.distance(distance)
	);

	// START BCD convertion block
	wire [3:0] distance_ones;
	wire [3:0] distance_tens;
	wire [3:0] distance_hundreds;
	wire [3:0] distance_thousands;

	bin2bcd decoder(
		.B({2'b00, distance}),

		.BCD_0(distance_ones),
		.BCD_1(distance_tens),
		.BCD_2(distance_hundreds),
		.BCD_3(distance_thousands)
	);

	// START Show distance on HEX block
	hex_7seg decoder2(
		.cs(distance_ones),
		.ds(distance_tens),
		.s(distance_hundreds),
		.das(distance_thousands),

		.seg0(HEX0),
		.seg1(HEX1),
		.seg2(HEX2),
		.seg3(HEX3)
	);

	// START FSM block
	wire [6:0] sound_volume;
	FSM fsm(
		.CLOCK_50(CLOCK_50),
		.distance(distance),

		.sound_volume(sound_volume)
	);
	
	// START Audio block
	wire AUD_CTRL_CLK;
	assign AUD_ADCLRCK = AUD_DACLRCK;
	assign AUD_XCK = AUD_CTRL_CLK;

	wire I2C_END; // Generate 18.432 MGz
	VGA_Audio_PLL u1(
		.areset(~I2C_END),
		.inclk0(CLOCK_27),

		.c1(AUD_CTRL_CLK)
	);
	
	reg [7:0] delay; // Delay for reset Audio out
	always @(posedge CLOCK_50) begin
		if (!delay[7])
			delay <= delay + 1;
	end
	
	I2C_AV_Config u7( // Config volume and reset with I2C interface
		.iCLK(CLOCK_50),
		.iRST_N(delay[7]),
		.o_I2C_END(I2C_END),
		.iVOL(sound_volume),
		.I2C_SCLK(I2C_SCLK),
		.I2C_SDAT(I2C_SDAT)
	);

	reg [31:0] VGA_CLK_o;
	wire keyboard_sysclk = VGA_CLK_o[11];

	assign VGA_CLK = VGA_CLK_o[0];
	always @(posedge CLOCK_50)
		VGA_CLK_o = VGA_CLK_o + 1;

	wire [7:0] demo_code;
	demo_sound gen(
		.clock(VGA_CLK_o[18]),
		.k_tr(~1'b1), // TODO: add counter*
		
		.key_code(demo_code)
	);

	wire [7:0] sound_code = demo_code;
	wire [15:0] sound;
	staff st( // Generate frequency
		.scan_code(sound_code),
		.sound(sound)
	);
	
	audio_codec ad1(
		.iSrc_Select(2'b00),
		.iCLK_18_4(AUD_CTRL_CLK),

		.sound(sound),
		
		.oAUD_BCK (AUD_BCLK),
		.oAUD_DATA(AUD_DACDAT),
		.oAUD_LRCK(AUD_DACLRCK)
	);

endmodule