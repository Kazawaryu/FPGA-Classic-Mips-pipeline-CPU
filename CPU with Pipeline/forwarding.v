// 这个module主要是检查是否有数据冒险，如果有的话，就进行数据前递。

module forwarding (
  input [4:0] rs, // the address of rs register
  input [4:0] rt, // the address of rt register
  input [4:0] exMemRd, // 来自访存模块的对通用寄存器的访问地址
  input       exMemRw, // 来自访存模块的对通用寄存器的写使能信号
  input [4:0] memWBRd, // 来自写回模块的对通用寄存器的访问地址
  input       memWBRw, // 来自写回模块的对通用寄存器的写使能信号
  input        mem_wb_ctrl_data_toReg,
  input [31:0] mem_wb_readData,
  input [31:0] mem_wb_data_result,
  // 下面两个分别是不发生数据冒险时使用的信号
  input [31:0] id_ex_data_regRData1, // data from rs register after decoder 
  input [31:0] id_ex_data_regRData2, // data from rt register after decoder
  input [31:0] ex_mem_data_result, // 访存阶段需要写到通用寄存器的数据

  output [31:0] forward_rs_data,
  output [31:0] forward_rt_data
);

  //检查是否发生数据冒险
  wire [1:0] forward_rs_sel = (exMemRw & (rs == exMemRd) & (exMemRd != 5'b0)) ? 2'b01
                              :(memWBRw & (rs == memWBRd) & (memWBRd != 5'b0)) ? 2'b10
                              : 2'b00;
                  
  wire [1:0] forward_rt_sel = (exMemRw & (rt == exMemRd) & (exMemRd != 5'b0)) ? 2'b01
                              :(memWBRw & (rt == memWBRd) & (memWBRd != 5'b0)) ? 2'b10
                              : 2'b00;

  // 回写阶段需要更新到通用寄存器的数据
  wire [31:0] regWData = mem_wb_ctrl_data_toReg ? mem_wb_readData : mem_wb_data_result; 

  //根据数据冒险的类型选择前递的数据
  assign forward_rs_data = (forward_rs_sel == 2'b00) ? id_ex_data_regRData1 :
                            (forward_rs_sel == 2'b01) ? ex_mem_data_result   :
                            (forward_rs_sel == 2'b10) ? regWData : 32'h0; 

  assign forward_rt_data = (forward_rt_sel == 2'b00) ? id_ex_data_regRData2 :
                            (forward_rt_sel == 2'b01) ? ex_mem_data_result   :
                            (forward_rt_sel == 2'b10) ? regWData : 32'h0; 
endmodule