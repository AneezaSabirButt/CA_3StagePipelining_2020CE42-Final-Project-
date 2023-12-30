`timescale 1ns / 1ps

module RISC_V_tb();
	logic clk, reset;
	
	RISC_V uut(.clk(clk), .reset(reset));
	
	initial
	begin
		clk = 5;
		forever #5 clk <= ~clk;
	end
	
	initial
	begin
		#10
		reset = 1;
		#10
		reset = 0;
		#500
		$stop;
	end
	
endmodule