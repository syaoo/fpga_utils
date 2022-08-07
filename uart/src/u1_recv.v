`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2022 13:50:00
// Design Name: 
// Module Name: uart_recv
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


module uart_recv(
    input               sys_clk,
    input               sys_rst_n,
    input               uart_rxd,
    output reg [7:0]    uart_data,
    output reg          uart_done
    );

parameter CLK_FREQ = 65000000;
parameter UART_BPS = 115200;
localparam BPS_CNT = CLK_FREQ/UART_BPS;

reg [7:0]   rx_data;
reg [7:0]   rx_cnt;
reg [15:0]  clk_cnt;
reg         rx_flag;
reg         uart_rxd_d0;
reg         uart_rxd_d1;

wire        start_flag;

assign start_flag = (~uart_rxd_d0)&uart_rxd_d1;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        uart_rxd_d0<=1'b0;
        uart_rxd_d1<=1'b0;
    end else begin
        uart_rxd_d0 <= uart_rxd;
        uart_rxd_d1 <= uart_rxd_d0;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        rx_flag<=1'b0;
    end else begin
        if(start_flag)
            rx_flag <= 1'b1;
        else if ((rx_cnt==9) && (clk_cnt==BPS_CNT/2))
            rx_flag <= 1'b0;
        else
            rx_flag <= rx_flag;
     end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        clk_cnt <= 16'd0;
    end else if (rx_flag) begin
        if (clk_cnt<BPS_CNT-1)
            clk_cnt <= clk_cnt+1'b1;
        else
            clk_cnt<=16'd0;
    end
    else 
        clk_cnt <= 16'd0;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        rx_cnt <= 4'd0;
    end else begin
        if (rx_flag) begin
            if (clk_cnt==BPS_CNT-1)
                rx_cnt <= rx_cnt + 1'b1;
            else 
                rx_cnt <= rx_cnt;
        end else
            rx_cnt <= 4'd0;

    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        rx_data <= 8'd0;
    end else if (rx_flag)
        if (clk_cnt==BPS_CNT/2) begin
            case(rx_cnt)
                4'd1:   rx_data[0] <= uart_rxd_d1; 
                4'd2:   rx_data[1] <= uart_rxd_d1; 
                4'd3:   rx_data[2] <= uart_rxd_d1; 
                4'd4:   rx_data[3] <= uart_rxd_d1; 
                4'd5:   rx_data[4] <= uart_rxd_d1; 
                4'd6:   rx_data[5] <= uart_rxd_d1; 
                4'd7:   rx_data[6] <= uart_rxd_d1; 
                4'd8:   rx_data[7] <= uart_rxd_d1; 
                default: ;
            endcase
        end else
            rx_data <= rx_data;
    else
        rx_data <= 8'd0;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end else if (rx_cnt==9) begin
        uart_data <= rx_data;
        uart_done <= 1'b1;
    end else begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end
end
endmodule
