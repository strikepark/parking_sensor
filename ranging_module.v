module ranging_module(
	input wire clk,
	input wire echo,
	input wire reset,

	output reg trig,
	output wire flag,
	output wire [11:0] distance,
	output wire [23:0] period_cnt_output
);

	// Период между импульсами 100мс
	reg [23:0] period_cnt;
	wire period_cnt_full;
	
	always @(posedge clk or posedge reset)
		begin
			if (reset)
				period_cnt <= 0;
			else
				begin
					if (period_cnt_full)
						period_cnt <= 0;
					else
						period_cnt <= period_cnt + 1;
				end
		end

	assign period_cnt_full = (period_cnt == 5000000);
	
	// DEBUG
	assign period_cnt_output = period_cnt;

	// Отправляем Trig в течении 100мкс
	always @(posedge clk or posedge reset)
		begin
			if (reset)
				trig <= 0;
			else
				trig <= ( period_cnt > 100 && period_cnt < 5100);
		end


	// Слушаем и считаем Echo
	reg [11:0] echo_length;
	always @(posedge clk or posedge reset)
		begin
			if (reset)
				echo_length <= 0;
			else
				begin
					if (trig || echo_length == 275)
						echo_length <= 0;
					else if (echo)
						echo_length <= echo_length + 1;
				end
		end


	// Считаем дистанцию в см
	reg [11:0] distance_temp;
	always @(posedge clk or posedge reset)
		begin
			if (reset)
				distance_temp <= 0;
			else
				begin
					if (trig)
						distance_temp <= 0;
					else if (echo && echo_length == 275 && distance_temp < 500)
						distance_temp <= distance_temp + 1;
				end
		end


	// Каждый период на выход передаем текущую дистанцию
	 reg [11:0] distance_output;
	 always @(posedge clk or posedge reset)
	 	begin
	 		if (reset)
	 			distance_output <= 0;
	 		else if (period_cnt_full)
	 			distance_output <= distance_temp;
	 	end

	assign distance = distance_output / 10;
	assign flag = period_cnt_full ? 1 : 0;

endmodule