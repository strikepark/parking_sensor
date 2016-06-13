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

	// I2C (2 Wire MODE, CSB and MODE = 0)
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

	// Inout ports turn to tri-state
	assign I2C_SDAT = 1'bz;

	// Config audio ports
	wire UD_CTRL_CLK;
	assign AUD_ADCLRCK = AUD_DACLRCK;
	assign AUD_XCK = AUD_CTRL_CLK;

	// PLL
	PLL b1( // Generate 18.432 MGz
		.areset(~I2C_END),
		.inclk0(CLOCK_27),

		.c1(AUD_CTRL_CLK)
	);

	// Software control interface
	reg [7:0] delay;
	always @(posedge CLOCK_50) begin
		if (!delay[7])
			delay = delay + 1;
	end

	// START Key block
	wire key_reset;

	button btn(
		.clk(CLOCK_50),
		.key(KEY[0]),

		.btn_pressed(key_reset)
	);

	reg res = 0;
	wire [6:0] vol;
	reg  [6:0] volume;
	always @(posedge CLOCK_50) begin
		if (distance == 0 || distance >= 50) begin
			volume <= 0;
		end

		if (distance > 39 && distance < 49) begin
			volume <= 82;
		end

		if (distance > 29 && distance < 39) begin
			volume <= 91;
		end

		if (distance > 19 && distance < 12'd29) begin
			volume <= 109;
		end

		if (distance > 0 && distance < 19'd19) begin
			volume <= 127;
		end
	end

	reg [13:0] volume_sync;

	always @(posedge CLOCK_50) begin
		volume_sync[6:0] <= volume;
		volume_sync[13:7] <= volume_sync[6:0];

		if(volume_sync[13:7] == volume)
			res <= 1;
		else
			res <= 0;
	end

	assign vol = volume;
	assign LEDG[6:0] = volume;

	wire I2C_END;
	software_control_interface b2(
		.iCLK(CLOCK_50),
		.iRST_N(res),
		.iVOL(vol),
		.o_I2C_END(I2C_END),

		// For Wolfson
		.I2C_SCLK(I2C_SCLK),
		.I2C_SDAT(I2C_SDAT)
	);

	// Generate sound
	reg [31:0] sound_clock_counter;
	wire sound_clock = sound_clock_counter[18];

	always @(posedge CLOCK_50) begin
		sound_clock_counter = sound_clock_counter + 1;
	end

	// wire [15:0] sound;
	// assign sound = 423;
	// generate_sound b3(
	// 	.sound_clock(sound_clock),
	// 	.sound(sound)
	// );

	// Play audio
	audio_codec b4(
		.iCLK_18_4(AUD_CTRL_CLK),
		// .sound(sound),
		.distance(distance),

		.oAUD_BCK(AUD_BCLK),
		.oAUD_DATA(AUD_DACDAT),
		.oAUD_LRCK(AUD_DACLRCK),
	);

endmodule
