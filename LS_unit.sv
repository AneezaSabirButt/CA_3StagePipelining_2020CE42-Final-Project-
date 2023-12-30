
//LS_Unit
module LS_unit(ALU_out, data_loaded, rd_en, wr_en, rdata2, mask, data_store, rdata);
	input  logic [31:0] ALU_out;
	input  logic [31:0] data_loaded;
	input  logic [31:0] rdata2;
	input  logic [2:0]  rd_en, wr_en;
	output logic [3:0]  mask;
	output logic [31:0] data_store;
	output logic [31:0] rdata;

	logic [7:0]  rdata_byte;
	logic [15:0] rdata_half_word;
	logic [31:0] rdata_word;

	always_comb
	begin
		case (rd_en)
		    3'b001,3'b010: begin  // LB & LBU
						   case(ALU_out[1:0])
								2'b00 : rdata_byte = data_loaded[7:0];
								2'b01 : rdata_byte = data_loaded[15:8];
								2'b10 : rdata_byte = data_loaded[23:16];
								2'b11 : rdata_byte = data_loaded[31:24];
						   endcase
						   end	
			3'b011,3'b100: begin  // HW & HWU
						   case(ALU_out[2])
								1'b0 : rdata_half_word = data_loaded[15:0];
								1'b1 : rdata_half_word = data_loaded[31:16];
						   endcase
						   end
			3'b101 : rdata_word = data_loaded; //LW	
        endcase
	end
	
	always_comb
	begin
		case(rd_en)
			3'b001 : rdata = {{24{rdata_byte[7]}},       rdata_byte};
			3'b010 : rdata = {24'b0,                     rdata_byte};
			3'b011 : rdata = {{16{rdata_half_word[15]}}, rdata_half_word};
			3'b100 : rdata = {16'b0,                     rdata_half_word};
			3'b101 : rdata = {                           rdata_word};
		endcase
	end
	
	always_comb
	begin
		case (wr_en)
		    3'b001 : begin // SB
					 case(ALU_out[1:0])
						2'b00 : begin
									data_store[7:0] = rdata2[7:0];
									mask = 4'b0001;
								end
						2'b01 : begin
									data_store[15:8] = rdata2[15:8];
									mask = 4'b0010;
								end
						2'b10 : begin
									data_store[23:16] = rdata2[23:16];
									mask = 4'b0100;
								end
						2'b11 : begin
									data_store[31:24] = rdata2[31:24];
									mask = 4'b1000;
								end
					 endcase
					 end
			3'b010 : begin // SW
					 case(ALU_out[2])
						1'b0 : begin
					    			data_store[15:0] = rdata2[15:0];
									mask = 4'b0011;
							   end
						1'b1 : begin
									data_store[31:16] = rdata2[31:16];
									mask = 4'b1100;
							   end
					 endcase
					 end
			3'b011 : begin
						data_store = rdata2;
						mask = 4'b1111;
					 end
	    endcase
	end


endmodule