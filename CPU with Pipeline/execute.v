`timescale 1ns / 1ps

module execute (
    input [31:0] Read_data_1, // rs输入数据源
    input [31:0] Read_data_2, // rt输入数据源
    input [31:0] Imme_extend, // immediate扩展后的值
    input [5:0] Function_opcode, // 指令[5:0]
    input [5:0] opcode, // 指令[31:26]
    input [4:0] Shamt, // 指令[10:6]，移位量
    input [31:0] PC, // PC, current PC
    input [1:0] ALUOp, // {(R_format || I_format), (Branch || nBranch)}
    input ALUSrc, // 1表示第二个操作数是立即数（除了beq、bne）
    input I_format, // 1表示I型指令，除了beq、bne、LW、SW
    input Sftmd, // 1表示这是一个移位指令
    input Jr, // 1表示这是一个jr指令

    output Zero, // 1表示ALU计算结果为0，否则为0
    output reg [31:0] ALU_Result, // ALU计算结果
    output [31:0] Addr_Result // 计算得到的指令地址, 用于branch指令
);

    wire [31:0] Ainput, Binput; // 两个用于计算的操作数
    wire [5:0] Exe_code; // 用于生成ALU_ctrl的变量，(I_format==0) ? Function_opcode : {3'b000, Opcode[2:0]}
    wire [2:0] ALU_ctl; // 直接影响ALU操作的控制信号
    wire [2:0] Sftm; // 用于识别移位指令类型，等于Function_opcode[2:0]
    reg [31:0] ALU_output_mux; // 算术或逻辑运算的结果
    reg [31:0] Shift_Result; // 移位操作的结果
    wire [32:0] Branch_Addr; // 指令的计算地址，Addr_Result是Branch_Addr[31:0]
    wire PC_plus_4 = PC + 4; // PC+4

    // 选择A、B输入数据源
    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc == 0) ? Read_data_2 : Imme_extend[31:0];

    // 生成ALU控制信号
    assign Exe_code = (I_format == 0) ? Function_opcode : {3'b000, opcode[2:0]};
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1];
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];
    assign Sftm = Function_opcode[2:0];

    // ALU计算
    always @ (ALU_ctl or Ainput or Binput) begin
        case (ALU_ctl)
            3'b000: ALU_output_mux <= Ainput & Binput;
            3'b001: ALU_output_mux <= Ainput | Binput;
            3'b010: ALU_output_mux <= $signed(Ainput) + $signed(Binput);
            3'b011: ALU_output_mux <= Ainput + Binput;
            3'b100: ALU_output_mux <= Ainput ^ Binput;
            3'b101: ALU_output_mux <= ~(Ainput | Binput);
            3'b110: ALU_output_mux <= $signed(Ainput) - $signed(Binput);
            3'b111: ALU_output_mux <= Ainput - Binput;
            default: ALU_output_mux <= 32'h00000000;
        endcase
    end

    // 移位操作
    always @* begin
        if (Sftmd) begin
            case (Sftm[2:0])
                3'b000: Shift_Result <= Binput << Shamt; // Sll rd, rt, shamt 00000
                3'b010: Shift_Result <= Binput >> Shamt; // Srl rd, rt, shamt 00010
                3'b100: Shift_Result <= Binput << Ainput; // Sllv rd, rt, rs 000100
                3'b110: Shift_Result <= Binput >> Ainput; // Srlv rd, rt, rs 000110
                3'b011: Shift_Result <= $signed(Binput) >>> Shamt; // Sra rd, rt, shamt 00011
                3'b111: Shift_Result <= $signed(Binput) >>> Ainput; // Srav rd, rt, rs 00111
                default: Shift_Result <= Binput;
            endcase
        end else begin
            Shift_Result = Binput;
        end
    end

    // 设置类型操作（slt, slti, sltu, sltiu）
    // 或者lui操作
    // 或者移位操作
    // 或者其他ALU操作（算术或逻辑运算）
    always @* begin
        if (((ALU_ctl == 3'b111) && (Exe_code[3] == 1)) || ((ALU_ctl[2:1] == 2'b11) && (I_format == 1))) begin
            ALU_Result <= ALU_output_mux[31] == 1 ? 1 : 0;
        end else if ((ALU_ctl == 3'b101) && (I_format == 1)) begin
            ALU_Result[31:0] <= {Binput[15:0], {16{1'b0}}};
        end else if (Sftmd == 1) begin
            ALU_Result <= Shift_Result;
        end else begin
            ALU_Result <= ALU_output_mux[31:0];
        end
    end

    // 判断ALU计算结果是否为0
    assign Zero = (ALU_output_mux == 32'b0) ? 1'b1 : 1'b0;

    // 计算分支指令的地址
    assign Branch_Addr = PC_plus_4[31:2] + Imme_extend; // to do: +4 即可
    assign Addr_Result = Branch_Addr[31:0];

endmodule