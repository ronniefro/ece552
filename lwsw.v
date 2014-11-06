module sw(input clk, input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
//store rt into mem[rs + offset]
  
   supply0 ZERO;
   supply1 ONE;

   wire memlocation;
   reg[15:0] r1,r2;
   
   
   rf RT(.clk(clk),.p0_addr(rt),.p1_addr(rs),.p0(r1),.p1(r2),.re0(ONE),.re1(ONE),.dst_addr(ZERO),.dst(ZERO),.we(ZERO),.hlt(hlt));
   
   
   assign memlocation = r2 + offset;
   DM memory(.clk(clk),.addr(memlocation),.re(ZERO),.we(ONE),.wrt_data(r1), .rd_data(ZERO));

endmodule

module lw(input clk, input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
//load rt with rs + offset

   supply0 ZERO;
   supply1 ONE;

   
   reg[15:0] r1,r2;
   wire memlocation;
   
   rf Register(.clk(clk),.p0_addr(rs),.p1_addr(ZERO),.p0(r2),.p1(ZERO),.re0(ONE),.re1(ZERO),.dst_addr(rt),.dst(r1),.we(ONE),.hlt(hlt));
   
   assign memlocation = r2 + offset;
   
   DM memory(.clk(clk),.addr(memlocation),.re(ONE),.we(ZERO),.wrt_data(ZERO), .rd_data(r1));

endmodule
