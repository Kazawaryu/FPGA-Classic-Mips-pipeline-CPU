module mem_wb(
    input clk,
    input reset,
    // input
    input in_RegWrite,
    input in_Jal,
    input in_RegDST,
    input in_MemtoReg,
    input [31:0] in_ReadData, // data from memory
    input [31:0] in_ALUResult,
    input [4:0] in_rt_addr,
    input [4:0] in_rd_addr,
    input [31:0] in_pc,
    input in_Zero,
    input [31:0] in_Addr_Result,
    // output
    output out_RegWrite,
    output out_Jal,
    output out_RegDST,
    output out_MemtoReg,
    output [31:0] out_ReadData,
    output [31:0] out_ALUResult,
    output [4:0] out_rt_addr,
    output [4:0] out_rd_addr,
    output [31:0] out_pc,
    output out_Zero,
    output [31:0] out_Addr_Result

);

    reg reg_RegWrite;
    reg reg_Jal;
    reg reg_RegDST;
    reg reg_MemtoReg;
    reg [31:0] reg_ReadData;
    reg [31:0] reg_ALUResult;
    reg [4:0] reg_rt_addr;
    reg [4:0] reg_rd_addr;
    reg [31:0] reg_pc;
    reg reg_Zero;
    reg [31:0] reg_Addr_Result;

    assign out_RegWrite = reg_RegWrite;
    assign out_Jal = reg_Jal;
    assign out_RegDST = reg_RegDST;
    assign out_MemtoReg = reg_MemtoReg;
    assign out_ReadData = reg_ReadData;
    assign out_ALUResult = reg_ALUResult;
    assign out_rt_addr = reg_rt_addr;
    assign out_rd_addr = reg_rd_addr;
    assign out_pc = reg_pc;
    assign out_Zero = reg_Zero;
    assign out_Addr_Result = reg_Addr_Result;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_RegWrite <= 1'b0;
        end else begin
            reg_RegWrite <= in_RegWrite;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_Jal <= 1'b0;
        end else begin
            reg_Jal <= in_Jal;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_RegDST <= 1'b0;
        end else begin
            reg_RegDST <= in_RegDST;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_MemtoReg <= 1'b0;
        end else begin
            reg_MemtoReg <= in_MemtoReg;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_ReadData <= 32'b0;
        end else begin
            reg_ReadData <= in_ReadData;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_ALUResult <= 32'b0;
        end else begin
            reg_ALUResult <= in_ALUResult;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_rt_addr <= 32'b0;
        end else begin
            reg_rt_addr <= in_rt_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_rd_addr <= 32'b0;
        end else begin
            reg_rd_addr <= in_rd_addr;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_pc <= 32'b0;
        end else begin
            reg_pc <= in_pc;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_Zero <= 1'b0;
        end else begin
            reg_Zero <= in_Zero;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_Addr_Result <= 32'b0;
        end else begin
            reg_Addr_Result <= in_Addr_Result;
        end
    end

endmodule