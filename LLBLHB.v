module LLBorLHB(input c, input[15:0] rd, input[7:0] imm, output[15:0] out);
// if c is 1 rd gets lower 8 bits changed to input else rd gets higher 8 changed
	 assign out = (c) ? {rd[15:8], imm} : {imm, rd[7:0]};
 
endmodule


