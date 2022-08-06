`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2022 17:24:20
// Design Name: 
// Module Name: uart_top_wrap
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


module uart_top_wrap(
(* mark_debug = "true"*)input                   RSTn,

    // control & status signals
(* mark_debug = "true"*)output  [1:0]           LED,

(* mark_debug = "true"*)input   UART_RXD,
(* mark_debug = "true"*)output  UART_TXD
    );

wire sys_clk;
wire sys_rst_n;
STARTUPE2 STARTUPE2_inst (
.CFGMCLK(sys_clk),     // 1-bit output: Configuration internal oscillator clock output 65MHz.
.EOS(sys_rst_n)            // 1-bit output: Active high output signal indicating the End Of Startup.
);

localparam FLASH_COUNT=31'd50_000_000;
reg         fled;
reg  [31:0] hx_cnt0;
reg         fhx = 0;
// LED测试
assign LED[0] = fhx;
assign LED[1] = fled;

always @(*) begin
    if (~RSTn) begin
        fled <= 0;
    end else begin
        fled <= 1;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        hx_cnt0 <= 0;
    end else begin
        if (hx_cnt0 < FLASH_COUNT)
            hx_cnt0 <= hx_cnt0 + 1'b1;
        else
            hx_cnt0 <= 0;
    end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        fhx <= 1'b0;
    end else begin
        if(hx_cnt0==FLASH_COUNT)
            fhx <= ~fhx;
    end
end



parameter CLK_FREQ = 65_000_000;
parameter UART_BPS = 9600;
parameter BPS_CNT = CLK_FREQ/UART_BPS;

uart_loopback_top #(
    .CLK_FREQ   (CLK_FREQ),
    .UART_BPS   (UART_BPS)
    )
u_loop (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .UART_RXD       (UART_RXD),
    .UART_TXD       (UART_TXD)
    );
endmodule
