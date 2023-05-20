// this module is the ID/EX pipeline register
// it takes the output from the ID stage and passes it to the EX stage

module id_ex(
    input clk,
    input reset,
    // these are pipeline signals
    input flush,
    input valid,
    // these are inputs from decode stage
    input in_Jr, // jump or not
    input in_Jmp,
    input in_Jal,
    input in_Branch,
    input in_nBranch,
    input in_RegDST,
    input in_MemtoReg, // lw
    input in_RegWrite,
    input in_MemWrite, // sw
    input in_ALUSrc,
    input in_I_format,
    input in_Sftmd,
    input[1:0] in_ALUOp,
    input[4:0] in_rs_addr,
    input[4:0] in_rt_addr,
    input[4:0] in_rd_addr,
    input[31:0] in_imm_extended,
    input[5:0] in_Opcode,
    input[5:0] in_Function_Opcode,
    input[31:0] in_pc,
    // these are outputs to the execute stage
    output out_Jr,
    output out_Jmp,
    output out_Jal,
    output out_Branch,
    output out_nBranch,
    output out_RegDST,
    output out_MemtoReg,
    output out_RegWrite,
    output out_MemWrite,
    output out_ALUSrc,
    output out_I_format,
    output out_Sftmd,
    output[1:0] out_ALUOp,
    output[4:0] out_rs_addr,
    output[4:0] out_rt_addr,
    output[4:0] out_rd_addr,
    output[31:0] out_imm_extended
    output[5:0] out_Opcode,
    output[5:0] out_Function_Opcode
    output[31:0] out_pc
);

    reg reg_Jr;
    reg reg_Jmp;
    reg reg_Jal;
    reg reg_Branch;
    reg reg_nBranch;
    reg reg_RegDST;
    reg reg_MemtoReg;
    reg reg_RegWrite;
    reg reg_MemWrite;
    reg reg_ALUSrc;
    reg reg_I_format;
    reg reg_Sftmd;
    reg[1:0] reg_ALUOp;
    reg[4:0] reg_rs_addr;
    reg[4:0] reg_rt_addr;
    reg[4:0] reg_rd_addr;
    reg[31:0] reg_imm_extended;
    reg[5:0] reg_Opcode;
    reg[5:0] reg_Function_Opcode;
    reg[31:0] reg_pc;

    assign out_Jr = reg_Jr;
    assign out_Jmp = reg_Jmp;
    assign out_Jal = reg_Jal;
    assign out_Branch = reg_Branch;
    assign out_nBranch = reg_nBranch;
    assign out_RegDST = reg_RegDST;
    assign out_MemtoReg = reg_MemtoReg;
    assign out_RegWrite = reg_RegWrite;
    assign out_MemWrite = reg_MemWrite;
    assign out_ALUSrc = reg_ALUSrc;
    assign out_I_format = reg_I_format;
    assign out_Sftmd = reg_Sftmd;
    assign out_ALUOp = reg_ALUOp;
    assign out_rs_addr = reg_rs_addr;
    assign out_rt_addr = reg_rt_addr;
    assign out_rd_addr = reg_rd_addr;
    assign out_imm_extended = reg_imm_extended;
    assign out_Opcode = reg_Opcode;
    assign out_Function_Opcode = reg_Function_Opcode;
    assign out_pc = reg_pc;

    // decide to pass these signals through or not

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Jr <= 1'b0;
        end else if (flush) begin 
            reg_Jr <= 1'b0; 
        end else if (valid) begin 
            reg_Jr <= in_Jr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Jmp <= 1'b0;
        end else if (flush) begin 
            reg_Jmp <= 1'b0; 
        end else if (valid) begin 
            reg_Jmp <= in_Jmp;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Jal <= 1'b0;
        end else if (flush) begin 
            reg_Jal <= 1'b0; 
        end else if (valid) begin 
            reg_Jal <= in_Jal;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Branch <= 1'b0;
        end else if (flush) begin 
            reg_Branch <= 1'b0; 
        end else if (valid) begin 
            reg_Branch <= in_Branch;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_nBranch <= 1'b0;
        end else if (flush) begin 
            reg_nBranch <= 1'b0; 
        end else if (valid) begin 
            reg_nBranch <= in_nBranch;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_RegDST <= 1'b0;
        end else if (flush) begin 
            reg_RegDST <= 1'b0; 
        end else if (valid) begin 
            reg_RegDST <= in_RegDST;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_MemtoReg <= 1'b0;
        end else if (flush) begin 
            reg_MemtoReg <= 1'b0; 
        end else if (valid) begin 
            reg_MemtoReg <= in_MemtoReg;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_RegWrite <= 1'b0;
        end else if (flush) begin 
            reg_RegWrite <= 1'b0; 
        end else if (valid) begin 
            reg_RegWrite <= in_RegWrite;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_MemWrite <= 1'b0;
        end else if (flush) begin 
            reg_MemWrite <= 1'b0; 
        end else if (valid) begin 
            reg_MemWrite <= in_MemWrite;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_ALUSrc <= 1'b0;
        end else if (flush) begin 
            reg_ALUSrc <= 1'b0; 
        end else if (valid) begin 
            reg_ALUSrc <= in_ALUSrc;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_I_format <= 1'b0;
        end else if (flush) begin 
            reg_I_format <= 1'b0; 
        end else if (valid) begin 
            reg_I_format <= in_I_format;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Sftmd <= 1'b0;
        end else if (flush) begin 
            reg_Sftmd <= 1'b0; 
        end else if (valid) begin 
            reg_Sftmd <= in_Sftmd;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_ALUOp <= 2'b0;
        end else if (flush) begin 
            reg_ALUOp <= 2'b0; 
        end else if (valid) begin 
            reg_ALUOp <= in_ALUOp;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_rs_addr <= 5'b0;
        end else if (flush) begin 
            reg_rs_addr <= 5'b0; 
        end else if (valid) begin 
            reg_rs_addr <= in_rs_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_rt_addr <= 5'b0;
        end else if (flush) begin 
            reg_rt_addr <= 5'b0; 
        end else if (valid) begin 
            reg_rt_addr <= in_rt_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_rd_addr <= 5'b0;
        end else if (flush) begin 
            reg_rd_addr <= 5'b0; 
        end else if (valid) begin 
            reg_rd_addr <= in_rd_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_imm_extended <= 16'b0;
        end else if (flush) begin 
            reg_imm_extended <= 16'b0; 
        end else if (valid) begin 
            reg_imm_extended <= in_imm_extended;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Opcode <= 6'b0;
        end else if (flush) begin 
            reg_Opcode <= 6'b0; 
        end else if (valid) begin 
            reg_Opcode <= in_Opcode;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_Function_Opcode <= 6'b0;
        end else if (flush) begin 
            reg_Function_Opcode <= 6'b0; 
        end else if (valid) begin 
            reg_Function_Opcode <= in_Function_Opcode;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            reg_PC <= 32'b0;
        end else if (flush) begin 
            reg_PC <= 32'b0; 
        end else if (valid) begin 
            reg_PC <= in_PC;
        end
    end



endmodule