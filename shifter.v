module sll(input[15:0] A, input[3:0] shift_amount,
			output[15:0] out);

	assign out = A << shift_amount;
	
endmodule

module srl(input[15:0] A, input[3:0] shift_amount,
			output[15:0] out);

	assign out = A >> shift_amount;
	
endmodule

module sra(input signed[15:0] A, input[3:0] shift_amount,
			output signed[15:0] out);

	assign out = A >>> shift_amount;

endmodule

