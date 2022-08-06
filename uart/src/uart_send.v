`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2022 13:22:56
// Design Name: 
// Module Name: uart_send
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

module uart_send
(
    input           sys_clk,
    input           sys_rst_n,
    input           uart_en,
    input  [7:0]    uart_din,
    output reg      uart_txd,
    output          uart_tx_busy
    );

parameter CLK_FREQ = 65_000_000;
parameter UART_BPS = 115200;

localparam BPS_CNT = CLK_FREQ/UART_BPS;


reg tx_flag;
reg uart_en_d0;
reg uart_en_d1;
reg [7:0] tx_data;

reg [7:0]  r0_uart_din;
reg [7:0]  r1_uart_din;
wire en_flag;

reg [8:0] clk_cnt;
reg [3:0] tx_cnt;

assign uart_tx_busy = uart_en ||uart_en_d0||tx_flag;

assign en_flag = uart_en_d0&(~uart_en_d1);
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        uart_en_d0 <= 1'b0;
        uart_en_d1 <= 1'b0;
    end
    else begin
        uart_en_d0 <= uart_en;
        uart_en_d1 <= uart_en_d0;
    end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        r0_uart_din <= 8'b0;
        r1_uart_din <= 8'b0;
    end
    else begin
        r0_uart_din <= uart_din;
        r1_uart_din <= r0_uart_din;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        tx_flag <= 1'b0;
        tx_data <= 8'b0;
    end
    else if (en_flag) begin
        tx_flag <= 1'b1;
        tx_data <= r0_uart_din;
    end
    // else if ((tx_cnt==4'd9) && (clk_cnt==BPS_CNT -(BPS_CNT/16)) )begin
    else if ((tx_cnt==4'd9) && (clk_cnt==BPS_CNT -1))begin
        tx_data <= 0;
        tx_flag <= 0;
    end
    else begin
        tx_data <= tx_data;
        tx_flag <= tx_flag;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        tx_cnt <= 0;
    end else if (tx_flag) begin
        if (clk_cnt==BPS_CNT-1) begin
            tx_cnt <= tx_cnt + 1'b1;
        end else begin
            tx_cnt <= tx_cnt;
        end 
    end else begin 
            tx_cnt <= 4'd0;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        clk_cnt <= 9'd0;
    end
    else if (tx_flag) begin
        if (clk_cnt<BPS_CNT-1) begin
            clk_cnt <= clk_cnt+1'b1;
        end else begin
            clk_cnt <= 9'd0;
        end
    end
    else
        clk_cnt <= 9'd0;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        uart_txd <= 1'b1;
    end else if (tx_flag) begin
        case (tx_cnt)
            4'd0:   uart_txd <= 1'b0; 
            4'd1:   uart_txd <= tx_data[0]; 
            4'd2:   uart_txd <= tx_data[1]; 
            4'd3:   uart_txd <= tx_data[2]; 
            4'd4:   uart_txd <= tx_data[3]; 
            4'd5:   uart_txd <= tx_data[4]; 
            4'd6:   uart_txd <= tx_data[5]; 
            4'd7:   uart_txd <= tx_data[6]; 
            4'd8:   uart_txd <= tx_data[7]; 
            4'd9:   uart_txd <= 1'b1;
            default:;
        endcase
    end
    else
        uart_txd <= 1'b1;
end
endmodule
