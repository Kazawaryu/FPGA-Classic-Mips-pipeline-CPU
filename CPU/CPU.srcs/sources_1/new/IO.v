`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/19 21:57:40
// Design Name: 
// Module Name: IO
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


module IO(SwitchCtrl,LedCtrl,SegmentCtrl,keyboardCtrl,clk,rst,IORead,IOWrite,addr,switch,
        Led_data,keyboard_read_data,SegmentData,io_data,led,Segment_num);
    input SwitchCtrl;		//  从memorio经过地址高端线获得的拨码开关模块片选
    input LedCtrl;		      	// 从memorio来的LED片选信号   !!!!!!!!!!!!!!!!!
    input SegmentCtrl;
    input keyboardCtrl;
    input clk;
    input rst;			// 复位信号 
    input IORead;              //  从控制器来的I/O读，
    input IOWrite;		       	// 写信号
    input[1:0] addr;

    input [23:0] switch;		    //  从板上读的24位开关数据 
    input[15:0] Led_data;	  	//  写到LED模块的数据，注意数据线只有16根
    input [15:0]keyboard_read_data;

    input [7:0] SegmentData;   //新地址，8bit，用于数码管左数第34位的值!!!!!!!!!

    output reg [15:0] io_data;	    //  送到CPU的拨码开关值注意数据总线只有16根
    output reg [23:0] led;		//  向板子上输出的24位LED信号
    output reg [31:0] Segment_num;

     always@(negedge clk or posedge rst) begin
        if(rst) begin
           io_data <= 0;
        end
		else if(IORead) begin
			if(addr==2'b00)
				io_data[15:0] <= switch[15:0];   // data output,lower 16 bits non-extended
			else if(addr==2'b10)
				io_data[15:0] <= { 8'h00, switch[23:16] }; //data output, upper 8 bits extended with zero
			else if(addr==2'b11) 
                io_data <= keyboard_read_data;
            else io_data = io_data;
        end
		else begin
            io_data <= io_data;
            // io_data <= 0;
        end
    end

     always@(posedge clk or posedge rst) begin
        if(rst) begin
            led <= 0;
        end
		else if(LedCtrl) begin
			if(addr == 2'b00)
				led[23:0] <= { led[23:16], Led_data[15:0] };
			else if(addr == 2'b10 )
				led[23:0] <= { Led_data[7:0], led[15:0] };
			else
				led <= led;
        end
		else begin
            // led <= led;
            led <= 0;
        end
    end

    // always@(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         Segment_num <= 0;
    //     end
	// 	else if(SegmentCtrl) begin
	// 		if(addr == 2'b00)
    //             Segment_num[31:0] <= {8'b0,Segment_num[23:16],Led_data[15:0]};
	// 		else if(addr == 2'b10 )
	// 			Segment_num[31:0] <= {8'b0,Led_data[7:0], Segment_num[15:0] };
	// 		else
	// 			Segment_num <= Segment_num;
    //     end
	// 	else begin
    //         Segment_num <= Segment_num;
    //         // Segment_num <= 0;
    //     end
    // end


    // //数码管和LED同步
    // always@(posedge clk or posedge rst) begin
    //     if(rst) begin
    //         Segment_num <= 0;
    //     end
	// 	else if(SegmentCtrl ) begin
	// 		if(addr == 2'b00)
    //             if(switch[23:21] == 3'b000) Segment_num[31:0] <= {8'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b001) Segment_num[31:0] <= {4'b0001,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b010) Segment_num[31:0] <= {4'b0010,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b011) Segment_num[31:0] <= {4'b0011,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b100) Segment_num[31:0] <= {4'b0100,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b101) Segment_num[31:0] <= {4'b0101,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b110) Segment_num[31:0] <= {4'b0110,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else if (switch[23:21] == 3'b111) Segment_num[31:0] <= {4'b0111,4'b0,Segment_num[23:16],Led_data[15:0]};
    //             else Segment_num[31:0] <= {8'b0,Segment_num[23:16],Led_data[15:0]};
	// 		else if(addr == 2'b10 )
    //             if(switch[23:21] == 3'b000) Segment_num[31:0] <= {8'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b001) Segment_num[31:0] <= {4'b0001,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b010) Segment_num[31:0] <= {4'b0010,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b011) Segment_num[31:0] <= {4'b0011,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b100) Segment_num[31:0] <= {4'b0100,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b101) Segment_num[31:0] <= {4'b0101,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b110) Segment_num[31:0] <= {4'b0110,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else if (switch[23:21] == 3'b111) Segment_num[31:0] <= {4'b0111,4'b0,Led_data[7:0],Segment_num[15:0]};
    //             else Segment_num[31:0] <= {8'b0,Segment_num[23:16],Segment_num[15:0]};
	// 		else
	// 			if(switch[23:21] == 3'b00) Segment_num[31:0] <= {4'b0,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b001) Segment_num[31:0] <= {4'b0001,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b010) Segment_num[31:0] <= {4'b0010,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b011) Segment_num[31:0] <= {4'b0011,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b100) Segment_num[31:0] <= {4'b0100,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b101) Segment_num[31:0] <= {4'b0101,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b110) Segment_num[31:0] <= {4'b0110,Segment_num[23:0]};
    //             else if (switch[23:21] == 3'b111) Segment_num[31:0] <= {4'b0111,Segment_num[23:0]};
    //             else Segment_num[31:0] <= {4'b0,Segment_num[23:0]};
    //     end
	// 	else begin
    //         Segment_num <= Segment_num;
    //         // Segment_num <= 0;
    //     end
    // end

    //数码管和LED同步
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            Segment_num <= 0;
        end
		else if(SegmentCtrl ) begin
			if(addr == 2'b00)
                if(switch[23:21] == 3'b000) Segment_num[31:0] <= {8'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b001) Segment_num[31:0] <= {4'b0001,4'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b010) Segment_num[31:0] <= {4'b0010,4'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b011) Segment_num[31:0] <= {4'b0011,4'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b100) Segment_num[31:0] <= {4'b0100,4'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b101) Segment_num[31:0] <= {4'b0101,4'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b110) Segment_num[31:0] <= {4'b0110,4'b0,Segment_num[23:16],Led_data[15:0]};
                else if (switch[23:21] == 3'b111) Segment_num[31:0] <= {4'b0111,4'b0,Segment_num[23:16],Led_data[15:0]};
                else Segment_num[31:0] <= {8'b0,Segment_num[23:16],Led_data[15:0]};
			else if(addr == 2'b11)
				if(switch[23:21] == 3'b00) Segment_num[31:0] <= {4'b0,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b001) Segment_num[31:0] <= {4'b0001,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b010) Segment_num[31:0] <= {4'b0010,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b011) Segment_num[31:0] <= {4'b0011,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b100) Segment_num[31:0] <= {4'b0100,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b101) Segment_num[31:0] <= {4'b0101,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b110) Segment_num[31:0] <= {4'b0110,SegmentData[7:0],Segment_num[15:0]};
                else if (switch[23:21] == 3'b111) Segment_num[31:0] <= {4'b0111,SegmentData[7:0],Segment_num[15:0]};
                else Segment_num[31:0] <= {4'b0,SegmentData[7:0],Segment_num[23:0]};
        end
		else begin
            Segment_num[31:0] <= Segment_num;
            // Segment_num <= 0;
        end
    end

endmodule
// module IO(SwitchCtrl,LedCtrl,SegmentCtrl,clk,rst,IORead,IOWrite,addr,switch,Switch_data,Led_data,led,Segment_num);
//     input SwitchCtrl;		//  ��memorio������ַ�߶��߻�õĲ��뿪��ģ��Ƭѡ
//     input LedCtrl;		      	// ��memorio����LEDƬѡ�ź�   !!!!!!!!!!!!!!!!!
//     input SegmentCtrl;
//     input clk;
//     input rst;			// ��λ�ź� 
//     input IORead;              //  �ӿ���������I/O����
//     input IOWrite;		       	// д�ź�
//     input[1:0] addr;
//     input [23:0] switch;		    //  �Ӱ��϶���24λ��������
//     output reg [15:0] Switch_data;	    //  �͵�CPU�Ĳ��뿪��ֵע����������ֻ��16��
//     input[15:0] Led_data;	  	//  д��LEDģ������ݣ�ע��������ֻ��16��
//     output reg [23:0] led;		//  ������������24λLED�ź�
//     output reg [31:0] Segment_num;

//     always@(negedge clk or posedge rst) begin
//         if(rst) begin
//            Switch_data <= 0;
//         end
// 		else if(SwitchCtrl && IORead) begin
// 			if(addr==2'b00)
// 				Switch_data[15:0] <= switch[15:0];   // data output,lower 16 bits non-extended
// 			else if(addr==2'b10)
// 				Switch_data[15:0] <= { 8'h00, switch[23:16] }; //data output, upper 8 bits extended with zero
// 			else 
// 				Switch_data <= Switch_data;
//         end
// 		else begin
//             Switch_data <= 0;
//         end
//     end

//      always@(posedge clk or posedge rst) begin
//         if(rst) begin
//             led <= 0;
//         end
// 		else if(LedCtrl && IOWrite) begin
// 			if(addr == 2'b00)
// 				led[23:0] <= { led[23:16], Led_data[15:0] };
// 			else if(addr == 2'b10 )
// 				led[23:0] <= { Led_data[7:0], led[15:0] };
// 			else
// 				led <= led;
//         end
// 		else begin
//             led <= 0;
//         end
//     end

//     always@(posedge clk or posedge rst) begin
//         if(rst) begin
//             Segment_num <= 0;
//         end
// 		else if(SegmentCtrl && IOWrite) begin
// 			if(addr == 2'b00)
// 				Segment_num[31:0]<={8'b0,Segment_num[23:16],Led_data[15:0]};
// 			else if(addr == 2'b10 )
// 				 Segment_num[31:0] <= {8'b0,Led_data[7:0], Segment_num[15:0] };
// 			else
// 				Segment_num <= Segment_num;
//         end
// 		else begin
//             Segment_num <= 0;
//         end
//     end

// endmodule