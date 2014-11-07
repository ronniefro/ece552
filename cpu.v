`include "instr_mem.v"
`include "alu.v"
`include "LLBLHB.v"
`include "control_instrucs.v"


module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
   supply0 ZERO;
   supply1 ONE;
   wire[15:0]  INST, REG_S, REG_TD, IMM, ID_EX_BRIMM, ID_EX_LHLB, ID_EX_JAL, MEMADDR, MEM_RDDATA, instruction ; 

    
 
   reg[3:0] REG_WB_ADDR;
   /////// SIZE 16 regs ////////
   reg[15:0] IF_ID_INST, ID_EX_INST, EX_MEM_INST, MEM_WB_INST, //instruction regs
               IF_ID_A, IF_ID_B, ID_EX_A, ID_EX_B, EX_MEM_B, //alu operands
                 EX_MEM_ALUR, MEM_WB_ALUR, MEM_WB_DATA, //alu and mem data
                  IF_ID_IMM, ID_EX_IMM, EX_MEM_NEWPC,
		             IF_ID_PC, ID_EX_PC, EX_MEM_PC, MEM_WB_PC4, EX_MEM_PC4,
		              EX_MEM_LLBLHB, MEM_WB_LLBLHB,  IMMshift, PC, MEM_WRDATA, REG_WB;
   ////// control regs ////////
   reg ID_EX_REGDST, ID_EX_ALUOP0, ID_EX_ALUOP1, ID_EX_ALUSRC, ID_EX_BRANCH, ID_EX_MEMREAD, ID_EX_MEMWRITE, ID_EX_REGWRITE, ID_EX_MEMTOREG, //ex stage controls
         EX_MEM_BRANCH, EX_MEM_MEMREAD, EX_MEM_MEMWRITE, EX_MEM_REGWRITE, EX_MEM_MEMTOREG, EX_MEM_ALUOP1,
           MEM_WB_REGWRITE, MEM_WB_MEMTOREG,  EXECUTEBRANCH;
   
   ////// flag regs ///////
   reg ZFLAG, NFLAG, VFLAG;   
   wire MEM_READ_EN, MEM_WRITE_EN;         
   ////// SIZE 4 wires ////////
   wire[3:0] ID_EX_RS, ID_EX_RT, EX_MEM_RD, MEM_WB_RD, MEM_WB_RT; // intermediate reg addrs
   
   wire[3:0] ID_EX_OP, EX_MEM_OP, MEM_WB_OP; // opcode wires
   ///// size 16 ////////
   wire[15:0] A,B; // alu wire parameters
   
   ////////// ID/EX ///////////
   assign ID_EX_RS = ID_EX_INST[7:4];
   assign ID_EX_RT = (ID_EX_INST[15])?ID_EX_INST[11:8]:ID_EX_INST[3:0];
   assign ID_EX_OP = ID_EX_INST[15:12];
   assign ID_EX_BRIMM = ID_EX_INST[8:0];
   assign ID_EX_LHLB = ID_EX_INST[7:0];
   assign ID_EX_JAL = ID_EX_INST[11:0];

   ////////// EX/MEM ///////////
   assign EX_MEM_RD = EX_MEM_INST[11:8];
   assign EX_MEM_OP = EX_MEM_INST[15:12];
   
   
   ////////// MEM/WB ///////////
   assign MEM_WB_RT = MEM_WB_INST[3:0];
   assign MEM_WB_RD = MEM_WB_INST[11:8];
   assign MEM_WB_OP = MEM_WB_INST[15:12];
   assign MEM_READ_EN =	EX_MEM_MEMREAD; 
   assign MEM_WRITE_EN = EX_MEM_MEMWRITE;
  ////////// ALU INPUT /////////// 
   assign A = ID_EX_A;
   assign B = ID_EX_B;
   
   DM memory(.clk(clk),.addr(MEMADDR),.re(MEM_READ_EN),.we(MEM_WRITE_EN),.wrt_data(MEM_WRDATA),.rd_data(MEM_RDDATA));
   
   IM pcAddr(.clk(clk),.addr(PC),.rd_en(ONE),.instr(instruction));

   rf reggie (.clk(clk),.p0_addr(ID_EX_RS),.p1_addr(ID_EX_RT),.p0(REG_S),.p1(REG_TD),.re0(ONE),.re1(ONE),.dst_addr(REG_WB_ADDR),.dst(REG_WB),.we(MEM_WB_REGWRITE),.hlt(ZERO));

   LLBLHB llblhb(.c(ID_EX_OP[0]), .rd(REG_TD), .imm(ID_EX_LHLB), .out(EX_MEM_LLBLHB));	

   alu ALU(.A(A), .B(B),.shift_amt(ID_EX_RT), .opcode(ID_EX_OP), .clk(clk),
		      .S(OUT), .N(N), .Z(Z), .V(V));
   branch br(.condition(ID_EX_INST[11:9]),.label(ID_EX_INST[8:0]), .N(N), .V(V), .Z(Z), .pc(ID_EX_PC),
		.newPc(EX_MEM_NEWPC), .execBranch(EXECUTEBRANCH));

   always@(posedge clk) begin
       /////////////////////////////
       ////////IF operations /////// 
       /////////////////////////////

       IF_ID_INST <= instruction;
       PC <= (EXECUTEBRANCH) ? EX_MEM_NEWPC : PC+4;
       IF_ID_PC <= PC;
       //////// END IF /////////////
       
       //////////////////////////////////
       ///////// ID OPERATIONS /////////
       ////////////////////////////////
       IF_ID_A <= REG_S;
       IF_ID_B <= REG_TD;
       ID_EX_INST <= IF_ID_INST;
       ID_EX_PC <= IF_ID_PC;
       //set control options for sw,lw,llb,lhb
       if(ID_EX_OP[3:2] == 2'b10) begin
            ID_EX_REGDST <= 1'b1;
            ID_EX_ALUOP0 <= 1'b1;
            ID_EX_ALUOP1 <= 1'b1;
            ID_EX_ALUSRC <= 1'b1;
            ID_EX_BRANCH <= 1'b0;  
            ID_EX_MEMTOREG <= 1'b1;
            if(ID_EX_OP[1:0] == 2'b00)begin
              // lw
               ID_EX_MEMREAD <= 1'b1;
               ID_EX_MEMWRITE <= 1'b0;
               ID_EX_REGWRITE <= 1'b1;
            end
            else if(ID_EX_OP[1:0] == 2'b01)begin
            // sw
               ID_EX_MEMREAD <= 1'b0;
               ID_EX_MEMWRITE <= 1'b1;
               ID_EX_REGWRITE <= 1'b0;
            end
            else if(ID_EX_OP[1:0] == 2'b10 && ID_EX_OP[1:0] == 2'b11)begin
            // llb/lhb
               ID_EX_MEMREAD <= 1'b0;
               ID_EX_MEMWRITE <= 1'b0;
               ID_EX_REGWRITE <= 1'b1;
            end
       end
       else if(ID_EX_OP[3] == 1'b0) begin
           // r format
            ID_EX_REGDST <= 1'b1;
            ID_EX_ALUOP0 <= 1'b0;
            ID_EX_ALUOP1 <= 1'b1;
            ID_EX_ALUSRC <= 1'b0;
            ID_EX_BRANCH <= 1'b0;  
            ID_EX_MEMTOREG <= 1'b0;
            ID_EX_MEMREAD <= 1'b0;
            ID_EX_MEMWRITE <= 1'b0;
            ID_EX_REGWRITE <= 1'b1;
       end
       else if(ID_EX_OP[3:2] == 2'b11) begin
           // br,jal,jr,hlt
           ID_EX_REGDST <= 1'b0;
           ID_EX_ALUOP0 <= 1'b1;
            ID_EX_ALUOP1 <= 1'b0;
            ID_EX_BRANCH <= 1'b1;  
            ID_EX_MEMTOREG <= 1'b0;
            ID_EX_MEMREAD <= 1'b0;
            ID_EX_MEMWRITE <= 1'b0;
            if(ID_EX_OP[0] == 1'b0) begin
                // br, jr
               ID_EX_REGWRITE <= 1'b0;//
               ID_EX_ALUSRC <= 1'b0;//
            end
            else if(ID_EX_OP[0] == 1'b1) begin
                //jal
               ID_EX_REGWRITE <= 1'b1;//
               ID_EX_ALUSRC <= 1'b1;//
            end
       end
       /// end control options /////////
       ///// end ID ////////////////////
       
       /////////////////////////////////
       ///////// EX OPERATIONS /////////
       /////////////////////////////////
        //// pass controls ////
       EX_MEM_BRANCH <= ID_EX_BRANCH;
       EX_MEM_MEMREAD <= ID_EX_MEMREAD;
       EX_MEM_MEMWRITE <= ID_EX_MEMWRITE;
       EX_MEM_REGWRITE <= ID_EX_REGWRITE;
       EX_MEM_MEMTOREG <= ID_EX_MEMTOREG;
       EX_MEM_ALUOP1 <= ID_EX_ALUOP1;
       EX_MEM_PC4 <= ID_EX_PC;
      ///////////////////////////////////
      ///////// ALU OPERATIONS //////////
      ///////////////////////////////////
      if(ID_EX_ALUOP0 == 1'b0 && ID_EX_ALUOP1 == 1'b0) begin
          // sw and lw
          EX_MEM_ALUR <= ID_EX_A +  IMM[3:0];
          EX_MEM_B <= ID_EX_B; 
      end
      else begin
         // r type ops
         EX_MEM_ALUR = OUT;
         ZFLAG = Z;
         NFLAG = N;
         VFLAG = V;
      end
      if (ID_EX_OP == 4'b1100)begin
	   IMMshift <= ID_EX_BRIMM << 2;
	   EX_MEM_PC <= ID_EX_PC + {{5{IMMshift[10]}},IMMshift[10:0]};
      end
      else if (ID_EX_OP == 4'b1101)begin
      	assign IMMshift = ID_EX_JAL << 2;
	EX_MEM_PC <= ID_EX_PC + {{2{IMMshift[13]}},IMMshift[13:0]};
      end
      EX_MEM_B <= B;
      EX_MEM_INST <= ID_EX_INST;

    /////////////////////////////////
	//////// MEM OPERATIONS /////////
	/////////////////////////////////   
   
      /// memory stage control signals ///
      MEM_WB_REGWRITE <= EX_MEM_REGWRITE;
      MEM_WB_MEMTOREG <= EX_MEM_MEMTOREG;
      
      if(EX_MEM_ALUOP1 == 1'b1)begin
      	   assign MEM_WB_ALUR = EX_MEM_ALUR;
      end
      else if(EX_MEM_MEMREAD == 1'b1)begin
	       MEM_WB_DATA <= MEM_RDDATA;
      end
      else if(EX_MEM_MEMWRITE == 1'b1)begin
	       MEM_WRDATA <= EX_MEM_B;
      end
   
      MEM_WB_INST <= EX_MEM_INST;
      MEM_WB_PC4 <= EX_MEM_PC4;
   
   
 	/////////////////////////////////
	//////// WB OPERATIONS //////////
	/////////////////////////////////  
	
	if(MEM_WB_OP[3] == 1'b0 || MEM_WB_OP == 4'b1011 || MEM_WB_OP == 4'b1010 )begin
	// r format wb
      		REG_WB <= MEM_WB_ALUR;
		REG_WB_ADDR <= MEM_WB_RD;
        end
	else if(MEM_WB_OP == 4'b1000)begin
	// load word
		REG_WB <= MEM_WB_DATA ;
		REG_WB_ADDR <= MEM_WB_RT;

        end
	else if(MEM_WB_OP == 4'b1101)begin
	// jail
		REG_WB <= MEM_WB_PC4;
		REG_WB_ADDR <= 4'hf;

        end
	else if(MEM_WB_OP == 4'b1011 || MEM_WB_OP == 4'b1010)begin
	//llb/lhb
		REG_WB <= MEM_WB_ALUR;
		REG_WB_ADDR <= MEM_WB_RD;

        end
 	 	

        end //end always

endmodule
