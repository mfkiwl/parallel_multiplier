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
// Revision 0.02 - Add the situation where there are no even numbers at the last
//					stage and this stage has to directly store the last number, e.g.
//					last stage = {a0,a1,a2,a3,a4}; this stage = {a5=a0+a1, a6=a2+a3, a7=a4}
//					(Shifting omitted).
// Revision 0.03 - Add the situation where the index of this stage is not simply
//					(2j-WIDTH_B) and (2j-WIDTH_B+1), rather there is -1 for some cases.
// Revision 0.04 - Add the situation where the last number of this stage has to be the
//					sum of last three number of last stage. This is determined by the index
//					length of this stage comparing to the index length of last stage.
// Revision 0.05 - Fix the issue where the index of this stage is not simply determined by
//					whether (WIDTH_B) can be fullly devided by (i) or not. The relationship
//					can be directly derived from that "The first (j) of this stage should
//					directly derive the last stage's first j. Otherwise has -1."
// Revision 0.06 - Add the last assignment according to that the last stage always only
//					consists one adder.
// Additional Comments: "Stages" in Revision means loop under same (i)
// 
//////////////////////////////////////////////////////////////////////////////////

module para_mult #(
	parameter WIDTH_A = 32,
	parameter WIDTH_B = 32)
(
	input [WIDTH_A-1:0] a,
	input [WIDTH_B-1:0] b,
	input clk,
	input reset,
	input clken,
	output [WIDTH_A+WIDTH_B-1:0] prod);

	// Sum of the partial product
	reg [WIDTH_A+WIDTH_B-1:0] part_sum_d [WIDTH_B-1:0];
	
	genvar i;
	genvar j;
	generate
	for (i = 1; i < WIDTH_B; i = i * 2) begin: stage
		for (j = WIDTH_B - WIDTH_B / i; j < WIDTH_B - WIDTH_B / (i * 2); j = j + 1) begin: part_adder
			always @(posedge clk)
			begin
				if (reset) begin
					part_sum_d[j] <= 0;
				end else if (clken) begin
					// The initial stage performing the multiplication is not pipelined
					if (i == 1) begin
						// Situation where the index length is odd (else) at the first stage
						// The last data is directly pipelined
						if (WIDTH_B % 2 == 0) begin
							part_sum_d[j] <= a * b[2*j] + ((a * b[2*j+1]) << i);
						end else begin
							if (j == (WIDTH_B - WIDTH_B / (i * 2) - 1)) begin
								part_sum_d[j] <= a * b[2*j];
							end else begin
								part_sum_d[j] <= a * b[2*j] + ((a * b[2*j+1]) << i);
							end
						end
					end else begin
						// Situation where non, the last number or the last three number
						// of the previous stage has to be combined to be last number of present stage
						if ((WIDTH_B/i - WIDTH_B/(i*2)) * 2 == (WIDTH_B/(i/2) - WIDTH_B/i)) begin
							// The difference in the indexing depends on the first index comparison
							// between previous and present stage
							if ((WIDTH_B / i) * 2 == WIDTH_B / (i / 2)) begin
								part_sum_d[j] <= part_sum_d[2*j-WIDTH_B] + (part_sum_d[2*j-WIDTH_B+1] << i);
							end else begin
								part_sum_d[j] <= part_sum_d[2*j-WIDTH_B-1] + (part_sum_d[2*j-WIDTH_B] << i);
							end
						end else if ((WIDTH_B/i - WIDTH_B/(i*2)) * 2 > (WIDTH_B/(i/2) - WIDTH_B/i)) begin
							if ((WIDTH_B / i) * 2 == WIDTH_B / (i / 2)) begin
								// Combine the last or three number(s)
								// under the condtion of index length comparison
								if (j == (WIDTH_B - WIDTH_B / (i * 2) - 1)) begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B];
								end else begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B] + (part_sum_d[2*j-WIDTH_B+1] << i);
								end
							end else begin
								if (j == (WIDTH_B - WIDTH_B / (i * 2) - 1)) begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B-1];
								end else begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B-1] + (part_sum_d[2*j-WIDTH_B] << i);
								end
							end
						end else begin
							if ((WIDTH_B / i) * 2 == WIDTH_B / (i / 2)) begin
								if (j == (WIDTH_B - WIDTH_B / (i * 2) - 1)) begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B] + (part_sum_d[2*j-WIDTH_B+1] << i) + 
														(part_sum_d[2*j-WIDTH_B+2] << (i + i));
								end else begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B] + (part_sum_d[2*j-WIDTH_B+1] << i);
								end
							end else begin
								if (j == (WIDTH_B - WIDTH_B / (i * 2) - 1)) begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B-1] +
													(part_sum_d[2*j-WIDTH_B] << i) +
													(part_sum_d[2*j-WIDTH_B+1] << (i + i));
								end else begin
									part_sum_d[j] <= part_sum_d[2*j-WIDTH_B-1] + (part_sum_d[2*j-WIDTH_B] << i);
								end
							end
						end
					end
				end
			end
			
			// Index length is 1, then it is the last stage
			if (WIDTH_B / i - WIDTH_B / (i * 2) - 1 == 0)
				assign prod = part_sum_d[j];
		end
	end
	endgenerate
	
endmodule
