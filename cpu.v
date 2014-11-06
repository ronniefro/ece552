`include "instr_mem.v"

module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
	reg [15:0] pcAddress;
	reg [15:0] instruction;
	reg [15:0] instruc;
	wire rd_en = 1'b1;
	
	IM pcAddr(clk, pcAddress, rd_en, instruction);
	
	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			pcAddress = 16'h0000;
		end
		else begin		
			instruc = instruction; 
			pcAddress = pcAddress + 4;
		end
	end
endmodule
