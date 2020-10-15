`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/14 21:15:04
// Design Name: Testing top module of the parallel multiplier module
// Module Name: test_top
// Project Name: parallel_mult
// Target Devices: xc7z020clg400-1
// Tool Versions: Vivado 2020.1
// Description: This module test the parallel multiplier with the use of
//				VIO and ILA ip cores.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_top(
	input clk,
	input resetn);
	
	localparam WIDTH = 8;
	
	wire [WIDTH*2-1:0] prod;
	
	wire clkout;
	wire reset;
	
	reg [WIDTH-1:0] a;
	reg [WIDTH-1:0] b;
	
	wire [31:0] dds_out;
	
	assign clkout = clk;
	assign reset = ~resetn;
	
	always @(posedge clkout) begin
		if (reset) begin
			a <= 0;
			b <= 0;
		end else begin
			a <= a + 1'b1;
			b <= b + 1'b1;
		end
	end
	
	para_mult i_para_mult (
		.a(a),
		.b(b),
		.clk(clkout),
		.reset(reset),
		.clken(1'b1),
		.prod(prod));
		
	
	ila_0 i_ila (
		.clk(clkout),
		.probe0(prod),
		.probe1(a),
		.probe2(b));
		
endmodule
