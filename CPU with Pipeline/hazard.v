module hazard (
  input  [4:0]  rs,                 // 第一个寄存器编号
  input  [4:0]  rt,                 // 第二个寄存器编号
  input         id_ex_jr,           // jump and link 指令
  input         id_ex_Branch,       // 是否是分支指令, beq
  input         id_ex_nBranch,      // 是否是分支指令, bne
  input         ex_Zero,         // 两数比较, 结果是否为0
  input  [1:0]  id_ex_jump,         // 跳转类型
  input         id_ex_memRead,      // 是否从内存读取数据，decode里的MemToReg
  input         id_ex_memWrite,     // 是否向内存写入数据
  input  [4:0]  id_ex_rd,           // 要写入的寄存器编号
  input         ex_mem_memWrite,    // 是否向内存写入数据

  output reg    pcFromTaken,  //分支指令执行结果，判断是否与预测方向一样
  output reg    pcStall,    //程序计数器停止信号
  output reg    IF_ID_stall,  //流水线IF_ID段停止信号
  output reg    ID_EX_stall,  //流水线ID_EX段停止信号
  output reg    ID_EX_flush,  //流水线ID_EX段清零信号
  output reg    EX_MEM_flush,   //流水线EX_MEM段清零信号
  output reg    IF_ID_flush    //流水线IF_ID段清零信号
);

  // 条件分支指令的条件比较结果，beq时候结果不是0，bne时候结果是0，分支预测失败
  wire branch_do = ((id_ex_Branch == 1) && (id_ex_Zero == 0)) || ((id_ex_nBranch == 1) && (id_ex_Zero == 1));   // 计算分支指令是否成立
  // 确认分支指令跳转的信号,这两种情况下分支预测失败
  wire ex_mem_taken = id_ex_jr || branch_do;   // 判断是否需要跳转

  // 存储器的选通信号，当对存储器的“读”或者“写”控制信号有效时产生
  wire id_ex_memAccess = id_ex_memRead | id_ex_memWrite;   // 判断是否需要访问内存

  // 表示流水线需要停顿，当执行 sw 指令时就会出现这样的情况
  wire ex_mem_need_stall = ex_mem_memWrite;   // 判断是否需要停顿

  always @(*) begin
    /*
    解决数据相关性问题
    指令之间存在的依赖关系。当两条指令之间存在相关关系时，它们就不能在流水线中重叠执行
    z.B. 前一条指令是访存指令 Store，后一条也是 Load 或者 Store 指令，
    因为我们采用的是同步 RAM，需要先读出再写入，占用两个时钟周期，
    所以这时要把之后的指令停一个时钟周期。
    */
    if(id_ex_memAccess && ex_mem_need_stall) begin   // 如果需要访问内存且需要停顿
      pcFromTaken  <= 0;            // 不跳转
      pcStall      <= 1;            // 停顿
      IF_ID_stall  <= 1;            // IF/ID 停顿
      IF_ID_flush  <= 0;            // 不清空 IF/ID
      ID_EX_stall  <= 1;            // ID/EX 停顿
      ID_EX_flush  <= 0;            // 不清空 ID/EX
      EX_MEM_flush <= 1;            // 清空 EX/MEM
    end
    /* 
    分支预测失败的问题
    当分支指令执行之后，如果发现分支跳转的方向与预测方向不一致。
    这时就需要冲刷流水线，清除处于取指、译码阶段的指令数据，更新 PC 值。
    */
    // branch prediction fail or jr appears
    else if(ex_mem_taken) begin      // 如果需要跳转
      pcFromTaken  <= 1;            // 跳转
      pcStall      <= 0;            // 不停顿
      IF_ID_flush  <= 1;            // 清空 IF/ID
      ID_EX_flush  <= 1;            // 清空 ID/EX
      EX_MEM_flush <= 0;            // 不清空 EX/MEM
    end
    /* 
    数据冒险问题。
    当前一条指令是 Load，后一条指令的源寄存器 rs 和 rt 依赖于前一条从存储器中读出来的值，
    需要把 Load 指令之后的指令停顿一个时钟周期，而且还要冲刷 ID _EX 阶段的指令数据。
    */
    else if(id_ex_memRead & (id_ex_rd == rs || id_ex_rd == rt)) begin   // 如果需要访问内存且需要停顿
      pcFromTaken <= 0;             // 不跳转
      pcStall     <= 1;             // 停顿
      IF_ID_stall <= 1;             // IF/ID 停顿
      ID_EX_flush <= 1;             // 清空 ID/EX
    end
    /* 
    吼吼，一切正常。Respect！
    */
    else begin                      // 如果不需要停顿也不需要跳转
      pcFromTaken    <= 0;          // 不跳转
      pcStall        <= 0;          // 不停顿
      IF_ID_stall    <= 0;          // 不停顿 IF/ID
      ID_EX_stall    <= 0;          // 不停顿 ID/EX
      ID_EX_flush    <= 0;          // 不清空 ID/EX
      EX_MEM_flush   <= 0;          // 不清空 EX/MEM 
      IF_ID_flush    <= 0;          // 不清空 IF/ID
    end
  end
  
endmodule