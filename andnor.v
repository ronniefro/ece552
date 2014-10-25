module and16bit(input [15:0] A, B,
			output [15:0] out);
	and(out[0], A[0], B[0]);
	and(out[1], A[1], B[1]);
	and(out[2], A[2], B[2]);
	and(out[3], A[3], B[3]);
	and(out[4], A[4], B[4]);
	and(out[5], A[5], B[5]);
	and(out[6], A[6], B[6]);
	and(out[7], A[7], B[7]);
	and(out[8], A[8], B[8]);
	and(out[9], A[9], B[9]);
	and(out[10], A[10], B[10]);
	and(out[11], A[11], B[11]);
	and(out[12], A[12], B[12]);
	and(out[13], A[13], B[13]);
	and(out[14], A[14], B[14]);
	and(out[15], A[15], B[15]);
endmodule

module nor16bit(input [15:0] A, B,
		output [15:0] out);
	assign out = ~(A|B);
endmodule

module and16bit_tb ();
	reg [15:0] A;
	reg [15:0] B;
	reg [15:0] out;
	wire [15:0] OUT;
	real i;
	initial begin
		$display("Simulation of 16 Bit AND");
	end

	and16bit DUT(.A(A), .B(B), .out(OUT));

	initial begin
		A=0; B=0;
	end
	
	always @ (A, B)
		begin

		for(i=0; i < 1000; i = i + 1) begin
			#1 A = $random;
			B = $random;
			assign out = A&B;
			#1
			//$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %b", $time, A, B, cin, cout, S);
			if (OUT !== out) begin
				$display("ERROR");
				$display("A   = %b", A);
				$display("B   = %b", B);
				$display("out = %b", out); 
				$display("OUT = %b", OUT);
				//$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %d", $time, A, B, cin, cout, S);
			end
		end
	#10 $stop;
	end

endmodule

module nor16bit_tb ();
	reg [15:0] A;
	reg [15:0] B;
	reg [15:0] out;
	wire [15:0] OUT;
	real i;
	initial begin
		$display("Simulation of 16 Bit AND");
	end

	nor16bit DUT(.A(A), .B(B), .out(OUT));

	initial begin
		A=0; B=0;
	end
	
	always @ (A, B)
		begin

		for(i=0; i < 1000; i = i + 1) begin
			#1 A = $random;
			B = $random;
			assign out = ~(A|B);
			#1
			//$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %b", $time, A, B, cin, cout, S);
			if (OUT !== out) begin
				$display("ERROR");
				$display("A   = %b", A);
				$display("B   = %b", B);
				$display("out = %b", out); 
				$display("OUT = %b", OUT);
				//$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %d", $time, A, B, cin, cout, S);
			end
		end
	#10 $stop;
	end

endmodule