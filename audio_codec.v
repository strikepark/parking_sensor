module audio_codec(
	input iCLK_18_4,
	input [15:0] sound,
	input [11:0] distance,

	output oAUD_DATA,
	output oAUD_LRCK,
	output reg oAUD_BCK
);

	parameter REF_CLK =	18432000; // 18.432	MHz
	parameter SAMPLE_RATE =	48000; // 48 KHz (?anoioa aene?aoecaoee)
	parameter DATA_WIDTH = 16; // 16 Bits (Sample size)
	parameter CHANNEL_NUM =	2; // Dual Channel
	parameter SIN_SAMPLE_DATA = 48;

	parameter SIN_SANPLE = 0; // Input Source Number

	// Internal Registers and Wires
	reg	[3:0] BCK_DIV;
	reg	[8:0] LRCK_1X_DIV;
	reg	[7:0] LRCK_2X_DIV;
	reg	[6:0] LRCK_4X_DIV;
	reg	[3:0] SEL_Cont;

	reg	LRCK_1X;
	reg	LRCK_2X;
	reg	LRCK_4X;

	// AUD_BCK Generator
	always @(posedge iCLK_18_4) begin
		if (BCK_DIV >= REF_CLK / (SAMPLE_RATE * DATA_WIDTH * CHANNEL_NUM * 2) - 1) begin
			BCK_DIV <= 0;
			oAUD_BCK <= ~oAUD_BCK;
		end else
			BCK_DIV	<= BCK_DIV + 1;
	end
	
	// AUD_LRCK Generator
	always @(posedge iCLK_18_4) begin
		if (LRCK_1X_DIV >= REF_CLK / (SAMPLE_RATE * 2) - 1) begin // LRCK 1X
				LRCK_1X_DIV	<=	0;
				LRCK_1X	<= ~LRCK_1X;
		end else
			LRCK_1X_DIV <= LRCK_1X_DIV + 1;

		if (LRCK_2X_DIV >= REF_CLK / (SAMPLE_RATE * 4) - 1) begin // LRCK 2X
			LRCK_2X_DIV	<= 0;
			LRCK_2X	<= ~LRCK_2X;
		end else
			LRCK_2X_DIV <= LRCK_2X_DIV + 1;

		if (LRCK_4X_DIV >= REF_CLK / (SAMPLE_RATE * 8) - 1) begin // LRCK 4X
			LRCK_4X_DIV	<= 0;
			LRCK_4X	<= ~LRCK_4X;
		end else
			LRCK_4X_DIV	 <= LRCK_4X_DIV + 1;
	end

	assign oAUD_LRCK = LRCK_1X;
	
	// Sound out
	wire [15:0] music_sin;
	
	always @(negedge oAUD_BCK) begin
		SEL_Cont <= SEL_Cont + 1;
	end
	
	assign oAUD_DATA = music_sin[~SEL_Cont];

	reg [15:0] ramp;
	wire [35:0] ramp_max;
	assign ramp_max = (distance < 20) ? (20000 + (distance << 10)) : 40000;
	always @(negedge LRCK_1X) begin
		if (ramp > ramp_max)
			ramp = 0;
		else
			ramp = ramp + 1;
	end

	wire [7:0] ramp_sin= ramp[15:7];
	
	wave_gen_sin b1(
		.ramp(ramp_sin),
		.music_o(music_sin)
	);

endmodule