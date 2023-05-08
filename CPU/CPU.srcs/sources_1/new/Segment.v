`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/18 21:01:53
// Design Name: 
// Module Name: Segment
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


module Segment(num,DIG,Y,clk,rst_n,SegmentCtrl);
// input [31:0]            number,
input  [31:0]            num;
output [7:0]            DIG;//八位使能信号
output reg[7:0]         Y;//点亮数码管
input                   clk;
input                   rst_n;//从右往左 1号开关 进入Hello界面
input                   SegmentCtrl;



reg clk_out;//1 clk模块 
// parameter period = 4600;//周期扩大到 period 倍 
parameter period = 20000;//周期扩大到 period 倍 

reg [31:0] cnt;//1 clk模块 
reg [3:0]  scan_cnt;//1 clk模块 点亮对应数码管
reg [7:0]  DIG_r;
wire [6:0] dig1;
wire [6:0] dig2;
wire [6:0] dig3;
wire [6:0] dig4;
wire [6:0] dig5;
wire [6:0] dig6;
wire [6:0] dig7;
wire [6:0] dig8;
assign DIG = ~DIG_r;//滚动选中使能信号

seg_trans  seg_trans_name1(.n(num[3:0]),.LightSeg(dig1));
seg_trans  seg_trans_name2(.n(num[7:4]),.LightSeg(dig2));
seg_trans  seg_trans_name3(.n(num[11:8]),.LightSeg(dig3));
seg_trans  seg_trans_name4(.n(num[15:12]),.LightSeg(dig4));
seg_trans  seg_trans_name5(.n(num[19:16]),.LightSeg(dig5));
seg_trans  seg_trans_name6(.n(num[23:20]),.LightSeg(dig6));
seg_trans  seg_trans_name7(.n(num[27:24]),.LightSeg(dig7));
seg_trans  seg_trans_name8(.n(num[31:28]),.LightSeg(dig8));

//分频
always@(posedge clk , posedge rst_n) begin
    if(rst_n) begin
        cnt <= 0;
        clk_out <= 0;
    end
    else if(cnt == ((period>>1)-1)) begin
        clk_out <= ~clk_out;
        cnt <= 0;
    end
    else begin 
        cnt <= cnt+1;
    end
end
// always @(posedge clk or posedge rst_n)      //分频50Hz
// begin 
//     if (rst_n)
//         cnt <= 0 ;
//     else  begin  
//         cnt<= cnt + 1;

//         if (cnt == (period >> 1) - 1)               
//             clk_out <= #1 1'b1;
//         else if (cnt == period - 1)                    
//         begin 
//             clk_out <= #1 1'b0;
//             cnt <= #1 'b0;      
//         end  
//     end
// end 
            
always@(posedge clk_out , posedge rst_n)//敏感于时钟上升沿,随clk_out上升沿让scan_cnt 从0>7>0
    begin
    if(rst_n)//reset信号低电频有效，把scan_cnt初始化为0
        scan_cnt <= 4'd8;
    else
    begin
        scan_cnt <= scan_cnt+1;
        if(scan_cnt == 4'd8) scan_cnt <= 0;
    end 
end



always@(*) begin//结合 assign DIG=~DIG_r 用随时间改变的scan_cnt来使得被选中的使能信号DIG随时间由[0]-[7]切换
    case(scan_cnt)
        4'b0000:
        begin
            Y<={1'b1,(~dig1[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b0000_0001;//[0]
        end
        4'b0001 :
        begin
            Y<={1'b1,(~dig2[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b0000_0010;//[0]
        end
        4'b0010 :
        begin
            Y<={1'b1,(~dig3[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b0000_0100;//[0]
        end
        4'b0011 :
        begin
            Y<={1'b1,(~dig4[6:0])};//亮管信号,小数点保持不亮 
            DIG_r <= 8'b0000_1000;//[0]
        end
        4'b0100 :
        begin
            Y<={1'b1,(~dig5[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b0001_0000;//[0]
        end
        4'b0101 :
        begin
            Y<={1'b1,(~dig6[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b0010_0000;//[0]
        end
        4'b0110 :
        begin
            Y<={1'b1,(~dig7[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b0100_0000;//[0]
        end
        4'b0111 :
        begin
            Y<={1'b1,(~dig8[6:0])};//亮管信号,小数点保持不亮 
            DIG_r<= 8'b1000_0000;//[0]
        end
        default: DIG_r<= 8'b0000_0000;
    endcase
end
endmodule