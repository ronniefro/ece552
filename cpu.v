`include "instr_mem.v"
`include "alu.v"
`include "LLBLHB.v"
`include "control_instrucs.v"
`include "rf_pipelined.v"

module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
   supply0 ZERO; 
   supply1 ONE;
  
  
   wire[15:0]  INST, REG_S, REG_TD, IMM, ID_EX_BRIMM,  ID_EX_JAL, MEM_RDDATA, instruction, OUT; 
   wire[7:0] ID_EX_LHLB;

   reg[3:0] REG_WB_ADDR, IF_ID_RS, IF_ID_RT,IF_ID_OP ;
   /////// SIZE 16 regs ////////
   reg[15:0] IF_ID_INST, ID_EX_INST, EX_MEM_INST, MEM_WB_INST, //instruction regs
               IF_ID_A, IF_ID_B, ID_EX_A, ID_EX_B, EX_MEM_B, //alu operands
                 EX_MEM_ALUR, MEM_WB_ALUR, MEM_WB_DATA, //alu and mem data
                  IF_ID_IMM, ID_EX_IMM, 
		             IF_ID_PC, ID_EX_PC, EX_MEM_PC, MEM_WB_PC4, EX_MEM_PC4, MEMADDR,
		               EX_MEM_LLBLHB, MEM_WB_LLBLHB,  IMMshift, PC, MEM_WRDATA, REG_WB;
   wire[15:0] EX_MEM_NEWPC, ID_EX_LLBLHB;
   ////// control regs ////////
   reg ID_EX_REGDST, ID_EX_ALUOP0, ID_EX_ALUOP1, ID_EX_ALUSRC, ID_EX_BRANCH, ID_EX_MEMREAD, ID_EX_MEMWRITE, ID_EX_REGWRITE, ID_EX_MEMTOREG, //ex stage controls
         EX_MEM_BRANCH, EX_MEM_MEMREAD, EX_MEM_MEMWRITE, EX_MEM_REGWRITE, EX_MEM_MEMTOREG, EX_MEM_ALUOP1,
           MEM_WB_REGWRITE, MEM_WB_MEMTOREG, MEM_WB_ALUOP1, MEM_WB_ALUOP0,
            IF_ID_HLT, ID_EX_HLT, EX_MEM_HLT, MEM_WB_HLT , POST_HLT;
   
   ////// flag regs ///////
   reg ZFLAG, NFLAG, VFLAG;   
   wire MEM_READ_EN, MEM_WRITE_EN, stall;   
   wire EXECUTEBRANCH;    
   reg EXECUTEJUMP = 1'b0; 


   ////// SIZE 4 wires ////////
   wire[3:0] EX_MEM_RD, MEM_WB_RD, MEM_WB_RT, ID_EX_RS, ID_EX_RT; // intermediate reg addrs
   //reg[3:0] ID_EX_RS, ID_EX_RT;
   wire[3:0] ID_EX_OP, EX_MEM_OP, MEM_WB_OP; // opcode wires
   ///// size 16 ////////
   wire[15:0] A,B; // alu wire parameters
   
   ////////// IF/ID ///////////


   ////////// ID/EX ///////////
   assign ID_EX_RS = ID_EX_INST[7:4];
   assign ID_EX_RT = (ID_EX_INST[15]) ? ID_EX_INST[11:8]:ID_EX_INST[3:0];
   assign ID_EX_RD = ID_EX_INST[11:8];
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
  

     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// DATA FORWARDING ////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
	
	// Forwarding A from MEM to EX
   assign ForwardAfromMEM = (ID_EX_RS == EX_MEM_RD) & (ID_EX_RS!=0) & (EX_MEM_OP[3] == 1'b0 || EX_MEM_OP == 4'h8 ||EX_MEM_OP == 4'h9);  	
   // Forwarding B from MEM to EX
   assign ForwardBfromMEM = (ID_EX_RT == EX_MEM_RD)&(ID_EX_RD!=0) & (EX_MEM_OP[3] == 1'b0 || EX_MEM_OP == 4'h8 ||EX_MEM_OP == 4'h9); 
 	// Forwarding A from WB to EX
   assign ForwardAfromALUinWB =( ID_EX_RS == MEM_WB_RD) & (ID_EX_RS != 0) & (MEM_WB_OP[3] == 1'b0 || EX_MEM_OP == 4'h8 ||EX_MEM_OP == 4'h9); 
 	// Forwarding B from WB to EX
   assign ForwardBfromALUinWB = (ID_EX_RT == MEM_WB_RD) & (ID_EX_RT != 0) & (MEM_WB_OP[3] == 1'b0 || EX_MEM_OP == 4'h8 ||EX_MEM_OP == 4'h9); 
 	// Forwarding A from WB to MEM
   assign ForwardAfromLWinWB =( ID_EX_RS == MEM_WB_INST[7:4]) & (ID_EX_RS != 0) & (MEM_WB_OP == 4'h8); 
 	// Forwarding B from WB to MEM
   assign ForwardBfromLWinWB = (ID_EX_RT == MEM_WB_INST[7:4]) & (ID_EX_RT != 0) & (MEM_WB_OP == 4'h8); 
 	// Forwarding A from MEM to EX or from WB to EX or from ID_EX
   assign Ain = ForwardAfromMEM? EX_MEM_ALUR :
   	(ForwardAfromALUinWB | ForwardAfromLWinWB)? MEM_WB_DATA : ID_EX_A;
 	// Forwarding  from MEM to EX or from WB to EX or from ID_EX
   assign Bin = ForwardBfromMEM? EX_MEM_ALUR :
   	(ForwardBfromALUinWB | ForwardBfromLWinWB)? MEM_WB_DATA : ID_EX_B;

     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// HAZARD STALL ///////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 

    assign stall = (MEM_WB_INST[15:12] == 4'h8) && // source instruction is a load
       ((((ID_EX_OP == 4'h8)|(ID_EX_OP == 4'h9)) && (ID_EX_RS == MEM_WB_RD)) | // stall for address calc
       ((ID_EX_OP[3] == 1'h1 ) && ((ID_EX_RS == MEM_WB_RD)|(ID_EX_RT == MEM_WB_RD)))); // ALU use
  ////////// ALU INPUT /////////// 
   assign A = ID_EX_A;
   assign B = ID_EX_B;
    
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// INITALIZATIONS /////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 

   DM memory(.clk(clk),.addr(MEMADDR),.re(MEM_READ_EN),.we(MEM_WRITE_EN),.wrt_data(B),.rd_data(MEM_RDDATA));
   
   IM pcAddr(.clk(clk),.addr(PC),.rd_en(ONE),.instr(instruction));

   rf reggie (.clk(clk),.p0_addr(IF_ID_RS),.p1_addr(IF_ID_RT),.p0(REG_S),.p1(REG_TD),.re0(ONE),.re1(ONE),.dst_addr(REG_WB_ADDR),
               .dst(REG_WB),.we(MEM_WB_REGWRITE),.hlt(POST_HLT));

   LLBorLHB llblhb(.c(ID_EX_OP[0]), .rd(B), .imm(ID_EX_LHLB), .out(ID_EX_LLBLHB));	

   alu ALU(.A(A), .B(B),.shift_amt(ID_EX_RT), .opcode(ID_EX_OP), .clk(clk),
		      .S(OUT), .N(N), .Z(Z), .V(V));
   branch br(.condition(EX_MEM_INST[11:9]),.label(EX_MEM_INST[8:0]), .N(N), .V(V), .Z(Z), .pc(ID_EX_PC),
		.newPc(EX_MEM_NEWPC), .execBranch(EXECUTEBRANCH));


   ////////// ALWAYS BLOCK //////////
    
   always@(posedge clk or negedge rst_n) begin
       if(!rst_n)begin
           PC <= 16'h0000;
       end
       else begin
       
       //if (~stall) begin 
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// IF OPERATIONS //////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
       IF_ID_OP <= instruction[15:12];
       IF_ID_HLT <= (instruction[15:12] == 4'b1111) ? 1'b1: 1'b0; 
       IF_ID_INST <= instruction;
       //PC <= (EXECUTEBRANCH | EXECUTEJUMP) ? EX_MEM_NEWPC : PC+1;
       PC <= PC + 1;
       IF_ID_PC <= PC;
       IF_ID_RS <= instruction[7:4];
       IF_ID_RT <= (instruction[15]) ? instruction[11:8] : instruction[3:0];
       //ID_EX_RS <= instruction[7:4];
       //ID_EX_RT <= (instruction[15]) ? instruction[11:8]:instruction[3:0];
              
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 //////////////////////////////////////// FLUSH ON BR,JR,JAL ////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
      /* if((EXECUTEBRANCH | EXECUTEJUMP) == 1'b1)begin
           IF_ID_INST <= 16'h0000;
           IF_ID_A <= 16'h0000;
           IF_ID_B <= 16'h0000;
           IF_ID_PC <= 16'h0000;
           ID_EX_HLT <= 1'h0; 
           ID_EX_A <= 16'h0000;
           ID_EX_B <= 16'h0000;
           ID_EX_INST <= 16'h0000;
           ID_EX_PC <= 16'h0000;
           EX_MEM_HLT <= 1'h0; 
           EX_MEM_BRANCH <= 1'h0;
           EX_MEM_MEMREAD <= 1'h0;
           EX_MEM_MEMWRITE <= 1'h0;
           EX_MEM_REGWRITE <= 1'h0;
           EX_MEM_MEMTOREG <= 1'h0;
           EX_MEM_ALUOP1 <= 1'h0;
           EX_MEM_PC4 <= 16'h0000;
           EX_MEM_B <= 16'h0000;
           EX_MEM_INST <= 16'h0000;
       end
       //////// END IF /////////////
       */
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// ID OPERATIONS //////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
       ID_EX_HLT <= IF_ID_HLT; 
       ID_EX_A <= REG_S;
       ID_EX_B <= REG_TD;
       ID_EX_INST <= IF_ID_INST;
       ID_EX_PC <= IF_ID_PC;
       
       if(ID_EX_INST[15:14] == 2'b10) begin
           //set control options for sw,lw,llb,lhb
            ID_EX_REGDST <= 1'b1;
            ID_EX_ALUOP0 <= 1'b0;
            ID_EX_ALUOP1 <= 1'b0;
            ID_EX_ALUSRC <= 1'b1;
            ID_EX_BRANCH <= 1'b0;  
            ID_EX_MEMTOREG <= 1'b1;
            if(ID_EX_INST[13:12] == 2'b00)begin
              // lw
               ID_EX_MEMREAD <= 1'b1;
               ID_EX_MEMWRITE <= 1'b0;
               ID_EX_REGWRITE <= 1'b1;
            end
            else if(ID_EX_INST[13:12] == 2'b01)begin
            // sw
               ID_EX_MEMREAD <= 1'b0;
               ID_EX_MEMWRITE <= 1'b1;
               ID_EX_REGWRITE <= 1'b0;
            end
            else if(ID_EX_INST[13:12] == 2'b10 || ID_EX_INST[13:12] == 2'b11)begin
            // llb/lhb
               ID_EX_MEMREAD <= 1'b0;
               ID_EX_MEMWRITE <= 1'b0;
               ID_EX_REGWRITE <= 1'b1;
            end
       end
       else if(ID_EX_INST[15] == 1'b0) begin
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
       else if(ID_EX_INST[15:14] == 2'b11) begin
           // br,jal,jr,hlt
           ID_EX_REGDST <= 1'b0;
           ID_EX_ALUOP0 <= 1'b1;
            ID_EX_ALUOP1 <= 1'b0;
            ID_EX_BRANCH <= 1'b1;  
            ID_EX_MEMTOREG <= 1'b0;
            ID_EX_MEMREAD <= 1'b0;
            ID_EX_MEMWRITE <= 1'b0;
            if(ID_EX_INST[12] == 1'b0) begin
                // br, jr
               ID_EX_REGWRITE <= 1'b0;//
               ID_EX_ALUSRC <= 1'b0;//
            end
            else if(ID_EX_INST[12] == 1'b1) begin
                //jal
               ID_EX_REGWRITE <= 1'b1;//
               ID_EX_ALUSRC <= 1'b1;//
            end
       end
       /// end control options /////////
       ///// end ID ////////////////////
       
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// EX OPERATIONS //////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
        
        //// pass controls ////
        
       EX_MEM_HLT <= ID_EX_HLT; 
       EX_MEM_BRANCH <= ID_EX_BRANCH;
       EX_MEM_MEMREAD <= ID_EX_MEMREAD;
       EX_MEM_MEMWRITE <= ID_EX_MEMWRITE;
       EX_MEM_REGWRITE <= ID_EX_REGWRITE;
       EX_MEM_MEMTOREG <= ID_EX_MEMTOREG;
       EX_MEM_ALUOP1 <= ID_EX_ALUOP1;
       EX_MEM_PC4 <= ID_EX_PC;
       EX_MEM_B <= B;
       EX_MEM_INST <= ID_EX_INST;
       EX_MEM_LLBLHB <= ID_EX_LLBLHB;
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// ALU OPERATIONS /////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
      if(ID_EX_ALUOP0 == 1'b0 || ID_EX_ALUOP1 == 1'b0) begin
          // sw and lw
          EX_MEM_ALUR <= ID_EX_A +  ID_EX_INST[3:0];
          
      end
      else begin
         // r type ops
         EX_MEM_ALUR <= OUT;
         ZFLAG <= Z;
         NFLAG <= N;
         VFLAG <= V;
      end
      if (ID_EX_OP == 4'b1100)begin
	   IMMshift <= ID_EX_BRIMM << 2;
	   EX_MEM_PC <= ID_EX_PC + {{5{IMMshift[10]}},IMMshift[10:0]};
      end
      else if (ID_EX_OP == 4'b1101)begin
      	assign IMMshift = ID_EX_JAL << 2;
	    EX_MEM_PC <= ID_EX_PC + {{2{IMMshift[13]}},IMMshift[13:0]};
      end
      

     ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 /////////////////////////////////////////// MEM OPERATIONS /////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////  
   
      /// memory stage control signals ///
      MEMADDR <= EX_MEM_ALUR;
      MEM_WB_HLT <= EX_MEM_HLT;
      MEM_WB_REGWRITE <= EX_MEM_REGWRITE;
      MEM_WB_MEMTOREG <= EX_MEM_MEMTOREG;
      MEM_WB_INST <= EX_MEM_INST;
      MEM_WB_PC4 <= EX_MEM_PC4;
      MEM_WB_LLBLHB <= EX_MEM_LLBLHB;
      MEM_WB_ALUOP1 <= EX_MEM_ALUOP1;

      
      if(EX_MEM_MEMREAD == 1'b1)begin
          //pass memory data to be written to reg on lw
	       MEM_WB_DATA <= MEM_RDDATA;
      end
      else if(EX_MEM_MEMWRITE == 1'b1)begin

          //write to mem on sw
	       MEM_WRDATA <= EX_MEM_B;
      end
   
     
      if(EX_MEM_INST[15:12] == 4'b1101 || EX_MEM_INST[15:12] == 4'b1110)begin
          //check if it is jr or jal and set jump condition
          EXECUTEJUMP <= 1'b1;
      end
   
 	  ////////////////////////////////////////////////////////////////////////////////////////////////////////
	 ///////////////////////////////////////////  WB OPERATIONS /////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////// 
	POST_HLT <= MEM_WB_HLT;
	if(MEM_WB_OP[3] == 1'b0)begin
	// r format wb
      		REG_WB <= EX_MEM_ALUR;
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
	else if(MEM_WB_OP === 4'hB || MEM_WB_OP === 4'hA)begin
	//llb/lhb
		REG_WB <= MEM_WB_LLBLHB;
		REG_WB_ADDR <= MEM_WB_RD;

        end
 	 	//end//end stall
 	 	//else begin 
 	 	//    EX_MEM_INST <= 16'h0000; //send "nop" which is actually just adding zero reg to itself
          
          /////////////// NEW MEM ///////////////////
    //      MEM_WB_INST <= EX_MEM_INST; //pass Instruction
          
     //     if (EX_MEM_OP[3] == 1'b0) MEM_WB_DATA <= EX_MEM_ALUR; // ALU result
    //      else if (EX_MEM_OP == 4'h8) MEM_WB_DATA <= MEM_RDDATA; 
     //     else if (EX_MEM_OP == 4'h9)MEM_WRDATA <= EX_MEM_B; //store 
          // the WB stage
     //     if ((MEM_WB_OP[3] == 1'h1) & (MEM_WB_RD != 0)) REG_WB <= MEM_WB_DATA; // ALU operation
     //     else if ((EX_MEM_OP == 4'h8)& (MEM_WB_RT != 0)) REG_WB <= MEM_WB_DATA;
 	 //	end// end stall else
 	 	
    end// end rst_n

end //end always

endmodule
