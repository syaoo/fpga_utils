`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2022 09:50:26
// Design Name: 
// Module Name: sim2
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


module sim2(

    );
    reg     clk;
    reg     rst_n;
    
    wire    UART_TXD;
    reg     UART_RXD;
    
    reg     uart_pulse;

    fpga_top #( 
        .CLK_FREQ           (CLK_FREQ),
        .BAUT_RATE          (BAUT_RATE)    
    )dut(
        .CLK        (clk        ),
        .RSTn       (rst_n      ),
        .LED        (           ),
        .UART_RXD   (UART_RXD),
        .UART_TXD   (UART_TXD)
    );
endmodule
