module branch(input [2:0] condition, input signed [8:0] label, input N, V, Z, input [15:0] pc,
		output reg [15:0] newPc, output reg execBranch);
	
	always @ (*) begin

		newPc = pc + label;

		// Condition is not equal
		if (condition == 3'b000) begin
			if (Z == 1'b0) begin
				execBranch = 1'b1;
			end
		end
		
		// Condition is equal
		else if (condition == 3'b001) begin
			if (Z == 1'b1) begin
				execBranch = 1'b1;
			end
		end
		
		// Condition is greater than
		else if (condition == 3'b010) begin
			if (Z == 1'b0 && N == 1'b0) begin
				execBranch = 1'b1;
			end
		end

		// Condition is less than
		else if (condition == 3'b011) begin
			if (N == 1'b1) begin	
				execBranch = 1'b1;
			end
		end

		// Condition is greater than or equal
		else if (condition == 3'b100) begin
			if (Z == 1'b1 || (Z == 1'b0 && N == 1'b0)) begin
				execBranch = 1'b1;
			end
		end

		// Condition is less than or equal
		else if (condition == 3'b101) begin
			if (N == 1'b1 || Z == 1'b1) begin
				execBranch = 1'b1;
			end
		end

		// Condition is overflow
		else if (condition == 3'b110) begin
			if (V == 1'b1) begin
				execBranch = 1'b1;
			end
		end
		
		// Unconditional
		else begin
			execBranch = 1'b0;
		end
		

	end

endmodule 


module jumpandlink(input signed [8:0] target, input [15:0] pc, input clk, input hlt,
		output [15:0] newPc);
	
	supply0 ZERO;
	supply1 ONE;

	wire retAddrReg = 4'hF;
	rf RT(.clk(clk),.p0_addr(ZERO),.p1_addr(ZERO),.p0(ZERO),.p1(ZERO),.re0(ZERO),.re1(ZERO),.dst_addr(retAddrReg),.dst(pc),.we(ONE),.hlt(hlt));

	assign newPc = pc + target;

endmodule


module jumpregister(input clk, input[15:0] rs, input hlt, output newPC );
   // jump to pc location in rs
   supply0 ZERO;
   supply1 ONE;
   rf Rooster(.clk(clk),.p0_addr(rs),.p1_addr(ZERO),.p0(newPC),.p1(ZERO),.re0(ONE),.re1(ZERO),.dst_addr(ZERO),.dst(ZERO),.we(ZERO),.hlt(hlt));
  
   
endmodule


module halt(input clk);
   //halt and dump registers
   supply0 ZERO;
   supply1 ONE;
   
   rf rocky(.clk(clk),.p0_addr(ZERO),.p1_addr(ZERO),.p0(ZERO),.p1(ZERO),.re0(ZERO),.re1(ZERO),.dst_addr(ZERO),.dst(ZERO),.we(ZERO),.hlt(ONE));
   
endmodule