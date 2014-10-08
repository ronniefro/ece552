module alu_tb;
	reg [15:0] src0, src1;
	reg [3:0] func, shift_amt;
	wire [15:0] dst;
	wire ov, zr, neg;

	ALU0 alu(.src0 (src0), 
	.src1 (src1), 
	.func (func), 
	.shift_amt (shift_amt), 
	.dst (dst), 
	.ov (ov), 
	.zr (zr), 
	.neg (neg));

	// Instantiate variables
	initial begin
		src0 = 0;
		src1 = 0;
		func = 0;
		shift_amt = 0;
		$display ("======= Begin Test ======== ");
		$monitor ("Time = %d, src0= %d, src1= %d, shift_amt= %d, func= %b", $time, src0, src1, shift_amt, func);
		$monitor ("dst= %d, ov= %b, zr= %b, neg= %b", dst, ov, zr, neg);
	end

	// Where the inputs are changed
	initial begin
		// Test add
		#10 func= 4'b0000; src0= 10; src1=20;
		#10 src0= 65000; src1= 25000;
		#10 src0= -25; src1= 25;
		#10 src0= 50000; src1= -25000;
		#10 src0= 10; src0= 10;

		// Test subtract
		#10 func= 4'b0010; src0= 10; src1=20;
		#10 src0= 65000; src1= 25000;
		#10 src0= -25; src1= 25;
		#10 src0= 50000; src1= -25000;
		#10 src0= 10; src0= 10;

		// Test PADDSB
		#10 func= 4'b0001; src0= 10; src1=20;
		#10 src0= 65000; src1= 25000;
		#10 src0= -25; src1= 25;
		#10 src0= 50000; src1= -25000;
		#10 src0= 10; src0= 10;

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
