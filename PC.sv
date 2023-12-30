// module for program counter
module PC_1st(clk, reset, stall, new_pc, pc);
    input  logic clk, reset, stall;
    input  logic [31:0] new_pc;
	output logic [31:0] pc;
	
	always_ff@(posedge clk,posedge reset)
	begin
		if(reset) pc <= 0;
		else if (|stall) pc <= pc;
	    else pc <= new_pc;
	end
endmodule

module PC(clk, stall, new_pc, pc);
    input  logic        clk, stall;
    input  logic [31:0] new_pc;
	output logic [31:0] pc;
	
	always_ff@(posedge clk)
	begin
		if (|stall)
		begin
			pc <= pc;
		end
		else pc <= new_pc;
	end
endmodule

//IR register
module IR(clk, stall, new_inst, inst);
    input  logic clk, stall;
    input  logic [31:0] new_inst;
	output logic [31:0] inst;
	
	always_ff@(posedge clk)
	begin
		if (|stall)
		begin
			inst <= inst;
		end
		else inst <= new_inst;
	end
endmodule

module I_reg(clk, stall, flush, new_inst, inst);
    input  logic clk, stall, flush;
    input  logic [31:0] new_inst;
	output logic [31:0] inst;
	
	always_ff@(posedge clk)
	begin
		if (|flush) inst <= 0;
		else if (|stall) inst <= inst;
		else inst <= new_inst;
	end
endmodule

//Forwarding Unit
module Fwd_Flush_Stall_Unit(br_taken, inst, inst1, rd_en_1, sel_rd1, sel_rd2, stall, flush);
    input  logic        br_taken;
	input  logic [31:0] inst, inst1;
	input  logic [2 :0] rd_en_1;
	output logic        sel_rd1, sel_rd2;
	output logic        stall, flush;
	
	logic [31:0] raddr1, raddr2, waddr;
	
	always_comb
	begin
		raddr1 = inst[19:15];
	    raddr2 = inst[24:20];
	    waddr  = inst1[11: 7];
	end
	
	always_comb
	begin
		stall = 0;
		sel_rd1 = 0;
		sel_rd2 = 0;
		if (|rd_en_1)
		begin
			if ((raddr1 == waddr) || (raddr2 == waddr))
			begin
				stall = 1;
				sel_rd1 = 0;
				sel_rd2 = 0;
			end
		end
		else
		begin
			stall = 0;
			if(raddr1 == waddr) sel_rd1 = 1;
			if(raddr2 == waddr) sel_rd2 = 1;
		end
	end
// for flush 
	always_comb
	begin
		if (|br_taken) flush = 1;
		else flush = 0;
	end

endmodule

// Mux used to slect input of PC
module mux_PC(pc, ALU_out, br_taken, new_pc);
	input  logic [31:0] pc;
	input  logic [31:0] ALU_out;
	input  logic        br_taken;
	output logic [31:0] new_pc;
	
	always_comb
	begin
		if(br_taken == 1) new_pc = ALU_out;
		else new_pc = pc + 4;
	end
endmodule


//ALU input selector
module mux_ALU(pc, rdata1, sel_A, A);
    input  logic [31:0] pc;
	input  logic [31:0] rdata1;
	input  logic        sel_A;
	output logic [31:0] A;
	
	always_comb
	begin
	    case(sel_A)
	        0 : A = pc;
		    1 : A = rdata1;
	    endcase
    end
endmodule


// Immidiate generator
module Imm_Gen(inst, Imm_out);
    input  logic [31:0] inst;
	output logic [31:0] Imm_out;
	
    always_comb
    begin
	    case(inst[6:0])
		    7'b0010011 : Imm_out = inst[31:20];                         // imidiate for I-Type instruction
	   		7'b0000011 : Imm_out = $signed(inst[31:20]);                // signExtended imm for I-Type load instruction
	   		7'b0100011 : Imm_out = $signed({inst[31:25], inst[11:7]});  // signedExtended imm for S-Type store instruction
	   		7'b0110111 : Imm_out = {inst[31:12], 12'b0};                // imidiate for U-Type LUI instruction
			7'b0010111 : Imm_out = {inst[31:12], 12'b0};                // imidiate for U-Type AUIPC instruction
	   		7'b1100011 : Imm_out = $signed({inst[31], inst[7], inst[30:25], inst[11:8], 1'b0});   //immediate for B-Type instruction
	   		7'b1101111 : Imm_out = $signed({inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}); //immediate for J-Type JAL instruction
			7'b1100111 : Imm_out = $signed(inst[31:20]);                                          //immediate for J-Type JALR instruction
		endcase
	end
endmodule

// wdata mux
module mux_wdata(pc, ALU_out, rdata, wb_sel, wdata);
	input  logic [31:0] pc;
	input  logic [31:0] ALU_out;
	input  logic [31:0] rdata;
	input  logic [1:0]  wb_sel;
	output logic [31:0] wdata;
	
	always_comb
	begin
		case(wb_sel)
		    0 : wdata = pc + 4;
			1 : wdata = ALU_out;
			2 : wdata = rdata;
		endcase
	end
endmodule

//Branching
module Brn_cond(rdata1, rdata2, br_type, br_taken);
    input  logic [31:0] rdata1;
	input  logic [31:0] rdata2;
	input  logic [2:0]  br_type;
	output logic        br_taken;
		
	always_comb
	begin
		case(br_type)
			3'b000 : br_taken = 0;
		    3'b001 : begin  //BEQ condition
			            if (rdata1 == rdata2) br_taken = 1;
					    else br_taken = 0;
				     end
		    3'b010 : begin  //BNE condition
						if (rdata1 != rdata2) br_taken = 1;
					    else br_taken = 0;
				     end
		    3'b011 : begin  //BLT condition
			            if ($signed(rdata1) < $signed(rdata2)) br_taken = 1;
					    else br_taken = 0;
				     end
			3'b100 : begin  //BGE condition
			            if (($signed(rdata1) > $signed(rdata2)) || ($signed(rdata1) == $signed(rdata2))) br_taken = 1;
					    else br_taken = 0;
				     end
			3'b101 : begin  //BLTU condition
			            if (rdata1 < rdata2) br_taken = 1;
					    else br_taken = 0;
				     end
			3'b110 : begin  //BGE condition
			            if ((rdata1 > rdata2) || (rdata1 == rdata2)) br_taken = 1;
					    else br_taken = 0;
				     end
			3'b111 : br_taken = 1;
		endcase
    end
endmodule