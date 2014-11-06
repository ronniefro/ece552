`include "instr_mem.v"
`include "alu.v"
`include "lwsw.v"
`include "LLBLHB.v"
`inlcude "control_instrucs.v"


module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
	reg [15:0] pcAddress;
	reg [15:0] instruction;
	reg [15:0] instruc;
	wire rd_en = 1'b1;
	//RS RT RD 4 bit
	//OPCODE 4 bit
	//IMMEDIATE 16bit
	wire[15:0] OUT;
	wire Z, N, V;
	//rs = A, rt = B
	wire[15:0] A,B;
   alu ALU(.A(A), .B(B),.shift_amt(RT), .opcode(OPCODE), .clk(clk),
		      .S(OUT), .N(N), .Z(Z), .V(V));
   
   LLB LLB(.clk(clk), input[3:0] rd, input[7:0] imm, input hlt);	
   
   LHB LHB(.clk(clk), input[3:0] rd, input[7:0] imm, input hlt); 
   
   sw LW(.clk(clk), input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
   
   lw LW(.clk(clk), input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
   
   branch BRANCH(input [2:0] condition, input signed [8:0] label, input N, V, Z, input [15:0] pc,
	   output reg [15:0] newPc, output reg execBranch);
	
	jumpandlink JUMPANDLINK(input signed [8:0] target, input [15:0] pc, input clk, input hlt,
	   output [15:0] newPc);
	
	jumpregister JUMPREGISTER(.clk(clk), input[15:0] rs, input hlt, output newPC );
	
	halt HALT(.clk(clk));
	IM pcAddr(.clk, pcAddress, rd_en, instruction);
	
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
