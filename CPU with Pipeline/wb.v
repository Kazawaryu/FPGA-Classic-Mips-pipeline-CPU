module wb(
    input Jal,
    input RegDST,
    input rd_addr,
    input rt_addr,
    input [31:0] PC,
    input RegWrite,
    input MemtoReg,
    input [31:0] ReadData,
    input [31:0] ALUResult,
    output write,
    output [31:0] write_data,
    output [4:0] write_reg
);

    reg reg_write;
    reg [31:0] reg_write_data;
    reg [4:0] reg_write_reg;

    assign reg_write_reg = Jal ? 5'b11111 : RegDST ? rd_addr : rt_addr;
    assign reg_write = (RegWrite || Jal) && (reg_write_reg != 0);
    assign reg_write_data = Jal ? ((PC + 4)>>2) : (MemtoReg ? ReadData : ALUResult);

    assign write = reg_write;
    assign write_data = reg_write_data;
    assign write_reg = reg_write_reg;

endmodule