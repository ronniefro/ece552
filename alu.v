`include "andnor.v"
`include "add.v"
`include "shifter.v"


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
module alu(input [15:0]A, B, input [3:0] shift_amt, opcode, input clk,
		output reg[15:0] S, output N, Z, V);
	wire [15:0] andOut, addOut, subOut, norOut, sllOut;
	wire [15:0] subB = ~B;
	wire addCout, subCout;
	reg addCin = 1'b0;
	reg subCin = 1'b1;

	and16bit and1(.A(A), .B(B), .out(andOut));
	fa16bit add1(.A(A), .B(B), .cin(addCin), .S(addOut), .cout(addCout));
	fa16bit sub1(.A(A), .B(subB), .cin(subCin), .S(subOut), .cout(subCout));
	nor16bit nor1(.A(A), .B(B), .out(norOut));
	sll shifterLeft(.A(A), .shift_amount(shift_amt), .out(sllOut));
	always@(posedge clk) begin
		//ADD
		if (opcode == 4'b0000) begin
			S = addOut;
		end
		//PADDSB
		//SUB
		else if (opcode == 4'b0010) begin
			S = subOut;
		end
		//AND
		else if (opcode == 4'b0011) begin
			S = andOut;
		end
		//NOR
		else if (opcode == 4'b0100) begin
			S = norOut;		
		end
		//SLL
		else if (opcode == 4'b0101) begin
			S = sllOut;
		end
		else begin
			S = 16'h0000;
		end
		
	end

endmodule

module alu_tb;
	reg [15:0] src0, src1;
	reg [3:0] func, shift_amt;
	reg clk;
	wire [15:0] dst;
	wire N, V, Z;

	alu DUT(.A(src0), .B(src1), .shift_amt(shift_amt), .opcode(func), .clk(clk),
		.S(dst), .N(N), .Z(Z), .V(V));

	initial begin
		$display("Simulation of ALU");
		$monitor ("Time = %d, src0= %d, src1= %d, shift_amt= %d, func= %b", $time, src0, src1, shift_amt, func);
		$monitor ("dst= %d, ov= %b, zr= %b, neg= %b", dst, V, Z, N);
		src0 = 0; src1 = 0;
		clk = 0;
	end
	always
		#2 clk = !clk;

	initial begin
		// Test add
		#10 func= 4'b0000; src0= 10; src1=20;
		#10 src0= 65000; src1= 25000;
		#10 src0= -25; src1= 25;
		#10 src0= 50000; src1= -25000;
		#10 src0= 10; src1= 10;

		// Test subtract
		#10 func= 4'b0010; src0= 10; src1=20;
		#10 src0= 65000; src1= 25000;
		#10 src0= -25; src1= 25;
		#10 src0= 50000; src1= -25000;
		#10 src0= 10; src1= 10;

		// Test PADDSB
		#10 func= 4'b0001; src0= 10; src1=20;
		#10 src0= 65000; src1= 25000;
		#10 src0= -25; src1= 25;
		#10 src0= 50000; src1= -25000;
		#10 src0= 10; src1= 10;

		// Test AND
		#10 func= 4'b0011; src0= 4'hFFFF; src1= 4'h0000;
		#10 src0= 4'hFFFF; src1= 4'hFFFF;
		#10 src0= 4'hFFFF; src1= 4'hF0F0;
		#10 src0= 4'hDEAD; src1= 4'hBEEF;

		// Test NOR
		#10 func= 4'b0100; src0= 4'hFFFF; src1= 4'h0000;
		#10 src0= 4'hFFFF; src1= 4'hFFFF;
		#10 src0= 4'hFFFF; src1= 4'hF0F0;
		#10 src0= 4'hDEAD; src1= 4'hBEEF;

		// Test SLL
		#10 func= 4'b0101; src0= 4'h8808; shift_amt= 4'b0001;
		#10 src0= 4'h1111; shift_amt= 4'h0011;

		// Test SRL
		#10 func= 4'b0110; src0= 4'h0808; shift_amt= 4'b0001;
		#10 src0= 4'h1111; shift_amt= 4'h0011;	
	
		// Test SRA
		#10 func= 4'b0111; src0= 4'h0808; shift_amt= 4'b0001;
		#10 src0= 4'hF000; shift_amt= 4'h0100;

		// Test LLB
		#10 func= 4'b1010; src0= 4'h1111; src1=4'hBEEF;

		// Test LBH
		#10 func= 4'b1011; src0= 4'h1111; src1=4'hDEAD;
	end
	
endmodule

