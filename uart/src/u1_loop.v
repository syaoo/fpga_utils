`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2022 14:16:17
// Design Name: 
// Module Name: uart_loop
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


module uart_loop(
    input           sys_clk,
    input           sys_rst_n,
    
    input           recv_done,
    input [7:0]     recv_data,
    input           tx_busy,

    output reg      send_en,
    output   [7:0]send_data
    );

reg        recv_done_d0;
reg        recv_done_d1;

wire        recv_done_flag;

reg         tx_ready;
wire        empty;

reg         frd;
wire [7:0]   fdo;

fifo #(
    .DEPTH (10),
    .WIDTH (8)
    )u_fifo (
    .rst_n       (sys_rst_n),
    .clk         (sys_clk),
    .DI          (recv_data), 
    .RD          (frd), 
    .WR          (recv_done_flag), 
    .DO          (fdo),
    .EMPTY       (empty),   
    .FULL            (),    
    .aEMPTY      (),  
    .aFULL    ()
    );
assign recv_done_flag = recv_done_d0&(~recv_done_d1);
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        recv_done_d0 <= 1'b0;
        recv_done_d1 <= 1'b0;
    end
    else begin
        recv_done_d0 <= recv_done;
        recv_done_d1 <= recv_done_d0;
    end
end
assign send_data = fdo;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        send_en <= 1'b0;
        frd <= 0;
    end else begin
        if (~empty && ~tx_busy) begin
            frd <= 1'b1;
            send_en <= 1'b1;
        end else begin
            send_en <= 1'b0;
            frd <= 1'b0;
        end
    end
end

endmodule
