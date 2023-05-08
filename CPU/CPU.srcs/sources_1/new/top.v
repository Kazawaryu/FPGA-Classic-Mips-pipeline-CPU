// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 2022/05/22 18:34:29
// // Design Name: 
// // Module Name: toppest
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Created
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////


// module cpu_uart(
//     fpga_clk,fpga_rst,switch,led,rx,tx,start_pg,
//     DIG,Y,row,col,backplace
//     );
//     //may need a enable to choose mode
//     input fpga_clk; //fpga chip's clock
//     input fpga_rst; //origin rst
//     input start_pg; //change state of reading and writing 
//     input [23:0]    switch;    
//     output[23:0]    led;

//     output[7:0]     DIG;//八位使能信号
//     output[7:0]     Y;//点亮数码管
//     input  [3:0] row;
//     output [3:0] col;
//     input backplace; 

//     wire clk;
//     assign clk = fpga_clk;

//     //used for other modules which don't relatetoUART
//     wire rst;
//     assign rst = fpga_rst | ~upg_rst;
 
//     wire [31:0] Instruction;
//     wire [31:0] Instruction_i;

//     //contorller
//     wire[5:0]   Opcode = Instruction[31:26];            // 来自IFetch模块的指令高6bit, inFstruction[31..26]
//     wire[5:0]   Function_opcode = Instruction[5:0];  	// 来自IFetch模块的指令低6bit, 用于区分r-类型中的指令, instructions[5..0]
//     wire       Jr;         	 // 为1表明当前指令是jr, 为0表示当前指令不是jr
//     wire       RegDST;       // 为1表明目的寄存器是rd, 否则目的寄存器是rt
//     wire       ALUSrc;       // 为1表明第二个操作数（ALU中的Bwire）是立即数（beq, bne除外）, 为0时表示第二个操作数来自寄存器
//     wire       RegWrite;   	  // 为1表明该指令需要写寄存器
//     wire       MemWrite;       // 为1表明该指令需要写存储器
//     wire       Branch;        // 为1表明是beq指令, 为0时表示不是beq指令
//     wire       nBranch;       // 为1表明是Bne指令, 为0时表示不是bne指令
//     wire       Jmp;            // 为1表明是J指令, 为0时表示不是J指令
//     wire       Jal;            // 为1表明是Jal指令, 为0时表示不是Jal指令
//     wire       I_format;      // 为1表明该指令是除beq, bne, LW, SW之外的其他I-类型指令
//     wire       Sftmd;         // 为1表明是移位指令, 为0表明不是移位指令
//     wire[1:0]  ALUOp;        // 是R-类型或I_format=1时位1（高bit位）为1,  beq、bne指令则位0（低bit位）为1

//     wire[31:0]  ALU_result;   				// 从执行单元来的运算的结果
//     // wire[21:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
//     wire MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the reg
//     wire MemRead; // 1 indicates that the instruction needs to read from the memor
//     wire IORead; // 1 indicates I/O read
//     wire IOWrite; // 1 indicates I/O write

//     //括号中的为本模块变量！！！！！！！！
//     control32 contorller(
//         .Opcode(Opcode),
//         .Function_opcode(Function_opcode),
//         .Jr(Jr),
//         .RegDST(RegDST),
//         .ALUSrc(ALUSrc),
//         .RegWrite(RegWrite),
//         .MemWrite(MemWrite),
//         .Branch(Branch),
//         .nBranch(nBranch),
//         .Jmp(Jmp),
//         .Jal(Jal),
//         .I_format(I_format),
//         .Sftmd(Sftmd),
//         .ALUOp(ALUOp),
//         .Alu_resultHigh(ALU_result[31:10]),
//         .MemorIOtoReg(MemorIOtoReg),
//         .MemRead(MemRead),
//         .IORead(IORead),
//         .IOWrite(IOWrite));

//     // UART Programmer Pinouts
//     // start Uart communicate at high level

//     input rx;
//     wire upg_rx;
//     assign upg_rx = rx;
//     output tx;
//     wire upg_tx;
//     assign tx = upg_tx;

//     //15 - low highest, 16 - high lowest
//     wire cpu_clk;
//     wire upg_clk;

//     //clock，1 -> normal mode, 2 -> uart communication mode
//     cpuclk cpuclk1_v1_0(.clk_in1(clk),.clk_out1(cpu_clk),.clk_out2(upg_clk));

