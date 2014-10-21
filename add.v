module fa16bit(input[15:0] A, B, input cin,
			output [15:0] S, output cout);

	fa4bit fa0(.A( A[3:0] ), 	.B( B[3:0] ), 	.cin( cin ), 		.S( S[3:0] ), 	.cout( ripple0 ) );
	fa4bit fa1(.A( A[7:4] ), 	.B( B[7:4] ), 	.cin( ripple0 ),	.S( S[7:4] ), 	.cout( ripple1 ) );
	fa4bit fa2(.A( A[11:8] ), 	.B( B[11:8] ),	.cin( ripple1 ),	.S( S[11:8] ), 	.cout( ripple2 ) );
	fa4bit fa3(.A( A[15:12] ), 	.B( B[15:12] ), .cin( ripple2 ),	.S( S[15:12] ), .cout( cout ) );

endmodule

module fa4bit(input[3:0] A, B, input cin,
			output [3:0] S, output cout);
	
	fa1bit fa0(.A( A[0] ), .B( B[0] ), .cin( cin ), .S( S[0] ), .cout( ripple0 ) );
	fa1bit fa1(.A( A[1] ), .B( B[1] ), .cin( ripple0 ), .S( S[1] ), .cout( ripple1 ) );
	fa1bit fa2(.A( A[2] ), .B( B[2] ), .cin( ripple1 ), .S( S[2] ), .cout( ripple2 ) );
	fa1bit fa3(.A( A[3] ), .B( B[3] ), .cin( ripple2 ), .S( S[3] ), .cout( cout ) );

endmodule


module fa1bit(input A, B, cin,
			output S, cout);
	wire w1, w2, w3;
	
	// Intermediate steps
	and (w1, A, B);
	and (w2, A, cin);
	and (w3, B, cin);

	// Compute cout
	or (cout, w1, w2, w3);

	// Compute sum
	xor (S, A, B, cin);

endmodule

module fa16bit_tb ();
	reg [15:0] A;
	reg [15:0] B;
	reg cin;
	reg COUT;
	reg [15:0] SUM;
	wire [15:0] S;
	wire cout;
	real i;

	initial begin
		$display("Simulation of Four Bit Full Adder");
	end

	fa16bit DUT(.A(A), .B(B), .cin(cin), .S(S), .cout(cout));

	initial begin
		A=0; B=0; cin=0;
	end
	
	always @ (A, B, cin)
		begin

		for(i=0; i < 1000; i = i + 1) begin
			#1 A = $random;
			B = $random;
			cin = $random;
			assign {COUT, SUM} = A + B + cin;
			#1
			//$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %b", $time, A, B, cin, cout, S);
			if (SUM !== S || COUT !== cout) begin
				$display("ERROR");
				$display("SUM = %d COUT = %b", SUM, COUT);
				//$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %d", $time, A, B, cin, cout, S);
				$monitor("%g ns: sum = %d cout = %b", $time, S, cout);
			end
		end
	#10 $stop;
	end

endmodule


module fa4bit_tb ();
	reg [3:0] A;
	reg [3:0] B;
	reg cin;
	wire [3:0] S;
	wire cout;
	integer i;

	initial begin
		$display("Simulation of Four Bit Full Adder");
	end

	fa4bit DUT(.A(A), .B(B), .cin(cin), .S(S), .cout(cout));

	initial begin
		A=0; B=0; cin=0;
	end
	
	always @ (A, B, cin)
		begin

		for(i=0; i < 16*16*2; i = i + 1) begin
			#1 {A, B, cin} = i;
			$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %b", $time, A, B, cin, cout, S);
			end
		#10 $stop;
		end

endmodule

module fa1bit_tb ();
	reg A, B, cin;
	wire S, cout;
	integer i;

	initial begin
		$display("Simulation of One Bit Full Adder");
	end

	fa1bit DUT(.A(A), .B(B), .cin(cin), .S(S), .cout(cout));

	initial begin
		A=0; B=0; cin=0;
	end
	
	always @ (A, B, cin)
		begin

		for(i=0; i < 8; i = i + 1) begin
			#10 {A, B, cin} = i;
			$monitor("%d ns: A + B + cin = %b + %b + %b = cout sum = %b %b", $time, A, B, cin, cout, S);
			end
		#10 $stop;
		end

endmodule
