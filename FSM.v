module FSM(
	input CLOCK_50,
	input wire [11:0] distance,
	output reg [6:0] sound_volume
);

	reg [2:0] sound_state;

	// States
	parameter distance_idle = 0;
	parameter distance_five = 1;
	parameter distance_ten = 2;
	parameter distance_twenty = 3;
	parameter distance_thirty = 4;
	parameter distance_over_thirty = 5;

	always @(sound_state) begin
		case (sound_state)
			distance_idle: begin
				sound_volume <= 0;
			end
			distance_five: begin
				sound_volume <= 100;
			end
			distance_ten: begin
				sound_volume <= 75;
			end
			distance_twenty: begin
				sound_volume <= 50;
			end
			distance_thirty: begin
				sound_volume <= 25;
			end
			distance_over_thirty: begin
				sound_volume <= 0;
			end
		endcase
	end

	always @(posedge CLOCK_50) begin
		case (sound_state)
			distance_idle: sound_state <= distance_five;
			distance_five: begin
				if (distance < 5)
					sound_state <= distance_five;
				else
					sound_state <= distance_ten;
			end
			distance_ten: begin
				if (distance < 10)
					sound_state <= distance_ten;
				else
					sound_state <= distance_twenty;
			end
			distance_twenty: begin
				if (distance < 20)
					sound_state <= distance_twenty;
				else
					sound_state <= distance_thirty;
			end
			distance_thirty: begin
				if (distance < 30)
					sound_state <= distance_thirty;
				else
					sound_state <= distance_over_thirty;
			end
			distance_over_thirty: begin
				if (distance >= 30)
					sound_state <= distance_over_thirty;
				else
					sound_state <= distance_idle;
			end
		endcase
	end

endmodule