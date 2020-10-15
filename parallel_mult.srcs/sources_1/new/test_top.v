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
	input clkin,
	input resetn);
	
	localparam WIDTH_A = 14;
	localparam WIDTH_B = 14;
	
	wire [WIDTH_A+WIDTH_B-1:0] prod;
	
	wire clk;
	wire reset;
	
	reg [WIDTH_A-1:0] a;
	reg [WIDTH_B-1:0] b;
	
	assign reset = ~resetn;
	
	always @(posedge clk) begin
		if (reset) begin
			a <= 0;
			b <= 0;
		end else begin
			a <= a + 1'b1;
			b <= b + 1'b1;
		end
	end
	
	para_mult #(
		.WIDTH_A(WIDTH_A),
		.WIDTH_B(WIDTH_B))
	i_para_mult (
		.a(a),
		.b(b),
		.clk(clk),
		.reset(reset),
		.clken(1'b1),
		.prod(prod));
		
	wire clkfbout;
	wire clkfbin;
	wire locked;
	wire pwrdwn;
	wire clkout;
	MMCME2_BASE #(
		.BANDWIDTH("OPTIMIZED"),
		.CLKFBOUT_MULT_F(9.0),
		.CLKFBOUT_PHASE(0.0),
		.CLKIN1_PERIOD(8.0),
		.CLKOUT0_DIVIDE_F(7.5),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT0_PHASE(0.0),
		.CLKOUT4_CASCADE("FALSE"),
		.DIVCLK_DIVIDE(1),
		.REF_JITTER1(0.0),
		.STARTUP_WAIT("FALSE"))
	i_mmcme2_base (
		.CLKOUT0(clkout),
		.CLKFBOUT(clkfbout),
		.CLKFBIN(clkfbin),
		.CLKIN1(clkin),
		.LOCKED(locked),
		.PWRDWN(pwrdwn),
		.RST(reset));
		
	BUFH i_bufh_fb (
		.O(clkfbin),
		.I(clkfbout));
		
	BUFH i_bufh (
		.O(clk),
		.I(clkout));
	
	ila_0 i_ila (
		.clk(clk),
		.probe0(prod),
		.probe1(a),
		.probe2(reset));
		
endmodule
