module cpu(
    input clk,
    input reset,
    output ram_wen_w, // when to write data to data memory
    output [31:0] ram_adr_i_w, // address of data memeory
    output [31:0] ram_dat_i_w, // output data to data memory input
    input [31:0] ram_dat_o_w, // input data from data memory output
    input[31:0] imem_instr,
    output [31:0] imem_addr
);

    wire [31:0] pc;
    wire [31:0] pre_pc; 
    wire if_id_in_flush;
    wire if_id_valid;
    wire[31:0] if_id_instr;
    wire [31:0] if_id_in_instr;
    wire [31:0] if_id_pc;
    wire if_id_noflush;
    wire decode_Jr;
    wire decode_Jmp;
    wire decode_Jal;
    wire decode_Branch;
    wire decode_nBranch;
    wire decode_RegDST;
    wire decode_MemtoReg;
    wire decode_RegWrite;
    wire decode_MemWrite;
    wire decode_ALUSrc;
    wire decode_I_format;
    wire decode_Sftmd;
    wire [1:0] decode_ALUOp;
    wire [4:0] decode_rs_addr;
    wire [4:0] decode_rt_addr;
    wire [4:0] decode_rd_addr;
    wire [31:0] decode_imm_extended;
    wire [5:0] decode_Opcode;
    wire [5:0] decode_Function_Opcode;
    wire id_ex_flush;
    wire id_ex_valid;
    wire id_ex_Jr;
    wire id_ex_Jmp;
    wire id_ex_Jal;
    wire id_ex_Branch;
    wire id_ex_nBranch;
    wire id_ex_RegDST;
    wire id_ex_MemtoReg;
    wire id_ex_RegWrite;
    wire id_ex_MemWrite;
    wire id_ex_ALUSrc;
    wire id_ex_I_format;
    wire id_ex_Sftmd;
    wire [1:0] id_ex_ALUOp;
    wire [4:0] id_ex_rs_addr;
    wire [4:0] id_ex_rt_addr;
    wire [4:0] id_ex_rd_addr;
    wire [31:0] id_ex_imm_extended;
    wire [5:0] id_ex_Opcode;
    wire [5:0] id_ex_Function_Opcode;
    wire [31:0] id_ex_pc;
    wire regs_wirte;
    wire [4:0] regs_write_reg;
    wire [31:0] regs_write_data;
    wire regs_outter_input; // TO DO
    wire [31:0] regs_outter_t9; // TO DO
    wire [31:0] regs_ram_reg_o; // TO DO
    wire [31:0] regs_ram_reg_o2; // TO DO
    wire [31:0] regs_read_data_1;
    wire [31:0] regs_read_data_2;
    wire ex_Zero,
    wire [31:0] ex_ALUResult;
    wire [31:0] ex_Addr_Result;
    // ex_mem part
    wire ex_mem_flush;
    wire ex_mem_MemtoReg;
    wire ex_mem_MemWrite;
    wire ex_mem_RegWrite;
    wire ex_mem_RegDST;
    wire ex_mem_Jal;
    wire ex_mem_Zero;
    wire [31:0] ex_mem_rs_addr;
    wire [31:0] ex_mem_rt_addr;
    wire [31:0] ex_mem_rd_addr;
    wire [31:0] ex_mem_ALUResult;
    wire [31:0] ex_mem_Addr_Result;
    wire [31:0] ex_mem_imm_extended;
    wire [31:0] ex_mem_read_data_1;
    wire [31:0] ex_mem_read_data_2;
    wire [31:0] ex_mem_pc;
    // mem_wb part
    wire mem_wb_RegWrite;
    wire mem_wb_Jal;
    wire mem_wb_RegDST;
    wire mem_wb_MemtoReg;
    wire [31:0] mem_wb_ReadData;
    wire [31:0] mem_wb_ALUResult;
    wire [4:0] mem_wb_rt_addr;
    wire [4:0] mem_wb_rd_addr;
    wire [31:0] mem_wb_pc;
    wire mem_wb_Zero;
    wire [31:0] mem_wb_Addr_Result;
    // wb part
    wire [4:0] wb_write_reg;
    wire wb_write;
    wire [31:0] wb_write_data;
    wire [31:0] forwarding_rs_data;
    wire [31:0] forwarding_rt_data;
    wire [4:0] forwarding_exMem_read;
    wire [4:0] forwarding_memWb_read;
    wire [31:0] forwarding_mem_wb_data_result;
    wire [31:0] forwarding_ex_mem_data_result;
    wire hazard_pcFromTaken;
    wire hazard_pcStall;
    wire hazard_IF_ID_stall;
    wire hazard_ID_EX_stall;
    wire hazard_IF_ID_flush;
    wire hazard_ID_EX_flush;
    wire hazard_EX_MEM_flush;


    // pre_if, guese the next pc, 50% correct rate
    pre_if u_pre_if(
        .instr(imem_instr),
        .pc(pc),
        .pre_pc(pre_pc)
    );
    
    // if_id part, the path from if to id
    if_id u_if_id(
        .clk(clk),
        .reset(reset),
        .in_instr(if_id_in_instr),
        .in_pc(pc),
        .flush(if_id_flush),
        .valid(if_id_valid),
        .out_instr(if_id_instr),
        .out_pc(if_id_pc),
        .out_noflush(if_id_noflush)
    );

    // decode part, decoder
    decode u_decoder(
        .instr(if_id_instr),
        .Jr(decode_Jr),
        .Jmp(decode_Jmp),
        .Jal(decode_Jal),
        .Branch(decode_Branch),
        .nBranch(decode_nBranch),
        .RegDST(decode_RegDST),
        .MemtoReg(decode_MemtoReg),
        .RegWrite(decode_RegWrite),
        .MemWrite(decode_MemWrite),
        .ALUSrc(decode_ALUSrc),
        .I_format(decode_I_format),
        .Sftmd(decode_Sftmd),
        .ALUOp(decode_ALUOp),
        .rs_addr(decode_rs),
        .rt_addr(decode_rt),
        .rd_addr(decode_rd),
        .immediate(decode_imm_extended),
        .Opcode(decode_Opcode),
        .Function_Opcode(decode_Function_Opcode)
    );

    // id_ex part, the path from id to ex
    id_ex u_id_ex(
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush),
        .valid(id_ex_valid),
        .in_Jr(decode_Jr),
        .in_Jmp(decode_Jmp),
        .in_Jal(decode_Jal),
        .in_Branch(decode_Branch),
        .in_nBranch(decode_nBranch),
        .in_RegDST(decode_RegDST),
        .in_MemtoReg(decode_MemtoReg),
        .in_RegWrite(decode_RegWrite),
        .in_MemWrite(decode_MemWrite),
        .in_ALUSrc(decode_ALUSrc),
        .in_I_format(decode_I_format),
        .in_Sftmd(decode_Sftmd),
        .in_ALUOp(decode_ALUOp),
        .in_rs_addr(decode_rs_addr),
        .in_rt_addr(decode_rt_addr),
        .in_rd_addr(decode_rd_addr),
        .in_imm_extended(decode_imm_extended),
        .in_Opcode(decode_Opcode),
        .in_Function_Opcode(decode_Function_Opcode),
        .in_pc(if_id_pc),
        .out_Jr(id_ex_Jr),
        .out_Jmp(id_ex_Jmp),
        .out_Jal(id_ex_Jal),
        .out_Branch(id_ex_Branch),
        .out_nBranch(id_ex_nBranch),
        .out_RegDST(id_ex_RegDST),
        .out_MemtoReg(id_ex_MemtoReg),
        .out_RegWrite(id_ex_RegWrite),
        .out_MemWrite(id_ex_MemWrite),
        .out_ALUSrc(id_ex_ALUSrc),
        .out_I_format(id_ex_I_format),
        .out_Sftmd(id_ex_Sftmd),
        .out_ALUOp(id_ex_ALUOp),
        .out_rs_addr(id_ex_rs_addr),
        .out_rt_addr(id_ex_rt_addr),
        .out_rd_addr(id_ex_rd_addr),
        .out_imm_extended(id_ex_imm_extended),
        .out_Opcode(id_ex_Opcode),
        .out_Function_Opcode(id_ex_Function_Opcode),
        .out_pc(id_ex_pc),
    );

    // register part
    gen_regs u_gen_regs(
        .clock(clk),
        .reset(reset),
        .opcode(id_ex_Opcode),
        .rs(id_ex_rs_addr),
        .rt(id_ex_rt_addr),
        .rd(id_ex_rd_addr),
        .write(regs_wirte),
        .write_reg(regs_write_reg),
        .write_data(regs_write_data),
        .outter_input(regs_outter_input),
        .outter_t9(regs_outter_t9),
        .ram_reg_o(regs_ram_reg_o),
        .ram_reg_o2(regs_ram_reg_o2),
        .read_data_1(regs_read_data_1),
        .read_data_2(regs_read_data_2)
    );

    // execute part
    execute u_execute(
        .Read_data_1(forwarding_rs_data),
        .Read_data_2(forwarding_rt_data),
        .Imme_extend(id_ex_imm_extended),
        .Function_Opcode(id_ex_Function_Opcode),
        .opcode(id_ex_Opcode),
        .Shamt(id_ex_Sftmd),
        .PC(id_ex_pc),
        .ALUOp(id_ex_ALUOp),
        .ALUSrc(id_ex_ALUSrc),
        .I_format(id_ex_I_format),
        .Sftmd(id_ex_Sftmd),
        .Jr(id_ex_Jr),
        .Zero(ex_Zero),
        .ALU_result(ex_ALU_result),
        .Addr_Result(ex_Addr_Result),
    );

    // ex_mem part
    ex_mem u_ex_mem(
        .clk(clk),
        .reset(reset),
        .flush(ex_mem_flush),
        .in_MemtoReg(id_ex_MemtoReg),
        .in_RegWrite(id_ex_RegWrite),
        .in_MemWrite(id_ex_MemWrite),
        .in_RegDST(id_ex_RegDST),
        .in_Jal(id_ex_Jal),
        .in_Zero(ex_Zero),
        .in_rs_addr(id_ex_rs_addr),
        .in_rt_addr(id_ex_rt_addr),
        .in_rd_addr(id_ex_rd_addr),
        .in_ALU_result(ex_ALU_result),
        .in_Addr_Result(ex_Addr_Result),
        .in_imm_extended(id_ex_imm_extended),
        .in_read_data_1(regs_read_data_1),
        .in_read_data_2(regs_read_data_2),
        .in_pc(id_ex_pc),
        .out_MemtoReg(ex_mem_MemtoReg),
        .out_RegWrite(ex_mem_RegWrite),
        .out_MemWrite(ex_mem_MemWrite),
        .out_RegDST(ex_mem_RegDST),
        .out_Jal(ex_mem_Jal),
        .out_Zero(ex_mem_Zero),
        .out_rs_addr(ex_mem_rs_addr),
        .out_rt_addr(ex_mem_rt_addr),
        .out_rd_addr(ex_mem_rd_addr),
        .out_ALU_result(ex_mem_ALU_result),
        .out_Addr_Result(ex_mem_Addr_Result),
        .out_imm_extended(ex_mem_imm_extended),
        .out_read_data_1(ex_mem_read_data_1),
        .out_read_data_2(ex_mem_read_data_2),
        .out_pc(ex_mem_pc),
    );
        
    // mem_wb part
    mem_wb u_mem_wb(
        .clk(clk),
        .reset(reset),
        .in_RegWrite(ex_mem_RegWrite),
        .in_Jal(ex_mem_Jal),
        .in_RegDST(ex_mem_RegDST),
        .in_MemtoReg(ex_mem_MemtoReg),
        .in_ReadData(ram_dat_o_w),
        .in_ALU_result(ex_mem_ALU_result),
        .in_rt_addr(ex_mem_rt_addr),
        .in_rd_addr(ex_mem_rd_addr),
        .in_pc(ex_mem_pc),
        .in_Zero(ex_mem_Zero),
        .in_Addr_Result(ex_mem_Addr_Result),
        .out_RegWrite(mem_wb_RegWrite),
        .out_Jal(mem_wb_Jal),
        .out_RegDST(mem_wb_RegDST),
        .out_MemtoReg(mem_wb_MemtoReg),
        .out_ReadData(mem_wb_ReadData),
        .out_ALU_result(mem_wb_ALU_result),
        .out_rt_addr(mem_wb_rt_addr),
        .out_rd_addr(mem_wb_rd_addr),
        .out_pc(mem_wb_pc),
        .out_Zero(mem_wb_Zero),
        .out_Addr_Result(mem_wb_Addr_Result),
    );

    // wb part
    wb u_wb(
        .Jal(mem_wb_Jal),
        .RegDST(mem_wb_RegDST),
        .rd_addr(mem_wb_rd_addr),
        .rt_addr(mem_wb_rt_addr),
        .PC(mem_wb_pc),
        .RegWrite(mem_wb_RegWrite),
        .MemtoReg(mem_wb_MemtoReg),
        .ReadData(mem_wb_ReadData),
        .ALU_result(mem_wb_ALU_result),
        .write(regs_write),
        .write_reg(regs_write_reg),
        .write_data(regs_write_data),
    );

    // forwarding part
    forwarding u_forwarding(
        .rs(id_ex_rs_addr),
        .rt(id_ex_rt_addr),
        .exMemRd(forwarding_exMem_read),
        .exMemRw(ex_mem_RegWrite),
        .memWbRd(forwarding_memWb_read),
        .memWbRw(mem_wb_RegWrite),
        .mem_wb_ctrl_data_toReg(mem_wb_MemtoReg),
        .mem_wb_readData(mem_wb_ReadData),
        .mem_wb_data_result(forwarding_mem_wb_data_result),
        .id_ex_data_regRData1(regs_read_data_1),
        .id_ex_data_regRData2(regs_read_data_2),
        .ex_mem_data_result(forwarding_ex_mem_data_result),
        .forward_rs_data(forwarding_rs_data),
        .forward_rt_data(forwarding_rt_data),
    );

    // hazard part
    hazard u_hazard(
        .rs(id_ex_rs_addr),
        .rt(id_ex_rt_addr),
        .id_ex_Jr(id_ex_Jr),
        .id_ex_Branch(id_ex_Branch),
        .id_ex_nBranch(id_ex_nBranch),
        .ex_Zero(ex_Zero), 
        .id_ex_jump(id_ex_Jmp),
        .id_ex_memRead(id_ex_MemtoReg),
        .id_ex_memWrite(id_ex_MemWrite),
        .id_ex_rd(id_ex_rd_addr),
        .ex_mem_MemWrite(ex_mem_MemWrite),
        .pcFromTaken(hazard_pcFromTaken),
        .pcStall(hazard_pcStall),
        .IF_ID_stall(hazard_IF_ID_stall),
        .IF_ID_flush(hazard_IF_ID_flush),
        .ID_EX_stall(hazard_ID_EX_stall),
        .ID_EX_flush(hazard_ID_EX_flush),
        .EX_MEM_flush(hazard_EX_MEM_flush),
    );

    // pc_gen part
    pc_gen u_pc_gen(
        .clk(clk),
        .reset(reset),
        .Read_data_1(forwarding_rs_data),
        .hazard_pcStall(hazard_pcStall),
        .hazard_pcFromTaken(hazard_pcFromTaken),
        .id_ex_Jr(id_ex_Jr),
        .pre_pc(pre_pc),
        .pc_o(pc),
    );

    assign if_id_in_instr = imem_instr;
    assign if_id_flush = hazard_IF_ID_flush; 
    assign if_id_valid = ~hazard_IF_ID_stall;
    assign id_ex_flush = hazard_ID_EX_flush;
    assign id_ex_valid = ~hazard_ID_EX_stall;
    assign ex_mem_flush = hazard_EX_MEM_flush;
    assign ram_wen_i = ex_mem_MemWrite;
    assign ram_adr_i_w = ex_mem_ALU_result;
    assign ram_dat_i_w = ex_mem_read_data_2;
    assign forwarding_exMem_read = ex_mem_RegDST ? ex_mem_rd_addr : ex_mem_rt_addr;
    assign forwarding_memWb_read = mem_wb_RegDST ? mem_wb_rd_addr : mem_wb_rt_addr;
    assign forwarding_mem_wb_data_result = (mem_wb_Jal)?((mem_wb_pc + 4)>>2):(mem_wb_MemtoReg?mem_wb_ReadData:mem_wb_ALU_result);
    assign forwarding_ex_mem_data_result = (ex_mem_Jal)?((ex_mem_pc + 4)>>2):ex_mem_ALU_result;
    assign imem_addr = pc;


endmodule