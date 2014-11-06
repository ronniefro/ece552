`include "instr_mem.v"
`include "alu.v"
`include "lwsw.v"
`include "LLBLHB.v"
`inlcude "control_instrucs.v"


module cpu(input clk, rst_n, 
		output hlt, output [15:0] pc);
	
	supply0 ZERO;
	supply1 ONE;
   wire[15:0] PC, INST, REG_A, REG_B, IMM; 
   IM pcAddr(clk, pcAddress, rd_en, instruction);
   rf READ (.clk(clk),.p0_addr(RS),.p1_addr(RT),.p0(REG_A),.p1(REG_B),.re0(ONE),.re1(ONE),.dst_addr(ZERO),.dst(ZERO),.we(ZERO),.hlt(ZERO));
   alu ALU(.A(A), .B(B),.shift_amt(ID_EX_RT), .opcode(ID_EX_OP), .clk(clk),
		      .S(OUT), .N(N), .Z(Z), .V(V));
   /////// SIZE 16 regs ////////
   reg[15:0] IF_ID_INST, ID_EX_INST, EX_MEM_INST, MEM_WB_INST, //instruction regs
               ID_EX_A, ID_EX_B, EX_MEM_B, //alu operands
                 EX_MEM_ALUR, MEM_WB_ALUR, MEM_WB_DATA, //alu and mem data
                 
   ////// control regs ////////
   reg ID_EX_REGDST, ID_EX_ALUOP0, ID_EX_ALUOP1, ID_EX_ALUSRC, ID_EX_BRANCH, ID_EX_MEMREAD, ID_EX_MEMWRITE, ID_EX_REGWRITE, ID_EX_MEMTOREG, //ex stage controls
         EX_MEM_BRANCH, EX_MEM_MEMREAD, EX_MEM_MEMWRITE, EX_MEM_REGWRITE, EX_MEM_MEMTOREG,
           MEM_WB_REGWRITE, MEM_WB_MEMTOREG;
   
   ////// flag regs ///////
   reg ZFLAG, NFLAG, VFLAG;   
            
   ////// SIZE 4 wires ////////
   wire[3:0] ID_EX_RS, ID_EX_RT, EX_MEM_RD, MEM_WB_RD, MEM_WB_RT; // intermediate reg addrs
   
   wire[3:0] ID_EX_OP, EX_MEM_OP, MEM_WB_OP; // opcode wires
   ///// size 16 ////////
   wire[15:0] A,B; // alu wire parameters
   
   ////////// ID/EX ///////////
   assign ID_EX_RS = ID_EX_INST[7:4];
   assign ID_EX_RT = ID_EX_INST[3:0];
   assign ID_EX_OP = ID_EX_INST[15:12];
   
   ////////// EX/MEM ///////////
   assign EX_MEM_RD = EX_MEM_INST[11:8];
   assign EX_MEM_OP = EX_MEM_INST[15:12];
   assign EX_MEM_B = ID_EX_B;
   
   ////////// MEM/WB ///////////
   assign MEM_WB_RT = MEM_WB_INST[3:0];
   assign MEM_WB_RD = MEM_WB_INST[11:8];
   assign MEM_WB_OP = MEM_WB_INST[15:12];
   
  ////////// ALU INPUT /////////// 
   assign A = ID_EX_A;
   assign B = ID_EX_B;
   
   

   always@(posedge clk) begin
       ////////IF operations /////// 
       IF_ID_INST <= instruction;
       PC <= PC + 4;
       //////// END IF /////////////
       
       
       ///////// ID OPERATIONS /////////
       
       IF_ID_A <= REG_A;
       IF_ID_B <= REG_B;
       ID_EX_INST <= IF_ID_INST;
       
       //set control options for sw,lw,llb,lhb
       if(ID_EX_OP[3:2] = 2'b10) begin
            ID_EX_REGDST <= 1'b1;
            ID_EX_ALUOP0 <= 1'b1;
            ID_EX_ALUOP1 <= 1'b1;
            ID_EX_ALUSRC <= 1'b1;
            ID_EX_BRANCH <= 1'b0;  
            ID_EX_MEMTOREG <= 1'b1;
            if(ID_EX_OP[1:0] = 2b'00)begin
              // lw
               ID_EX_MEMREAD <= 1'b1;
               ID_EX_MEMWRITE <= 1'b0;
               ID_EX_REGWRITE <= 1'b1;
            end
            else if(ID_EX_OP[1:0] = 2b'01)begin
            // sw
               ID_EX_MEMREAD <= 1'b0;
               ID_EX_MEMWRITE <= 1'b1;
               ID_EX_REGWRITE <= 1'b0;
            end
            else if(ID_EX_OP[1:0] = 2b'10 && ID_EX_OP[1:0] = 2b'11)begin
            // llb/lhb
               ID_EX_MEMREAD <= 1'b0;
               ID_EX_MEMWRITE <= 1'b0;
               ID_EX_REGWRITE <= 1'b1;
            end
       end
       else if(ID_EX_OP[3] = 1'b0) begin
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
       else if(ID_EX_OP[3:2] = 2'b11) begin
           // br,jal,jr,hlt
           ID_EX_REGDST <= 1'b0;
           ID_EX_ALUOP0 <= 1'b1;
            ID_EX_ALUOP1 <= 1'b0;
            ID_EX_BRANCH <= 1'b1;  
            ID_EX_MEMTOREG <= 1'b0;
            ID_EX_MEMREAD <= 1'b0;
            ID_EX_MEMWRITE <= 1'b0;
            if(ID_EX_OP[0] = 1'b0) begin
                // br, jr
               ID_EX_REGWRITE <= 1'b0;//
               ID_EX_ALUSRC <= 1'b0;//
            end
            else if(ID_EX_OP[0] = 1'b1) begin
                //jal
               ID_EX_REGWRITE <= 1'b1;//
               ID_EX_ALUSRC <= 1'b1;//
            end
       end
       /// end control options /////////
       ///// end ID ////////////////////
       
       
       ///////// EX OPERATIONS /////////
        //// pass controls ////
       EX_MEM_BRANCH <= ID_EX_BRANCH;
       EX_MEM_MEMREAD <= ID_EX_MEMREAD;
       EX_MEM_MEMWRITE <= ID_EX_MEMWRITE;
       EX_MEM_REGWRITE <= ID_EX_REGWRITE;
       EX_MEM_MEMTOREG <= ID_EX_MEMTOREG;
      
      ///// alu operations /////
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
  //////// MEM OPERATIONS /////////
      
      MEM_WB_REGWRITE <= EX_MEM_REGWRITE;
      MEM_WB_MEMTOREG <= EX_MEM_MEMTOREG;
   
   
   
   
   
   
   end
   





	reg [15:0] pcAddress;
	reg [15:0] instruction;
	reg [15:0] instruc;
	wire rd_en = 1'b1;
   //RS RT RD 4 bit
	//OPCODE 4 bit
	//IMMEDIATE 16bit
	wire[15:0] OUT;
	wire Z, N, V;
	//rs = A, rt = B
	wire[15:0] A,B;
   
   
   LLB LLB(.clk(clk), input[3:0] rd, input[7:0] imm, input hlt);	
   
   LHB LHB(.clk(clk), input[3:0] rd, input[7:0] imm, input hlt); 
   
   sw LW(.clk(clk), input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
   
   lw LW(.clk(clk), input[3:0] rt, input[3:0] rs, input[3:0] offset, input hlt);
   
   branch BRANCH(input [2:0] condition, input signed [8:0] label, input N, V, Z, input [15:0] pc,
	   output reg [15:0] newPc, output reg execBranch);
	
	jumpandlink JUMPANDLINK(input signed [8:0] target, input [15:0] pc, input clk, input hlt,
	   output [15:0] newPc);
	
	jumpregister JUMPREGISTER(.clk(clk), input[15:0] rs, input hlt, output newPC );
	
	halt HALT(.clk(clk));
	
	

	wire [3:0] OPCODE;
	wire [3:0] RS, RT, RD;
	wire [15:0] IMMEDIATE;

	
	
	rf WRITE(.clk(clk),.p0_addr(ZERO),.p1_addr(ONE),.p0(ZERO),.p1(ZERO),.re0(ZERO),.re1(ZERO),.dst_addr(RD),.dst(OUT),.we(ONE),.hlt(ZERO));

	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			pcAddress = 16'h0000;
		end
		else begin		
			assign instruc = instruction; 
			pcAddress = pcAddress + 4;
			assign OPCODE = [15:12]instruc;

			// ALU operation
			if (OPCODE[3] == 1'b0)	begin
				assign RD = [11:8]instruc;
				assign RS = [7:4]instruc;
				assign RT = [3:0]instruc;


			end
		end
	end
endmodule
