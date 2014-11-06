module sw(input clk, input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
//store rt into mem[rs + offset]
  
   supply0 ZERO;
   supply1 ONE;

   wire[15:0] memlocation;
   reg[15:0] randy,rakim;
   
   
   rf RT(.clk(clk),.p0_addr(rt),.p1_addr(rs),.p0(randy),.p1(rakim),.re0(ONE),.re1(ONE),.dst_addr(ZERO),.dst(ZERO),.we(ZERO),.hlt(hlt));
   
   
   assign memlocation = rakim + offset;
   DM memory(.clk(clk),.addr(memlocation),.re(ZERO),.we(ONE),.wrt_data(randy), .rd_data(ZERO));

endmodule

module lw(input clk, input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
//load rt with rs + offset

   supply0 ZERO;
   supply1 ONE;

   
   reg[15:0] randy,rakim;
   wire[15:0] memlocation;
   
   rf Register(.clk(clk),.p0_addr(rs),.p1_addr(ZERO),.p0(rakim),.p1(ZERO),.re0(ONE),.re1(ZERO),.dst_addr(rt),.dst(randy),.we(ONE),.hlt(hlt));
   
   assign memlocation = rakim + offset;
   
   DM memory(.clk(clk),.addr(memlocation),.re(ONE),.we(ZERO),.wrt_data(ZERO), .rd_data(randy));

endmodule
