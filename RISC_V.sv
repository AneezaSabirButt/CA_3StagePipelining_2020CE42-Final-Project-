`timescale 1ns / 1ps

module RISC_V(clk, reset);
	input logic clk, reset;
	
	logic        rg_wr;
	logic        sel_A, sel_B, sel_rd1, sel_rd2, br_taken;
	logic        stall, stall_MW;
	logic [1:0]  wb_sel, wb_sel_1;
	logic [2:0]  rd_en, rd_en_1, wr_en, wr_en_1, br_type;
	logic [3:0]  alu_op, mask;
	logic [4:0]  raddr1, raddr2, waddr;
	logic [31:0] Imm_out;
	logic [31:0] new_inst, inst, inst1; 
	logic [31:0] new_pc, pc, pc_1, pc_2;
	logic [31:0] rd1, rd2, st_rd2;
	logic [31:0] rdata1, rdata2, wdata, rdata;
	logic [31:0] A, B, ALU_out, ALU_out_1;
	logic [31:0] data_loaded, data_store;
	
	always_comb
	begin
		raddr1 = inst[19:15];
	    raddr2 = inst[24:20];
	    waddr  = inst1[11: 7];
	end
	
	Inst_mem   im1(pc, new_inst);
	I_reg      IR0(clk, stall, flush, new_inst, inst);
	IR         IR1(clk, stall_MW, inst, inst1);
	Imm_Gen    ig1(inst, Imm_out);
	ALU        al1(A, B, alu_op, ALU_out);
	PC_1st     pc0(clk, reset, stall, new_pc, pc);
	PC         pc1(clk, stall, pc, pc_1);
	PC         pc2(clk, stall_MW, pc_1, pc_2);
	Fwd_Flush_Stall_Unit     FSU(br_taken, inst, inst1, rd_en_1, sel_rd1, sel_rd2, stall, flush);
	mux_ALU    mxA(pc_1, rd1, sel_A, A);
	mux_ALU    mxB(rd2, Imm_out, sel_B, B);
	mux_ALU    mR1(rdata1, rdata, sel_rd1, rd1);
	mux_ALU    mR2(rdata2, rdata, sel_rd2, rd2);
	mux_PC     mxP(pc, ALU_out, br_taken, new_pc);
	IR         alu(clk, stall_MW, ALU_out, ALU_out_1);
	IR         wd1(clk, stall_MW, rd2, st_rd2);
	Brn_cond   bc1(rd1, rd2, br_type, br_taken);
	mux_wdata  mxW(pc_2, ALU_out_1, rdata, wb_sel_1, wdata);
	Reg_file   rf1(clk, raddr1, raddr2, waddr, wdata, rg_wr, rdata1, rdata2);
	Data_mem   dm1(clk, mask, rd_en_1, wr_en_1, ALU_out_1, data_store, data_loaded);
	LS_unit    ls1(ALU_out_1, data_loaded, rd_en_1, wr_en_1, st_rd2, mask, data_store, rdata);
	controller ct1(inst, rg_wr, alu_op, sel_A, sel_B, br_type, rd_en, wr_en, wb_sel);
	cont_reg   cr1(clk, stall, wb_sel, rd_en, wr_en, wb_sel_1, rd_en_1, wr_en_1, stall_MW);
	
endmodule