module pc_gen(
    reset,                    // 复位信号
    clk,                      // 时钟信号
    Read_data_1,              // jr指令使用的指令地址, PC=reg[rs]
    hazard_pcStall,           // 是否停顿
    hazard_pcFromTaken,       // 是否跳转
    id_ex_Jr,                 // 是否为 Jr 指令
    pre_pc,                   // 前一条指令的 PC 地址
    pc_o                      // 当前指令的 PC 地址
);

input         reset;                 // 复位信号
input         clk;                   // 时钟信号
input [31:0]  Read_data_1;           // jr指令使用的指令地址, PC=reg[rs]
input         hazard_pcStall;        // 是否停顿
input         hazard_pcFromTaken;    // 是否跳转
input         id_ex_Jr;              // 是否为 Jr 指令
input [31:0]  pre_pc;                // 预测的指令的 PC 地址

output [31:0] pc_o;                  // 输出的指令的 PC 地址

reg [31:0] pc;                       // 下一条指令的 PC 地址

wire [31:0] next_pc = pc + 32'h4;  // 计算下一条指令的 PC 地址

always @(posedge clk or posedge reset) begin
    if (reset) begin 
      pc <= 32'h0;                 // 复位时将 PC 置为 0
    end else if (!(hazard_pcStall)) begin 
      if (hazard_pcFromTaken) begin 
        // predict fail!
        if (id_ex_Jr==1) begin 
          // Jr type
          pc <= Read_data_1 << 2;        // 跳转时将 PC 跳到分支目标地址
        end else begin
          // normal pc+4
          // this happens when beq and bne fails
          pc <= next_pc;           // 非跳转指令时将 PC 加上 4
        end
      end else begin
        pc <= pre_pc;              // 没有跳转时将 PC 设置为上一条指令的地址
      end
    end
  end

assign pc_o = pc;                   // 将当前指令的 PC 地址赋值给输出端口

endmodule