module generate_sound(
	input sound_clock,
	output [15:0] sound
);

	// Music-processing
	reg [15:0] step = 0;
	reg [15:0] step_max = 10;
	reg tr;

	reg [5:0] state = 0;
	reg go_end;
	always @(posedge sound_clock) begin // TODO: check condition with state = 0;
		if (step < step_max) begin
			case (state)
				0: begin
					state <= state + 1;
				end
				1: begin
					tr = 0;
					state <= state + 1;
				end
				2: begin
					tr = 1;
					state <= state + 1;
				end
				3: begin
					if (go_end)
						state <= state + 1;
				end
				4: begin
					state <= 0;
					step <= step + 1;
				end
			endcase
		end else begin
			step <= 0;
			state <= 0;
			tr <= 0;
		end
	end
	
	// Pitch effect (������ ��������� ����)
	wire [7:0] pitch = (
		(TT[3:0] == 1) ? 8'h2b : (
		(TT[3:0] == 2) ? 8'h34 : (
		(TT[3:0] == 3) ? 8'h33 : (
		(TT[3:0] == 4) ? 8'h3b : (
		(TT[3:0] == 5) ? 8'h42 : (
		(TT[3:0] == 6) ? 8'h4b : (
		(TT[3:0] == 7) ? 8'h4c : (
		(TT[3:0] == 10) ? 8'h52 : (
		(TT[3:0] == 15) ? 8'hf0 : 8'hf0
		))))))))
	);
	
	// Paddle effect
	wire [15:0] paddle = (
		(TT[7:4] == 15) ? 16'h10 : (
		(TT[7:4] == 8) ? 16'h20 : (
		(TT[7:4] == 9) ? 16'h30 : (
		(TT[7:4] == 1) ? 16'h40 : (
		(TT[7:4] == 3) ? 16'h60 : (
		(TT[7:4] == 2) ? 16'h80 : (
		(TT[7:4] == 4) ? 16'h100 : 0
		))))))
	);
	
	// Note list
	reg [15:0] TT;
	always @(posedge sound_clock) begin
		if (state == 0) begin
			case (step)
				0: TT = 8'h86;
				1: TT = 8'h86;
				2: TT = 8'hf6;
				3: TT = 8'h35;
				4: TT = 8'h84;
				5: TT = 8'h13;
				6: TT = 8'h12;
				7: TT = 8'h31;
				8: TT = 8'h85;
				9: TT = 8'h36;
				10: TT = 8'h86;
			endcase
		end
	end

	// Generate code from note list
	reg [15:0] tmp;
	always @(negedge tr or posedge sound_clock) begin
		if (!tr) begin
			tmp <= 0;
			go_end <= 0;
		end else if (tmp > paddle) begin
			go_end <= 1;
		end else begin
			tmp <= tmp + 1;
		end
	end

	assign sound_code = (tmp < (paddle - 1)) ? pitch : 8'hf0;
	
	// Staff
	wire sound_off = (sound_code == 8'hf0) ? 0 : 1;

	// Trigger
	wire L_5_tr = (sound_code == 8'h1c) ? 1 : 0; // -5
	wire L_6_tr = (sound_code == 8'h1b) ? 1 : 0; // -6
	wire L_7_tr = (sound_code == 8'h23) ? 1 : 0; // -7
	wire M_1_tr = (sound_code == 8'h2b) ? 1 : 0; // 1
	wire M_2_tr = (sound_code == 8'h34) ? 1 : 0; // 2
	wire M_3_tr = (sound_code == 8'h33) ? 1 : 0; // 3
	wire M_4_tr = (sound_code == 8'h3b) ? 1 : 0; // 4
	wire M_5_tr = (sound_code == 8'h42) ? 1 : 0; // 5
	wire M_6_tr = (sound_code == 8'h4b) ? 1 : 0; // 6
	wire M_7_tr = (sound_code == 8'h4c) ? 1 : 0; // 7
	wire H_1_tr = (sound_code == 8'h52) ? 1 : 0; // 1
	wire Hu1_tr = (sound_code == 8'h5b) ? 1 : 0; // 1
	wire Mu6_tr = (sound_code == 8'h4d) ? 1 : 0; // 6
	wire Mu5_tr = (sound_code == 8'h44) ? 1 : 0; // 5
	wire Mu4_tr = (sound_code == 8'h43) ? 1 : 0; // 4
	wire Mu2_tr = (sound_code == 8'h35) ? 1 : 0; // 2
	wire Mu1_tr = (sound_code == 8'h2c) ? 1 : 0; // 1
	wire Lu6_tr = (sound_code == 8'h24) ? 1 : 0; // -6
	wire Lu5_tr = (sound_code == 8'h1d) ? 1 : 0; // -5
	wire Lu4_tr = (sound_code == 8'h15) ? 1 : 0; // -4

	// Frequency
	assign sound = (
		(Lu4_tr) ? 400 : (
		(L_5_tr) ? 423 : (
		(Lu5_tr) ? 448 : (
		(L_6_tr) ? 475 : (
		(Lu6_tr) ? 503 : (
		(L_7_tr) ? 533 : (
		(M_1_tr) ? 565 : (
		(Mu1_tr) ? 599 : (
		(M_2_tr) ? 634 : (
		(Mu2_tr) ? 672 : (
		(M_3_tr) ? 712 : (
		(M_4_tr) ? 755 : (
		(Mu4_tr) ? 800 : (
		(M_5_tr) ? 847 : (
		(Mu5_tr) ? 897 : (
		(M_6_tr) ? 951 : (
		(Mu6_tr) ? 1007 : (
		(M_7_tr) ? 1067 : (
		(H_1_tr) ? 1131 : (
		(Hu1_tr) ? 1198 : 1
		)))))))))))))))))))
	);

endmodule