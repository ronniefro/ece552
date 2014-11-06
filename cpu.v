`include "instr_mem.v"
`include "alu.v"
`include "lwsw.v"
`include "LLBLHB.v"
`inlcude "control_instrucs.v"


module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
	supply0 ZERO;
	supply1 ONE;

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
	
	

	wire [3:0] OPCODE;
	wire [3:0] RS, RT, RD;
	wire [15:0] IMMEDIATE;

	IM pcAddr(clk, pcAddress, rd_en, instruction);
	rf READ (.clk(clk),.p0_addr(RS),.p1_addr(RT),.p0(A),.p1(B),.re0(ONE),.re1(ONE),.dst_addr(ZERO),.dst(ZERO),.we(ZERO),.hlt(ZERO));
	rf WRITE(.clk(clk),.p0_addr(ZERO),.p1_addr(ONE),.p0(ZERO),.p1(ZERO),.re0(ZERO),.re1(ZERO),.dst_addr(RD),.dst(OUT),.we(ONE),.hlt(ZERO));

	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			pcAddress = 16'h0000;
		end
		else begin		
			assign instruc = instruction; 
			pcAddress = pcAddress + 4;
			assign OPCODE = [15:12]instruc;

			// ALU operation
			if (OPCODE[3] == 1'b0)	begin
				assign RD = [11:8]instruc;
				assign RS = [7:4]instruc;
				assign RT = [3:0]instruc;


			end
		end
	end
endmodule
