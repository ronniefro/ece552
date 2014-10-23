module sll(input[15:0] A, input[3:0] shift_amount,
			output[15:0] out);

	assign out = A << shift_amount;
	
endmodule
module sll_tb ();
	reg [15:0] A;
	wire [15:0] out;
	reg [3:0] shift_amount;
	reg[15:0] OUT;
	real i;

	initial begin
		$display("Simulation of sll");
	end

	sll DUT(.A(A), .shift_amount(shift_amount), .out(out));

	initial begin
		A=16'hbeef; shift_amount = 4'h0;
	end
	
	always @ (A, shift_amount)
	begin

		for(i=0; i < 16; i = i + 1) begin
			#1
			shift_amount = i;
			assign OUT = A << shift_amount;
			#1
			$display("out = %b", OUT);
			if (out !== OUT) begin
				$display("ERROR");
				$display("out = %b", out);
				$monitor("%g ns: out = %d", $time, out);
			end
		end
	#10 $stop;
	end

endmodule

/*module mux(input A, input B, input SEL, 
			output Z;
	wire w1,w2;

	and(w1, SEL, B);
	and(w2, not(SEL), A);
	or(Z, w1, w2);

endmodule
*/