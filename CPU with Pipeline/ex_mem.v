// this module is used to pass data from the EX stage to the MEM stage
// the data is related to MEM and WB
module ex_mem(
    input clk,
    input reset,
    input flush, // flush the pipeline
    // input
    input in_MemtoReg, // 是否把内存数据写入寄存器
    input in_MemWrite, // 1: 写入内存
    input in_RegWrite, // 1: 写入寄存器
    input in_RegDST, // 1: 写入寄存器的地址为 rd，0: 写入寄存器的地址为 rt
    input in_Jal, // jump and link
    input in_Zero, // ALU计算结果是否为0
    input [4:0] in_rs_addr,
    input [4:0] in_rt_addr,
    input [4:0] in_rd_addr,
    input [31:0] in_ALUResult, // ALU计算结果
    input [31:0] in_Addr_Result, // 计算出的内存地址
    input [31:0] in_imm_extended, // 符号扩展后的立即数
    input [31:0] in_read_data_1,
    input [31:0] in_read_data_2,
    input [31:0] in_pc, // PC值
    // output
    output out_MemtoReg,
    output out_MemWrite,
    output out_RegWrite,
    output out_RegDST,
    output out_Jal,
    output out_Zero,
    output [4:0] out_rs_addr,
    output [4:0] out_rt_addr,
    output [4:0] out_rd_addr,
    output [31:0] out_ALUResult,
    output [31:0] out_Addr_Result,
    output [31:0] out_imm_extended,
    output [31:0] out_read_data_1,
    output [31:0] out_read_data_2,
    output [31:0] out_pc
);
    reg reg_MemtoReg;
    reg reg_MemWrite;
    reg reg_RegWrite;
    reg reg_RegDST;
    reg reg_Jal;
    reg reg_Zero;
    reg [4:0] reg_rs_addr;
    reg [4:0] reg_rt_addr;
    reg [4:0] reg_rd_addr;
    reg [31:0] reg_ALUResult;
    reg [31:0] reg_Addr_Result;
    reg [31:0] reg_imm_extended;
    reg [31:0] reg_read_data_1;
    reg [31:0] reg_read_data_2;
    reg [31:0] reg_pc;

    assign out_MemtoReg = reg_MemtoReg;
    assign out_MemWrite = reg_MemWrite;
    assign out_RegWrite = reg_RegWrite;
    assign out_RegDST = reg_RegDST;
    assign out_Jal = reg_Jal;
    assign out_Zero = reg_Zero;
    assign out_rs_addr = reg_rs_addr;
    assign out_rt_addr = reg_rt_addr;
    assign out_rd_addr = reg_rd_addr;
    assign out_ALUResult = reg_ALUResult;
    assign out_Addr_Result = reg_Addr_Result;
    assign out_imm_extended = reg_imm_extended;
    assign out_read_data_1 = reg_read_data_1;
    assign out_read_data_2 = reg_read_data_2;
    assign out_pc = reg_pc;

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_MemtoReg <= 1'b0; 
        end else if (flush) begin 
            reg_MemtoReg <= 1'b0; 
        end else begin 
            reg_MemtoReg <= in_regWAddr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_MemWrite <= 1'b0; 
        end else if (flush) begin 
            reg_MemWrite <= 1'b0; 
        end else begin 
            reg_MemWrite <= in_MemWrite;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_RegWrite <= 1'b0; 
        end else if (flush) begin 
            reg_RegWrite <= 1'b0; 
        end else begin 
            reg_RegWrite <= in_RegWrite;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_RegDST <= 1'b0; 
        end else if (flush) begin 
            reg_RegDST <= 1'b0; 
        end else begin 
            reg_RegDST <= in_RegDST;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Jal <= 1'b0; 
        end else if (flush) begin 
            reg_Jal <= 1'b0; 
        end else begin 
            reg_Jal <= in_Jal;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Zero <= 1'b0; 
        end else if (flush) begin 
            reg_Zero <= 1'b0; 
        end else begin 
            reg_Zero <= in_Zero;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_rs_addr <= 32'b0; 
        end else if (flush) begin 
            reg_rs_addr <= 32'b0; 
        end else begin 
            reg_rs_addr <= in_rs_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_rt_addr <= 32'b0; 
        end else if (flush) begin 
            reg_rt_addr <= 32'b0; 
        end else begin 
            reg_rt_addr <= in_rt_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_rd_addr <= 32'b0; 
        end else if (flush) begin 
            reg_rd_addr <= 32'b0; 
        end else begin 
            reg_rd_addr <= in_rd_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_ALUResult <= 32'b0; 
        end else if (flush) begin 
            reg_ALUResult <= 32'b0; 
        end else begin 
            reg_ALUResult <= in_ALUResult;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Addr_Result <= 32'b0; 
        end else if (flush) begin 
            reg_Addr_Result <= 32'b0; 
        end else begin 
            reg_Addr_Result <= in_Addr_Result;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_imm_extended <= 32'b0; 
        end else if (flush) begin 
            reg_imm_extended <= 32'b0; 
        end else begin 
            reg_imm_extended <= in_imm_extended;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_read_data_1 <= 32'b0; 
        end else if (flush) begin 
            reg_read_data_1 <= 32'b0; 
        end else begin 
            reg_read_data_1 <= in_read_data_1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_read_data_2 <= 32'b0; 
        end else if (flush) begin 
            reg_read_data_2 <= 32'b0; 
        end else begin 
            reg_read_data_2 <= in_read_data_2;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_pc <= 32'b0; 
        end else if (flush) begin 
            reg_pc <= 32'b0; 
        end else begin 
            reg_pc <= in_pc;
        end
    end

endmodule