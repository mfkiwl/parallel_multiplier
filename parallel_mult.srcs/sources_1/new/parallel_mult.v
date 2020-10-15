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

	localparam PIPE_POINT = 3;

	wire [WIDTH_A+WIDTH_B-1:0] prod_s;
	
	// Sum of the partial product
	wire [WIDTH_A-1:0] tmp_half_sum [WIDTH_B-1:1];
	wire [WIDTH_A:0] tmp_sum [WIDTH_B-1:0];
	// Pipelined FFs of the partial sum at the pipeline point (3)
	// and partial product after the pipeline point
	reg [WIDTH_A:1] tmp_sum_3_d;
	reg [PIPE_POINT:0] prod_3_d;
	// Pipelined input to be used after pipeline point
	reg [WIDTH_A-1:0] a_d;
	reg [WIDTH_B-1:PIPE_POINT+1] b_d;
	
	genvar i;
	generate
	for (i = 0; i < WIDTH_B; i = i + 1) begin: part_mult
		if (i == 0) begin
			assign tmp_sum[i] = a * b[i];
		end else if (i == (PIPE_POINT + 1)) begin
			// Use pipelined sum of partial right after the pipeline point
			// Also use the pipelined multiplicand for synchronization
			assign tmp_half_sum[i] = tmp_sum_3_d ^ a_d * b_d[i];
			carry_8bit i_carry_8bit (.DI(tmp_sum_3_d), .S(tmp_half_sum[i]),
				.O(tmp_sum[i][WIDTH_A-1:0]), .cout(tmp_sum[i][WIDTH_A]),
				.CYINIT(0), .CI(0));
		end else if (i > (PIPE_POINT + 1)) begin
			// Pipelined multiplicand is used after for synchronization
			assign tmp_half_sum[i] = tmp_sum[i-1][WIDTH_A:1] ^ a_d * b_d[i];
			carry_8bit i_carry_8bit (.DI(tmp_sum[i-1][WIDTH_A:1]),
				.S(tmp_half_sum[i]), .O(tmp_sum[i][WIDTH_A-1:0]),
				.cout(tmp_sum[i][WIDTH_A]), .CYINIT(0), .CI(0));
		end else begin
			assign tmp_half_sum[i] = tmp_sum[i-1][WIDTH_A:1] ^ a * b[i];
			carry_8bit i_carry_8bit (.DI(tmp_sum[i-1][WIDTH_A:1]),
				.S(tmp_half_sum[i]), .O(tmp_sum[i][WIDTH_A-1:0]),
				.cout(tmp_sum[i][WIDTH_A]), .CYINIT(0), .CI(0));
		end
		// The LSB of each partial sum is the direct result
		assign prod_s[i] = tmp_sum[i][0];
	end
	endgenerate
	assign prod_s[WIDTH_A+WIDTH_B-1:WIDTH_B] = tmp_sum[WIDTH_B-1][WIDTH_A:1];
	
	always @(posedge clk)
	begin
		if (reset) begin
			prod <= 0;
		end else if (clken) begin
			prod <= {prod_s[WIDTH_A+WIDTH_B-1:PIPE_POINT+1], prod_3_d};
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			tmp_sum_3_d <= 0;
			prod_3_d <= 0;
		end else if (clken) begin
			// Pipeline the partial adder output at the pieline point and
			// pipeline the product output before the pipeline point
			tmp_sum_3_d <=  tmp_sum[PIPE_POINT][WIDTH_A:1];
			prod_3_d <= prod_s[PIPE_POINT:0];
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			a_d <= 0;
			b_d <= 0;
		end else if (clken) begin
			// Pipeline the multiplicand after the pipeline point
			a_d <= a;
			b_d <= b[WIDTH_B-1:PIPE_POINT+1];
		end
	end
	
endmodule
