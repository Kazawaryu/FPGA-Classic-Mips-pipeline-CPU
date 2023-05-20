module top(
    input clk,
    input reset,
);

wire ram_wen;
wire [31:0] ram_adr_i;
wire [31:0] ram_dat_i;
wire [31:0] ram_dat_o;
wire [31:0] imem_instr;
wire [31:0] imem_addr;

cpu u_cpu(
    .clk(clk),
    .reset(reset)
    .ram_wen_w(ram_wen),
    .ram_adr_i_w(ram_adr_i),
    .ram_dat_i_w(ram_dat_i),
    .ram_dat_o_w(ram_dat_o),
    .imem_instr(imem_instr),
    .imem_addr(imem_addr)
);

programrom imem(
    .rom_clk_i(clk),
    .rom_adr_i(imem_addr),
    .Instruction_o(imem_instr)
);

dememory dmem(
    .ram_clk_i(clk),
    .ram_wen_i(ram_wen),
    .ram_adr_i(ram_adr_i),
    .ram_dat_i(ram_dat_i),
    .ram_dat_o(ram_dat_o)
);

endmodule