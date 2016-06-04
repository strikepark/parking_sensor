module bin2bcd(B, BCD_0, BCD_1, BCD_2, BCD_3);

	input [13:0] B;
	output [3:0] BCD_0, BCD_1, BCD_2, BCD_3;
	
	wire [3:0]	w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13;
	wire [3:0]	w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24,w25;
	wire [3:0]	a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13;
	wire [3:0]	a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25;

	add3_ge5 A1 (w1,a1);
	add3_ge5 A2 (w2,a2);
	add3_ge5 A3 (w3,a3);
	add3_ge5 A4 (w4,a4);
	add3_ge5 A5 (w5,a5);
	add3_ge5 A6 (w6,a6);
	add3_ge5 A7 (w7,a7);
	add3_ge5 A8 (w8,a8);
	add3_ge5 A9 (w9,a9);
	add3_ge5 A10 (w10,a10);
	add3_ge5 A11 (w11,a11);
	add3_ge5 A12 (w12,a12);
	add3_ge5 A13 (w13,a13);
	add3_ge5 A14 (w14,a14);
	add3_ge5 A15 (w15,a15);
	add3_ge5 A16 (w16,a16);
	add3_ge5 A17 (w17,a17);
	add3_ge5 A18 (w18,a18);
	add3_ge5 A19 (w19,a19);
	add3_ge5 A20 (w20,a20);
	add3_ge5 A21 (w21,a21);
	add3_ge5 A22 (w22,a22);
	add3_ge5 A23 (w23,a23);
	add3_ge5 A24 (w24,a24);
	add3_ge5 A25 (w25,a25);

	assign  w1 = {1'b0, B[13:11]};
	assign  w2 = {a1[2:0], B[10]};
	assign  w3 = {a2[2:0], B[9]};
	assign  w4 = {1'b0, a1[3], a2[3], a3[3]};
	assign  w5 = {a3[2:0], B[8]};
	assign  w6 = {a4[2:0], a5[3]};
	assign  w7 = {a5[2:0], B[7]};
	assign  w8 = {a6[2:0], a7[3]};
	assign  w9 = {a7[2:0], B[6]};
	assign  w10 = {1'b0, a4[3], a6[3], a8[3]};
	assign  w11 = {a8[2:0], a9[3]};
	assign  w12 = {a9[2:0], B[5]};
	assign  w13 = {a10[2:0], a11[3]};
	assign  w14 = {a11[2:0], a12[3]};
	assign  w15 = {a12[2:0], B[4]};
	assign  w16 = {a13[2:0], a14[3]};
	assign  w17 = {a14[2:0], a15[3]};
	assign  w18 = {a15[2:0], B[3]};
	assign  w19 = {a16[2:0], a17[3]};
	assign  w20 = {a17[2:0], a18[3]};
	assign  w21 = {a18[2:0], B[2]};
	assign  w22 = {a10[3], a13[3], a16[3], a19[3]};
	assign  w23 = {a19[2:0], a20[3]};
	assign  w24 = {a20[2:0], a21[3]};
	assign  w25 = {a21[2:0], B[1]};

	assign BCD_0 = {a25[2:0],B[0]};
	assign BCD_1 = {a24[2:0],a25[3]};
	assign BCD_2 = {a23[2:0],a24[3]};
	assign BCD_3 = {a22[2:0],a23[3]};

endmodule