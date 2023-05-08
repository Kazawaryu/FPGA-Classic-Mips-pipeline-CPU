`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/18 23:59:33
// Design Name: 
// Module Name: seg_trans
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


module seg_trans(
    input[3:0] n,//传入一位16进制数n 0-15
    output reg [6:0] LightSeg//输出使得七段数码管亮起对应内容的信号
    );
    always@*
     begin
      case(n)
        4'd0: LightSeg = 7'b011_1111;
        4'd1: LightSeg = 7'b000_0110;
        4'd2: LightSeg = 7'b101_1011;
        4'd3: LightSeg = 7'b100_1111;
        4'd4: LightSeg = 7'b110_0110;
        4'd5: LightSeg = 7'b110_1101;
        4'd6: LightSeg = 7'b111_1101;
        4'd7: LightSeg = 7'b010_0111;
        4'd8: LightSeg = 7'b111_1111;
        4'd9: LightSeg = 7'b110_1111;
        
        4'd10: LightSeg = 7'b111_0111;
        4'd11: LightSeg = 7'b111_1100;
        4'd12: LightSeg = 7'b011_1001;
        4'd13: LightSeg = 7'b101_1110;
        4'd14: LightSeg = 7'b111_1001;
        4'd15: LightSeg = 7'b111_0001;
        default: LightSeg = 7'b0000000;
      endcase
     end
endmodule
