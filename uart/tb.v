`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2022 11:11:39
// Design Name: 
// Module Name: tb
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

`define SIM 12

module tb;

    reg     clk;
    reg     rst_n;
    
    wire    UART_TXD;
    reg     UART_RXD;
        
    localparam CLK_PERIOD = 10;
    
    initial begin
        clk <= 1;
        rst_n <= 0;
        repeat(10) @(posedge clk) 
        rst_n <= 1;
        
    end
    reg [7:0] dat[13:0];
    initial begin
        dat[0]  = 8'h48; // H
        dat[1]  = 8'h65; // e
        dat[2]  = 8'h6c; // l
        dat[3]  = 8'h6c; // l
        dat[4]  = 8'h6f; // o
        dat[5]  = 8'h20; //  
        dat[6]  = 8'h57; // W
        dat[7]  = 8'h6f; // o
        dat[8]  = 8'h72; // r
        dat[9]  = 8'h6c; // l
        dat[10] = 8'h64; // d
        dat[11] = 8'h21; // !
        dat[12] = "\n"; //  \n
    end
    // `define SIM 1
    always #(CLK_PERIOD/2) clk = ~clk;
    

    reg [7:0] tx_data;
    reg [31:0] count;
    reg        tx_en;
    wire       tx_busy;
    reg  [3:0] dd;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data <= 0;
            count <= 0;
            tx_en <= 0;
            dd<=0;
        end else begin
            
                if (count<14 && ~tx_busy) begin
                    tx_data <= dat[count];
                    count <= count+1'b1;
                    tx_en <= 1;
                end else begin
                if (dd==4'b0011) begin
                    tx_en = 0;
                    dd <= 0;
                end else begin
                dd <= dd+1'b1;

                end
                end
            
        end
    end

    uart_send  #(
        .CLK_FREQ  (16),
        .UART_BPS  (1)
        )u_send(
    .sys_clk        (clk),
    .sys_rst_n      (rst_n),
    .uart_en        (tx_en),
    .uart_din       (tx_data),
    .uart_txd       (UART_TXD),
    .uart_tx_busy   (tx_busy)
    );


endmodule
