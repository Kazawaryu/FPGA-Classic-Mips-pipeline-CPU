`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/23 04:17:22
// Design Name: 
// Module Name: debounce
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


module debounce(
    input wire clk, nrst,
    input wire key_in,
    output reg key_out
    );

	//localparam TIME_20MS = 1_000_000;
    localparam TIME_20MS = 2_000_000_000; // just for test

    reg key_cnt;
    reg [30:0] cnt;

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            key_cnt <= 0;
        else if(key_cnt == 0 && key_out != key_in)
            key_cnt <= 1;
        else if(cnt == TIME_20MS - 1)
            key_cnt <= 0;
    end

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            cnt <= 0;
        else if(key_cnt)
            cnt <= cnt + 1'b1;
        else
            cnt <= 0;
    end

    always @(posedge clk or negedge nrst) begin
        if(nrst == 0)
            key_out <= 0;
        //一开始，就直接将key_in赋值给key_out，也即方案3中说的：
        //只要一发生变化，就立即将输入赋给输出，然后保持20ms后输出。
        else if(key_cnt == 0 && key_out != key_in)
            key_out <= key_in;
    end
endmodule