//     //decoder
//     wire[31:0] read_data_1;               // 输出的第一操作数
//     wire[31:0] read_data_2;               // 输出的第二操作数
//     wire[31:0] mem_data;   			  //从DATA RAM or I/O port取出的数据

//     wire[31:0] Sign_extend;               // 扩展后的32位立即数
//     wire[31:0] opcplus4; 
//                     // 来自取指单元，JAL中用
//     wire clock =  cpu_clk;

//     decode32 decoder(
//         .read_data_1(read_data_1),
//         .read_data_2(read_data_2),
//         .Instruction(Instruction),
//         .mem_data(mem_data),
//         .ALU_result(ALU_result),
//         .Jal(Jal),
//         .RegWrite(RegWrite),
//         .MemtoReg(MemorIOtoReg),
//         .RegDst(RegDST),
//         .Sign_extend(Sign_extend),
//         .clock(clock),
//         .reset(rst),
//         .opcplus4(opcplus4));


//     //ALU
//     wire Zero;
//     wire [31:0] PC_plus_4; 
//     wire [31:0] Addr_Result;
//     wire [4:0]  Shamt = Instruction[10:6];

//     executs32 ALU(
//         .Read_data_1(read_data_1),
//         .Read_data_2(read_data_2),
//         .Sign_extend(Sign_extend),
//         .Function_opcode(Function_opcode),
//         .Exe_opcode(Opcode),
//         .ALUOp(ALUOp),
//         .Shamt(Shamt),
//         .Sftmd(Sftmd),
//         .ALUSrc(ALUSrc),
//         .I_format(I_format),
//         .Jr(Jr),
//         .Zero(Zero),
//         .ALU_Result(ALU_result),
//         .Addr_Result(Addr_Result),
//         .PC_plus_4(PC_plus_4));

 
//     //memoryIO
//     wire [31:0] addr_out;
//     wire [31:0] readData; //from memory m_rdata
//     wire [15:0] io_rdata ;
//     wire [31:0] write_data;
//     wire  LEDCtrl ;
//     wire  SwitchCtrl;
//     wire  SegmentCtrl;
//     wire  keyboardCtrl;



// //Ledctrl和SegmentCtrl相同
// //switchCtrl和KeyboardCtrl相同
// //如果左数第6个开关拨上去，从键盘传入数据，否则从switch传入数据
// //keyboard只在场景3中使用，左边3个拨码开关输入样例编号
// //从键盘传入数据，用拨码开关做确认

//     MemOrIO memoryIO(
//     .mRead(MemRead),
//     .mWrite(MemWrite),
//     .ioRead(IORead),
//     .ioWrite(IOWrite),
//     .addr_in(ALU_result),
//     .addr_out(addr_out),
//     .m_rdata(readData),
//     .io_rdata(io_rdata),
//     .r_wdata(mem_data),
//     .r_rdata(read_data_2),
//     .write_data(write_data),
//     .LEDCtrl(LEDCtrl),
//     .SwitchCtrl(SwitchCtrl),
//     .SegmentCtrl(SegmentCtrl),
//     .keyboardCtrl(keyboardCtrl));

//     // UART Programmer Pinouts
//     wire upg_clk_o;
//     wire upg_wen_o; //Uart write out enable
    
//     //which memory unit of program_rom/dmemory32
//     wire [14:0] upg_adr_o;

//     //data to program_rom or dmemory32
//     wire [31:0] upg_dat_o;
//     wire upg_done_o; //Uart rx data have done
    

//     wire spg_bufg;

//     //对输入的信号进行一个稳定和加强
//     BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter
//     // Generate UART Programmer reset signal
//     reg upg_rst;
//     always @ (posedge fpga_clk) begin
//     if (spg_bufg) upg_rst = 0;
//     if (fpga_rst) upg_rst = 1;
//     end


//     //uart ip core
//     uart_bmpg_0 uart_bmpg_v1_3(
//                   .upg_clk_i(upg_clk),
//                   .upg_rst_i(upg_rst),
//                   .upg_rx_i(upg_rx),
//                   .upg_clk_o(upg_clk_o),
//                   .upg_wen_o(upg_wen_o),
//                   .upg_adr_o(upg_adr_o),
//                   .upg_dat_o(upg_dat_o),
//                   .upg_done_o(upg_done_o),
//                   .upg_tx_o(upg_tx));



