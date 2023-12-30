// Data memory

module Data_mem(clk, mask, rd_en, wr_en, ALU_out, data_store, data_loaded);
	input  logic        clk;
	input  logic [3:0]  mask;
	input  logic [2:0]  rd_en;           // load instruction enable
	input  logic [2:0]  wr_en;           // store instruction enable
    input  logic [31:0] ALU_out;         // register address
	input  logic [31:0] data_store;      // data to be stored for s-type 
    output logic [31:0] data_loaded;     // loaded data for L-type
	
    logic [31:0] data_mem [0:31];
	initial	$readmemb("DataMem_machine_code.txt",data_mem);
	
	always_comb
	begin
		if(|rd_en)
		begin
			assign data_loaded = data_mem[ALU_out];
		end
	end
	
	always_ff@(negedge clk)
	begin
		if(|wr_en)
		begin
			if(mask[0]   == 1'b1)    data_mem[ALU_out][7:0]   <= data_store[7:0];
			if(mask[1]   == 1'b1)    data_mem[ALU_out][15:8]  <= data_store[15:8];
			if(mask[2]   == 1'b1)    data_mem[ALU_out][23:16] <= data_store[23:16];
			if(mask[3]   == 1'b1)    data_mem[ALU_out][31:24] <= data_store[31:24];
			if(mask[1:0] == 2'b11)   data_mem[ALU_out][15:0]  <= data_store[15:0];
			if(mask[3:2] == 2'b11)   data_mem[ALU_out][31:16] <= data_store[31:16];
			if(mask      == 4'b1111) data_mem[ALU_out]        <= data_store;
		end
	end

endmodule