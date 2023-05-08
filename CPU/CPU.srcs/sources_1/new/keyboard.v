`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/02 11:01:06
// Design Name: 
// Module Name: key_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//也许可能可以实现一个退格键，应该对其它模块没有什么影响的吧
module keyboard(clk,rst,row,col,data,backplace);
  input           clk;
  input           rst;
  input      [3:0] row;                // 矩阵键盘 行
  output reg [3:0] col;                // 矩阵键盘 列
  output reg [15:0]data;
  input backplace;               //退格键（消抖前）


reg [2:0]realbackplace;        //退格键（消抖后）
 

//消抖
wire down;
wire downed;	//消抖后
assign down = row != 4'hF ? 1'b1 : 1'b0;

//消抖例化
debounce  u(
	.clk		(clk),						//时钟
	.nrst		(rst),						//复位
	
	.key_in		(down),						//按键输入
	.key_out(downed)					//按键真的被按下，并且释放了
);

//++++++++++++++++++++++++++++++++++++++
// 分频部分 开始
//++++++++++++++++++++++++++++++++++++++
reg [19:0] cnt;                         // 计数子
wire key_clk;
 
always @ (posedge clk or posedge rst)
  if (rst)
    cnt <= 0;
  else
    cnt <= cnt + 1'b1;
    
assign key_clk = cnt[19];                // (2^20/50M = 21)ms 
//--------------------------------------
// 分频部分 结束
//--------------------------------------
 
//++++++++++++++++++++++++++++++++++++++
// 状态机部分 开始
//++++++++++++++++++++++++++++++++++++++
// 状态数较少，独热码编码
parameter NO_KEY_PRESSED = 6'b000_001;  // 没有按键按下  
parameter SCAN_COL0      = 6'b000_010;  // 扫描第0列 
parameter SCAN_COL1      = 6'b000_100;  // 扫描第1列 
parameter SCAN_COL2      = 6'b001_000;  // 扫描第2列 
parameter SCAN_COL3      = 6'b010_000;  // 扫描第3列 
parameter KEY_PRESSED    = 6'b100_000;  // 有按键按下

reg [5:0] current_state, next_state;    // 现态、次态
 
always @ (posedge key_clk or posedge rst)
  if (rst)
    current_state <= NO_KEY_PRESSED;
  else
    current_state <= next_state;


// 根据条件转移状态
always @ (*)
  case (current_state)
    NO_KEY_PRESSED :                    // 没有按键按下
        if (down)
          next_state = SCAN_COL0;
        else
          next_state = NO_KEY_PRESSED;
    SCAN_COL0 :                         // 扫描第0列 
        if (down)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL1;
    SCAN_COL1 :                         // 扫描第1列 
        if (down)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL2;    
    SCAN_COL2 :                         // 扫描第2列
        if (down)
          next_state = KEY_PRESSED;
        else
          next_state = SCAN_COL3;
    SCAN_COL3 :                         // 扫描第3列
        if (down)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;
    KEY_PRESSED :                       // 有按键按下
        if (downed)
          next_state = KEY_PRESSED;
        else
          next_state = NO_KEY_PRESSED;                      
  endcase
 
reg       key_pressed_flag;             // 键盘按下标志
reg [3:0] col_val, row_val;             // 列值、行值

 
// 根据次态，给相应寄存器赋值
always @ (posedge key_clk or posedge rst)
  if (rst)
  begin
    col              <= 4'h0;
    key_pressed_flag <=    0;
  end
  else
    case (next_state)
      NO_KEY_PRESSED :                  // 没有按键按下
      begin
        col              <= 4'h0;
        key_pressed_flag <=    0;       // 清键盘按下标志
      end
      SCAN_COL0 :                       // 扫描第0列
        col <= 4'b1110;
      SCAN_COL1 :                       // 扫描第1列
        col <= 4'b1101;
      SCAN_COL2 :                       // 扫描第2列
        col <= 4'b1011;
      SCAN_COL3 :                       // 扫描第3列
        col <= 4'b0111;
      KEY_PRESSED :                     // 有按键按下
      begin
        col_val  <= col;        // 锁存列值
        row_val  <= row;        // 锁存行值
        key_pressed_flag <= 1;          // 置键盘按下标志  
      end
    endcase
//--------------------------------------
// 状态机部分 结束
//--------------------------------------
 
 
//++++++++++++++++++++++++++++++++++++++
// 扫描行列值部分 开始
//++++++++++++++++++++++++++++++++++++++
//最多输入16bit 即4个16进制数字 count最大为4
reg [2:0] count;
reg [3:0] keyboard_val;

// wire index;
// assign index = 15 - 4 * (count - 1);


always @ (posedge key_clk or posedge rst)begin
  if (rst) begin
    keyboard_val <= 4'h0;
    data <= 16'b0;
    count <= 3'b0;
    // light <= 1'b0;
  end
  else begin
    if (key_pressed_flag) begin
      case ({col_val, row_val})
        8'b1110_1110 :begin   //1
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h1;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h1;
          end
        end


        8'b1110_1101 : begin  //4
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h4;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h4;
          end
        end


        8'b1110_1011 : begin  //7
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h7;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h7;
          end
        end


        8'b1110_0111 : begin //E
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'hE;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'hE;
          end
        end
         
        8'b1101_1110 : begin  //2
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h2;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h2;
          end
        end


        8'b1101_1101 : begin  //5
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h5;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h5;
          end
        end


        8'b1101_1011 : begin  //8
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h8;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h8;
          end
        end


        8'b1101_0111 : begin  //0
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h0;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h0;
          end
        end
         

        8'b1011_1110 : begin  //3
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h3;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h3;
          end
        end


        8'b1011_1101 : begin  //6
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h6;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h6;
          end
        end


        8'b1011_1011 : begin  //9
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'h9;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'h9;
          end
        end


        8'b1011_0111 : begin  //F
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'hF;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'hF;
          end
        end
         
        8'b0111_1110 : begin  //A
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'hA;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'hA;
          end
        end 


        8'b0111_1101 : begin  //B
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'hB;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'hB;
          end
        end


        8'b0111_1011 : begin  //C
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'hC;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'hC;
          end
        end

        
        8'b0111_0111 : begin   //D
          if(count==3'b101) begin
            keyboard_val <= 4'h0;
            data <= 16'b0;
            count <= 3'b0;
            // light <= 1'b1;
          end
          else begin
          keyboard_val <= 4'hD;
          count = count + 1;
          data [15 - 4 * (count - 1) -: 4] = 4'hD;
          end
        end       
      endcase
    end

    else begin
      if (backplace) begin
        realbackplace = realbackplace + 1;
        if(realbackplace == 3'b100) begin
          if(count > 0) begin
          data [15 - 4 * (count - 1) -: 4] = 4'h0;
          count = count - 1'b1;
          end
        end
      end
    end

  end
end
//--------------------------------------
//  扫描行列值部分 结束
//--------------------------------------  
endmodule