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
	parameter WIDTH_A = 14,
	parameter WIDTH_B = 14)
(
	input [WIDTH_A-1:0] a,
	input [WIDTH_B-1:0] b,
	input clk,
	input reset,
	input clken,
	output [WIDTH_A+WIDTH_B-1:0] prod);

	// Sum of the partial product
	reg [WIDTH_A+WIDTH_B-1:0] part_sum_d [WIDTH_B-1:0];
	// Pipelined input to be used after the corresponding pipeline point
	reg [WIDTH_A-1:0] a_d [WIDTH_B-1:0];
	reg [WIDTH_B-1:0] b_d [WIDTH_B-1:0];
	
	genvar i;	
	generate
		for (i = 0; i < WIDTH_B; i = i + 1) begin: pipe_chain
			always @(posedge clk) begin
				if (reset) begin
					a_d[i] <= 0;
					b_d[i] <= 0;
					part_sum_d[i] <= 0;
				end else if (clken) begin
					if (i == 0) begin
						a_d[i] <= a;
						b_d[i] <= b;
					end else begin
						a_d[i] <= a_d[i-1];
						b_d[i] <= b_d[i-1];
						if (i == 1)
							part_sum_d[i] <= a * b[i-1] + ((a * b[i]) << i);
						else
							part_sum_d[i] <= part_sum_d[i-1] + ((a_d[i-2] * b_d[i-2][i]) << i);
					end
				end
			end
		end
	endgenerate
	
	assign prod = part_sum_d[WIDTH_B-1];
	
endmodule
