`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2022 10:52:33
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


module debounce #(
    parameter  CLK_FREQ = 65_000_000,           // 时钟频率
    parameter  DELAY_TIME = 20_000_000,         //延迟时间ns
    parameter  DEFAULT_VALUE = 1                // 按键默认值
    )
(
    input           clk,
    input           rst_n,
    input           ikey,
    output reg      okey
    );

localparam CNT = CLK_FREQ/DELAY_TIME;       // 延迟时钟数

reg [$clog2(CNT)-1:0]           count;         // 计数器
reg                             r_key0;

// 将输入延迟一个周期，存储r_key0中
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_key0 <= DEFAULT_VALUE;
    end else begin
        r_key0 <=ikey;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        count <= CNT;
    end else begin
        if (r_key0 != ikey) begin
            // 当输入发生变化时，为count赋初值
            count <= CNT;
        end else begin
            if (count>0)
                // 当输入不变化时，更新计数器
                count <= count-1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        okey <= DEFAULT_VALUE;
    end else begin
        if (count==1'b1) begin
            // 延迟CNT个时钟周期后更新输出值
            // 此处不使用0因为cnt可能会在0值维持较长一段时间
            okey <= ikey;
        end else begin
            okey <= okey;
        end
    end
end

endmodule
