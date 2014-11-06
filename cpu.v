`include "instr_mem.v"

module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
	supply0 ZERO;
	supply1 ONE;

	reg [15:0] pcAddress;
	reg [15:0] instruction;
	reg [15:0] instruc;
	wire rd_en = 1'b1;
	wire [3:0] OPCODE;
	wire [3:0] RS, RT, RD;
	wire [15:0] IMMEDIATE, A, B;

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
