module LLB(input clk, input[3:0] rd, input[7:0] imm, input hlt);
//rd gets lower 8 bits changed to input

   supply0 ZERO;
   supply1 ONE;
   reg[15:0] reggie;
   wire[15:0] willy;
  
   
   rf RT(.clk(clk),.p0_addr(rd),.p1_addr(ZERO),.p0(reggie),.p1(ZERO),.re0(ONE),.re1(ZERO),.dst_addr(rd),.dst(willy),.we(ONE),.hlt(hlt));
   assign willy = reggie & 16'hff00;
   assign willy = willy + imm;
   
endmodule


module LHB(input clk, input[3:0] rd, input[7:0] imm, input hlt);
//rd gets upper 8 bits changed to input


   supply0 ZERO;
   supply1 ONE;
   reg[15:0] reggie;
   wire[15:0] willy;
   
   
   rf RT(.clk(clk),.p0_addr(rd),.p1_addr(ZERO),.p0(reggie),.p1(ZERO),.re0(ONE),.re1(ZERO),.dst_addr(rd),.dst(willy),.we(ONE),.hlt(hlt));
   assign willy = reggie & 16'h00ff;
   assign willy[15:8] = imm;

endmodule