//     //uart给出来dmemory

//     dmemory32 dmemory32_v1_0(
//                .ram_clk_i(cpu_clk),
//                .ram_wen_i(MemWrite),
//                .ram_adr_i(addr_out[15:2]),
//                .ram_dat_i(write_data),
//                .ram_dat_o(read_data),
//                .upg_rst_i(upg_rst),
//                .upg_clk_i(upg_clk_o),
//                .upg_wen_i(upg_wen_o & (upg_adr_o[14])?1'b1:1'b0),
//                .upg_adr_i(upg_adr_o[13:0]),
//                .upg_dat_i(upg_dat_o),
//                .upg_done_i(upg_done_o));

//     wire Instruction_o;
//     wire[13:0] rom_adr_o;

//     prorom prorom_v1_0(
//         .rom_clk_i(cpu_clk),
//         .rom_adr_i(rom_adr_o),
//         .upg_rst_i(upg_rst),
//         .upg_clk_i(upg_clk_o),
//         .upg_wen_i((upg_wen_o & (~upg_adr_o[14])) ? 1'b1:1'b0),
//         .upg_adr_i(upg_adr_o[13:0]),
//         .upg_dat_i(upg_dat_o),
//         .upg_done_i(upg_done_o),
//         .Instruction_o(Instruction_i)//out
//     );

//     Ifetc32 Ifetc32_v1_0(
//         .Instruction_i(Instruction_i),
//         .Instruction_o(Instruction),
//         .branch_base_addr(PC_plus_4),
//         .Addr_result(Addr_Result),
//         .Read_data_1(read_data_1),
//         .Branch(Branch),
//         .nBranch(nBranch),
//         .Jmp(Jmp),
//         .Jal(Jal),
//         .Jr(Jr),
//         .Zero(Zero),
//         .clock(clock),
//         .reset(rst),
//         .link_addr(opcplus4),
//         .rom_adr_o(rom_adr_o)
//     );


// wire [31:0] Segment_num;
// wire [15:0] keyboard_read_data;

// Segment LightSeg (.num(Segment_num),.DIG(DIG),.Y(Y),.clk(clock),.rst_n(rst),.SegmentCtrl(SegmentCtrl));

// //从keyboard传出data keyboard_read_data为keyboard传入的值
// //用最左边的灯表示输入超出限度，暂时还没开
// // keyboard keyboardu (.keyboard_or_switch(keyboard_or_switch),.clk(clock),.rst(rst),.row(row),.col(col),.data(keyboard_read_data));
// // keyboard keyboardu (.clk(clk),.rst(rst),.row(row),.col(col),.data(keyboard_read_data),.light_out(led[23]));
// keyboard keyboardu (.clk(clock),.rst(rst),.row(row),.col(col),.data(keyboard_read_data),.backplace(backplace));

// IO io(
//     .SwitchCtrl(SwitchCtrl),
//     .LedCtrl(LEDCtrl),
//     .SegmentCtrl(SegmentCtrl),
//     .keyboardCtrl(keyboardCtrl),
//     .clk(clock),
//     .rst(rst),
//     .IORead(IORead),
//     .IOWrite(IOWrite),
//     .addr(addr_out[1:0]),

//     .switch(switch),
//     .Led_data(write_data[15:0]),
//     .keyboard_read_data(keyboard_read_data),
//     .SegmentData(write_data[7:0]),

//     .io_data(io_rdata),//本来为Switch_data(io_rdata)
//     .led(led[23:0]),
//     .Segment_num(Segment_num));

// // IO dataio(
// //     .SwitchCtrl(SwitchCtrl),
// //     .LedCtrl(LedCtrl),
// //     .SegmentCtrl(SegmentCtrl),
// //     .clk(clock),
// //     .rst(rst),
// //     .IORead(IORead),
// //     .IOWrite(IOWrite),
// //     .addr(addr_out[1:0]),
// //     .switch(switch),
// //     .Switch_data(io_rdata),
// //     .Led_data(write_data[15:0]),
// //     .led(led),
// //     .Segment_num(Segment_num));

