`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: S.J. Wu
// 
// Create Date: 2020/10/14 17:01:55
// Design Name: 8bit carry chain
// Module Name: carry_8bit
// Project Name: parallel_mult
// Target Devices: xc7z020clg400-1
// Tool Versions: Vivado 2020.1
// Description: This module implements 8bit carry chain with CARRY4 logi
//				with the main purpose to circumvent Vivado's insertion
//				of extra CARRY4 logic in 8to9 addtion.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module carry_8bit(
	input [7:0] DI,
	input [7:0] S,
	output [7:0] O,
	output cout,
	input CYINIT,
	input CI);
	
	localparam WIDTH = 8;
	
	wire [WIDTH/2-1:0] CO_inter;
	// Prevent Vivado from adding extra CARRY4 logic to the COUT pin
	(* dont_touch = "yes" *) wire [WIDTH/2-1:0] CO_out;
	
	assign cout = CO_out[WIDTH/2-1];
	
	CARRY4 i_carry4_1 (
		.CO(CO_inter),
		.O(O[WIDTH/2-1:0]),
		.CI(CI),
		.CYINIT(CYINIT),
		.DI(DI[WIDTH/2-1:0]),
		.S(S[WIDTH/2-1:0]));
		
	CARRY4 i_carry4_2 (
		.CO(CO_out),
		.O(O[WIDTH-1:WIDTH/2]),
		.CI(CO_inter[WIDTH/2-1]),
		.CYINIT(CYINIT),
		.DI(DI[WIDTH-1:WIDTH/2]),
		.S(S[WIDTH-1:WIDTH/2]));
	
endmodule
