`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2022 15:43:33
// Design Name: 
// Module Name: debounce1
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


module debounce1 #(
    parameter  CLK_FREQ = 65_000_000,           // 时钟频率
    parameter  DELAY_TIME = 20_000_000,         //延迟时间ns
    parameter  DEFAULT_VALUE = 0                // 按键默认值
)
(
    input       clk,
    input       rst_n,
    input       ikey,
    output      okey
    );

localparam CNT = CLK_FREQ/DELAY_TIME;
reg [$clog2(CNT)-1:0]           cnt;
reg                             ovalid;

reg                             r_key0;
reg                             r_key1;
wire                            fcnt;
reg                             dkey;
reg                             r_dkey;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r_key0 <= DEFAULT_VALUE;
        r_key1 <= DEFAULT_VALUE;
    end else begin
        r_key0 <= ikey;
        r_key1 <= r_key0;
    end
end

generate
    if (DEFAULT_VALUE==0) begin
        // 按键默认输入为0时，检测上升沿
        assign fcnt = (~r_key1)&r_key0;
        assign okey = (~r_dkey) & dkey;
        
    end else begin
        // 按键默认输入为1时，检测下降沿
        assign fcnt = r_key1 & (~r_key0);
        assign okey = r_dkey & (~dkey);
    end
endgenerate


always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        cnt<=20'd0;
    else if (fcnt) 
        cnt<=20'd0;
    else
        cnt <= cnt+1'b1;
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 
        dkey <= 1'b0;
    else if (cnt==CNT) 
        // 延迟cnt时钟后更新dkey
        dkey<= ikey;
end 

// 记录dkey用于更新输出
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 
        r_dkey<=1'b0;
    else 
        r_dkey <= dkey;
end
endmodule
