// 指令预读取，也就是先把指令从存储器中读出。
// this is pre_if for a minisys cpu
module pre_if (
    input [31:0] instr,
    input [31:0] pc,

    output [31:0] pre_pc
);

    wire immediate = instr[15:0]; // i type immediate
    wire address = instr[25:0]; // j type address
    
    wire Branch = (instr[31:26] == 6'b000100); // branch
    wire nBranch = (instr[31:26] == 6'b000101); // branch not equal
    wire Jump = (instr[31:26] == 6'b000010); // jump
    wire JumpAndLink = (instr[31:26] == 6'b000011); // jump and link
    
    wire BranchAddr = {14{immediate[15]}, immediate, 2'b0};
    wire JumpAddr = {pc+4[31:28], address, 2'b0};

    assign pre_pc = (Branch || nBranch) ? BranchAddr :
                    (Jump || JumpAndLink) ? JumpAddr : 
                    pc + 4;

endmodule