// instruction memory

module Inst_mem(pc, inst);
    input  logic [31:0] pc;
    output logic [31:0] inst;

    logic [31:0] inst_mem [0:21];

    initial $readmemb("Instmem_machine_code_factorial.txt",inst_mem);
	
    always_comb
	begin
	    inst = inst_mem[pc[31:2]];
	end
	
endmodule