// Register File

module Reg_file(clk, raddr1, raddr2, waddr, wdata, rg_wr, rdata1, rdata2);
    input  logic clk, rg_wr;
	input  logic [4:0] raddr1;
	input  logic [4:0] raddr2;
	input  logic [4:0] waddr;
    input  logic [31:0] wdata;
    output logic [31:0] rdata1;
	output logic [31:0] rdata2;

    logic [31:0] reg_mem [0:31];

    initial	$readmemb("RegFile_machine_code.txt",reg_mem);

    always_comb
	begin
        if(|raddr1) rdata1 = reg_mem[raddr1];
        else rdata1 = 0;
        if(|raddr2) rdata2 = reg_mem[raddr2];
    end
	
    always_ff @(negedge clk)
	begin
	    if (rg_wr) 
		begin
			if(|waddr) reg_mem[waddr] <= wdata;
        end
	end
endmodule