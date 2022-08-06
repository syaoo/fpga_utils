`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2022 10:55:51
// Design Name: 
// Module Name: baud_gen
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


module baud_gen
#(
    parameter   BPS  = 434      // 波特率因子=时钟频率/波特率  传输一位所需要的时钟周期
)(

    input               clk,
    input               rst_n,

	input				baud_en,        // 使能
    output              baud_pulse      // 采样脉冲
);

    reg     [15:0]      cnt;            // 计数器  
    reg                 baud_pulse_r;   // 采样脉冲
	wire 				rst_flag;       // 计数器复位标志
	wire                sample_flag;    // 计数器采样标志
    
	assign rst_flag = (cnt==(BPS-1));
	// 这里以cnt计到7时, 也就是每8个clk输出一个采样脉冲,因此注意prescale不要小于8
	assign sample_flag =(cnt==BPS/2);     // 中间时刻信号相对稳定，此时采样避免出现采样错误
    assign baud_pulse = baud_pulse_r;
 
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            cnt <=0;
        else if(rst_flag)
            cnt <=0;
        else if(baud_en)
            cnt <=cnt + 1;
        else
            cnt <=0;
    end

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) 
            baud_pulse_r <=0;
        else 
            baud_pulse_r <=sample_flag;
    end

endmodule
