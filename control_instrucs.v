module branch(input [2:0] condition, input signed [8:0] label, input N, V, Z, input [15:0] pc,
		output reg [15:0] newPc, output reg execBranch);
	
	always @ (*) begin

		newPc = pc + label;
      execBranch = 1'b0;
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




