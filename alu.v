// ALU module
// Opcodes:
// ADD 		0000
// PADDSB 	0001
// SUB		0010
// AND		0011
// NOR		0100
// SLL		0101
// SRL		0110
// SRA		0111
module alu(input [15:0]A, B, input [3:0] shift_amt, opcode,
		output [15:0] S, output N, Z, V);
	always@(posedge clk)
		if (opcode[2] == 0) begin

		end
		else
			if (opcode == 0100) begin
				nor16bit nor1(.A(A), .B(B), .out(S));
			end
	end

endmodule