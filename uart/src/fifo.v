`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2022 17:37:23
// Design Name: 
// Module Name: fifo
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



module fifo #(
    parameter       DEPTH = 10,
    parameter       WIDTH = 16
)(   
input               rst_n,
input               clk,
input [WIDTH-1:0]   DI, 
input               RD, 
input               WR, 
// input               EN, 
output  [WIDTH-1:0] DO,
// output  reg [WIDTH-1:0] DO,
output              EMPTY,          // 当剩余元素为0时拉高
output              FULL,           // 当剩余元素为DEPTH个时拉高
output              aEMPTY,         // 当剩余元素小于等于2个时拉高
output              aFULL           // 当剩余元素大于等于DEPTH-1个时拉高
); 
localparam                  ADD_WIDTH = $clog2(DEPTH);
reg  [ADD_WIDTH:0]          Count; 
reg  [WIDTH-1:0]            FIFO [0:DEPTH-1]; 
// (* keep = "true" *) 可以消除 Warning:Unused sequential element readCounter_reg_rep was removed. 同时，综合结果使用cell也少6个88->82
// (* keep = "true" *)reg  [ADD_WIDTH:0]          readCounter;
reg  [ADD_WIDTH:0]          readCounter;
reg  [ADD_WIDTH:0]          writeCounter; 
assign aEMPTY = (Count<=1'b1)? 1'b1:1'b0; 
assign aFULL = (Count<DEPTH-1)? 1'b0:1'b1; 
assign EMPTY = (Count==1'b0)? 1'b1:1'b0;
assign FULL = (Count<DEPTH)? 1'b0:1'b1;
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        writeCounter <= 0; 
    end else begin 
        if (WR==1'b1 && Count<DEPTH-1) begin
           // FIFO[writeCounter] <= DI;
            if (writeCounter==DEPTH-1) begin
                // if(Count<DEPTH-1) writeCounter <= 0;
                writeCounter <= 0;
            end else begin
                writeCounter <= writeCounter+1;
            end
        end else begin
            if (writeCounter==DEPTH-1) writeCounter <= 0;
        end
    end 
end 
always @ (posedge clk) begin
   if (WR && Count<DEPTH && rst_n)FIFO[writeCounter] <= DI;
end
// always @ (posedge clk or negedge rst_n) begin
//     if (~rst_n) begin
//     end else begin
//         if (WR && ~FULL) FIFO[writeCounter] <= DI;
//     end
    
// end
assign DO = (RD&&Count>0)?FIFO[readCounter]:'hz;
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        readCounter <= 0;
    end else begin
        if (RD && Count>0) begin
           // DO <= FIFO[readCounter];
            if (readCounter==DEPTH-1) begin 
                readCounter <= 0;
            end else begin
                readCounter <= readCounter+1;
            end
        end else begin
            if (readCounter==DEPTH-1) readCounter <= 0;
        end
    end
end
// 计数时钟应域读取时钟相同
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        Count <= 0;
    end else begin
        if (WR&&~RD) begin
            if (Count<DEPTH)Count <= Count+1'b1;
        end else if (~WR&&RD) begin
            if(Count>0)Count <= Count-1'b1;
        end else if(WR&&RD)begin
            if (Count==0) Count<=Count+1'b1;
            else Count<=Count;
        end else begin
            Count <= Count;
        end
    end
end
endmodule

