`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: S.J. Wu (wusj42@outlook.com)
// 
// Create Date: 2020/10/11 16:22:04
// Design Name: Parallel Multiplier
// Module Name: mult_top
// Project Name: parallel_mult
// Target Devices: xc7z020clg400-1
// Tool Versions: Vivado 2020.1
// Description: This module calculates the product of two input numbers of the
// 				power of 2.
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// Vivado does not actually support macro function
`define LOG2(x) \
		(x <= 1) ? 0 : \
		(x <= 2) ? 1 : \
		(x <= 4) ? 2 : \
		(x <= 8) ? 3 : \
		(x <= 16) ? 4 : \
		(x <= 32) ? 5 : \
		(x <= 64) ? 6 : -1
`define pow2(x) \
		(x == 0) ? 1 : \
		(x == 1) ? 2 : \
		(x == 2) ? 4 : \
		(x == 3) ? 8 : \
		(x == 4) ? 16 : \
		(x == 5) ? 32 : \
		(x == 6) ? 64 : -1

module para_mult #(
	parameter WIDTH_A = 8,
	parameter WIDTH_B = 8)
(
	input [WIDTH_A-1:0] a,
	input [WIDTH_B-1:0] b,
	input clk,
	input reset,
	input clken,
	output reg [WIDTH_A+WIDTH_B-1:0] prod);

	wire [WIDTH_A:0] part_sum [WIDTH_B-1:0];
	wire [WIDTH_A-1:0] part_half_sum [WIDTH_B-1:1];
	wire [WIDTH_A+WIDTH_B-1:0] prod_s;

	genvar i;
	generate
	for (i = 0; i < WIDTH_B; i = i + 1) begin: part_mult
		if (i == 0)
			assign part_sum[i] = a * b[i];
		else begin
			assign part_half_sum[i] = part_sum[i-1][WIDTH_A:1] ^ a * b[i];
			carry_8bit i_carry (.DI(part_sum[i-1][WIDTH_A:1]),
				.S(part_half_sum[i]), .O(part_sum[i][WIDTH_A-1:0]),
				.cout(part_sum[i][WIDTH_A]), .CYINIT(0), .CI(0));
		end
		assign prod_s[i] = part_sum[i][0];
	end
	endgenerate
	assign prod_s[WIDTH_A+WIDTH_B-1:WIDTH_B] = part_sum[WIDTH_B-1][WIDTH_A:1];
	
	always @(posedge clk) begin
		if (reset) begin
			prod <= 0;
		end else if (clken) begin
			prod <= prod_s;
		end
	end
	
endmodule
