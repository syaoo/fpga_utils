`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2022 10:29:43
// Design Name: 
// Module Name: debounce0
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


module debounce0 #(
    parameter  DIV_TIMES = 100
    )(
    input           rst_n,
    input           pb_1,
    input           clk,
    output          pb_out
    );
wire slow_clk_en;
wire Q1,Q2,Q2_bar,Q0;

fre_div #(DIV_TIMES) u1(clk,slow_clk_en);

my_dff_en d0(rst_n,clk,slow_clk_en,pb_1,Q0);
my_dff_en d1(rst_n,clk,slow_clk_en,Q0,Q1);
my_dff_en d2(rst_n,clk,slow_clk_en,Q1,Q2);
assign pb_out = Q1 & ~Q2;
endmodule
// Slow clock enable for debouncing button 
module fre_div #(
    parameter  DIV_TIMES = 100              // 分频倍数，newP=oldP*DIV_TIMES

    )(
    input           iclk,
    output          oclk
    );
    reg [26:0]      counter=0;
    reg             rclk = 0;
    assign oclk = rclk;
    always @(posedge iclk) begin

            if (counter<DIV_TIMES-1)
                counter <= counter+1;
            else
                counter <= 0;
    end
    always @(posedge iclk) begin

            if (counter==DIV_TIMES-1)
                rclk <= ~rclk;
    end
endmodule
// D-flip-flop with clock enable signal for debouncing module 
module my_dff_en(
    input       rst_n,
    input       clk,
    input       slow_clk_en,
    input       D, 
    output reg  Q
);
    always @ (posedge clk or negedge rst_n) begin 
    if (~rst_n) Q<=D;
    else
        if (slow_clk_en)Q <= D;
    end
    
endmodule 

