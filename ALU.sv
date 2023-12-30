// ALU

module ALU(A, B, alu_op, ALU_out);
     input  logic [31:0] A;
     input  logic [31:0] B;
     input  logic [3 :0] alu_op;
	 output logic [31:0] ALU_out;
		 
	always_comb
	begin
		case (alu_op) //R-Type implementation in ALU
			4'b0001 : ALU_out = A + B; //ADD
			4'b0010 : ALU_out = A - B; //SUB
			4'b0011 : ALU_out = A ^ B; //XOR
			4'b0100 : ALU_out = A | B; //OR
			4'b0101 : ALU_out = A & B; //AND
			4'b0110 : begin            //SLT
					     if ($signed(A) < $signed(B)) ALU_out = 1;
					     else ALU_out = 0;
					  end
			4'b0111 : begin            //SLTU
					     if (A < B) ALU_out = 1;
					     else ALU_out = 0;
					  end
			4'b1000 : ALU_out = (A >> B);  //SRL
			4'b1001 : ALU_out = (A >>> B); //SRA
			4'b1010 : ALU_out = A << (B);  //SLL
			4'b1011 : ALU_out = B;         //U-Type LUI,  ALU_out = U-Imm
		endcase
	end
endmodule
