`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: S.J. Wu
// 
// Create Date: 2020/10/15 13:28:13
// Design Name: Parallel multiplier testbench
// Module Name: mult_tb
// Project Name: parallel_mult
// Target Devices: xc7z020clg400-1
// Tool Versions: Vivado 2020.1
// Description: This module is the simulation testbench of the parallel
//				multiplier module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mult_tb( );
	
	localparam CLK_PERIOD = 8;
	
	reg [7:0] a;
	reg [7:0] b;
	reg clk;
	reg reset;
	reg clken;
	
	wire [15:0] prod;
	
	initial begin
		clk = 0;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end
	
	initial begin
		reset = 1;
		clken = 1;
		#100 reset = 0;
		#200 reset = 1;
		#1 reset = 0;
	end
	
	initial begin
		a = 0;
		b = 8'h0f;
		forever #(CLK_PERIOD) begin
			a = a + 1;
			b = b + 1;
		end
	end
	

	para_mult i_para_mult (
		.a(a),
		.b(b),
		.clk(clk),
		.reset(reset),
		.clken(clken),
		.prod(prod));

endmodule
