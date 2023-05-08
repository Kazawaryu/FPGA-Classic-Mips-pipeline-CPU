`timescale 1ns / 1ps

module control32(Opcode, Function_opcode, Jr, RegDST, ALUSrc, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp,
                Alu_resultHigh,MemorIOtoReg,MemRead,IORead, IOWrite);
    input[5:0]   Opcode;            // 来自IFetch模块的指令高6bit, instruction[31..26]
    input[5:0]   Function_opcode;  	// 来自IFetch模块的指令低6bit, 用于区分r-类型中的指令, instructions[5..0]
    output       Jr;         	 // 为1表明当前指令是jr, 为0表示当前指令不是jr
    output       RegDST;          // 为1表明目的寄存器是rd, 否则目的寄存器是rt
    output       ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）是立即数（beq, bne除外）, 为0时表示第二个操作数来自寄存器
    // output       MemtoReg;     // 为1表明需要从存储器或I/O读数据到寄存器
    output       RegWrite;   	  // 为1表明该指令需要写寄存器
    output       MemWrite;       // 为1表明该指令需要写存储器
    output       Branch;        // 为1表明是beq指令, 为0时表示不是beq指令
    output       nBranch;       // 为1表明是Bne指令, 为0时表示不是bne指令
    output       Jmp;            // 为1表明是J指令, 为0时表示不是J指令
    output       Jal;            // 为1表明是Jal指令, 为0时表示不是Jal指令
    output       I_format;      // 为1表明该指令是除beq, bne, LW, SW之外的其他I-类型指令
    output       Sftmd;         // 为1表明是移位指令, 为0表明不是移位指令
    output[1:0]  ALUOp;        // 是R-类型或I_format=1时位1（高bit位）为1,  beq、bne指令则位0（低bit位）为1

    input[21:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the reg
    output MemRead; // 1 indicates that the instruction needs to read from the memor
    output IORead; // 1 indicates I/O read
    output IOWrite; // 1 indicates I/O write

wire R_format;
assign R_format = (Opcode == 6'b000000)? 1'b1 : 1'b0;

assign Jmp = (Opcode == 6'b000010)? 1'b1 : 1'b0;
assign Jr = ((Opcode == 6'b000000)&&(Function_opcode == 6'b001000))? 1'b1 : 1'b0;
assign Jal = (Opcode == 6'b000011)? 1'b1 : 1'b0;
assign Branch = (Opcode == 6'b000100)? 1'b1 : 1'b0;
assign nBranch = (Opcode == 6'b000101)? 1'b1 : 1'b0;
assign RegDST = R_format;
// assign MemtoReg =  (Opcode == 6'b100011)? 1'b1 : 1'b0;  //lw
assign I_format = (Opcode[5:3]==3'b001)? 1'b1 : 1'b0;
assign ALUSrc = I_format||Opcode == 6'b100011||Opcode == 6'b101011; //给到ALU判断第二个操作数来自于哪
assign Sftmd =  (((Function_opcode==6'b000000)||(Function_opcode==6'b000010)
||(Function_opcode==6'b000011)||(Function_opcode==6'b000100)
||(Function_opcode==6'b000110)||(Function_opcode==6'b000111))
&& R_format)? 1'b1:1'b0;
assign ALUOp = {(R_format||I_format),(Branch||nBranch)};


//这一块儿待测试！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
assign RegWrite = (R_format||MemorIOtoReg||Jal||I_format)&&!(Jr); 
// Opcode == 6'b101011 sw==1 不表示一定存到memory里，只表示从寄存器取出数据
assign MemWrite = (Opcode == 6'b101011 && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ? 1'b1:1'b0;       //sw+存到memory里 
assign MemRead = (Opcode == 6'b100011 && Alu_resultHigh[21:0] != 22'h3FFFFF) ? 1'b1:1'b0;          //lw+从memory里 
assign IORead = (Opcode == 6'b100011 && Alu_resultHigh[21:0] == 22'h3FFFFF) ? 1'b1:1'b0;           //lw+从io 

assign IOWrite =(Opcode == 6'b101011 && Alu_resultHigh[21:0] == 22'h3FFFFF) ? 1'b1:1'b0;           //sw+输出到LED灯
// Read operations require reading data from memory or I/O to write to the register
//lw : memory or io
assign MemorIOtoReg = IORead || MemRead;  //实际上没变 都是lw                     

endmodule