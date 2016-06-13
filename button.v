module button(
	input clk,
	input key,
	
	output btn_pressed
);

	wire btn;
	assign btn = key;

	reg [2:0] btn_sync;

	always @(posedge clk) begin
		btn_sync[0] <= ~btn;
		btn_sync[1] <= btn_sync[0];
		btn_sync[2] <= btn_sync[1];
	end
	
	assign btn_pressed = (~btn_sync[2]) && btn_sync[1];

endmodule