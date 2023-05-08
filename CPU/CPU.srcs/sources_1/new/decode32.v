`timescale 1ns / 1ps

module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output[31:0] read_data_1;               // 输出的第一操作数
    output[31:0] read_data_2;               // 输出的第二操作数
    input[31:0]  Instruction;               // 取指单元来的指令
    input[31:0]  mem_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				// 从执行单元来的运算的结果
    input        Jal;                       //  来自控制单元，说明是JAL指令 
    input        RegWrite;                  // 来自控制单元 
    input        MemtoReg;              // 来自控制单元           是controller的MemorIOtoReg！！！！！！！！！！！！！！！！！！！！！！！！！！！
    input        RegDst;             
    output[31:0] Sign_extend;               // 扩展后的32位立即数
    input		 clock,reset;                // 时钟和复位
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用

reg [31:0] register[0:31]; //32个通用寄存器
wire [5:0] op = Instruction[31:26];

//读数据
wire [4:0]rs,rt;
assign rs = Instruction[25:21];//给r_data1读的
assign rt = Instruction[20:16];//给r_data2读的
assign read_data_1 = register[rs];
assign read_data_2 = register[rt];


//立即数扩展
wire sign;
assign sign = Instruction[15];
assign Sign_extend[31:0] = ((op==6'b001100)     // andi
                          ||(op==6'b001101)             // ori
                          ||(op==6'b001110)             // xori
                          ||(op==6'b001011) //altiu
                          ||(op==6'b001001))?{{16{1'b0}},Instruction[15:0]}:{{16{sign}},Instruction[15:0]};  //addiu


//写数据                          
reg [5:0] write_addrass;//写进的register
always @(*) begin
    if(Jal) write_addrass[5:0] = 5'b11111;
    else if(RegDst) write_addrass[5:0] = Instruction[15:11]; //R-type
    else write_addrass[5:0] = Instruction[20:16]; //运算类I-type和lw
end

always @(posedge clock) begin
    if(reset==1) 
        begin
            register[0]=32'b0;
            register[1]=32'b0;
            register[2]=32'b0;
            register[3]=32'b0;
            register[4]=32'b0;
            register[5]=32'b0;
            register[6]=32'b0;
            register[7]=32'b0;
            register[8]=32'b0;
            register[9]=32'b0;
            register[10]=32'b0;
            register[11]=32'b0;
            register[12]=32'b0;
            register[13]=32'b0;
            register[14]=32'b0;
            register[15]=32'b0;
            register[16]=32'b0;
            register[17]=32'b0;
            register[18]=32'b0;
            register[19]=32'b0;
            register[20]=32'b0;
            register[21]=32'b0;
            register[22]=32'b0;
            register[23]=32'b0;
            register[24]=32'b0;
            register[25]=32'b0;
            register[26]=32'b0;
            register[27]=32'b0;
            register[28]=32'b0;
            register[29]=32'b0;
            register[30]=32'b0;
            register[31]=32'b0;
        end
    if(RegWrite) begin
        if(Jal) register[write_addrass] <= opcplus4;
        else begin
            if(MemtoReg) register[write_addrass] <= mem_data;
            else register[write_addrass] <= ALU_result;
        end
    end
    register[0] = 32'b0;
end

endmodule