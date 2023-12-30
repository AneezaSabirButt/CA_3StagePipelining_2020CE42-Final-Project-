//controller

module controller(inst, rg_wr, alu_op, sel_A, sel_B, br_type, rd_en, wr_en, wb_sel);
	input  logic [31:0] inst;
	output logic        rg_wr, sel_A, sel_B;
	output logic [1:0]  wb_sel;
	output logic [2:0]  rd_en, wr_en, br_type;
	output logic [3:0]  alu_op;
	
	logic [6:0] opcode;
	logic [2:0] func3;
	logic [6:0] func7;
	
	always_comb
	begin
		opcode = inst[6 : 0];
		func3  = inst[14:12];
		func7  = inst[31:25];
	end
	
	always_comb
	begin
		if (opcode == 7'b0110011) //R-Type
		begin
			br_type = 3'b000;  // pc+4
			sel_A   = 1; 		// A = rdata1
			sel_B   = 0; 		// B = rdata2
			wb_sel  = 1; 		// wdata = ALu_out
			rg_wr   = 1; 		// reg_mem[rd] = wdata
			if (func3 == 3'b000)// Arthimetic operation
			begin
			case (func7)
				7'b0000000 : alu_op = 4'b0001; //ADD 
				7'b0100000 : alu_op = 4'b0010; //SUB 
			endcase
			end
			
			if (func7 == 7'b0000000)// Logical operation
			begin
			case (func3)
				3'b100 : alu_op = 4'b0011; //XOR
				3'b110 : alu_op = 4'b0100; //OR
				3'b111 : alu_op = 4'b0101; //AND
			endcase
			end
			
			if (func7 == 7'b0000000)// Compare operation
			begin
			case (func3)
				3'b010 : alu_op = 4'b0110;//SLT
				3'b011 : alu_op = 4'b0111;//SLTU
			endcase
			end
				
			if (func3 == 3'b101)// Shift operation
			begin
			case (func7)
				7'b0000000 : alu_op = 4'b1000; //SRL
				7'b0100000 : alu_op = 4'b1001; //SRA
			endcase
			end

			if (func3 == 3'b001)// Shift operation
			begin
				alu_op = 4'b1010; //SLL
			end
	    end
			
		if (opcode == 7'b0010011) //I-Type
		begin
			br_type = 3'b000;  // pc+4
			sel_A   = 1; 		// A = rdata1
			sel_B   = 1; 		// B = I-imm
			wb_sel  = 1; 		// wdata = ALu_out
			rg_wr   = 1; 		// reg_mem[rd] = wdata
			case (func3)
				3'b000 : alu_op = 4'b0001; //ADDi
				3'b100 : alu_op = 4'b0011; //XORi
				3'b110 : alu_op = 4'b0100; //ORi
				3'b111 : alu_op = 4'b0101; //ANDi
				3'b010 : alu_op = 4'b1000; //SLTi
				3'b001 : alu_op = 4'b1010; //SLLi
				3'b101 : alu_op = 4'b1000; //SRLi
				3'b011 : alu_op = 4'b1001; //SRAi
			endcase
		end
		
		if (opcode == 7'b0000011) //I-Type load
		begin
			br_type = 3'b000;	// pc+4
			sel_A   = 1; 		// A = rdata1
			sel_B   = 1; 		// B = I-imm
			wb_sel  = 2; 		// wdata = data_mem[rd1 + I-imm] = rdata
			rg_wr   = 1; 		// reg_mem[rd] = wdata
			wr_en   = 0;
			alu_op  = 4'b0001; //ADDi  ALu_out = rd1 + I-imm
			case(func3)
			    3'b000 : rd_en = 3'b001; //for LB
				3'b100 : rd_en = 3'b010; //for LBU
				3'b001 : rd_en = 3'b011; //for LH
				3'b101 : rd_en = 3'b100; //for LHU
				3'b010 : rd_en = 3'b101; //for LW
		    endcase
		end
		
		if (opcode == 7'b0100011) //S-Type
		begin
			br_type = 3'b000; 	// pc+4
			sel_A   = 1; 		// A = rdata1
			sel_B   = 1; 		// B = I-imm
			rg_wr   = 0;
			rd_en   = 0;
			alu_op  = 4'b0001; //ADDi  Alu_out = rd1 + S-imm
			case(func3)
		        3'b000 : wr_en = 3'b001; //for SB
			    3'b001 : wr_en = 3'b010; //for SH
			    3'b010 : wr_en = 3'b011; //for SW
			endcase
		end
		
		if (opcode == 7'b1100011)  //B-Type
		begin
			sel_A  = 0;       // A = pc
			sel_B  = 1;       // B = B-Imm
			rg_wr  = 0;
			alu_op = 4'b0001;  //ADD  ALu_out = B-Imm + pc
	        case(func3)
		        3'b000 : br_type = 3'b001; //for BEQ
			    3'b001 : br_type = 3'b010; //for BNE
				3'b101 : br_type = 3'b100; //for BGE
			    3'b100 : br_type = 3'b011; //for BLT
				3'b111 : br_type = 3'b110; //for BGEU
				3'b110 : br_type = 3'b101; //for BLTU
			endcase
	    end
		
		if (opcode == 7'b0110111) // U-Type LUI instruction
        begin
	        br_type = 3'b000;	// pc+4
			sel_B   = 1; 		// B = U-imm
			wb_sel  = 1; 		// wdata = ALu_out
			rg_wr   = 1; 		// reg_mem[rd] = wdata
			alu_op = 4'b1011;  // ALu_out = U-Imm
    	end
		
		if (opcode == 7'b0010111) // U-Type AUIPC instruction
        begin
	        br_type = 3'b000;	// pc+4
			sel_A   = 0; 		// A = pc
			sel_B   = 1; 		// B = U-imm
			wb_sel  = 1; 		// wdata = ALu_out
			rg_wr   = 1; 		// reg_mem[rd] wdata
			alu_op  = 4'b0001; // ALu_out = pc + U-Imm
    	end
		
		if (opcode == 7'b1101111) // J-Type JAL instruction
        begin
	        wb_sel  = 0;       // wdata = pc+4
			rg_wr   = 1;       // reg_mem[rd] = wdata
			sel_A   = 0;       // A = pc
			sel_B   = 1;       // B = J-imm
			alu_op  = 4'b0001; // ALu_out = pc + J-Imm
			br_type = 3'b111;  // can not make it zero because pc = pc + J-Imm
    	end
		
		if (opcode == 7'b1100111) // J-Type JALR instruction
        begin
	        wb_sel  = 0;       // wdata = pc+4
			rg_wr   = 1;       // reg_mem[rd] = wdata
			sel_A   = 1;       // A = rdata1
			sel_B   = 1;       // B = J-imm
			alu_op  = 4'b0001; // ALu_out = rdata1 + J-Imm
			br_type = 3'b111;  // can not make it zero because pc = rdata1 + J-Imm
    	end
		
	end
	
endmodule


// control register for memory and writeback stage
module cont_reg(clk, stall, wb_sel, rd_en, wr_en, wb_sel_1, rd_en_1, wr_en_1, stall_MW);
	input  logic       clk, stall;
	input  logic [1:0] wb_sel;
	input  logic [2:0] rd_en, wr_en;
	output logic       stall_MW;
	output logic [1:0] wb_sel_1;
	output logic [2:0] rd_en_1, wr_en_1;
		
	always_ff@(posedge clk)
	begin
		wb_sel_1 <= wb_sel;
		rd_en_1  <= rd_en;
		wr_en_1  <= wr_en;
		stall_MW <= stall;
	end

endmodule