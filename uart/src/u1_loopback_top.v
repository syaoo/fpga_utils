`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2022 14:25:18
// Design Name: 
// Module Name: uart_loopback_top
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


module uart_loopback_top(
    input   sys_clk,
    input   sys_rst_n,

    input   UART_RXD,
    output  UART_TXD
    );


parameter CLK_FREQ = 65_000_000;
parameter UART_BPS = 115200;
parameter BPS_CNT = CLK_FREQ/UART_BPS;

(* mark_debug = "true"*)wire        uart_en;
(* mark_debug = "true"*)wire [7:0]  uart_din;
(* mark_debug = "true"*)wire [7:0]  uart_data;
(* mark_debug = "true"*)wire        uart_done;

(* mark_debug = "true"*)wire        uart_tx_busy;

uart_send #(
    .CLK_FREQ   (CLK_FREQ),
    .UART_BPS   (UART_BPS)
    ) u_send (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .uart_en        (uart_en),
    .uart_din       (uart_din),
    .uart_txd       (UART_TXD),
    .uart_tx_busy   (uart_tx_busy)
    );

uart_recv #(
    .CLK_FREQ   (CLK_FREQ),
    .UART_BPS   (UART_BPS)
    ) u_recv (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .uart_rxd       (UART_RXD),
    .uart_data      (uart_data),
    .uart_done      (uart_done)
    ); 
uart_loop u_loop (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .recv_done      (uart_done),
    .recv_data      (uart_data),
    .tx_busy        (uart_tx_busy),
    .send_en        (uart_en),
    .send_data      (uart_din)
    );
endmodule