// endmodule
`timescale 1ns / 1ps

module top(clk,rst,led,switch,DIG,Y,row,col,backplace);
input           clk;
input           rst;
input [23:0]    switch;    
output[23:0]    led;
output[7:0]     DIG;//八位使能信号
output[7:0]     Y;//点亮数码管  
input  [3:0] row;
output [3:0] col;
input backplace;


wire [31:0] Instruction;

//contorller
    wire[5:0]   Opcode = Instruction[31:26];            // 来自IFetch模块的指令高6bit, instruction[31..26]
    wire[5:0]   Function_opcode = Instruction[5:0];  	// 来自IFetch模块的指令低6bit, 用于区分r-类型中的指令, instructions[5..0]
    wire       Jr;         	 // 为1表明当前指令是jr, 为0表示当前指令不是jr
    wire       RegDST;       // 为1表明目的寄存器是rd, 否则目的寄存器是rt
    wire       ALUSrc;       // 为1表明第二个操作数（ALU中的Bwire）是立即数（beq, bne除外）, 为0时表示第二个操作数来自寄存器
    wire       RegWrite;   	  // 为1表明该指令需要写寄存器
    wire       MemWrite;       // 为1表明该指令需要写存储器
    wire       Branch;        // 为1表明是beq指令, 为0时表示不是beq指令
    wire       nBranch;       // 为1表明是Bne指令, 为0时表示不是bne指令
    wire       Jmp;            // 为1表明是J指令, 为0时表示不是J指令
    wire       Jal;            // 为1表明是Jal指令, 为0时表示不是Jal指令
    wire       I_format;      // 为1表明该指令是除beq, bne, LW, SW之外的其他I-类型指令
    wire       Sftmd;         // 为1表明是移位指令, 为0表明不是移位指令
    wire[1:0]  ALUOp;        // 是R-类型或I_format=1时位1（高bit位）为1,  beq、bne指令则位0（低bit位）为1

    wire[31:0]  ALU_result;   				// 从执行单元来的运算的结果
    // wire[21:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    wire MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the reg
    wire MemRead; // 1 indicates that the instruction needs to read from the memor
    wire IORead; // 1 indicates I/O read
    wire IOWrite; // 1 indicates I/O write

//括号中的为本模块变量！！！！！！！！
control32 contorller(.Opcode(Opcode),.Function_opcode(Function_opcode),.Jr(Jr),.RegDST(RegDST),.ALUSrc(ALUSrc),.RegWrite(RegWrite),.MemWrite(MemWrite),.Branch(Branch),.nBranch(nBranch)
                    ,.Jmp(Jmp),.Jal(Jal),.I_format(I_format),.Sftmd(Sftmd),.ALUOp(ALUOp),.Alu_resultHigh(ALU_result[31:10]),.MemorIOtoReg(MemorIOtoReg),.MemRead(MemRead)
                    ,.IORead(IORead),.IOWrite(IOWrite));



//decoder
    wire[31:0] read_data_1;               // 输出的第一操作数
    wire[31:0] read_data_2;               // 输出的第二操作数
    wire[31:0] mem_data;   			  //从DATA RAM or I/O port取出的数据

    wire[31:0] Sign_extend;               // 扩展后的32位立即数
    wire[31:0] opcplus4;                 // 来自取指单元，JAL中用
    wire clock;

decode32 decoder(.read_data_1(read_data_1),.read_data_2(read_data_2),.Instruction(Instruction),.mem_data(mem_data),.ALU_result(ALU_result),.Jal(Jal),.RegWrite(RegWrite)
                ,.MemtoReg(MemorIOtoReg),.RegDst(RegDST),.Sign_extend(Sign_extend),.clock(clock),.reset(rst),.opcplus4(opcplus4));




//clock
cpuclk cpuclk(.clk_in1(clk),.clk_out1(clock));



//ALU
wire Zero;
wire [31:0] PC_plus_4; 
wire [31:0] Addr_Result;
wire [4:0]  Shamt = Instruction[10:6];


executs32 ALU(.Read_data_1(read_data_1),.Read_data_2(read_data_2),.Sign_extend(Sign_extend),.Function_opcode(Function_opcode),.Exe_opcode(Opcode),
            .ALUOp(ALUOp),.Shamt(Shamt),.Sftmd(Sftmd),.ALUSrc(ALUSrc),.I_format(I_format),.Jr(Jr),.Zero(Zero),.ALU_Result(ALU_result),.Addr_Result(Addr_Result),
            .PC_plus_4(PC_plus_4));


Ifetc32 ifetc(.Instruction(Instruction),.branch_base_addr(PC_plus_4),.Addr_result(Addr_Result),.Read_data_1(read_data_1),.Branch(Branch),.nBranch(nBranch),.Jmp(Jmp),
            .Jal(Jal),.Jr(Jr),.Zero(Zero),.clock(clock),.reset(rst),.link_addr(opcplus4));


//memoryIO
wire [31:0] addr_out;
wire [31:0] readData; //from memory m_rdata
wire [31:0] write_data;
wire  LEDCtrl ;
wire  SwitchCtrl;
wire  SegmentCtrl;
wire  keyboardCtrl;

//Ledctrl和SegmentCtrl相同
//switchCtrl和KeyboardCtrl相同
//如果左数第6个开关拨上去，从键盘传入数据，否则从switch传入数据
//keyboard只在场景3中使用，左边3个拨码开关输入样例编号
//从键盘传入数据，用拨码开关做确认
// wire keyboard_or_switch ;
// assign keyboard_or_switch = switch [18];
// wire [15:0]switch_data;
// wire [15:0]keyboard_data;
// wire [15:0]input_data;
// assign input_data = (keyboard_or_switch == 1'b1 && IORead == 1'b1)? keyboard_data : switch_data;
wire [15:0]io_data;



MemOrIO memoryIO(
    .mRead(MemRead),
    .mWrite(MemWrite),
    .ioRead(IORead),
    .ioWrite(IOWrite),
    .addr_in(ALU_result),
    .addr_out(addr_out),
    .m_rdata(readData),
    .io_rdata(io_data),
    .r_wdata(mem_data),
    .r_rdata(read_data_2),
    .write_data(write_data),
    .LEDCtrl(LEDCtrl),
    .SwitchCtrl(SwitchCtrl),
    .SegmentCtrl(SegmentCtrl),
    .keyboardCtrl(keyboardCtrl));


dmemory32 dememory(.clock(clock),.memWrite(MemWrite),.address(addr_out),.writeData(write_data),.readData(readData));

wire [31:0] Segment_num;
wire [15:0] keyboard_read_data;


// IO io(
//     .SwitchCtrl(SwitchCtrl),
//     .LedCtrl(LEDCtrl),
//     .SegmentCtrl(SegmentCtrl),
//     .keyboardCtrl(keyboardCtrl),
//     .clk(clock),
//     .rst(rst),
//     .IORead(IORead),
//     .IOWrite(IOWrite),
//     .addr(addr_out[1:0]),

//     .switch(switch),
//     .Led_data(write_data[15:0]),
//     .keyboard_read_data(keyboard_read_data),

//     .io_data(io_data),//本来为Switch_data(io_rdata)
//     .led(led[23:0]),
//     .Segment_num(Segment_num),
//     // .keyboard_data(keyboard_data),
//     .keyboard_or_switch(keyboard_or_switch));


IO io(
    .SwitchCtrl(SwitchCtrl),
    .LedCtrl(LEDCtrl),
    .SegmentCtrl(SegmentCtrl),
    .keyboardCtrl(keyboardCtrl),
    .clk(clock),
    .rst(rst),
    .IORead(IORead),
    .IOWrite(IOWrite),
    .addr(addr_out[1:0]),

    .switch(switch),
    .Led_data(write_data[15:0]),
    .keyboard_read_data(keyboard_read_data),
    .SegmentData(write_data[7:0]),

    .io_data(io_data),//本来为Switch_data(io_rdata)
    .led(led[23:0]),
    .Segment_num(Segment_num));



Segment LightSeg (.num(Segment_num),.DIG(DIG),.Y(Y),.clk(clock),.rst_n(rst),.SegmentCtrl(SegmentCtrl));

//从keyboard传出data keyboard_read_data为keyboard传入的值
//用最左边的灯表示输入超出限度，暂时还没开
// keyboard keyboardu (.keyboard_or_switch(keyboard_or_switch),.clk(clock),.rst(rst),.row(row),.col(col),.data(keyboard_read_data));
// keyboard keyboardu (.clk(clk),.rst(rst),.row(row),.col(col),.data(keyboard_read_data),.light_out(led[23]));
keyboard keyboardu (.clk(clock),.rst(rst),.row(row),.col(col),.data(keyboard_read_data),.backplace(backplace));

endmodule